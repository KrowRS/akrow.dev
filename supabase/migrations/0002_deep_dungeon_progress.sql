create table if not exists deep_dungeon_progress (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null unique,
  character_name text not null default '',
  palace boolean not null default false,
  heaven text not null default '',
  eureka text not null default '',
  pilgrims text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint deep_dungeon_progress_character_name_length check (length(character_name) <= 64),
  constraint deep_dungeon_progress_heaven_length check (length(heaven) <= 8),
  constraint deep_dungeon_progress_eureka_length check (length(eureka) <= 8),
  constraint deep_dungeon_progress_pilgrims_length check (length(pilgrims) <= 8)
);

alter table deep_dungeon_progress
add column if not exists sort_order integer;

alter table deep_dungeon_progress
add column if not exists character_name text not null default '';

alter table deep_dungeon_progress
add column if not exists palace boolean not null default false;

alter table deep_dungeon_progress
add column if not exists heaven text not null default '';

alter table deep_dungeon_progress
add column if not exists eureka text not null default '';

alter table deep_dungeon_progress
add column if not exists pilgrims text not null default '';

alter table deep_dungeon_progress
add column if not exists created_at timestamptz not null default now();

alter table deep_dungeon_progress
add column if not exists updated_at timestamptz not null default now();

update deep_dungeon_progress
set sort_order = ordered.row_number
from (
  select id, row_number() over (order by created_at, id) as row_number
  from deep_dungeon_progress
  where sort_order is null
) ordered
where deep_dungeon_progress.id = ordered.id;

alter table deep_dungeon_progress
alter column sort_order set not null;

create unique index if not exists deep_dungeon_progress_sort_order_key
on deep_dungeon_progress (sort_order);

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'deep_dungeon_progress_character_name_length'
  ) then
    alter table deep_dungeon_progress
    add constraint deep_dungeon_progress_character_name_length check (length(character_name) <= 64);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'deep_dungeon_progress_heaven_length'
  ) then
    alter table deep_dungeon_progress
    add constraint deep_dungeon_progress_heaven_length check (length(heaven) <= 8);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'deep_dungeon_progress_eureka_length'
  ) then
    alter table deep_dungeon_progress
    add constraint deep_dungeon_progress_eureka_length check (length(eureka) <= 8);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'deep_dungeon_progress_pilgrims_length'
  ) then
    alter table deep_dungeon_progress
    add constraint deep_dungeon_progress_pilgrims_length check (length(pilgrims) <= 8);
  end if;
end $$;

drop trigger if exists deep_dungeon_progress_set_updated_at on deep_dungeon_progress;
create trigger deep_dungeon_progress_set_updated_at
before update on deep_dungeon_progress
for each row execute function set_updated_at();

insert into deep_dungeon_progress (sort_order, character_name, palace, heaven, eureka, pilgrims)
values
  (1, 'Astrid', false, '1', '1', '1'),
  (2, 'Avery', true, '1', '0', '2'),
  (3, 'Bari', false, '4', '4', ''),
  (4, 'Corvus', false, '', '', ''),
  (5, 'Eli', false, '', '', ''),
  (6, 'Ellix', true, '4', '', ''),
  (7, 'Frosty', true, '4', '4', ''),
  (8, 'Hanabi', true, '4', '0', '3'),
  (9, 'Kirby', true, '4', '4', '8'),
  (10, 'Krippy', false, '', '', ''),
  (11, 'Lhei', true, '4', '1', '1'),
  (12, 'Luna', false, '', '', ''),
  (13, 'Mateen', false, '', '', ''),
  (14, 'Preto', true, '2', '2', ''),
  (15, 'Raova', true, '3', '', ''),
  (16, 'Selene', true, '2', '', ''),
  (17, 'Selicia', true, '4', '2', ''),
  (18, 'Shark', false, '', '', ''),
  (19, 'Tiri', true, '4', '4', '8'),
  (20, 'Yen', false, '4', '', '')
on conflict (sort_order) do nothing;

create or replace function list_deep_dungeon_progress()
returns jsonb
language sql
stable
as $$
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'name', character_name,
        'palace', palace,
        'heaven', heaven,
        'eureka', eureka,
        'pilgrims', pilgrims
      )
      order by sort_order
    ),
    '[]'::jsonb
  )
  from deep_dungeon_progress;
$$;

create or replace function replace_deep_dungeon_progress(p_rows jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row jsonb;
  v_sort_order integer;
begin
  if jsonb_typeof(p_rows) <> 'array' then
    raise exception 'rows must be an array.';
  end if;

  if jsonb_array_length(p_rows) > 200 then
    raise exception 'Spreadsheet can include 200 rows or fewer.';
  end if;

  delete from deep_dungeon_progress where true;

  v_sort_order := 1;
  for v_row in select value from jsonb_array_elements(p_rows) order by normalize_ign(value->>'name')
  loop
    if length(coalesce(v_row->>'name', '')) > 64 then
      raise exception 'Each character name must be 64 characters or fewer.';
    end if;

    if length(coalesce(v_row->>'heaven', '')) > 8
      or length(coalesce(v_row->>'eureka', '')) > 8
      or length(coalesce(v_row->>'pilgrims', '')) > 8 then
      raise exception 'Progress values must be 8 characters or fewer.';
    end if;

    insert into deep_dungeon_progress (
      sort_order,
      character_name,
      palace,
      heaven,
      eureka,
      pilgrims
    )
    values (
      v_sort_order,
      coalesce(v_row->>'name', ''),
      coalesce((v_row->>'palace')::boolean, false),
      coalesce(v_row->>'heaven', ''),
      coalesce(v_row->>'eureka', ''),
      coalesce(v_row->>'pilgrims', '')
    );

    v_sort_order := v_sort_order + 1;
  end loop;

  return jsonb_build_object('savedCount', jsonb_array_length(p_rows));
end;
$$;
