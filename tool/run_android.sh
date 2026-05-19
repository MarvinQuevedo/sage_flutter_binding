#!/usr/bin/env bash
# The canonical way to run the example app on Android.
#
#   tool/run_android.sh                 # flutter run on a device/emulator
#   tool/run_android.sh --clean         # also stop stale Gradle daemons first
#   tool/run_android.sh -d <id> [args]  # extra args pass through to flutter run
#
# Why this wrapper exists: the Chia/aws-lc stack only cross-compiles to Android
# with the toolchain env from tool/android_env.sh (NDK sysroot, per-target
# CC/linkers, BINDGEN_EXTRA_CLANG_ARGS). Sourcing that by hand in the right
# shell, with the right NDK, every time is the step everyone forgets — which
# is exactly what produces `'stdlib.h' file not found`. Running through this
# script makes that impossible to get wrong: it sources the env in its own
# process and execs `flutter run` as a child, so Gradle/Cargokit inherit it.
# Execute it (do NOT `source` it) — the env only needs to live for this run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# r28: Flutter's NDK gate picks the highest version any plugin needs
# (integration_test/jni need 28.2.13676358). Override by exporting NDK_VERSION.
export NDK_VERSION="${NDK_VERSION:-28.2.13676358}"

clean=0
flutter_args=()
for arg in "$@"; do
  case "$arg" in
    --clean|-c) clean=1 ;;
    *) flutter_args+=("$arg") ;;
  esac
done

# shellcheck disable=SC1091
source "$REPO_ROOT/tool/android_env.sh"

if [ "$clean" -eq 1 ]; then
  echo "Stopping stale Gradle daemons so a fresh one inherits the env…"
  (cd "$REPO_ROOT/example/android" && ./gradlew --stop) || true
fi

cd "$REPO_ROOT/example"
exec flutter run "${flutter_args[@]}"
