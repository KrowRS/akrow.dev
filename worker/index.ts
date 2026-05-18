import { Hono } from "hono";
import { cors } from "hono/cors";
import { setCookie } from "hono/cookie";
import type {
  ContentCategoryGroup,
  DeepDungeonRow,
  SubmitEntriesRequest,
  SignupRole,
  SubmitEntryRequest,
} from "../src/lib/types";

interface Env {
  SUPABASE_URL: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
  FRONTEND_ORIGIN?: string;
  SITE_PASSWORD?: string;
  SESSION_SECRET?: string;
  ASSETS: Fetcher;
}

interface SupabaseRpcError {
  code?: string;
  details?: string;
  hint?: string;
  message?: string;
}

const roles: SignupRole[] = ["helper", "derust", "learner"];
const sessionCookieName = "stroodle_session";
const sessionMaxAgeSeconds = 60 * 60 * 24 * 7;

const app = new Hono<{ Bindings: Env }>();

app.use(
  "/api/*",
  cors({
    origin: (origin, c) => c.env.FRONTEND_ORIGIN || origin || "*",
    allowMethods: ["GET", "PUT", "OPTIONS"],
    allowHeaders: ["content-type"],
    credentials: true,
  }),
);

app.post("/api/login", async (c) => {
  if (!isAuthConfigured(c.env)) {
    return c.json({ ok: true });
  }

  let payload: { password?: string };

  try {
    payload = await c.req.json();
  } catch {
    return c.json({ error: "Request body must be valid JSON." }, 400);
  }

  if (payload.password !== c.env.SITE_PASSWORD) {
    return c.json({ error: "Invalid password." }, 401);
  }

  setCookie(c, sessionCookieName, await createSessionToken(c.env), {
    httpOnly: true,
    maxAge: sessionMaxAgeSeconds,
    path: "/",
    sameSite: "Lax",
    secure: new URL(c.req.url).protocol === "https:",
  });

  return c.json({ ok: true });
});

app.post("/api/logout", (c) => {
  setCookie(c, sessionCookieName, "", {
    httpOnly: true,
    maxAge: 0,
    path: "/",
    sameSite: "Lax",
    secure: new URL(c.req.url).protocol === "https:",
  });

  return c.json({ ok: true });
});

app.get("/api/session", async (c) => {
  return c.json({ authenticated: await hasValidSession(c.req.raw, c.env) });
});

app.use("/api/*", async (c, next) => {
  if (["/api/login", "/api/logout", "/api/session"].includes(c.req.path)) {
    return next();
  }

  if (!(await hasValidSession(c.req.raw, c.env))) {
    return c.json({ error: "Unauthorized." }, 401);
  }

  return next();
});

app.get("/api/content/ultimates", async (c) => {
  const category = await getCategory(c.env, "list_ultimate_content", {});
  return c.json(category);
});

app.get("/api/content/extremes", async (c) => {
  const expansionId = c.req.query("expansionId") || "dawntrail";
  const category = await getCategory(c.env, "list_extreme_content", {
    p_expansion_id: expansionId,
  });
  return c.json(category);
});

app.get("/api/content/savages", async (c) => {
  const expansionId = c.req.query("expansionId") || "dawntrail";
  const category = await getCategory(c.env, "list_savage_content", {
    p_expansion_id: expansionId,
  });
  return c.json(category);
});

app.get("/api/deep-dungeon-progress", async (c) => {
  const result = await supabaseRpc<DeepDungeonRow[]>(
    c.env,
    "list_deep_dungeon_progress",
    {},
  );

  if (!result.ok) {
    return c.json(
      { error: result.error.message || "Unable to load deep dungeon progress." },
      500,
    );
  }

  return c.json(result.data);
});

app.put("/api/entries", async (c) => {
  let payload: SubmitEntryRequest;

  try {
    payload = await c.req.json();
  } catch {
    return c.json({ error: "Request body must be valid JSON." }, 400);
  }

  const validationError = validateEntry(payload);
  if (validationError) {
    return c.json({ error: validationError }, 400);
  }

  const result = await supabaseRpc(c.env, "submit_content_role", {
    p_content_id: payload.contentId,
    p_ign: payload.ign,
    p_role: payload.role,
  });

  if (!result.ok) {
    const status = result.error.code === "P0001" ? 400 : 500;
    return c.json(
      { error: result.error.message || "Unable to save entry." },
      status,
    );
  }

  return c.json({ ok: true });
});

