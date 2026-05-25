// Sync loop — polls coinset.org and updates the wallet store.
// Stub: this will delegate to the WASM module once it's built and connected
// to IdbStorage callbacks.

let running = false;

export async function startSyncLoop() {
  if (running) return;
  running = true;
  try {
    // TODO:
    // 1. await ensureSageInstance(): boot WASM if not already
    // 2. call sage.request("sync_now", {}) — Rust drives the polling
    // 3. emit progress events to popup if open
    console.log("[Ozone] sync tick — stub");
  } finally {
    running = false;
  }
}
