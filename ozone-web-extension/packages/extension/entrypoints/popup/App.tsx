import { useEffect, useState } from "react";

type View = "lock" | "onboarding" | "home";

export function App() {
  const [view, setView] = useState<View>("lock");

  useEffect(() => {
    void (async () => {
      const { hasWallet } = await chrome.storage.local.get("hasWallet");
      const { unlocked } = await chrome.storage.session.get("unlocked");
      if (!hasWallet) setView("onboarding");
      else if (unlocked) setView("home");
      else setView("lock");
    })();
  }, []);

  return (
    <div className="ozone-popup">
      <header className="ozone-header">
        <span className="ozone-logo">Ozone</span>
      </header>
      <main>
        {view === "lock" && <LockScreen onUnlock={() => setView("home")} />}
        {view === "onboarding" && <OnboardingScreen onDone={() => setView("home")} />}
        {view === "home" && <HomeScreen />}
      </main>
    </div>
  );
}

function LockScreen({ onUnlock }: { onUnlock: () => void }) {
  return (
    <section className="screen">
      <h1>Unlock</h1>
      <p className="muted">Wallet UI not implemented yet.</p>
      <button onClick={onUnlock}>Skip (dev)</button>
    </section>
  );
}

function OnboardingScreen({ onDone }: { onDone: () => void }) {
  return (
    <section className="screen">
      <h1>Welcome to Ozone</h1>
      <p className="muted">Create or import a wallet. (Not implemented yet.)</p>
      <button onClick={onDone}>Skip (dev)</button>
    </section>
  );
}

function HomeScreen() {
  return (
    <section className="screen">
      <h1>0.0000 XCH</h1>
      <p className="muted">Sync stub — not wired to WASM yet.</p>
      <nav className="actions">
        <button>Send</button>
        <button>Receive</button>
      </nav>
    </section>
  );
}
