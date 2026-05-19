# sage_flutter_binding

A Flutter plugin that links the [**Sage**](https://github.com/xch-dev/sage) Chia
wallet core **in-process** (no RPC server, no TLS sockets, no extra processes)
and exposes every Sage endpoint to Dart as a **typed API**.

```dart
await SageBinding.init();
final dir = await getApplicationSupportDirectory();
final sage = await SageClient.newInstance(dataDir: '${dir.path}/sage');

// Typed API — request/response are real Dart classes (see doc/API.md).
final m = await sage.api.generateMnemonic(GenerateMnemonic(use24Words: true));
final key = await sage.api.importKey(
  ImportKey(name: 'Main', key: m.mnemonic, login: true),
);
final status = await sage.api.getSyncStatus();
print('${status.receiveAddress} — ${status.selectableBalance} mojos');

// Or drop to the raw JSON escape hatch for anything not yet modelled:
final raw = await sage.callJson('get_version');
```

The typed API (`SageClient.api`, **105 methods + ~224 models**, incl. the 5
WalletConnect endpoints) is generated from Sage's OpenAPI spec and stays in
sync with the vendored Sage. See:

- [`doc/WALLET_GUIDE.md`](doc/WALLET_GUIDE.md) — **how to build a wallet UI
  screen by screen** (flows, sequences, polling, Tauri-command gaps).
- [`doc/API.md`](doc/API.md) — full per-endpoint request/response reference.
- the **wallet-simulator example** in [`example/`](example/lib/main.dart).

## Architecture

```
Dart  ──flutter_rust_bridge──▶  rust/ (binding crate)
                                  │  SageClient::call(endpoint, json)
                                  │  impl_endpoints! → match on endpoint name
                                  ▼
                                vendor/sage/crates/sage  (full wallet, vendored)
```

- **`rust/`** – the binding crate. `SageClient` owns an `Arc<Mutex<Sage>>` and a
  multi-thread Tokio runtime. `impl_endpoints!` (Sage's own macro) generates one
  match arm per endpoint from `endpoints.json`, so the API is **always complete
  and in sync** with the vendored Sage — no per-endpoint glue to maintain.
- **`vendor/sage/`** – a vendored copy of the Sage workspace (crates +
  `migrations/` + `.sqlx/`). `src-tauri` and the Tauri plugin are excluded.
- **`lib/`** – generated bindings + `SageBinding.init()` and the `callJson`
  helper.
- Native libraries are built by **Cargokit** (Android Gradle / iOS podspec).

The endpoint list lives in
[`vendor/sage/crates/sage-api/endpoints.json`](vendor/sage/crates/sage-api/endpoints.json)
(`login`, `import_key`, `get_sync_status`, `send_xch`, `make_offer`, …).

## Why the previous build failed (and the fix)

The Chia stack pulls `chia-wallet-sdk → rustls 0.23 → aws-lc-rs → aws-lc-sys`,
which **does not cross-compile to Android/iOS by default**. The fix (mirroring
Sage's own mobile CI):

1. `aws-lc-rs = { version = "1", features = ["bindgen"] }` forced in
   [`rust/Cargo.toml`](rust/Cargo.toml) so `aws-lc-sys` generates bindings for
   the mobile triples instead of relying on absent pre-generated ones.
2. `bindgen-cli` installed globally (`cargo install bindgen-cli --locked`).
3. Android NDK **r26d** + `CC_/CXX_/AR_/RANLIB_` + linker env per target
   (see [`tool/android_env.sh`](tool/android_env.sh)).
4. `SQLX_OFFLINE=true` + vendored `.sqlx/` so `sqlx` needs no live database.
5. `specta` pinned to Sage's tested `2.0.0-rc.22` (newer rc needs nightly).

Status: **host ✅, `aarch64-linux-android` ✅, `aarch64-apple-ios` ✅**, and a
host smoke test exercises the full JSON dispatch path.

## Prerequisites

- Rust + targets: `rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios`
- `cargo install bindgen-cli --locked`
- Android NDK **26.3.11579264** (r26d); Xcode for iOS
- `flutter_rust_bridge_codegen` 2.11.1 (only if you change the Rust API)

## Build & run

```bash
# Android (env script sets NDK + per-target C toolchain)
source tool/android_env.sh
(cd example && flutter run)            # device/emulator

# iOS
(cd example && flutter run)            # device/simulator
```

Verify the cross-compiles directly:

```bash
source tool/android_env.sh
cargo build --manifest-path rust/Cargo.toml --lib --target aarch64-linux-android
cargo build --manifest-path rust/Cargo.toml --lib --target aarch64-apple-ios
cargo test  --manifest-path rust/Cargo.toml --lib   # host smoke test
```

> Debug builds of the full graph are large (~400–700 MB). The `[profile.release]`
> in `rust/Cargo.toml` (`opt-level=s`, `lto`, `strip`) shrinks release builds by
> an order of magnitude; Flutter release builds use it automatically.

## Release builds & FFI symbol stripping

In release, Xcode enables Dead Code Stripping (`-dead_strip`). The FFI entry
points (`frbgen_sage_flutter_binding_*`) are only ever resolved via
`dart:ffi` `lookup()` at runtime — never referenced from Swift/ObjC — so this
is a legitimate concern. It is **safe with the standard setup** because the
plugin links as a *dynamic* framework
(`Runner.app/Frameworks/sage_flutter_binding.framework`): a dylib keeps all
exported symbols by design, so `-dead_strip` cannot remove them. Combined with
`-force_load` (podspec) and Rust `#[no_mangle] pub extern "C"`, the symbols are
guaranteed.

Flutter does **not** support `--release` on the iOS simulator, so verify on a
device build:

```bash
cd example && flutter build ios --release --no-codesign
FW=build/ios/iphoneos/Runner.app/Frameworks/sage_flutter_binding.framework/sage_flutter_binding
nm -gU "$FW" | grep frbgen_sage_flutter_binding          # defined & exported
xcrun dyld_info -exports "$FW" | grep frbgen_sage_flutter_binding  # in export trie
```

Caveat: if a consuming app forces **static** linkage
(`use_frameworks! :linkage => :static` or a static podspec), the Rust code is
linked into the app executable, where exported symbols are *not* dead-strip
roots. The `-force_load` in the podspec covers this, but test that path
explicitly if you use it.

## Regenerating bindings

FFI bindings (only if you change the public Rust API in `rust/src/api/`):

```bash
flutter_rust_bridge_codegen generate
```

Typed Dart API + docs (`lib/src/sage_api.g.dart`, `doc/API.md`) — generated
from Sage's OpenAPI spec, so it tracks the vendored Sage automatically:

```bash
tool/generate_api.sh
```

`gen_sage_api.py` maps OpenAPI → Dart: `$ref`→class, string-enum→Dart `enum`,
`Amount`→`BigInt`, nullable/optional→`T?`, tagged unions (`Id`/`Action`)→raw
`Map`. `SageApi` gets one typed method per endpoint over `callJson`.

## Updating vendored Sage

Re-sync `crates/`, `migrations/`, `.sqlx/` from upstream, keep the
`[workspace] members`/`exclude` edit in `vendor/sage/Cargo.toml`, re-run the
cross-compiles, then `tool/generate_api.sh` to refresh the typed API.
