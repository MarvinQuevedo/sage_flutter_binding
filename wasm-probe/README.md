# wasm-probe

Minimal smoke test that proves `chia-sdk-coinset` + `reqwest` + the rest of
the Chia Rust ecosystem can be compiled to `wasm32-unknown-unknown` and
called from a browser.

Excluded from the outer Sage cargo workspace on purpose — it has its own
toolchain pin and its own dep graph, so it can move ahead of (or behind) the
Sage workspace without coupling.

## Build

```bash
CC_wasm32_unknown_unknown=/usr/local/opt/llvm/bin/clang \
AR_wasm32_unknown_unknown=/usr/local/opt/llvm/bin/llvm-ar \
cargo build --release --target wasm32-unknown-unknown
```

Result: `target/wasm32-unknown-unknown/release/wasm_coinset_probe.wasm`
(~1.1 MB unoptimized; `wasm-opt -Oz` typically halves that).

## Findings (recorded 2026-05-25)

Compiles cleanly with:

- `chia-sdk-coinset 0.33` as a **direct** dep (NOT via the `chia-wallet-sdk`
  umbrella crate). `chia-wallet-sdk` has `chia-sdk-client` as a non-optional
  dependency, and `chia-sdk-client` pulls `tokio` with net I/O which needs
  `mio` — and `mio` doesn't support `wasm32-unknown-unknown`.
- `getrandom 0.3` with feature `wasm_js` AND `RUSTFLAGS=--cfg
  getrandom_backend="wasm_js"` (set in `../.cargo/config.toml`).
- `getrandom 0.2` (transitive, e.g. via `rand 0.8`) with feature `js`.
- brew LLVM (`/usr/local/opt/llvm/bin/clang`) supplied to `cc-rs` via env;
  needed because Xcode's clang lacks the wasm backend (`blst` requires this).
- **Default `rust-lld` linker** — do NOT override the linker to brew clang;
  it triggers `R_WASM_MEMORY_ADDR_SLEB` relocation errors.

## What this validates

The `CoinsetBackend` path planned in `docs/OZONE_EXTENSION_PLAN.md` is
viable. The remaining work to compile the *full* `sage-wallet` for wasm32
is structural, not "is it possible":

1. Either fork `chia-wallet-sdk` to make `chia-sdk-client` and `chia-sdk-test`
   optional features (cleanest, potentially upstreamable), or
2. In `sage-wallet`, replace `chia-wallet-sdk = ...` with direct deps on the
   sub-crates we use: `chia-protocol`, `chia-bls`, `chia-puzzles`,
   `chia-puzzle-types`, `chia-sdk-coinset`, `chia-sdk-driver`,
   `chia-sdk-signer`, `chia-sdk-types`, `chia-sdk-utils`.
3. Refactor `sage-database` so `sqlx` is behind an optional feature; on wasm32
   we'd swap in an IndexedDB-backed `Storage` impl.

See `docs/OZONE_EXTENSION_PLAN.md` §6 for the planned refactor sequencing.
