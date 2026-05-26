// Popup ↔ Service Worker RPC.
//
// The popup is in the same extension origin as the SW, so we don't need the
// CHIP-0002 permission gate that gates dApp calls. The popup can invoke any
// engine method directly. We just need a thin envelope to forward the call
// + serialize errors.

import { callEngine } from "./engine.js";
import { setActiveWallet } from "./engine.js";
import { clearCoinStore, readCoinStore, totalUnspentMojos, unspentCoinCount } from "./coin-store.js";
import { readSyncTelemetry, tickCoinSync } from "./coin-sync.js";
import { resolveCatMetadata } from "./dexie.js";
import { readSyncState } from "./sync-loop.js";

export type PopupRpcMessage =
  | { from: "popup"; kind: "engine"; method: string; params: unknown }
  | { from: "popup"; kind: "set-active-wallet"; walletId: string | null }
  | { from: "popup"; kind: "get-sync-state" }
  | { from: "popup"; kind: "get-coin-store"; fingerprint: number }
  | { from: "popup"; kind: "clear-coin-store"; fingerprint: number }
  | { from: "popup"; kind: "force-coin-sync" }
  | { from: "popup"; kind: "get-coin-sync-telemetry" };

export type PopupRpcResponse =
  | { ok: true; value: unknown }
  | { ok: false; error: { code?: number; message: string } };

export function isPopupMessage(msg: unknown): msg is PopupRpcMessage {
  if (typeof msg !== "object" || msg === null) return false;
  const m = msg as { from?: unknown };
  return m.from === "popup";
}

export async function handlePopupMessage(
  msg: PopupRpcMessage,
): Promise<PopupRpcResponse> {
  try {
    switch (msg.kind) {
      case "engine": {
        const value = await callEngine(msg.method, msg.params);
        return { ok: true, value };
      }
      case "set-active-wallet": {
        setActiveWallet(msg.walletId);
        if (msg.walletId) {
          await chrome.storage.session.set({ walletId: msg.walletId });
        } else {
          await chrome.storage.session.remove("walletId");
        }
        return { ok: true, value: null };
      }
      case "get-sync-state": {
        const state = await readSyncState();
        return { ok: true, value: state };
      }
      case "get-coin-store": {
        const store = await readCoinStore(msg.fingerprint);
        const assetIds = Object.keys(store.cats ?? {});
        const metadata = await resolveCatMetadata(assetIds).catch(() => ({}));
        return {
          ok: true,
          value: {
            last_synced_height: store.last_synced_height,
            unspent_mojos: totalUnspentMojos(store),
            unspent_count: unspentCoinCount(store),
            coins: store.coins,
            cats: store.cats ?? {},
            cats_synced_at: store.cats_synced_at ?? null,
            cat_metadata: metadata,
            nfts: store.nfts ?? {},
            nfts_synced_at: store.nfts_synced_at ?? null,
          },
        };
      }
      case "clear-coin-store": {
        await clearCoinStore(msg.fingerprint);
        return { ok: true, value: null };
      }
      case "force-coin-sync": {
        await tickCoinSync();
        return { ok: true, value: null };
      }
      case "get-coin-sync-telemetry": {
        const t = await readSyncTelemetry();
        return { ok: true, value: t };
      }
    }
  } catch (err) {
    const e = err as Error & { code?: number };
    return {
      ok: false,
      error: { code: e.code, message: e.message ?? String(err) },
    };
  }
}
