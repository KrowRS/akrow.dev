import { Hono } from "hono";
import { cors } from "hono/cors";
import type {
  ContentCategoryGroup,
  SignupRole,
  SubmitEntryRequest,
} from "../src/lib/types";

interface Env {
  SUPABASE_URL: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
  FRONTEND_ORIGIN?: string;
}

interface SupabaseRpcError {
  code?: string;
  details?: string;
  hint?: string;
  message?: string;
}

const roles: SignupRole[] = ["helper", "derust", "learner"];

const app = new Hono<{ Bindings: Env }>();

app.use(
  "/api/*",
  cors({
    origin: (origin, c) => c.env.FRONTEND_ORIGIN || origin || "*",
    allowMethods: ["GET", "PUT", "OPTIONS"],
    allowHeaders: ["content-type"],
  }),
);

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

app.notFound((c) => c.json({ error: "Not found." }, 404));

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

export default app;
