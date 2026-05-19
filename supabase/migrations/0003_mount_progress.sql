create table if not exists mount_items (
  id text primary key,
  expansion_id text not null references expansions(id) on delete cascade,
  name text not null,
  sort_order integer not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (expansion_id, sort_order)
);

create table if not exists mount_progress_rows (
  id uuid primary key default gen_random_uuid(),
  expansion_id text not null references expansions(id) on delete cascade,
  sort_order integer not null,
  character_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint mount_progress_rows_character_name_length check (length(character_name) <= 64),
  unique (expansion_id, sort_order)
);

create table if not exists mount_progress_cells (
  id uuid primary key default gen_random_uuid(),
  row_id uuid not null references mount_progress_rows(id) on delete cascade,
  mount_id text not null references mount_items(id) on delete cascade,
  acquired boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (row_id, mount_id)
);

alter table mount_items
add column if not exists is_active boolean not null default true;

alter table mount_items
add column if not exists created_at timestamptz not null default now();

alter table mount_items
add column if not exists updated_at timestamptz not null default now();

alter table mount_progress_rows
add column if not exists created_at timestamptz not null default now();

alter table mount_progress_rows
add column if not exists updated_at timestamptz not null default now();

alter table mount_progress_cells
add column if not exists acquired boolean not null default false;

alter table mount_progress_cells
add column if not exists created_at timestamptz not null default now();

alter table mount_progress_cells
add column if not exists updated_at timestamptz not null default now();

drop trigger if exists mount_items_set_updated_at on mount_items;
create trigger mount_items_set_updated_at
before update on mount_items
for each row execute function set_updated_at();

drop trigger if exists mount_progress_rows_set_updated_at on mount_progress_rows;
create trigger mount_progress_rows_set_updated_at
before update on mount_progress_rows
for each row execute function set_updated_at();

drop trigger if exists mount_progress_cells_set_updated_at on mount_progress_cells;
create trigger mount_progress_cells_set_updated_at
before update on mount_progress_cells
for each row execute function set_updated_at();

insert into mount_items (id, expansion_id, name, sort_order)
values
  ('arr_garuda', 'arr', 'Garuda', 1),
  ('arr_ifrit', 'arr', 'Ifrit', 2),
  ('arr_titan', 'arr', 'Titan', 3),
  ('arr_ramuh', 'arr', 'Ramuh', 4),
  ('arr_leviathan', 'arr', 'Leviathan', 5),
  ('arr_shiva', 'arr', 'Shiva', 6),
  ('arr_nightmare', 'arr', 'Nightmare', 7),
  ('heavensward_ravana', 'heavensward', 'Ravana', 1),
  ('heavensward_bismarck', 'heavensward', 'Bismarck', 2),
  ('heavensward_thordan', 'heavensward', 'Thordan', 3),
  ('heavensward_nidhogg', 'heavensward', 'Nidhogg', 4),
  ('heavensward_sephirot', 'heavensward', 'Sephirot', 5),
  ('heavensward_sophia', 'heavensward', 'Sophia', 6),
  ('heavensward_zurvan', 'heavensward', 'Zurvan', 7),
  ('stormblood_susano', 'stormblood', 'Susano', 1),
  ('stormblood_lakshmi', 'stormblood', 'Lakshmi', 2),
  ('stormblood_shinryu', 'stormblood', 'Shinryu', 3),
  ('stormblood_byakko', 'stormblood', 'Byakko', 4),
  ('stormblood_tsukuyomi', 'stormblood', 'Tsukuyomi', 5),
  ('stormblood_suzaku', 'stormblood', 'Suzaku', 6),
  ('stormblood_seiryu', 'stormblood', 'Seiryu', 7),
  ('stormblood_rathalos', 'stormblood', 'Rathalos', 8),
  ('shadowbringers_titania', 'shadowbringers', 'Titania', 1),
  ('shadowbringers_innocence', 'shadowbringers', 'Innocence', 2),
  ('shadowbringers_hades', 'shadowbringers', 'Hades', 3),
  ('shadowbringers_ruby', 'shadowbringers', 'Ruby', 4),
  ('shadowbringers_wol', 'shadowbringers', 'WoL', 5),
  ('shadowbringers_emerald', 'shadowbringers', 'Emerald', 6),
  ('shadowbringers_diamond', 'shadowbringers', 'Diamond', 7),
  ('endwalker_zodiark', 'endwalker', 'Zodiark', 1),
  ('endwalker_hydaelyn', 'endwalker', 'Hydaelyn', 2),
  ('endwalker_endsinger', 'endwalker', 'Endsinger', 3),
  ('endwalker_barbariccia', 'endwalker', 'Barbariccia', 4),
  ('endwalker_rubicante', 'endwalker', 'Rubicante', 5),
  ('endwalker_golbez', 'endwalker', 'Golbez', 6),
  ('endwalker_zeromus', 'endwalker', 'Zeromus', 7),
  ('dawntrail_valigarmanda', 'dawntrail', 'Valigarmanda', 1),
  ('dawntrail_zoraal_ja', 'dawntrail', 'Zoraal Ja', 2),
  ('dawntrail_sphene', 'dawntrail', 'Sphene', 3),
  ('dawntrail_zelenia', 'dawntrail', 'Zelenia', 4),
  ('dawntrail_necron', 'dawntrail', 'Necron', 5),
  ('dawntrail_doomtrain', 'dawntrail', 'Doomtrain', 6),
  ('dawntrail_enuo', 'dawntrail', 'Enuo', 7),
  ('dawntrail_arkveld', 'dawntrail', 'Arkveld', 8)
