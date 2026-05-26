// Sync loop — polls coinset.org and updates the wallet store.
//
// Triggered by a chrome.alarms tick (every 30s by default). The actual sync
// algorithm lives in the WASM engine; this file just kicks it off and tracks
// in-flight state so two ticks don't stomp on each other.

import { callEngine } from "./engine.js";

let running = false;
let lastError: string | null = null;

export async function startSyncLoop(): Promise<void> {
  if (running) return;
  running = true;
  try {
    await callEngine("sync_tick", {});
    lastError = null;
  } catch (err) {
    // NotImplemented is expected today — log and move on.
    const e = err as Error & { code?: number };
    if (e.code === 4999) {
      // not implemented yet — silent
    } else {
      lastError = e.message;
      console.error("[Ozone] sync tick failed:", e);
    }
  } finally {
    running = false;
  }
}

export function lastSyncError(): string | null {
  return lastError;
}
