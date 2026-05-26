import { useEffect, useState } from "react";
import type { ApprovalMessage, ApprovalResponse, PendingRequest } from "../../src/background/approval";

const PARAMS = new URLSearchParams(window.location.search);
const REQUEST_ID = PARAMS.get("id") ?? "";

async function fetchPending(): Promise<PendingRequest | null> {
  const msg: ApprovalMessage = { from: "approval", kind: "fetch", id: REQUEST_ID };
  const res = (await chrome.runtime.sendMessage(msg)) as ApprovalResponse;
  if (!res.ok || !res.request) return null;
  return res.request;
}

async function decide(approved: boolean): Promise<void> {
  const msg: ApprovalMessage = { from: "approval", kind: "decide", id: REQUEST_ID, approved };
  await chrome.runtime.sendMessage(msg);
  window.close();
}

export function ApproveApp() {
  const [request, setRequest] = useState<PendingRequest | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    void (async () => {
      const r = await fetchPending();
      setRequest(r);
      setLoading(false);
    })();
  }, []);

  if (loading) {
    return (
      <div className="ozone-popup">
        <main>
          <section className="screen">
            <p className="muted">Loading…</p>
          </section>
        </main>
      </div>
    );
  }

  if (!request) {
    return (
      <div className="ozone-popup">
        <header className="ozone-header">
          <span className="ozone-logo">Ozone</span>
        </header>
        <main>
          <section className="screen">
            <h1>Request expired</h1>
            <p className="muted">
              This approval request is no longer pending. You can close this window.
            </p>
            <button onClick={() => window.close()}>Close</button>
          </section>
        </main>
      </div>
    );
  }

  return (
    <div className="ozone-popup">
      <header className="ozone-header">
        <span className="ozone-logo">Ozone</span>
        <span className="ozone-meta">{request.method}</span>
      </header>
      <main>
        <section className="screen">
          <h1>{titleForMethod(request.method)}</h1>
          <p className="muted">
            <strong>{request.origin}</strong> is requesting permission.
          </p>

          <SummaryFor request={request} />

          <details>
            <summary>Raw params</summary>
            <pre className="params-raw">
              {JSON.stringify(request.params, null, 2)}
            </pre>
          </details>

          <div className="row">
            <button onClick={() => void decide(false)}>Reject</button>
            <button onClick={() => void decide(true)} className="approve-btn">
              Approve
            </button>
          </div>
        </section>
      </main>
    </div>
  );
}

function titleForMethod(method: string): string {
  switch (method) {
    case "connect":
      return "Connect wallet";
    case "signCoinSpends":
      return "Sign coin spends";
    case "signMessage":
      return "Sign message";
    case "transfer":
      return "Send transfer";
    case "sendTransaction":
      return "Send transaction";
    case "createOffer":
      return "Create offer";
    case "takeOffer":
      return "Take offer";
    case "walletSwitchChain":
      return "Switch network";
    case "walletWatchAsset":
      return "Watch asset";
    default:
      return method;
  }
}

function SummaryFor({ request }: { request: PendingRequest }) {
  const params = request.params as Record<string, unknown> | null;

  switch (request.method) {
    case "connect":
      return (
        <p>This site wants to see your wallet's public addresses and balances.</p>
      );

    case "signMessage": {
      const message = params?.message;
      return (
        <div className="result">
          <div>
            <span className="muted">message (hex)</span>
            <code>{String(message ?? "")}</code>
          </div>
        </div>
      );
    }

    case "transfer": {
      const to = params?.to;
      const amount = params?.amount;
      const assetId = params?.assetId;
      const fee = params?.fee;
      return (
        <div className="result">
          <div>
            <span className="muted">to</span>
            <code>{String(to ?? "")}</code>
          </div>
          <div>
            <span className="muted">amount</span>
            <code>{String(amount ?? "")}</code>
          </div>
          <div>
            <span className="muted">asset id</span>
            <code>{String(assetId ?? "(XCH)")}</code>
          </div>
          {fee != null && (
            <div>
              <span className="muted">fee</span>
              <code>{String(fee)}</code>
            </div>
          )}
        </div>
      );
    }

    default:
      return null;
  }
}