on conflict (id) do update
set
  expansion_id = excluded.expansion_id,
  name = excluded.name,
  sort_order = excluded.sort_order,
  is_active = true;

with characters(sort_order, character_name) as (
  values
    (1, 'Astrid'),
    (2, 'Avery'),
    (3, 'Bari'),
    (4, 'Corvus'),
    (5, 'Eli'),
    (6, 'Ellix'),
    (7, 'Frosty'),
    (8, 'Hanabi'),
    (9, 'Kirby'),
    (10, 'Krippy'),
    (11, 'Lhei'),
    (12, 'Luna'),
    (13, 'Mateen'),
    (14, 'Preto'),
    (15, 'Ragna'),
    (16, 'Raova'),
    (17, 'Selene'),
    (18, 'Selicia'),
    (19, 'Shark'),
    (20, 'Tiri'),
    (21, 'Will'),
    (22, 'Yen')
),
mount_expansions(expansion_id) as (
  values ('arr'), ('heavensward'), ('stormblood'), ('shadowbringers'), ('endwalker'), ('dawntrail')
)
insert into mount_progress_rows (expansion_id, sort_order, character_name)
select mount_expansions.expansion_id, characters.sort_order, characters.character_name
from mount_expansions
cross join characters
on conflict (expansion_id, sort_order) do update
set character_name = excluded.character_name;

insert into mount_progress_cells (row_id, mount_id, acquired)
select
  rows.id,
  mounts.id,
  mounts.expansion_id <> 'dawntrail'
from mount_progress_rows rows
join mount_items mounts on mounts.expansion_id = rows.expansion_id
on conflict (row_id, mount_id) do update
set acquired = excluded.acquired;

