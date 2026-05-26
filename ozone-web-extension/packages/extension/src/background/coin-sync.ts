// Background coin sync loop driven by chrome.alarms.
//
// On every tick (default every 30 s) we:
//
//   1. Read the active wallet fingerprint from chrome.storage.session.
//   2. If the engine is locked → skip (we need the SK to derive puzzle hashes).
//   3. Ask the engine for the first N derived puzzle hashes (currently 50).
//   4. Find the lowest per-ph sync mark; back it off by REORG_WINDOW so a
//      reorg can't sneak past us, then call scan_puzzle_hashes with that
//      `start_height` for those PHs in one batch.
//   5. Merge the returned coin records into the store and update each PH's
//      sync mark to the new peak.
//   6. Take the still-unspent coin set and call check_coins_spent on it so
//      we detect outbound spends.
//   7. Persist + bump global last_synced_height.
//
// CATs/NFTs by hint will hook into step (4b) once we track hints we own —
// for now the wallet only tracks XCH at receive-address puzzle hashes.

import { callEngine } from "./engine.js";
import {
  type CoinRecord,
  readCoinStore,
  writeCoinStore,
} from "./coin-store.js";

const ACTIVE_FP_KEY = "activeFingerprint";
const DERIVE_COUNT = 50; // first N derived addresses; sage native gap_limit = 100
const REORG_WINDOW = 32; // re-pull this many blocks each tick to absorb reorgs
const MAX_TICK_MS = 25_000;

let running = false;

export async function tickCoinSync(): Promise<void> {
  if (running) return;
  running = true;
  const deadline = Date.now() + MAX_TICK_MS;
  try {
    const session = await chrome.storage.session.get(ACTIVE_FP_KEY);
    const fingerprint = session[ACTIVE_FP_KEY] as number | undefined;
    if (typeof fingerprint !== "number") return;

    // Make sure the engine has the SK cached. If not, we can't derive
    // puzzle hashes — the lock screen will re-unlock when the user opens
    // the popup.
    let unlocked = false;
    try {
      const res = await callEngine<{ unlocked: boolean }>("is_unlocked", { fingerprint });
      unlocked = res.unlocked;
    } catch {
      return;
    }
    if (!unlocked) return;

    // 1. Derive the puzzle_hashes we care about.
    let addresses: { index: number; puzzle_hash: string }[];
    try {
      const res = await callEngine<{
        addresses: { index: number; address: string; puzzle_hash: string }[];
      }>("derive_addresses", {
        fingerprint,
        start: 0,
        count: DERIVE_COUNT,
        testnet: false,
      });
      addresses = res.addresses;
    } catch {
      return;
    }

    if (Date.now() > deadline) return;

    // 2. Compute start_height = lowest known PH mark, minus reorg window.
    const store = await readCoinStore(fingerprint);
    const allPhs = addresses.map((a) => a.puzzle_hash);
    let lowest = Number.POSITIVE_INFINITY;
    for (const ph of allPhs) {
      const h = store.ph_heights[ph] ?? 0;
      if (h < lowest) lowest = h;
    }
    if (!isFinite(lowest)) lowest = 0;
    const startHeight = Math.max(0, lowest - REORG_WINDOW);

    // 3. Scan.
    let scan: { peak_height: number; coin_records: CoinRecord[] };
    try {
      scan = await callEngine<typeof scan>("scan_puzzle_hashes", {
        puzzle_hashes: allPhs,
        start_height: startHeight,
        include_spent: true,
        endpoint: "mainnet",
      });
    } catch {
      return;
    }

    // 4. Merge.
    for (const rec of scan.coin_records) {
      store.coins[rec.coin_id] = rec;
    }
    for (const ph of allPhs) {
      store.ph_heights[ph] = scan.peak_height;
    }
    store.last_synced_height = scan.peak_height;

    if (Date.now() > deadline) {
      await writeCoinStore(fingerprint, store);
      return;
    }

    // 5. Verify still-unspent set.
    const unspentIds = Object.values(store.coins)
      .filter((c) => !c.spent)
      .map((c) => c.coin_id);
    if (unspentIds.length > 0) {
      try {
        // Chunk to fit under engine's 500-coin batch limit.
        for (let i = 0; i < unspentIds.length; i += 250) {
          const chunk = unspentIds.slice(i, i + 250);
          const res = await callEngine<{
            spent: { coin_id: string; spent_block_index: number }[];
            missing: string[];
          }>("check_coins_spent", {
            coin_ids: chunk,
            endpoint: "mainnet",
          });
          for (const s of res.spent) {
            const c = store.coins[s.coin_id];
            if (c) {
              c.spent = true;
              c.spent_block_index = s.spent_block_index;
            }
          }
          for (const missingId of res.missing) {
            // Indexer doesn't know about it any more — likely chain reorged
            // it away. Drop from cache; the next scan will re-add if needed.
            delete store.coins[missingId];
          }
        }
      } catch {
        // best-effort; persist what we have
      }
    }

    await writeCoinStore(fingerprint, store);
  } finally {
    running = false;
  }
}
