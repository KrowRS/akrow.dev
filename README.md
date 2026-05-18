
Dynamic FFXIV content signup board with a Svelte frontend, Cloudflare Worker API, Hono, and Supabase.

## Setup

1. Install dependencies:

   ```sh
   npm install
   ```

2. Apply the Supabase schema and seed:

   ```sh
   npm run generate:seed
   supabase db push
   supabase db execute --file supabase/seed.sql
   ```

   Or run `supabase/migrations/0001_schema.sql` and the generated `supabase/seed.sql` in the Supabase SQL editor.

   Content seed data lives in `data/content.json`. Edit that file for future/past expansion content, then run `npm run generate:seed`.

   The deep dungeon spreadsheet schema and initial rows live in `supabase/migrations/0002_deep_dungeon_progress.sql`.

3. Configure Worker secrets:

   ```sh
   wrangler secret put SUPABASE_URL
   wrangler secret put SUPABASE_SERVICE_ROLE_KEY
   wrangler secret put SITE_PASSWORD
   wrangler secret put SESSION_SECRET
   ```

   `SITE_PASSWORD` is the shared password visitors enter. `SESSION_SECRET` should be a long random string used to sign login cookies.

4. Run locally in two terminals:

   ```sh
   npm run dev:worker
   npm run dev
   ```

The Vite dev server proxies `/api` requests to the Worker on `localhost:8787`.

## Deploy behind Cloudflare

Build the Svelte app first, then deploy the Worker. The Worker serves both the built app from `dist/` and the API.

```sh
npm run build
npx wrangler deploy
```

In Cloudflare, add your custom domain/route to this Worker. If your domain is registered at Porkbun, either move DNS to Cloudflare nameservers or point the relevant DNS record to Cloudflare according to the route you choose. Once deployed with `SITE_PASSWORD` and `SESSION_SECRET` set, visitors see a password screen before the app or API data loads.

## Checks

```sh
npm run check
npm run typecheck:worker
npm run build
```