with overrides(character_name, mount_id, acquired) as (
  values
    ('Luna', 'arr_garuda', false),
    ('Luna', 'arr_ifrit', false),
    ('Luna', 'arr_titan', false),
    ('Luna', 'arr_ramuh', false),
    ('Luna', 'arr_shiva', false),
    ('Luna', 'heavensward_ravana', false),
    ('Luna', 'heavensward_bismarck', false),
    ('Luna', 'heavensward_thordan', false),
    ('Luna', 'heavensward_nidhogg', false),
    ('Luna', 'heavensward_sephirot', false),
    ('Luna', 'heavensward_sophia', false),
    ('Astrid', 'stormblood_rathalos', false),
    ('Corvus', 'stormblood_rathalos', false),
    ('Hanabi', 'stormblood_rathalos', false),
    ('Krippy', 'stormblood_shinryu', false),
    ('Krippy', 'stormblood_tsukuyomi', false),
    ('Krippy', 'stormblood_suzaku', false),
    ('Krippy', 'stormblood_seiryu', false),
    ('Krippy', 'stormblood_rathalos', false),
    ('Luna', 'stormblood_suzaku', false),
    ('Luna', 'stormblood_rathalos', false),
    ('Shark', 'stormblood_shinryu', false),
    ('Shark', 'stormblood_suzaku', false),
    ('Shark', 'stormblood_seiryu', false),
    ('Bari', 'shadowbringers_hades', false),
    ('Hanabi', 'shadowbringers_titania', false),
    ('Hanabi', 'shadowbringers_innocence', false),
    ('Hanabi', 'shadowbringers_hades', false),
    ('Hanabi', 'shadowbringers_diamond', false),
    ('Krippy', 'shadowbringers_hades', false),
    ('Krippy', 'shadowbringers_emerald', false),
    ('Krippy', 'shadowbringers_diamond', false),
    ('Raova', 'shadowbringers_ruby', false),
    ('Raova', 'shadowbringers_emerald', false),
    ('Raova', 'shadowbringers_diamond', false),
    ('Shark', 'shadowbringers_hades', false),
    ('Shark', 'shadowbringers_ruby', false),
    ('Will', 'shadowbringers_hades', false),
    ('Astrid', 'endwalker_barbariccia', false),
    ('Astrid', 'endwalker_golbez', false),
    ('Avery', 'endwalker_barbariccia', false),
    ('Avery', 'endwalker_golbez', false),
    ('Avery', 'endwalker_zeromus', false),
    ('Bari', 'endwalker_endsinger', false),
    ('Bari', 'endwalker_barbariccia', false),
    ('Bari', 'endwalker_rubicante', false),
    ('Bari', 'endwalker_golbez', false),
    ('Frosty', 'endwalker_zodiark', false),
    ('Frosty', 'endwalker_endsinger', false),
    ('Frosty', 'endwalker_rubicante', false),
    ('Frosty', 'endwalker_golbez', false),
    ('Frosty', 'endwalker_zeromus', false),
    ('Hanabi', 'endwalker_zodiark', false),
    ('Hanabi', 'endwalker_endsinger', false),
    ('Hanabi', 'endwalker_barbariccia', false),
    ('Hanabi', 'endwalker_rubicante', false),
    ('Hanabi', 'endwalker_golbez', false),
    ('Hanabi', 'endwalker_zeromus', false),
    ('Krippy', 'endwalker_zodiark', false),
    ('Krippy', 'endwalker_hydaelyn', false),
    ('Krippy', 'endwalker_endsinger', false),
    ('Krippy', 'endwalker_barbariccia', false),
    ('Krippy', 'endwalker_rubicante', false),
    ('Krippy', 'endwalker_golbez', false),
    ('Krippy', 'endwalker_zeromus', false),
    ('Luna', 'endwalker_barbariccia', false),
    ('Luna', 'endwalker_golbez', false),
    ('Mateen', 'endwalker_barbariccia', false),
    ('Preto', 'endwalker_zeromus', false),
    ('Raova', 'endwalker_zodiark', false),
    ('Raova', 'endwalker_hydaelyn', false),
    ('Raova', 'endwalker_barbariccia', false),
    ('Raova', 'endwalker_rubicante', false),
    ('Raova', 'endwalker_golbez', false),
    ('Raova', 'endwalker_zeromus', false),
    ('Selicia', 'endwalker_barbariccia', false),
    ('Selicia', 'endwalker_golbez', false),
    ('Shark', 'endwalker_zodiark', false),
    ('Shark', 'endwalker_hydaelyn', false),
    ('Shark', 'endwalker_endsinger', false),
    ('Shark', 'endwalker_barbariccia', false),
    ('Shark', 'endwalker_rubicante', false),
    ('Shark', 'endwalker_golbez', false),
    ('Will', 'endwalker_barbariccia', false),
    ('Will', 'endwalker_rubicante', false),
    ('Will', 'endwalker_golbez', false),
    ('Yen', 'endwalker_endsinger', false),
    ('Yen', 'endwalker_barbariccia', false),
    ('Yen', 'endwalker_rubicante', false),
    ('Yen', 'endwalker_golbez', false),
    ('Yen', 'endwalker_zeromus', false),
    ('Astrid', 'dawntrail_zoraal_ja', true),
    ('Avery', 'dawntrail_valigarmanda', true),
    ('Bari', 'dawntrail_zoraal_ja', true),
    ('Eli', 'dawntrail_valigarmanda', true),
    ('Eli', 'dawntrail_zoraal_ja', true),
    ('Ellix', 'dawntrail_valigarmanda', true),
    ('Ellix', 'dawntrail_sphene', true),
    ('Frosty', 'dawntrail_valigarmanda', true),
    ('Frosty', 'dawntrail_zoraal_ja', true),
    ('Frosty', 'dawntrail_sphene', true),
    ('Frosty', 'dawntrail_zelenia', true),
    ('Frosty', 'dawntrail_necron', true),
    ('Hanabi', 'dawntrail_valigarmanda', true),
    ('Kirby', 'dawntrail_valigarmanda', true),
    ('Lhei', 'dawntrail_valigarmanda', true),
    ('Lhei', 'dawntrail_zoraal_ja', true),
    ('Lhei', 'dawntrail_sphene', true),
    ('Lhei', 'dawntrail_zelenia', true),
    ('Lhei', 'dawntrail_necron', true),
    ('Lhei', 'dawntrail_doomtrain', true),
    ('Lhei', 'dawntrail_enuo', true),
    ('Mateen', 'dawntrail_valigarmanda', true),
    ('Mateen', 'dawntrail_zoraal_ja', true),
    ('Mateen', 'dawntrail_arkveld', true),
    ('Ragna', 'dawntrail_valigarmanda', true),
    ('Ragna', 'dawntrail_zoraal_ja', true),
    ('Ragna', 'dawntrail_sphene', true),
    ('Ragna', 'dawntrail_zelenia', true),
    ('Ragna', 'dawntrail_necron', true),
    ('Ragna', 'dawntrail_doomtrain', true),
    ('Ragna', 'dawntrail_enuo', true),
    ('Raova', 'dawntrail_valigarmanda', true),
    ('Selene', 'dawntrail_valigarmanda', true),
    ('Selene', 'dawntrail_zoraal_ja', true),
    ('Selene', 'dawntrail_sphene', true),
    ('Selicia', 'dawntrail_valigarmanda', true),
    ('Selicia', 'dawntrail_zelenia', true),
    ('Tiri', 'dawntrail_valigarmanda', true),
    ('Tiri', 'dawntrail_zoraal_ja', true),
    ('Tiri', 'dawntrail_sphene', true),
    ('Tiri', 'dawntrail_zelenia', true),
    ('Tiri', 'dawntrail_necron', true),
    ('Tiri', 'dawntrail_doomtrain', true),
    ('Tiri', 'dawntrail_enuo', true),
    ('Tiri', 'dawntrail_arkveld', true)
)
update mount_progress_cells cells
set acquired = overrides.acquired
from mount_progress_rows rows
join overrides on overrides.character_name = rows.character_name
where cells.row_id = rows.id
  and cells.mount_id = overrides.mount_id;

