#!/usr/bin/env bash
# Regenerate the typed Dart API + docs from the vendored Sage's OpenAPI spec.
#
#   tool/generate_api.sh
#
# Run this after updating the vendored Sage. It:
#   1. builds Sage's CLI and emits its OpenAPI 3.1 spec,
#   2. generates lib/src/sage_api.g.dart and doc/API.md from it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPEC="${TMPDIR:-/tmp}/sage_openapi.json"

echo "==> Generating OpenAPI spec from vendored Sage..."
( cd "$ROOT/vendor/sage" && SQLX_OFFLINE=true \
    cargo run -q -p sage-cli -- rpc generate_openapi -o "$SPEC" )

echo "==> Generating Dart API + docs..."
python3 "$ROOT/tool/gen_sage_api.py" "$SPEC" "$ROOT"

echo "==> Formatting..."
( cd "$ROOT" && dart format lib/src/sage_api.g.dart >/dev/null )

echo "==> Analyzing..."
( cd "$ROOT" && dart analyze lib )

echo "Done. Review git diff for lib/src/sage_api.g.dart and doc/API.md."
