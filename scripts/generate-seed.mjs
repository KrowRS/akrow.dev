import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(fileURLToPath(new URL('..', import.meta.url)));
const inputPath = resolve(root, 'data/content.json');
const outputPath = resolve(root, 'supabase/seed.sql');

const data = JSON.parse(await readFile(inputPath, 'utf8'));

validateData(data);

const sql = [
  generateExpansions(data.expansions),
  generateCategories(data.categories),
  generateContent(data.content)
].join('\n\n');

await mkdir(dirname(outputPath), { recursive: true });
await writeFile(outputPath, `${sql}\n`, 'utf8');

function generateExpansions(expansions) {
  return `insert into expansions (id, name, short_name, release_order)
values
${expansions.map((expansion) => `  (${sqlString(expansion.id)}, ${sqlString(expansion.name)}, ${sqlString(expansion.shortName)}, ${sqlNumber(expansion.releaseOrder)})`).join(',\n')}
on conflict (id) do update set
  name = excluded.name,
  short_name = excluded.short_name,
  release_order = excluded.release_order,
  is_active = true;`;
}

function generateCategories(categories) {
  return `insert into content_categories (id, name, sort_order)
values
${categories.map((category) => `  (${sqlString(category.id)}, ${sqlString(category.name)}, ${sqlNumber(category.sortOrder)})`).join(',\n')}
on conflict (id) do update set
  name = excluded.name,
  sort_order = excluded.sort_order,
  is_active = true;`;
}

function generateContent(content) {
  return `insert into content (id, expansion_id, category_id, name, short_name, sort_order)
values
${content.map((item) => `  (${sqlString(item.id)}, ${sqlString(item.expansionId)}, ${sqlString(item.categoryId)}, ${sqlString(item.name)}, ${sqlNullableString(item.shortName)}, ${sqlNumber(item.sortOrder)})`).join(',\n')}
on conflict (id) do update set
  expansion_id = excluded.expansion_id,
  category_id = excluded.category_id,
  name = excluded.name,
  short_name = excluded.short_name,
  sort_order = excluded.sort_order,
  is_active = true;`;
}

function validateData(data) {
  if (!Array.isArray(data.expansions) || !Array.isArray(data.categories) || !Array.isArray(data.content)) {
    throw new Error('content.json must include expansions, categories, and content arrays.');
  }

  const expansionIds = new Set(data.expansions.map((expansion) => expansion.id));
  const categoryIds = new Set(data.categories.map((category) => category.id));
  const contentIds = new Set();

  for (const expansion of data.expansions) {
    requireString(expansion.id, 'expansion.id');
    requireString(expansion.name, `${expansion.id}.name`);
    requireString(expansion.shortName, `${expansion.id}.shortName`);
    requireInteger(expansion.releaseOrder, `${expansion.id}.releaseOrder`);
  }

  for (const category of data.categories) {
    requireString(category.id, 'category.id');
    requireString(category.name, `${category.id}.name`);
    requireInteger(category.sortOrder, `${category.id}.sortOrder`);
  }

  for (const item of data.content) {
    requireString(item.id, 'content.id');
    requireString(item.expansionId, `${item.id}.expansionId`);
    requireString(item.categoryId, `${item.id}.categoryId`);
    requireString(item.name, `${item.id}.name`);
    requireInteger(item.sortOrder, `${item.id}.sortOrder`);

    if (contentIds.has(item.id)) {
      throw new Error(`Duplicate content id: ${item.id}`);
    }

    if (!expansionIds.has(item.expansionId)) {
      throw new Error(`Unknown expansionId for ${item.id}: ${item.expansionId}`);
    }

    if (!categoryIds.has(item.categoryId)) {
      throw new Error(`Unknown categoryId for ${item.id}: ${item.categoryId}`);
    }

    contentIds.add(item.id);
  }
}

function requireString(value, label) {
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`${label} must be a non-empty string.`);
  }
}

function requireInteger(value, label) {
  if (!Number.isInteger(value)) {
    throw new Error(`${label} must be an integer.`);
  }
}

function sqlString(value) {
  return `'${value.replaceAll("'", "''")}'`;
}

function sqlNullableString(value) {
  return value === null || value === undefined ? 'null' : sqlString(value);
}

function sqlNumber(value) {
  if (!Number.isInteger(value)) {
    throw new Error(`Expected integer, received ${value}`);
  }

  return String(value);
}
