# vendor/chia-wallet-sdk — patched fork

Local clone of `xch-dev/chia-wallet-sdk` v0.33.0 with our `peer-client` feature
patch applied on branch `feat/peer-client-feature`.

The outer worktree's `vendor/sage/Cargo.toml` uses `[patch.crates-io]` to
redirect chia-wallet-sdk + sub-crates to this directory's path. NOT yet
configured as a git submodule because we haven't pushed to a remote fork yet.

**TODO before others can build this branch:**
1. Push `feat/peer-client-feature` to a remote (MarvinQuevedo/chia-wallet-sdk
   most likely).
2. Convert `vendor/chia-wallet-sdk/` to a proper git submodule.

For now anyone building locally needs to:
```bash
cd vendor && git clone https://github.com/xch-dev/chia-wallet-sdk.git
cd chia-wallet-sdk
git checkout 0.33.0
# Apply patches from the README (or once pushed: git fetch + checkout fork branch)
```