app.put("/api/entries/batch", async (c) => {
  let payload: SubmitEntriesRequest;

  try {
    payload = await c.req.json();
  } catch {
    return c.json({ error: "Request body must be valid JSON." }, 400);
  }

  const validationError = validateEntries(payload);
  if (validationError) {
    return c.json({ error: validationError }, 400);
  }

  const result = await supabaseRpc(c.env, "submit_content_roles_batch", {
    p_ign: payload.ign,
    p_entries: payload.entries.map((entry) => ({
      contentId: entry.contentId,
      role: entry.role,
    })),
  });

  if (!result.ok) {
    const status = result.error.code === "P0001" ? 400 : 500;
    return c.json(
      { error: result.error.message || "Unable to save entries." },
      status,
    );
  }

  return c.json({ ok: true });
});

app.put("/api/deep-dungeon-progress", async (c) => {
  let payload: { rows?: DeepDungeonRow[] };

  try {
    payload = await c.req.json();
  } catch {
    return c.json({ error: "Request body must be valid JSON." }, 400);
  }

  const validationError = validateDeepDungeonRows(payload.rows);
  if (validationError) {
    return c.json({ error: validationError }, 400);
  }

  const result = await supabaseRpc(c.env, "replace_deep_dungeon_progress", {
    p_rows: payload.rows,
  });

  if (!result.ok) {
    const status = result.error.code === "P0001" ? 400 : 500;
    return c.json(
      { error: result.error.message || "Unable to save deep dungeon progress." },
      status,
    );
  }

  return c.json({ ok: true });
});

app.notFound((c) => c.json({ error: "Not found." }, 404));

app.get("*", async (c) => {
  if (!(await hasValidSession(c.req.raw, c.env))) {
    return c.html(loginPageHtml());
  }

  const assetResponse = await c.env.ASSETS.fetch(c.req.raw);

  if (assetResponse.status !== 404) {
    return assetResponse;
  }

  const indexUrl = new URL(c.req.url);
  indexUrl.pathname = "/index.html";
  return c.env.ASSETS.fetch(new Request(indexUrl, c.req.raw));
});

function validateEntry(payload: SubmitEntryRequest): string | null {
  if (!payload || typeof payload !== "object") {
    return "Request body is required.";
  }

  if (
    typeof payload.contentId !== "string" ||
    payload.contentId.trim().length === 0
  ) {
    return "contentId is required.";
  }

  if (typeof payload.ign !== "string" || payload.ign.trim().length === 0) {
    return "In-game username is required.";
  }

  if (payload.ign.trim().length > 64) {
    return "In-game username must be 64 characters or fewer.";
  }

  if (!roles.includes(payload.role)) {
    return "Role must be helper, derust, or learner.";
  }

  return null;
}

function validateEntries(payload: SubmitEntriesRequest): string | null {
  if (!payload || typeof payload !== "object") {
    return "Request body is required.";
  }

  if (typeof payload.ign !== "string" || payload.ign.trim().length === 0) {
    return "In-game username is required.";
  }

  if (payload.ign.trim().length > 64) {
    return "In-game username must be 64 characters or fewer.";
  }

  if (!Array.isArray(payload.entries) || payload.entries.length === 0) {
    return "At least one role selection is required.";
  }

  for (const entry of payload.entries) {
    if (
      !entry ||
      typeof entry.contentId !== "string" ||
      entry.contentId.trim().length === 0
    ) {
      return "Each entry must include a contentId.";
    }

    if (!roles.includes(entry.role)) {
      return "Each entry role must be helper, derust, or learner.";
    }
  }

  return null;
}

function validateDeepDungeonRows(rows: unknown): string | null {
  if (!Array.isArray(rows)) {
    return "rows must be an array.";
  }

  if (rows.length > 200) {
    return "Spreadsheet can include 200 rows or fewer.";
  }

  for (const row of rows) {
    if (!row || typeof row !== "object") {
      return "Each row must be an object.";
    }

    const candidate = row as Partial<DeepDungeonRow>;

    if (typeof candidate.name !== "string" || candidate.name.length > 64) {
      return "Each character name must be 64 characters or fewer.";
    }

    if (typeof candidate.palace !== "boolean") {
      return "Palace of the Dead must be true or false.";
    }

    for (const key of ["heaven", "eureka", "pilgrims"] as const) {
      if (typeof candidate[key] !== "string" || candidate[key]!.length > 8) {
        return "Progress values must be 8 characters or fewer.";
      }
    }
  }

  return null;
}

async function getCategory(
  env: Env,
  functionName: string,
  body: Record<string, unknown>,
): Promise<ContentCategoryGroup> {
  const result = await supabaseRpc<ContentCategoryGroup>(env, functionName, body);

  if (!result.ok) {
    throw new Error(result.error.message || "Unable to load content.");
  }

  return result.data;
}