create or replace function list_mount_progress(p_expansion_id text default 'dawntrail')
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'expansionId', p_expansion_id,
    'columns', coalesce(
      (
        select jsonb_agg(mounts.name order by mounts.sort_order)
        from mount_items mounts
        where mounts.expansion_id = p_expansion_id
          and mounts.is_active = true
      ),
      '[]'::jsonb
    ),
    'rows', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'name', rows.character_name,
            'values', (
              select jsonb_agg(cells.acquired order by mounts.sort_order)
              from mount_items mounts
              join mount_progress_cells cells on cells.mount_id = mounts.id
              where mounts.expansion_id = rows.expansion_id
                and cells.row_id = rows.id
                and mounts.is_active = true
            )
          )
          order by rows.sort_order
        )
        from mount_progress_rows rows
        where rows.expansion_id = p_expansion_id
      ),
      '[]'::jsonb
    )
  );
$$;

create or replace function replace_mount_progress(
  p_expansion_id text,
  p_rows jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row jsonb;
  v_sort_order integer := 1;
  v_row_id uuid;
  v_mount record;
  v_mount_index integer;
  v_values jsonb;
begin
  if not exists (select 1 from expansions where id = p_expansion_id) then
    raise exception 'Expansion does not exist.';
  end if;

  if jsonb_typeof(p_rows) <> 'array' then
    raise exception 'rows must be an array.';
  end if;

  if jsonb_array_length(p_rows) > 200 then
    raise exception 'Spreadsheet can include 200 rows or fewer.';
  end if;

  delete from mount_progress_rows where expansion_id = p_expansion_id;

  for v_row in select * from jsonb_array_elements(p_rows)
  loop
    if length(coalesce(v_row->>'name', '')) > 64 then
      raise exception 'Each character name must be 64 characters or fewer.';
    end if;

    v_values := coalesce(v_row->'values', '[]'::jsonb);

    insert into mount_progress_rows (expansion_id, sort_order, character_name)
    values (p_expansion_id, v_sort_order, coalesce(v_row->>'name', ''))
    returning id into v_row_id;

    v_mount_index := 0;
    for v_mount in
      select id
      from mount_items
      where expansion_id = p_expansion_id
        and is_active = true
      order by sort_order
    loop
      insert into mount_progress_cells (row_id, mount_id, acquired)
      values (
        v_row_id,
        v_mount.id,
        coalesce((v_values->>v_mount_index)::boolean, false)
      );

      v_mount_index := v_mount_index + 1;
    end loop;

    v_sort_order := v_sort_order + 1;
  end loop;

  return jsonb_build_object('savedCount', jsonb_array_length(p_rows));
end;
$$;
