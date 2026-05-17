# Stroodlenoodle

Dynamic FFXIV content signup board with a Svelte frontend, Cloudflare Worker API, Hono, and Supabase.

## Setup

1. Install dependencies:

   ```sh
   npm install
   ```

2. Apply the Supabase schema and seed:

   ```sh
   supabase db push
   supabase db execute --file supabase/seed.sql
   ```

   Or run `supabase/migrations/0001_schema.sql` and `supabase/seed.sql` in the Supabase SQL editor.

3. Configure Worker secrets:

   ```sh
   wrangler secret put SUPABASE_URL
   wrangler secret put SUPABASE_SERVICE_ROLE_KEY
   ```

4. Run locally in two terminals:

   ```sh
   npm run dev:worker
   npm run dev
   ```

The Vite dev server proxies `/api` requests to the Worker on `localhost:8787`.

## Checks

```sh
npm run check
npm run typecheck:worker
npm run build
```
