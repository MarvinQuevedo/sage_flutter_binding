import { useEffect, useState } from "react";
import { callEngine, setActiveWallet } from "../../src/popup/engine-client";

interface VersionInfo {
  engine: string;
  sage_api: string;
}

interface DeriveResult {
  address: string;
  puzzle_hash: string;
  public_key: string;
  index: number;
  testnet: boolean;
}

const DEMO_MNEMONIC =
  "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";

export function App() {
  const [version, setVersion] = useState<VersionInfo | null>(null);
  const [ping, setPing] = useState<string>("pending");
  const [bootError, setBootError] = useState<string | null>(null);

  const [mnemonic, setMnemonic] = useState<string>(DEMO_MNEMONIC);
  const [derived, setDerived] = useState<DeriveResult | null>(null);
  const [deriving, setDeriving] = useState(false);
  const [deriveError, setDeriveError] = useState<string | null>(null);
  const [testnet, setTestnet] = useState(false);

  useEffect(() => {
    void (async () => {
      try {
        // Boot a dev wallet id so the engine can open IndexedDB.
        // In production this comes from the unlock flow.
        await setActiveWallet("dev-default");

        const [v, p] = await Promise.all([
          callEngine<VersionInfo>("version"),
          callEngine<{ pong: boolean }>("ping"),
        ]);
        setVersion(v);
        setPing(p.pong ? "pong" : "no-pong");
      } catch (err) {
        setBootError((err as Error).message ?? String(err));
      }
    })();
  }, []);

  const onDerive = async () => {
    setDeriving(true);
    setDeriveError(null);
    setDerived(null);
    try {
      const res = await callEngine<DeriveResult>("derive_address", {
        mnemonic: mnemonic.trim(),
        index: 0,
        testnet,
      });
      setDerived(res);
    } catch (err) {
      setDeriveError((err as Error).message ?? String(err));
    } finally {
      setDeriving(false);
    }
  };

  return (
    <div className="ozone-popup">
      <header className="ozone-header">
        <span className="ozone-logo">Ozone</span>
        <span className="ozone-meta">
          {version ? `engine ${version.engine} · sage ${version.sage_api}` : "loading…"}
        </span>
      </header>
      <main>
        <section className="screen">
          <h1>Engine status</h1>
          {bootError && <p className="error">Boot failed: {bootError}</p>}
          {!bootError && (
            <ul className="status-list">
              <li>
                <span className="muted">ping</span>{" "}
                <span className={ping === "pong" ? "ok" : "muted"}>{ping}</span>
              </li>
              <li>
                <span className="muted">engine</span>{" "}
                <span>{version?.engine ?? "—"}</span>
              </li>
              <li>
                <span className="muted">sage-api</span>{" "}
                <span>{version?.sage_api ?? "—"}</span>
              </li>
            </ul>
          )}
        </section>

        <section className="screen">
          <h2>Derive address</h2>
          <p className="muted">
            BIP-39 mnemonic → BLS unhardened derivation → synthetic key →
            bech32m. End-to-end through the WASM engine.
          </p>
          <textarea
            value={mnemonic}
            onChange={(e) => setMnemonic(e.target.value)}
            rows={3}
            spellCheck={false}
          />
          <label className="checkbox">
            <input
              type="checkbox"
              checked={testnet}
              onChange={(e) => setTestnet(e.target.checked)}
            />
            <span>testnet</span>
          </label>
          <button onClick={onDerive} disabled={deriving || !mnemonic.trim()}>
            {deriving ? "Deriving…" : "Derive index 0"}
          </button>
          {deriveError && <p className="error">{deriveError}</p>}
          {derived && (
            <div className="result">
              <div>
                <span className="muted">address</span>
                <code>{derived.address}</code>
              </div>
              <div>
                <span className="muted">puzzle hash</span>
                <code>{derived.puzzle_hash}</code>
              </div>
              <div>
                <span className="muted">pubkey</span>
                <code>{derived.public_key}</code>
              </div>
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
