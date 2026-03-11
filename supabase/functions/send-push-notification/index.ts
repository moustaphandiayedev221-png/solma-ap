// Envoie les notifications push via FCM HTTP v1 (payload riche, deep linking).
// Secrets: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY

import * as jose from "npm:jose@5.2.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FIREBASE_CLIENT_EMAIL = Deno.env.get("FIREBASE_CLIENT_EMAIL");
const FIREBASE_PRIVATE_KEY = Deno.env.get("FIREBASE_PRIVATE_KEY");

interface ExtractedPayload {
  title: string;
  body: string;
  target_type: string;
  target_user_id?: string;
  data?: Record<string, string>;
  category?: string;
  deep_link?: string;
  image_url?: string;
}

function extractPayload(body: unknown): ExtractedPayload | null {
  const obj = body as Record<string, unknown>;
  // Format webhook (Database Webhook)
  if (obj.type === "INSERT" && obj.table === "notifications" && obj.record) {
    const r = obj.record as Record<string, unknown>;
    const title = r.title as string;
    const body = r.body as string;
    const targetType = r.target_type as string;
    const targetUserId = r.target_user_id as string | undefined;
    if (!title || !body || !targetType) return null;
    const data = r.data as Record<string, unknown> | undefined;
    const dataStr: Record<string, string> = {};
    if (data) {
      for (const [k, v] of Object.entries(data)) {
        if (v != null) dataStr[k] = String(v);
      }
    }
    const deepLink = (r.deep_link as string) ?? data?.deep_link as string | undefined;
    const category = (r.category as string) ?? data?.category as string | undefined;
    const imageUrl = (r.image_url as string) ?? data?.image_url as string | undefined;
    if (deepLink) dataStr["deep_link"] = deepLink;
    if (category) dataStr["category"] = category;
    if (imageUrl) dataStr["image_url"] = imageUrl;
    return {
      title,
      body,
      target_type: targetType,
      target_user_id: targetUserId,
      data: Object.keys(dataStr).length > 0 ? dataStr : undefined,
      category,
      deep_link: deepLink,
      image_url: imageUrl,
    };
  }
  // Format appel direct (functions.invoke)
  const title = obj.title as string;
  const body = obj.body as string;
  const targetType = obj.target_type as string;
  const targetUserId = obj.target_user_id as string | undefined;
  if (!title || !body || !targetType) return null;
  const data = obj.data as Record<string, unknown> | undefined;
  const dataStr: Record<string, string> = {};
  if (data) {
    for (const [k, v] of Object.entries(data)) {
      if (v != null) dataStr[k] = String(v);
    }
  }
  const deepLink = (obj.deep_link as string) ?? data?.deep_link as string | undefined;
  const category = (obj.category as string) ?? data?.category as string | undefined;
  const imageUrl = (obj.image_url as string) ?? data?.image_url as string | undefined;
  if (deepLink) dataStr["deep_link"] = deepLink;
  if (category) dataStr["category"] = category;
  if (imageUrl) dataStr["image_url"] = imageUrl;
  return {
    title,
    body,
    target_type: targetType,
    target_user_id: targetUserId,
    data: Object.keys(dataStr).length > 0 ? dataStr : undefined,
    category,
    deep_link: deepLink,
    image_url: imageUrl,
  };
}

function channelForCategory(category?: string): string {
  if (!category) return "colways_notifications";
  const c = category.toLowerCase();
  if (c.includes("order") || c.includes("shipped") || c.includes("delivered"))
    return "colways_orders";
  if (c.includes("promo") || c.includes("cart")) return "colways_promos";
  return "colways_notifications";
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
    const reqBody = await req.json();
    const extracted = extractPayload(reqBody);
    if (!extracted) {
      return new Response(
        JSON.stringify({ error: "title, body, target_type required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
    const { title, body, target_type, target_user_id, data, category } = extracted;

    if (!FIREBASE_PROJECT_ID || !FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
      return new Response(
        JSON.stringify({
          error: "FCM v1 not configured. Set FIREBASE_* secrets.",
        }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    let url = `${SUPABASE_URL}/rest/v1/user_fcm_tokens?select=token`;
    if (target_type === "user" && target_user_id) {
      url += `&user_id=eq.${target_user_id}`;
    }

    const tokensRes = await fetch(url, {
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      },
    });
    if (!tokensRes.ok) {
      return new Response(
        JSON.stringify({ error: "Failed to fetch tokens", detail: await tokensRes.text() }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
    const tokensData = await tokensRes.json();
    const tokens: string[] = Array.isArray(tokensData)
      ? tokensData.map((r: { token: string }) => r.token).filter(Boolean)
      : [];

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ ok: true, sent: 0, message: "No tokens to send" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    const channelId = channelForCategory(category);
    const fcmData: Record<string, string> = { title, body, ...(data || {}) };

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
            data: fcmData,
            android: {
              priority: "high",
              notification: {
                channel_id: channelId,
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
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
