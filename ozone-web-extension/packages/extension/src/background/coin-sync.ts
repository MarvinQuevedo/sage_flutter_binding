// Background coin sync loop driven by chrome.alarms.
//
// Pulls the wallet's puzzle_hashes from the engine using ONLY the stored
// master_public_key (no unlock required) so it keeps running across SW
// restarts. Detects new coins + outbound spends and persists everything
// in chrome.storage.local["coins.<fp>"].
//
// Algorithm per tick:
//   1. Look up the active wallet from chrome.storage.local (the popup
//      writes it on unlock / save).
//   2. derive_addresses(master_public_key, 0..50) — stateless.
//   3. Find the lowest per-PH sync mark; back off by REORG_WINDOW so a
//      chain reorg can't sneak past us.
//   4. scan_puzzle_hashes(phs, start_height, peak) — incremental diff.
//   5. Merge new coin records into the store.
//   6. check_coins_spent for the still-unspent set in chunks of 250.
//   7. Persist + bump global last_synced_height + write telemetry.

import { callEngine } from "./engine.js";
import {
  type CoinRecord,
  type NftView,
  readCoinStore,
  writeCoinStore,
} from "./coin-store.js";
import { resolveCatMetadata } from "./dexie.js";

const DERIVE_COUNT = 50;
const REORG_WINDOW = 32;
const MAX_TICK_MS = 25_000;
const WALLETS_KEY = "wallets";
const ACTIVE_FP_KEY = "activeFingerprint";
const TELEMETRY_KEY = "coinSyncTelemetry";

export interface CoinSyncTelemetry {
  fingerprint: number | null;
  last_attempt_at: number;
  last_success_at: number | null;
  last_error: string | null;
  last_peak_height: number;
  last_new_coins: number;
}

interface StoredWalletEntry {
  fingerprint: number;
  keychainBlob: string;
  masterPublicKey?: string;
  label: string;
  createdAt: number;
}

let running = false;

async function loadActiveWallet(): Promise<StoredWalletEntry | null> {
  const session = await chrome.storage.session.get(ACTIVE_FP_KEY);
  const fingerprint = session[ACTIVE_FP_KEY] as number | undefined;
  if (typeof fingerprint !== "number") return null;
  const local = await chrome.storage.local.get(WALLETS_KEY);
  const wallets = (local[WALLETS_KEY] as Record<string, StoredWalletEntry> | undefined) ?? {};
  return wallets[fingerprint.toString()] ?? null;
}

async function writeTelemetry(patch: Partial<CoinSyncTelemetry>): Promise<void> {
  const current = (await chrome.storage.session.get(TELEMETRY_KEY))[TELEMETRY_KEY] as
    | CoinSyncTelemetry
    | undefined;
  const next: CoinSyncTelemetry = {
    fingerprint: current?.fingerprint ?? null,
    last_attempt_at: current?.last_attempt_at ?? 0,
    last_success_at: current?.last_success_at ?? null,
    last_error: current?.last_error ?? null,
    last_peak_height: current?.last_peak_height ?? 0,
    last_new_coins: current?.last_new_coins ?? 0,
    ...patch,
  };
  await chrome.storage.session.set({ [TELEMETRY_KEY]: next });
}

export async function readSyncTelemetry(): Promise<CoinSyncTelemetry | null> {
  const data = await chrome.storage.session.get(TELEMETRY_KEY);
  return (data[TELEMETRY_KEY] as CoinSyncTelemetry | undefined) ?? null;
}

