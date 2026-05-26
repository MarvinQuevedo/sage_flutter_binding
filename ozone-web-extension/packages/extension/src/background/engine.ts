// Lazy WASM engine bootstrap.
//
// The service worker is killed after ~30s of idle in MV3, so we instantiate
// the engine on-demand and cache it as a module-scoped singleton. When the SW
// wakes up, the first call to `getEngine()` re-loads the WASM module.
//
// The IdbStorage handle is keyed on a wallet id (fingerprint) that lives in
// `chrome.storage.session` for the duration of the browser session.

import init, { Sage } from "@ozone/wallet-wasm";
import { IdbStorage } from "@ozone/storage-idb";

let enginePromise: Promise<Sage> | null = null;
let currentWalletId: string | null = null;

/**
 * Bind the engine to a wallet id. Subsequent `getEngine()` calls will use
 * that wallet's IndexedDB database. Resetting to a different walletId tears
 * down the previous engine so its WASM memory can be reclaimed.
 */
export function setActiveWallet(walletId: string | null): void {
  if (walletId === currentWalletId) return;
  if (enginePromise) {
    void enginePromise
      .then((engine) => {
        try {
          engine.free();
        } catch {
          // already freed or wasm not initialized — ignore
        }
      })
      .catch(() => {});
  }
  enginePromise = null;
  currentWalletId = walletId;
}

export async function getEngine(): Promise<Sage> {
  if (!currentWalletId) {
    throw new Error("Engine requested before a wallet was unlocked");
  }
  if (!enginePromise) {
    const walletId = currentWalletId;
    enginePromise = (async () => {
      await init();
      const storage = await IdbStorage.open(walletId);
      return new Sage(storage.asWasmCallbacks());
    })();
  }
  return enginePromise;
}

/**
 * Convenience wrapper: serialize params, call request(), parse the response.
 * Errors thrown by the WASM side carry { code, message } as JSON; we re-throw
 * an Error subclass with the same shape so the rpc-router can forward it.
 */
export async function callEngine<T = unknown>(
  method: string,
  params: unknown,
): Promise<T> {
  const engine = await getEngine();
  try {
    const json = await engine.request(method, JSON.stringify(params ?? {}));
    return JSON.parse(json) as T;
  } catch (rejected) {
    // wasm-bindgen rejects with a string JSON. Try to parse it; fall through
    // to a plain message if it isn't valid JSON.
    if (typeof rejected === "string") {
      try {
        const parsed = JSON.parse(rejected) as { code?: number; message?: string };
        const err = new Error(parsed.message ?? "WASM call failed") as Error & {
          code?: number;
        };
        err.code = parsed.code;
        throw err;
      } catch {
        throw new Error(rejected);
      }
    }
    throw rejected;
  }
}