async function supabaseRpc<T = unknown>(
  env: Env,
  functionName: string,
  body: Record<string, unknown>,
): Promise<{ ok: true; data: T } | { ok: false; error: SupabaseRpcError }> {
  const response = await fetch(
    `${env.SUPABASE_URL}/rest/v1/rpc/${functionName}`,
    {
      method: "POST",
      headers: {
        apikey: env.SUPABASE_SERVICE_ROLE_KEY,
        authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
        "content-type": "application/json",
      },
      body: JSON.stringify(body),
    },
  );

  const payload = (await response.json().catch(() => null)) as
    | T
    | SupabaseRpcError
    | null;

  if (!response.ok) {
    return {
      ok: false,
      error: (payload as SupabaseRpcError | null) || {
        message: "Supabase request failed.",
      },
    };
  }

  return { ok: true, data: payload as T };
}

function isAuthConfigured(env: Env) {
  return Boolean(env.SITE_PASSWORD && env.SESSION_SECRET);
}

async function hasValidSession(request: Request, env: Env) {
  if (!isAuthConfigured(env)) {
    return true;
  }

  const token = getCookieValue(request.headers.get("cookie") || "", sessionCookieName);
  if (!token) {
    return false;
  }

  return verifySessionToken(env, token);
}

async function createSessionToken(env: Env) {
  const issuedAt = Math.floor(Date.now() / 1000).toString();
  const signature = await signSessionValue(env, issuedAt);
  return `${issuedAt}.${signature}`;
}

async function verifySessionToken(env: Env, token: string) {
  const [issuedAt, signature] = token.split(".");
  const timestamp = Number(issuedAt);

  if (!issuedAt || !signature || !Number.isFinite(timestamp)) {
    return false;
  }

  if (Date.now() / 1000 - timestamp > sessionMaxAgeSeconds) {
    return false;
  }

  return signature === (await signSessionValue(env, issuedAt));
}

function getCookieValue(cookieHeader: string, name: string) {
  const cookie = cookieHeader
    .split(";")
    .map((part) => part.trim())
    .find((part) => part.startsWith(`${name}=`));

  return cookie ? decodeURIComponent(cookie.slice(name.length + 1)) : "";
}

async function signSessionValue(env: Env, value: string) {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(env.SESSION_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(value),
  );

  return base64UrlEncode(signature);
}

function base64UrlEncode(buffer: ArrayBuffer) {
  let binary = "";
  for (const byte of new Uint8Array(buffer)) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

function loginPageHtml() {
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Comfy Content Tracker</title>
    <style>
      :root { color-scheme: dark; font-family: Raleway, Arial, sans-serif; background: #060810; color: #d0daf0; }
      body { min-height: 100vh; display: grid; place-items: center; margin: 0; background: #060810; }
      form { width: min(360px, calc(100% - 32px)); border: 1px solid #1e2d4a; border-radius: 4px; padding: 24px; background: linear-gradient(135deg, rgba(11, 15, 26, 0.96), rgba(17, 24, 39, 0.96)); }
      h1 { margin: 0 0 18px; color: #e8c98a; font-family: Georgia, serif; font-size: 22px; letter-spacing: 2px; text-align: center; text-transform: uppercase; }
      label { display: grid; gap: 8px; color: #c8a96e; font-size: 11px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; }
      input { min-height: 42px; border: 1px solid #1e2d4a; border-radius: 3px; background: #060810; color: #d0daf0; padding: 9px 12px; font: inherit; outline: none; }
      input:focus { border-color: #1a3a6a; box-shadow: 0 0 0 2px rgba(74, 158, 255, 0.12); }
      button { width: 100%; min-height: 42px; margin-top: 16px; border: 1px solid #1a3a6a; border-radius: 3px; background: linear-gradient(135deg, #1a3a6a, #0f2248); color: #4a9eff; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; cursor: pointer; }
      p { min-height: 18px; margin: 12px 0 0; color: #e05050; font-size: 12px; text-align: center; }
    </style>
  </head>
  <body>
    <form id="login-form">
      <h1>Comfy Tracker</h1>
      <label>
        Password
        <input name="password" type="password" autocomplete="current-password" autofocus />
      </label>
      <button type="submit">Enter</button>
      <p id="message"></p>
    </form>
    <script>
      const form = document.getElementById('login-form');
      const message = document.getElementById('message');
      form.addEventListener('submit', async (event) => {
        event.preventDefault();
        message.textContent = '';
        const password = new FormData(form).get('password');
        const response = await fetch('/api/login', {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({ password })
        });
        if (response.ok) {
          location.reload();
          return;
        }
        message.textContent = 'Invalid password.';
      });
    </script>
  </body>
</html>`;
}

export default app;