export async function tickCoinSync(): Promise<void> {
  if (running) return;
  running = true;
  const startedAt = Date.now();
  const deadline = startedAt + MAX_TICK_MS;
  try {
    const wallet = await loadActiveWallet();
    if (!wallet) {
      await writeTelemetry({
        last_attempt_at: startedAt,
        last_error: "no active wallet",
      });
      return;
    }
    const masterPk = wallet.masterPublicKey;
    if (!masterPk) {
      // Wallet predates master_public_key persistence — needs one unlock to
      // backfill (the popup does that on next login).
      await writeTelemetry({
        fingerprint: wallet.fingerprint,
        last_attempt_at: startedAt,
        last_error: "wallet missing masterPublicKey — open the popup and unlock once",
      });
      return;
    }

    // 1. Derive puzzle_hashes from the master_public_key (no unlock needed).
    let addresses: { index: number; puzzle_hash: string }[];
    try {
      const res = await callEngine<{
        addresses: { index: number; address: string; puzzle_hash: string }[];
      }>("derive_addresses", {
        master_public_key: masterPk,
        start: 0,
        count: DERIVE_COUNT,
        testnet: false,
      });
      addresses = res.addresses;
    } catch (err) {
      await writeTelemetry({
        fingerprint: wallet.fingerprint,
        last_attempt_at: startedAt,
        last_error: `derive_addresses: ${(err as Error).message}`,
      });
      return;
    }

    if (Date.now() > deadline) return;

    // 2. start_height = lowest per-PH mark - reorg window
    const store = await readCoinStore(wallet.fingerprint);
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
    } catch (err) {
      await writeTelemetry({
        fingerprint: wallet.fingerprint,
        last_attempt_at: startedAt,
        last_error: `scan_puzzle_hashes: ${(err as Error).message}`,
      });
      return;
    }

    // 4. Merge.
    let newCoins = 0;
    for (const rec of scan.coin_records) {
      if (!(rec.coin_id in store.coins)) newCoins += 1;
      store.coins[rec.coin_id] = rec;
    }
    for (const ph of allPhs) {
      store.ph_heights[ph] = scan.peak_height;
    }
    store.last_synced_height = scan.peak_height;

    // 5. Verify still-unspent set in chunks (in case the indexer says they're
    //    gone or now spent since the last tick).
    const unspentIds = Object.values(store.coins)
      .filter((c) => !c.spent)
      .map((c) => c.coin_id);
    for (let i = 0; i < unspentIds.length; i += 250) {
      if (Date.now() > deadline) break;
      const chunk = unspentIds.slice(i, i + 250);
      try {
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
          delete store.coins[missingId];
        }
      } catch {
        // best-effort; continue with next chunk
      }
    }

    // 6a. Discover CATs by hint matching. Best-effort.
    if (Date.now() < deadline) {
      try {
        const catRes = await callEngine<{
          cats: Array<{
            asset_id: string;
            total_unspent_mojos: string;
            unspent_coin_count: number;
            coins: Array<{
              coin_id: string;
              parent_coin_info: string;
              puzzle_hash: string;
              amount: string;
              inner_puzzle_hash: string;
              hint: string;
              confirmed_block_index: number;
              spent: boolean;
              spent_block_index: number;
            }>;
          }>;
        }>("scan_cats", {
          master_public_key: masterPk,
          start: 0,
          count: DERIVE_COUNT,
          testnet: false,
          endpoint: "mainnet",
        });
        const catsMap: Record<string, (typeof catRes)["cats"][number]> = {};
        for (const c of catRes.cats) {
          catsMap[c.asset_id] = c;
        }
        store.cats = catsMap;
        store.cats_synced_at = Date.now();

        // 6b. Resolve Dexie metadata for any CATs we found. Cached in
        //     chrome.storage.local["dexie.cats"], TTL 12h.
        const assetIds = Object.keys(catsMap);
        if (assetIds.length > 0) {
          void resolveCatMetadata(assetIds).catch(() => {});
        }
      } catch (err) {
        console.warn("[Ozone] CAT scan failed:", (err as Error).message);
      }
    }

    // 6c. NFT scan, same hint-matching pattern.
    if (Date.now() < deadline) {
      try {
        const nftRes = await callEngine<{
          nfts: NftView[];
        }>("scan_nfts", {
          master_public_key: masterPk,
          start: 0,
          count: DERIVE_COUNT,
          testnet: false,
          endpoint: "mainnet",
        });
        const nftsMap: Record<string, NftView> = {};
        for (const n of nftRes.nfts) {
          // Keep the most recent (unspent) version per launcher_id
          const existing = nftsMap[n.launcher_id];
          if (
            !existing ||
            n.confirmed_block_index >= existing.confirmed_block_index
          ) {
            nftsMap[n.launcher_id] = n;
          }
        }
        store.nfts = nftsMap;
        store.nfts_synced_at = Date.now();
      } catch (err) {
        console.warn("[Ozone] NFT scan failed:", (err as Error).message);
      }
    }

    await writeCoinStore(wallet.fingerprint, store);
    await writeTelemetry({
      fingerprint: wallet.fingerprint,
      last_attempt_at: startedAt,
      last_success_at: Date.now(),
      last_error: null,
      last_peak_height: scan.peak_height,
      last_new_coins: newCoins,
    });
  } catch (err) {
    await writeTelemetry({
      last_attempt_at: startedAt,
      last_error: (err as Error).message,
    });
  } finally {
    running = false;
  }
}
