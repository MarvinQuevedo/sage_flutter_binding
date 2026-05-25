# Ozone Web Extension

Chia browser extension wallet — Goby-compatible (CHIP-0002), syncs via `coinset.org`, powered by a WASM-compiled Sage fork.

## Layout

```
ozone-web-extension/
├── packages/
│   ├── extension/         # WXT app (popup + service worker + content script)
│   ├── goby-provider/     # window.chia injector + CHIP-0002 types
│   ├── storage-idb/       # IndexedDB-backed Storage impl for the WASM module
│   └── wallet-wasm/       # wasm-pack output of crates/sage-wasm (regenerated)
└── ../vendor/sage/        # Sage Rust source (modified — see web/ozone-extension branch)
```

## Branch model

- This folder lives in the `web/ozone-extension` worktree.
- That branch is **never merged to `main`** of `sage_flutter_binding`.
- Sage Rust modifications happen in `../vendor/sage/` on this same branch.

## Sage as an engine — not a pile of WASM exports

The Sage Rust library is used **as a single engine instance**, same pattern Ozone uses today through `sage_flutter_binding` (Dart FFI). The JS side only knows:

```ts
const engine = new Sage(idbCallbacks);          // boot the engine
const res = await engine.request(method, jsonParams);  // single dispatch
```

We do **not** ship 110 individual wasm-bindgen exports. We do **not** glue together other JS chia libs (`chia-bls.js`, `clvm-rs.wasm`, `greenweb`, etc.). Everything the wallet needs lives inside the sage engine.

## Build flow

```bash
# 1. Build the WASM bundle from the Sage fork (one-time + when Rust changes)
pnpm wasm:build
pnpm wasm:opt

# 2. Dev the extension
pnpm dev

# 3. Build for release
pnpm build
pnpm zip
```

See `../docs/OZONE_EXTENSION_PLAN.md` for the full implementation plan.
