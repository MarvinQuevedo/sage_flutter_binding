// JS-side coin record cache, keyed per fingerprint.
//
// We don't have the Rust storage bridge wired yet, so the background SW
// drives the sync loop and writes coin records into chrome.storage.local.
// The popup reads from this same store via popup-rpc.
//
// Layout per fingerprint:
//   chrome.storage.local["coins.<fp>"] = {
//     last_synced_height: number,           // global high-water mark
//     ph_heights: { [ph_hex]: number },     // per-ph sync mark (reorg safety)
//     coins: { [coin_id_hex]: CoinRecord }, // every coin we've ever seen
//   }

const KEY_PREFIX = "coins.";

export interface CoinRecord {
  coin_id: string;
  parent_coin_info: string;
  puzzle_hash: string;
  amount: string;
  coinbase: boolean;
  confirmed_block_index: number;
  spent: boolean;
  spent_block_index: number;
  timestamp: number;
  hint?: string;
}

export interface CoinStore {
  last_synced_height: number;
  ph_heights: Record<string, number>;
  coins: Record<string, CoinRecord>;
}

const empty = (): CoinStore => ({
  last_synced_height: 0,
  ph_heights: {},
  coins: {},
});

export async function readCoinStore(fingerprint: number): Promise<CoinStore> {
  const key = `${KEY_PREFIX}${fingerprint}`;
  const data = await chrome.storage.local.get(key);
  return (data[key] as CoinStore | undefined) ?? empty();
}

export async function writeCoinStore(fingerprint: number, store: CoinStore): Promise<void> {
  const key = `${KEY_PREFIX}${fingerprint}`;
  await chrome.storage.local.set({ [key]: store });
}

export async function clearCoinStore(fingerprint: number): Promise<void> {
  const key = `${KEY_PREFIX}${fingerprint}`;
  await chrome.storage.local.remove(key);
}

/** Total unspent XCH (as mojos BigInt string) for direct-receive coins. */
export function totalUnspentMojos(store: CoinStore): string {
  let total = 0n;
  for (const c of Object.values(store.coins)) {
    if (!c.spent) total += BigInt(c.amount);
  }
  return total.toString();
}

export function unspentCoinCount(store: CoinStore): number {
  let count = 0;
  for (const c of Object.values(store.coins)) {
    if (!c.spent) count += 1;
  }
  return count;
}
