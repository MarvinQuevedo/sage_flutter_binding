// Popup-side client for talking to the engine through the service worker.
//
// The popup never loads WASM itself — only the SW owns the wallet. Every
// call goes through chrome.runtime.sendMessage with the `from: "popup"`
// envelope handled in background/popup-rpc.ts.

import type { PopupRpcMessage, PopupRpcResponse } from "../background/popup-rpc";

export async function callEngine<T = unknown>(
  method: string,
  params: unknown = {},
): Promise<T> {
  const msg: PopupRpcMessage = { from: "popup", kind: "engine", method, params };
  const res = (await chrome.runtime.sendMessage(msg)) as PopupRpcResponse;
  if (!res.ok) {
    const err = new Error(res.error.message) as Error & { code?: number };
    err.code = res.error.code;
    throw err;
  }
  return res.value as T;
}

export async function setActiveWallet(walletId: string | null): Promise<void> {
  const msg: PopupRpcMessage = { from: "popup", kind: "set-active-wallet", walletId };
  const res = (await chrome.runtime.sendMessage(msg)) as PopupRpcResponse;
  if (!res.ok) {
    throw new Error(res.error.message);
  }
}

export interface SyncState {
  peak_height: number;
  peak_header_hash: string;
  synced: boolean;
  sync_mode: boolean;
  mempool_size: number;
  mempool_cost: number;
  difficulty: number;
  ticked_at: number;
  error?: string;
}

export async function getSyncState(): Promise<SyncState | null> {
  const msg: PopupRpcMessage = { from: "popup", kind: "get-sync-state" };
  const res = (await chrome.runtime.sendMessage(msg)) as PopupRpcResponse;
  if (!res.ok) {
    throw new Error(res.error.message);
  }
  return (res.value as SyncState | null) ?? null;
}

export interface CatCoin {
  coin_id: string;
  parent_coin_info: string;
  puzzle_hash: string;
  amount: string;
  inner_puzzle_hash: string;
  hint: string;
  confirmed_block_index: number;
  spent: boolean;
  spent_block_index: number;
}

export interface CatAsset {
  asset_id: string;
  total_unspent_mojos: string;
  unspent_coin_count: number;
  coins: CatCoin[];
}

export interface CoinSnapshot {
  last_synced_height: number;
  unspent_mojos: string;
  unspent_count: number;
  coins: Record<string, {
    coin_id: string;
    parent_coin_info: string;
    puzzle_hash: string;
    amount: string;
    confirmed_block_index: number;
    spent: boolean;
    spent_block_index: number;
    timestamp: number;
    hint?: string;
  }>;
  cats?: Record<string, CatAsset>;
  cats_synced_at?: number | null;
}

export async function getCoinSnapshot(fingerprint: number): Promise<CoinSnapshot> {
  const msg: PopupRpcMessage = { from: "popup", kind: "get-coin-store", fingerprint };
  const res = (await chrome.runtime.sendMessage(msg)) as PopupRpcResponse;
  if (!res.ok) throw new Error(res.error.message);
  return res.value as CoinSnapshot;
}

export async function clearCoinSnapshot(fingerprint: number): Promise<void> {
  const msg: PopupRpcMessage = { from: "popup", kind: "clear-coin-store", fingerprint };
  const res = (await chrome.runtime.sendMessage(msg)) as PopupRpcResponse;
  if (!res.ok) throw new Error(res.error.message);
}

export async function forceCoinSync(): Promise<void> {
  const msg: PopupRpcMessage = { from: "popup", kind: "force-coin-sync" };
  const res = (await chrome.runtime.sendMessage(msg)) as PopupRpcResponse;
  if (!res.ok) throw new Error(res.error.message);
}

export interface CoinSyncTelemetry {
  fingerprint: number | null;
  last_attempt_at: number;
  last_success_at: number | null;
  last_error: string | null;
  last_peak_height: number;
  last_new_coins: number;
}

export async function getCoinSyncTelemetry(): Promise<CoinSyncTelemetry | null> {
  const msg: PopupRpcMessage = { from: "popup", kind: "get-coin-sync-telemetry" };
  const res = (await chrome.runtime.sendMessage(msg)) as PopupRpcResponse;
  if (!res.ok) throw new Error(res.error.message);
  return (res.value as CoinSyncTelemetry | null) ?? null;
}

export interface SendXchResult {
  tx_id: string;
  status: string;
  error?: string | null;
  change_mojos: string;
}

export interface PickedCoin {
  coin_id: string;
  parent_coin_info: string;
  puzzle_hash: string;
  amount: string;
  derivation_index: number;
}

type CandidateCoin = {
  coin_id: string;
  parent_coin_info: string;
  puzzle_hash: string;
  amount: string;
  spent: boolean;
};

function toPicked(c: CandidateCoin, idx: number): PickedCoin {
  return {
    coin_id: c.coin_id,
    parent_coin_info: c.parent_coin_info,
    puzzle_hash: c.puzzle_hash,
    amount: c.amount,
    derivation_index: idx,
  };
}

/** Pick the smallest unspent coin whose amount covers needed mojos. */
export function pickCoinForSend(
  coins: Record<string, CandidateCoin>,
  phToIndex: Record<string, number>,
  neededMojos: bigint,
): PickedCoin | null {
  const candidates = Object.values(coins)
    .filter((c) => !c.spent && BigInt(c.amount) >= neededMojos)
    .filter((c) => phToIndex[c.puzzle_hash] !== undefined);
  if (candidates.length === 0) return null;
  candidates.sort((a, b) => (BigInt(a.amount) < BigInt(b.amount) ? -1 : 1));
  return toPicked(candidates[0]!, phToIndex[candidates[0]!.puzzle_hash]!);
}

/**
 * Select multiple coins that together cover `neededMojos`. Largest-first to
 * minimise the number of inputs. Returns null when the unspent total is
 * still insufficient.
 */
export function pickCoinsForSendMulti(
  coins: Record<string, CandidateCoin>,
  phToIndex: Record<string, number>,
  neededMojos: bigint,
  maxInputs = 50,
): PickedCoin[] | null {
  const available = Object.values(coins)
    .filter((c) => !c.spent && phToIndex[c.puzzle_hash] !== undefined)
    .sort((a, b) => (BigInt(b.amount) > BigInt(a.amount) ? 1 : -1));
  const picked: PickedCoin[] = [];
  let running = 0n;
  for (const c of available) {
    if (running >= neededMojos) break;
    if (picked.length >= maxInputs) break;
    picked.push(toPicked(c, phToIndex[c.puzzle_hash]!));
    running += BigInt(c.amount);
  }
  if (running < neededMojos) return null;
  return picked;
}
