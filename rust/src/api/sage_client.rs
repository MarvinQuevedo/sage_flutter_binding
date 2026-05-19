//! Flutter <-> Sage bridge.
//!
//! Sage is a full Chia wallet. Instead of running its RPC server, we link the
//! `sage` crate directly and expose a single generic entry point:
//!
//! ```dart
//! final client = await SageClient.newInstance(dataDir: dir);
//! final json = await client.call(endpoint: "login", requestJson: '{"fingerprint":123}');
//! ```
//!
//! Every endpoint that Sage's RPC server exposes is reachable through
//! [`SageClient::call`] using the exact same request/response JSON shapes.

use std::{
    path::PathBuf,
    sync::{Arc, Once, OnceLock},
};

use anyhow::{anyhow, Result};
use sage::Sage;
use sage_api_macro::impl_endpoints;
use tokio::{runtime::Runtime, sync::Mutex};

/// A single multi-threaded Tokio runtime drives all of Sage's async work
/// (peer sync manager, database, networking). Sage spawns long-lived tasks
/// via `tokio::spawn`, so they must live on a real Tokio runtime rather than
/// flutter_rust_bridge's executor.
static RUNTIME: OnceLock<Runtime> = OnceLock::new();

fn runtime() -> &'static Runtime {
    RUNTIME.get_or_init(|| {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .thread_name("sage-runtime")
            .build()
            .expect("failed to build the Sage Tokio runtime")
    })
}

/// rustls 0.23 (pulled in by `chia-wallet-sdk`'s `rustls` feature) needs a
/// crypto provider installed before any TLS handshake. We use the aws-lc-rs
/// provider, matching Sage's desktop/mobile builds.
fn install_crypto_provider() {
    static ONCE: Once = Once::new();
    ONCE.call_once(|| {
        let _ = rustls::crypto::aws_lc_rs::default_provider().install_default();
    });
}

// Generates `async fn dispatch(...)` with one match arm per Sage endpoint,
// reading the endpoint list straight from the vendored `endpoints.json`.
//
// For `login` this expands (roughly) to:
//   "login" => {
//       let req: sage_api::Login = serde_json::from_str(body)?;
//       let res = sage.login(req).await;
//       serde_json::to_string(&res.map_err(...)?)
//   }
impl_endpoints! {
    async fn dispatch(sage: &mut Sage, name: &str, body: &str) -> Result<String> {
        match name {
            (repeat endpoint_string => {
                let req: sage_api::Endpoint = serde_json::from_str(body)
                    .map_err(|e| anyhow!("invalid JSON request for `{}`: {e}", endpoint_string))?;
                let res = sage.endpoint(req) maybe_await;
                let value = res.map_err(|e| anyhow!("{e}"))?;
                serde_json::to_string(&value)
                    .map_err(|e| anyhow!("failed to serialize response: {e}"))
            },)
            other => Err(anyhow!("unknown endpoint: `{other}`")),
        }
    }
}

/// Handle to a running Sage wallet instance.
pub struct SageClient {
    sage: Arc<Mutex<Sage>>,
}

impl SageClient {
    /// Create and initialize a Sage wallet rooted at `data_dir`.
    ///
    /// This sets up the keychain, config, logging, peer sync manager and
    /// loads the active wallet (if a fingerprint was previously selected).
    /// `data_dir` should be an app-private, writable directory
    /// (e.g. `getApplicationSupportDirectory()` on Flutter).
    pub fn new_instance(data_dir: String) -> Result<SageClient> {
        install_crypto_provider();
        let path = PathBuf::from(data_dir);

        runtime().block_on(async move {
            let mut sage = Sage::new(&path, false);
            let mut receiver = sage.initialize().await?;
            sage.switch_wallet().await?;

            // Drain sync events so the bounded channel never stalls the
            // sync manager. (A typed event stream can be added later.)
            tokio::spawn(async move { while receiver.recv().await.is_some() {} });

            Ok(SageClient {
                sage: Arc::new(Mutex::new(sage)),
            })
        })
    }

    /// Invoke any Sage endpoint by name with a JSON request body, returning
    /// the JSON response. Endpoint names and payloads are identical to
    /// Sage's RPC API (see the vendored `endpoints.json`).
    pub fn call(&self, endpoint: String, request_json: String) -> Result<String> {
        let sage = self.sage.clone();
        runtime().block_on(async move {
            let mut guard = sage.lock().await;
            dispatch(&mut guard, &endpoint, &request_json).await
        })
    }
}

/// flutter_rust_bridge initialization hook.
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[cfg(test)]
mod tests {
    use super::*;

    /// End-to-end smoke test of the generic JSON passthrough: boot a real
    /// Sage instance in a temp dir and exercise a pure (offline) endpoint
    /// through the `impl_endpoints!`-generated dispatcher.
    #[test]
    fn generate_mnemonic_roundtrips_through_dispatch() {
        let dir = std::env::temp_dir().join(format!(
            "sage-fb-test-{}",
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));

        let client = SageClient::new_instance(dir.to_string_lossy().into_owned())
            .expect("Sage should initialize in a fresh data dir");

        let response = client
            .call(
                "generate_mnemonic".to_string(),
                r#"{"use_24_words": true}"#.to_string(),
            )
            .expect("generate_mnemonic should succeed");

        let parsed: serde_json::Value =
            serde_json::from_str(&response).expect("response must be JSON");
        let mnemonic = parsed["mnemonic"]
            .as_str()
            .expect("response must contain a mnemonic string");
        assert_eq!(mnemonic.split_whitespace().count(), 24);

        // Unknown endpoints must produce a clean error, not a panic.
        let err = client
            .call("not_a_real_endpoint".to_string(), "{}".to_string())
            .unwrap_err();
        assert!(err.to_string().contains("unknown endpoint"));

        let _ = std::fs::remove_dir_all(&dir);
    }
}
