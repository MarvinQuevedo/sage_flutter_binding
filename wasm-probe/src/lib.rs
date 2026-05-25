use chia_sdk_coinset::{ChiaRpcClient, CoinsetClient};
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub async fn peak_height() -> Result<u32, JsValue> {
    let client = CoinsetClient::mainnet();
    let state = client
        .get_blockchain_state()
        .await
        .map_err(|e| JsValue::from_str(&e.to_string()))?;
    state
        .blockchain_state
        .map(|s| s.peak.height)
        .ok_or_else(|| JsValue::from_str("no peak"))
}
