import { Hono } from "hono";
import { cors } from "hono/cors";
import type {
  ContentCategoryGroup,
  ContentItem,
  ContentResponse,
  ExpansionGroup,
  RoleEntries,
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

interface SupabaseExpansionRow {
  id: string;
  name: string;
  short_name: string;
  release_order: number;
}

interface SupabaseCategoryRow {
  id: string;
  name: string;
  sort_order: number;
}

interface SupabaseContentRow {
  id: string;
  expansion_id: string;
  category_id: string;
  name: string;
  short_name: string | null;
  sort_order: number;
}

interface SupabaseEntryRow {
  content_id: string;
  role: SignupRole;
  created_at: string;
  updated_at: string;
  users: {
    ign: string;
    ign_normalized: string;
  };
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

app.get("/api/content", async (c) => {
  const content = await getContent(c.env);
  return c.json(content);
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

  const content = await getContent(c.env);
  return c.json(content);
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

async function getContent(env: Env): Promise<ContentResponse> {
  const [expansions, categories, content, entries] = await Promise.all([
    supabaseSelect<SupabaseExpansionRow[]>(
      env,
      "/rest/v1/expansions?select=id,name,short_name,release_order&is_active=eq.true&order=release_order.asc",
    ),
    supabaseSelect<SupabaseCategoryRow[]>(
      env,
      "/rest/v1/content_categories?select=id,name,sort_order&is_active=eq.true&order=sort_order.asc",
    ),
    supabaseSelect<SupabaseContentRow[]>(
      env,
      "/rest/v1/content?select=id,expansion_id,category_id,name,short_name,sort_order&is_active=eq.true&order=sort_order.asc",
    ),
    supabaseSelect<SupabaseEntryRow[]>(
      env,
      "/rest/v1/content_roles?select=content_id,role,created_at,updated_at,users!inner(ign,ign_normalized)",
    ),
  ]);
  console.log(expansions, categories, content, entries);
  return buildContentResponse(expansions, categories, content, entries);
}

function buildContentResponse(
  expansionRows: SupabaseExpansionRow[],
  categoryRows: SupabaseCategoryRow[],
  contentRows: SupabaseContentRow[],
  entryRows: SupabaseEntryRow[],
): ContentResponse {
  const entriesByContent = new Map<string, RoleEntries>();

  for (const item of contentRows) {
    entriesByContent.set(item.id, emptyRoleEntries());
  }

  for (const entry of entryRows) {
    const contentEntries = entriesByContent.get(entry.content_id);
    if (!contentEntries || !roles.includes(entry.role)) {
      continue;
    }

    contentEntries[entry.role].push({
      ign: entry.users.ign,
      createdAt: entry.created_at,
      updatedAt: entry.updated_at,
    });
  }

  for (const contentEntries of entriesByContent.values()) {
    for (const role of roles) {
      contentEntries[role].sort((left, right) =>
        left.ign.localeCompare(right.ign),
      );
    }
  }

  const contentByExpansionAndCategory = new Map<string, ContentItem[]>();

  for (const item of contentRows) {
    const key = groupKey(item.expansion_id, item.category_id);
    const group = contentByExpansionAndCategory.get(key) ?? [];
    group.push({
      id: item.id,
      name: item.name,
      shortName: item.short_name,
      sortOrder: item.sort_order,
      entries: entriesByContent.get(item.id) ?? emptyRoleEntries(),
    });
    contentByExpansionAndCategory.set(key, group);
  }

  const expansions: ExpansionGroup[] = [];

  for (const expansion of expansionRows) {
    const groupedCategories: ContentCategoryGroup[] = [];

    for (const category of categoryRows) {
      const contents =
        contentByExpansionAndCategory.get(
          groupKey(expansion.id, category.id),
        ) ?? [];
      if (contents.length === 0) {
        continue;
      }

      groupedCategories.push({
        id: category.id,
        name: category.name,
        sortOrder: category.sort_order,
        contents: contents.sort(
          (left, right) => left.sortOrder - right.sortOrder,
        ),
      });
    }

    if (groupedCategories.length === 0) {
      continue;
    }

    expansions.push({
      id: expansion.id,
      name: expansion.name,
      shortName: expansion.short_name,
      releaseOrder: expansion.release_order,
      categories: groupedCategories,
    });
  }

  return { expansions };
}

function emptyRoleEntries(): RoleEntries {
  return {
    helper: [],
    derust: [],
    learner: [],
  };
}

function groupKey(expansionId: string, categoryId: string): string {
  return `${expansionId}:${categoryId}`;
}

async function supabaseSelect<T>(env: Env, path: string): Promise<T> {
  const response = await fetch(`${env.SUPABASE_URL}${path}`, {
    headers: {
      apikey: env.SUPABASE_SERVICE_ROLE_KEY,
      authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });

  const payload = (await response.json().catch(() => null)) as
    | T
    | SupabaseRpcError
    | null;

  if (!response.ok) {
    const error = payload as SupabaseRpcError | null;
    throw new Error(error?.message || "Supabase request failed.");
  }

  return payload as T;
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
