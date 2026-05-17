create extension if not exists pgcrypto;

do $$
begin
  create type signup_role as enum ('helper', 'derust', 'learner');
exception
  when duplicate_object then null;
end $$;

create table if not exists expansions (
  id text primary key,
  name text not null,
  short_name text not null,
  release_order integer not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists content_categories (
  id text primary key,
  name text not null,
  sort_order integer not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists content (
  id text primary key,
  expansion_id text not null references expansions(id),
  category_id text not null references content_categories(id),
  name text not null,
  short_name text,
  sort_order integer not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (expansion_id, category_id, sort_order)
);

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  ign text not null,
  ign_normalized text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists content_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  content_id text not null references content(id) on delete cascade,
  role signup_role not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, content_id)
);

create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists users_set_updated_at on users;
create trigger users_set_updated_at
before update on users
for each row execute function set_updated_at();

drop trigger if exists content_roles_set_updated_at on content_roles;
create trigger content_roles_set_updated_at
before update on content_roles
for each row execute function set_updated_at();

create or replace function normalize_ign(value text)
returns text
language sql
immutable
as $$
  select lower(regexp_replace(btrim(value), '\s+', ' ', 'g'));
$$;

create or replace function submit_content_role(
  p_content_id text,
  p_ign text,
  p_role signup_role
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ign text;
  v_ign_normalized text;
  v_user_id uuid;
  v_entry content_roles;
begin
  v_ign := regexp_replace(btrim(coalesce(p_ign, '')), '\s+', ' ', 'g');
  v_ign_normalized := normalize_ign(v_ign);

  if v_ign = '' then
    raise exception 'In-game username is required.';
  end if;

  if length(v_ign) > 64 then
    raise exception 'In-game username must be 64 characters or fewer.';
  end if;

  if not exists (select 1 from content where id = p_content_id and is_active = true) then
    raise exception 'Content does not exist or is inactive.';
  end if;

  insert into users (ign, ign_normalized)
  values (v_ign, v_ign_normalized)
  on conflict (ign_normalized)
  do update set ign = excluded.ign
  returning id into v_user_id;

  insert into content_roles (user_id, content_id, role)
  values (v_user_id, p_content_id, p_role)
  on conflict (user_id, content_id)
  do update set role = excluded.role
  returning * into v_entry;

  return jsonb_build_object(
    'id', v_entry.id,
    'contentId', v_entry.content_id,
    'role', v_entry.role,
    'createdAt', v_entry.created_at,
    'updatedAt', v_entry.updated_at
  );
end;
$$;
