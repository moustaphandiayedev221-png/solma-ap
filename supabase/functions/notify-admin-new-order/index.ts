// Envoie une notification push aux admins lorsqu'une nouvelle commande est créée.
// Déclenché par Database Webhook sur orders INSERT.
// Secrets requis : FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY

import * as jose from "npm:jose@5.2.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FIREBASE_CLIENT_EMAIL = Deno.env.get("FIREBASE_CLIENT_EMAIL");
const FIREBASE_PRIVATE_KEY = Deno.env.get("FIREBASE_PRIVATE_KEY");

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: {
    id: string;
    total?: number;
    user_id?: string;
    [key: string]: unknown;
  };
}

async function getAccessToken(): Promise<string> {
  if (!FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
    throw new Error("FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY required");
  }
  const privateKey = FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n");
  const key = await jose.importPKCS8(privateKey, "RS256");
  const jwt = await new jose.SignJWT({})
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(FIREBASE_CLIENT_EMAIL)
    .setSubject(FIREBASE_CLIENT_EMAIL)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(Math.floor(Date.now() / 1000))
    .setExpirationTime("1h")
    .sign(key);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`OAuth failed: ${res.status} ${text}`);
  }
  const data = await res.json();
  return data.access_token;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const payload: WebhookPayload = await req.json();
    if (payload.type !== "INSERT" || payload.table !== "orders") {
      return new Response(
        JSON.stringify({ ok: true, message: "Ignored: not an order insert" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    const record = payload.record;
    const orderId = record.id;
    const total = (record.total as number) ?? 0;
    const shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
    const totalStr = total.toFixed(2);
    const title = "Nouvelle commande";
    const body = `Commande #${shortId} - ${totalStr} €`;

    if (!FIREBASE_PROJECT_ID || !FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
      console.error("FCM not configured. Set FIREBASE_* secrets.");
      return new Response(
        JSON.stringify({ error: "FCM not configured" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    const tokensRes = await fetch(
      `${SUPABASE_URL}/rest/v1/admin_fcm_tokens?select=token`,
      {
        headers: {
          apikey: SUPABASE_SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
      }
    );

    if (!tokensRes.ok) {
      return new Response(
        JSON.stringify({
          error: "Failed to fetch admin tokens",
          detail: await tokensRes.text(),
        }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    const tokensData = await tokensRes.json();
    const tokens: string[] = Array.isArray(tokensData)
      ? tokensData.map((r: { token: string }) => r.token).filter(Boolean)
      : [];

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ ok: true, sent: 0, message: "No admin tokens" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    const accessToken = await getAccessToken();
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;

    let sent = 0;
    for (const token of tokens) {
      const fcmRes = await fetch(fcmUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body },
            data: {
              type: "new_order",
              order_id: orderId,
              total: totalStr,
            },
            android: {
              priority: "high",
              notification: {
                channel_id: "admin_new_orders",
                priority: "high",
              },
            },
          },
        }),
      });
      if (fcmRes.ok) sent += 1;
    }

    return new Response(
      JSON.stringify({ ok: true, sent, total: tokens.length }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("notify-admin-new-order error:", e);
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
