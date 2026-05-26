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
