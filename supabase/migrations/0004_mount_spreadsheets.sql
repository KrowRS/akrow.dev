drop table if exists mount_spreadsheet_cells cascade;
drop table if exists mount_spreadsheet_rows cascade;
drop table if exists mount_spreadsheet_columns cascade;
drop table if exists mount_spreadsheets cascade;
drop table if exists mount_progress_cells cascade;
drop table if exists mount_progress_rows cascade;
drop table if exists mount_items cascade;

create table if not exists arr_mount_progress (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null unique,
  character_name text not null default '',
  garuda boolean not null default false,
  ifrit boolean not null default false,
  titan boolean not null default false,
  ramuh boolean not null default false,
  leviathan boolean not null default false,
  shiva boolean not null default false,
  nightmare boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint arr_mount_progress_character_name_length check (length(character_name) <= 64)
);

create table if not exists heavensward_mount_progress (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null unique,
  character_name text not null default '',
  ravana boolean not null default false,
  bismarck boolean not null default false,
  thordan boolean not null default false,
  nidhogg boolean not null default false,
  sephirot boolean not null default false,
  sophia boolean not null default false,
  zurvan boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint heavensward_mount_progress_character_name_length check (length(character_name) <= 64)
);

create table if not exists stormblood_mount_progress (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null unique,
  character_name text not null default '',
  susano boolean not null default false,
  lakshmi boolean not null default false,
  shinryu boolean not null default false,
  byakko boolean not null default false,
  tsukuyomi boolean not null default false,
  suzaku boolean not null default false,
  seiryu boolean not null default false,
  rathalos boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint stormblood_mount_progress_character_name_length check (length(character_name) <= 64)
);

create table if not exists shadowbringers_mount_progress (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null unique,
  character_name text not null default '',
  titania boolean not null default false,
  innocence boolean not null default false,
  hades boolean not null default false,
  ruby boolean not null default false,
  wol boolean not null default false,
  emerald boolean not null default false,
  diamond boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shadowbringers_mount_progress_character_name_length check (length(character_name) <= 64)
);

create table if not exists endwalker_mount_progress (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null unique,
  character_name text not null default '',
  zodiark boolean not null default false,
  hydaelyn boolean not null default false,
  endsinger boolean not null default false,
  barbariccia boolean not null default false,
  rubicante boolean not null default false,
  golbez boolean not null default false,
  zeromus boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint endwalker_mount_progress_character_name_length check (length(character_name) <= 64)
);

create table if not exists dawntrail_mount_progress (
  id uuid primary key default gen_random_uuid(),
  sort_order integer not null unique,
  character_name text not null default '',
  valigarmanda boolean not null default false,
  zoraal_ja boolean not null default false,
  sphene boolean not null default false,
  zelenia boolean not null default false,
  necron boolean not null default false,
  doomtrain boolean not null default false,
  enuo boolean not null default false,
  arkveld boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint dawntrail_mount_progress_character_name_length check (length(character_name) <= 64)
);

drop trigger if exists arr_mount_progress_set_updated_at on arr_mount_progress;
create trigger arr_mount_progress_set_updated_at before update on arr_mount_progress
for each row execute function set_updated_at();

drop trigger if exists heavensward_mount_progress_set_updated_at on heavensward_mount_progress;
create trigger heavensward_mount_progress_set_updated_at before update on heavensward_mount_progress
for each row execute function set_updated_at();

drop trigger if exists stormblood_mount_progress_set_updated_at on stormblood_mount_progress;
create trigger stormblood_mount_progress_set_updated_at before update on stormblood_mount_progress
for each row execute function set_updated_at();

drop trigger if exists shadowbringers_mount_progress_set_updated_at on shadowbringers_mount_progress;
create trigger shadowbringers_mount_progress_set_updated_at before update on shadowbringers_mount_progress
for each row execute function set_updated_at();

drop trigger if exists endwalker_mount_progress_set_updated_at on endwalker_mount_progress;
create trigger endwalker_mount_progress_set_updated_at before update on endwalker_mount_progress
for each row execute function set_updated_at();

drop trigger if exists dawntrail_mount_progress_set_updated_at on dawntrail_mount_progress;
create trigger dawntrail_mount_progress_set_updated_at before update on dawntrail_mount_progress
for each row execute function set_updated_at();

insert into arr_mount_progress (sort_order, character_name, garuda, ifrit, titan, ramuh, leviathan, shiva, nightmare)
values
  (1,'Astrid',true,true,true,true,true,true,true),
  (2,'Avery',true,true,true,true,true,true,true),
  (3,'Bari',true,true,true,true,true,true,true),
  (4,'Corvus',true,true,true,true,true,true,true),
  (5,'Eli',true,true,true,true,true,true,true),
  (6,'Ellix',true,true,true,true,true,true,true),
  (7,'Frosty',true,true,true,true,true,true,true),
  (8,'Hanabi',true,true,true,true,true,true,true),
  (9,'Kirby',true,true,true,true,true,true,true),
  (10,'Krippy',true,true,true,true,true,true,true),
  (11,'Lhei',true,true,true,true,true,true,true),
  (12,'Luna',false,false,false,false,true,false,true),
  (13,'Mateen',true,true,true,true,true,true,true),
  (14,'Preto',true,true,true,true,true,true,true),
  (15,'Ragna',true,true,true,true,true,true,true),
  (16,'Raova',true,true,true,true,true,true,true),
  (17,'Selene',true,true,true,true,true,true,true),
  (18,'Selicia',true,true,true,true,true,true,true),
  (19,'Shark',true,true,true,true,true,true,true),
  (20,'Tiri',true,true,true,true,true,true,true),
  (21,'Will',true,true,true,true,true,true,true),
  (22,'Yen',true,true,true,true,true,true,true)
on conflict (sort_order) do update set
  character_name = excluded.character_name,
  garuda = excluded.garuda,
  ifrit = excluded.ifrit,
  titan = excluded.titan,
  ramuh = excluded.ramuh,
  leviathan = excluded.leviathan,
  shiva = excluded.shiva,
  nightmare = excluded.nightmare;

insert into heavensward_mount_progress (sort_order, character_name, ravana, bismarck, thordan, nidhogg, sephirot, sophia, zurvan)
values
  (1,'Astrid',true,true,true,true,true,true,true),
  (2,'Avery',true,true,true,true,true,true,true),
  (3,'Bari',true,true,true,true,true,true,true),
  (4,'Corvus',true,true,true,true,true,true,true),
  (5,'Eli',true,true,true,true,true,true,true),
  (6,'Ellix',true,true,true,true,true,true,true),
  (7,'Frosty',true,true,true,true,true,true,true),
  (8,'Hanabi',true,true,true,true,true,true,true),
  (9,'Kirby',true,true,true,true,true,true,true),
  (10,'Krippy',true,true,true,true,true,true,true),
  (11,'Lhei',true,true,true,true,true,true,true),
  (12,'Luna',false,false,false,false,false,false,true),
  (13,'Mateen',true,true,true,true,true,true,true),
  (14,'Preto',true,true,true,true,true,true,true),
  (15,'Ragna',true,true,true,true,true,true,true),
  (16,'Raova',true,true,true,true,true,true,true),
  (17,'Selene',true,true,true,true,true,true,true),
  (18,'Selicia',true,true,true,true,true,true,true),
  (19,'Shark',true,true,true,true,true,true,true),
  (20,'Tiri',true,true,true,true,true,true,true),
  (21,'Will',true,true,true,true,true,true,true),
  (22,'Yen',true,true,true,true,true,true,true)
on conflict (sort_order) do update set
  character_name = excluded.character_name,
  ravana = excluded.ravana,
  bismarck = excluded.bismarck,
  thordan = excluded.thordan,
  nidhogg = excluded.nidhogg,
  sephirot = excluded.sephirot,
  sophia = excluded.sophia,
  zurvan = excluded.zurvan;

insert into stormblood_mount_progress (sort_order, character_name, susano, lakshmi, shinryu, byakko, tsukuyomi, suzaku, seiryu, rathalos)
values
  (1,'Astrid',true,true,true,true,true,true,true,false),
  (2,'Avery',true,true,true,true,true,true,true,true),
  (3,'Bari',true,true,true,true,true,true,true,true),
  (4,'Corvus',true,true,true,true,true,true,true,false),
  (5,'Eli',true,true,true,true,true,true,true,true),
  (6,'Ellix',true,true,true,true,true,true,true,true),
  (7,'Frosty',true,true,true,true,true,true,true,true),
  (8,'Hanabi',true,true,true,true,true,true,true,false),
  (9,'Kirby',true,true,true,true,true,true,true,true),
  (10,'Krippy',true,true,false,true,false,false,false,false),
  (11,'Lhei',true,true,true,true,true,true,true,true),
  (12,'Luna',true,true,true,true,true,false,true,false),
  (13,'Mateen',true,true,true,true,true,true,true,true),
  (14,'Preto',true,true,true,true,true,true,true,true),
  (15,'Ragna',true,true,true,true,true,true,true,true),
  (16,'Raova',true,true,true,true,true,true,true,true),
  (17,'Selene',true,true,true,true,true,true,true,true),
  (18,'Selicia',true,true,true,true,true,true,true,true),
  (19,'Shark',true,true,false,true,true,false,false,true),
  (20,'Tiri',true,true,true,true,true,true,true,true),
  (21,'Will',true,true,true,true,true,true,true,true),
  (22,'Yen',true,true,true,true,true,true,true,true)
on conflict (sort_order) do update set
  character_name = excluded.character_name,
  susano = excluded.susano,
  lakshmi = excluded.lakshmi,
  shinryu = excluded.shinryu,
  byakko = excluded.byakko,
  tsukuyomi = excluded.tsukuyomi,
  suzaku = excluded.suzaku,
  seiryu = excluded.seiryu,
  rathalos = excluded.rathalos;

insert into shadowbringers_mount_progress (sort_order, character_name, titania, innocence, hades, ruby, wol, emerald, diamond)
values
  (1,'Astrid',true,true,true,true,true,true,true),
  (2,'Avery',true,true,true,true,true,true,true),
  (3,'Bari',true,true,false,true,true,true,true),
  (4,'Corvus',true,true,true,true,true,true,true),
  (5,'Eli',true,true,true,true,true,true,true),
  (6,'Ellix',true,true,true,true,true,true,true),
  (7,'Frosty',true,true,true,true,true,true,true),
  (8,'Hanabi',false,false,false,true,true,true,false),
  (9,'Kirby',true,true,true,true,true,true,true),
  (10,'Krippy',true,true,false,true,true,false,false),
  (11,'Lhei',true,true,true,true,true,true,true),
  (12,'Luna',true,true,true,true,true,true,true),
  (13,'Mateen',true,true,true,true,true,true,true),
  (14,'Preto',true,true,true,true,true,true,true),
  (15,'Ragna',true,true,true,true,true,true,true),
  (16,'Raova',true,true,true,false,true,false,false),
  (17,'Selene',true,true,true,true,true,true,true),
  (18,'Selicia',true,true,true,true,true,true,true),
  (19,'Shark',true,true,false,false,true,true,true),
  (20,'Tiri',true,true,true,true,true,true,true),
  (21,'Will',true,true,false,true,true,true,true),
  (22,'Yen',true,true,true,true,true,true,true)
on conflict (sort_order) do update set
  character_name = excluded.character_name,
  titania = excluded.titania,
  innocence = excluded.innocence,
  hades = excluded.hades,
  ruby = excluded.ruby,
  wol = excluded.wol,
  emerald = excluded.emerald,
  diamond = excluded.diamond;

insert into endwalker_mount_progress (sort_order, character_name, zodiark, hydaelyn, endsinger, barbariccia, rubicante, golbez, zeromus)
values
  (1,'Astrid',true,true,true,false,true,false,true),
  (2,'Avery',true,true,true,false,true,false,false),
  (3,'Bari',true,true,false,false,false,false,true),
  (4,'Corvus',true,true,true,true,true,true,true),
  (5,'Eli',true,true,true,true,true,true,true),
  (6,'Ellix',true,true,true,true,true,true,true),
  (7,'Frosty',false,true,false,true,false,false,false),
  (8,'Hanabi',false,true,false,false,false,false,false),
  (9,'Kirby',true,true,true,true,true,true,true),
  (10,'Krippy',false,false,false,false,false,false,false),
  (11,'Lhei',true,true,true,true,true,true,true),
  (12,'Luna',true,true,true,false,true,false,true),
  (13,'Mateen',true,true,true,false,true,true,true),
  (14,'Preto',true,true,true,true,true,true,false),
  (15,'Ragna',true,true,true,true,true,true,true),
  (16,'Raova',false,false,true,false,false,false,false),
  (17,'Selene',true,true,true,true,true,true,true),
  (18,'Selicia',true,true,true,false,true,false,true),
  (19,'Shark',false,false,false,false,false,false,true),
  (20,'Tiri',true,true,true,true,true,true,true),
  (21,'Will',true,true,true,false,false,false,true),
  (22,'Yen',true,true,false,false,false,false,false)
on conflict (sort_order) do update set
  character_name = excluded.character_name,
  zodiark = excluded.zodiark,
  hydaelyn = excluded.hydaelyn,
  endsinger = excluded.endsinger,
  barbariccia = excluded.barbariccia,
  rubicante = excluded.rubicante,
  golbez = excluded.golbez,
  zeromus = excluded.zeromus;

insert into dawntrail_mount_progress (sort_order, character_name, valigarmanda, zoraal_ja, sphene, zelenia, necron, doomtrain, enuo, arkveld)
values
  (1,'Astrid',false,true,false,false,false,false,false,false),
  (2,'Avery',true,false,false,false,false,false,false,false),
  (3,'Bari',false,true,false,false,false,false,false,false),
  (4,'Corvus',false,false,false,false,false,false,false,false),
  (5,'Eli',true,true,false,false,false,false,false,false),
  (6,'Ellix',true,false,true,false,false,false,false,false),
  (7,'Frosty',true,true,true,true,true,false,false,false),
  (8,'Hanabi',true,false,false,false,false,false,false,false),
  (9,'Kirby',true,false,false,false,false,false,false,false),
  (10,'Krippy',false,false,false,false,false,false,false,false),
  (11,'Lhei',true,true,true,true,true,true,true,false),
  (12,'Luna',false,false,false,false,false,false,false,false),
  (13,'Mateen',true,true,false,false,false,false,false,true),
  (14,'Preto',false,false,false,false,false,false,false,false),
  (15,'Ragna',true,true,true,true,true,true,true,false),
  (16,'Raova',true,false,false,false,false,false,false,false),
  (17,'Selene',true,true,true,false,false,false,false,false),
  (18,'Selicia',true,false,false,true,false,false,false,false),
  (19,'Shark',false,false,false,false,false,false,false,false),
  (20,'Tiri',true,true,true,true,true,true,true,true),
  (21,'Will',false,false,false,false,false,false,false,false),
  (22,'Yen',false,false,false,false,false,false,false,false)
on conflict (sort_order) do update set
  character_name = excluded.character_name,
  valigarmanda = excluded.valigarmanda,
  zoraal_ja = excluded.zoraal_ja,
  sphene = excluded.sphene,
  zelenia = excluded.zelenia,
  necron = excluded.necron,
  doomtrain = excluded.doomtrain,
  enuo = excluded.enuo,
  arkveld = excluded.arkveld;

create or replace function list_mount_progress(p_expansion_id text default 'dawntrail')
returns jsonb
language plpgsql
stable
as $$
begin
  if p_expansion_id = 'arr' then
    return jsonb_build_object(
      'columns', jsonb_build_array('Garuda','Ifrit','Titan','Ramuh','Leviathan','Shiva','Nightmare'),
      'rows', coalesce((select jsonb_agg(jsonb_build_object('name', character_name, 'values', jsonb_build_array(garuda, ifrit, titan, ramuh, leviathan, shiva, nightmare)) order by sort_order) from arr_mount_progress), '[]'::jsonb)
    );
  elsif p_expansion_id = 'heavensward' then
    return jsonb_build_object(
      'columns', jsonb_build_array('Ravana','Bismarck','Thordan','Nidhogg','Sephirot','Sophia','Zurvan'),
      'rows', coalesce((select jsonb_agg(jsonb_build_object('name', character_name, 'values', jsonb_build_array(ravana, bismarck, thordan, nidhogg, sephirot, sophia, zurvan)) order by sort_order) from heavensward_mount_progress), '[]'::jsonb)
    );
  elsif p_expansion_id = 'stormblood' then
    return jsonb_build_object(
      'columns', jsonb_build_array('Susano','Lakshmi','Shinryu','Byakko','Tsukuyomi','Suzaku','Seiryu','Rathalos'),
      'rows', coalesce((select jsonb_agg(jsonb_build_object('name', character_name, 'values', jsonb_build_array(susano, lakshmi, shinryu, byakko, tsukuyomi, suzaku, seiryu, rathalos)) order by sort_order) from stormblood_mount_progress), '[]'::jsonb)
    );
  elsif p_expansion_id = 'shadowbringers' then
    return jsonb_build_object(
      'columns', jsonb_build_array('Titania','Innocence','Hades','Ruby','WoL','Emerald','Diamond'),
      'rows', coalesce((select jsonb_agg(jsonb_build_object('name', character_name, 'values', jsonb_build_array(titania, innocence, hades, ruby, wol, emerald, diamond)) order by sort_order) from shadowbringers_mount_progress), '[]'::jsonb)
    );
  elsif p_expansion_id = 'endwalker' then
    return jsonb_build_object(
      'columns', jsonb_build_array('Zodiark','Hydaelyn','Endsinger','Barbariccia','Rubicante','Golbez','Zeromus'),
      'rows', coalesce((select jsonb_agg(jsonb_build_object('name', character_name, 'values', jsonb_build_array(zodiark, hydaelyn, endsinger, barbariccia, rubicante, golbez, zeromus)) order by sort_order) from endwalker_mount_progress), '[]'::jsonb)
    );
  elsif p_expansion_id = 'dawntrail' then
    return jsonb_build_object(
      'columns', jsonb_build_array('Valigarmanda','Zoraal Ja','Sphene','Zelenia','Necron','Doomtrain','Enuo','Arkveld'),
      'rows', coalesce((select jsonb_agg(jsonb_build_object('name', character_name, 'values', jsonb_build_array(valigarmanda, zoraal_ja, sphene, zelenia, necron, doomtrain, enuo, arkveld)) order by sort_order) from dawntrail_mount_progress), '[]'::jsonb)
    );
  end if;

  raise exception 'Unknown mount expansion.';
end;
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
  v_values jsonb;
  v_sort_order integer := 1;
begin
  if jsonb_typeof(p_rows) <> 'array' then
    raise exception 'rows must be an array.';
  end if;

  if jsonb_array_length(p_rows) > 200 then
    raise exception 'Spreadsheet can include 200 rows or fewer.';
  end if;

  for v_row in select * from jsonb_array_elements(p_rows)
  loop
    if length(coalesce(v_row->>'name', '')) > 64 then
      raise exception 'Each character name must be 64 characters or fewer.';
    end if;
  end loop;

  if p_expansion_id = 'arr' then
    delete from arr_mount_progress where true;
    v_sort_order := 1;
    for v_row in select value from jsonb_array_elements(p_rows) order by normalize_ign(value->>'name') loop
      v_values := coalesce(v_row->'values', '[]'::jsonb);
      insert into arr_mount_progress (sort_order, character_name, garuda, ifrit, titan, ramuh, leviathan, shiva, nightmare)
      values (v_sort_order, coalesce(v_row->>'name', ''), coalesce((v_values->>0)::boolean, false), coalesce((v_values->>1)::boolean, false), coalesce((v_values->>2)::boolean, false), coalesce((v_values->>3)::boolean, false), coalesce((v_values->>4)::boolean, false), coalesce((v_values->>5)::boolean, false), coalesce((v_values->>6)::boolean, false));
      v_sort_order := v_sort_order + 1;
    end loop;
  elsif p_expansion_id = 'heavensward' then
    delete from heavensward_mount_progress where true;
    v_sort_order := 1;
    for v_row in select value from jsonb_array_elements(p_rows) order by normalize_ign(value->>'name') loop
      v_values := coalesce(v_row->'values', '[]'::jsonb);
      insert into heavensward_mount_progress (sort_order, character_name, ravana, bismarck, thordan, nidhogg, sephirot, sophia, zurvan)
      values (v_sort_order, coalesce(v_row->>'name', ''), coalesce((v_values->>0)::boolean, false), coalesce((v_values->>1)::boolean, false), coalesce((v_values->>2)::boolean, false), coalesce((v_values->>3)::boolean, false), coalesce((v_values->>4)::boolean, false), coalesce((v_values->>5)::boolean, false), coalesce((v_values->>6)::boolean, false));
      v_sort_order := v_sort_order + 1;
    end loop;
  elsif p_expansion_id = 'stormblood' then
    delete from stormblood_mount_progress where true;
    v_sort_order := 1;
    for v_row in select value from jsonb_array_elements(p_rows) order by normalize_ign(value->>'name') loop
      v_values := coalesce(v_row->'values', '[]'::jsonb);
      insert into stormblood_mount_progress (sort_order, character_name, susano, lakshmi, shinryu, byakko, tsukuyomi, suzaku, seiryu, rathalos)
      values (v_sort_order, coalesce(v_row->>'name', ''), coalesce((v_values->>0)::boolean, false), coalesce((v_values->>1)::boolean, false), coalesce((v_values->>2)::boolean, false), coalesce((v_values->>3)::boolean, false), coalesce((v_values->>4)::boolean, false), coalesce((v_values->>5)::boolean, false), coalesce((v_values->>6)::boolean, false), coalesce((v_values->>7)::boolean, false));
      v_sort_order := v_sort_order + 1;
    end loop;
  elsif p_expansion_id = 'shadowbringers' then
    delete from shadowbringers_mount_progress where true;
    v_sort_order := 1;
    for v_row in select value from jsonb_array_elements(p_rows) order by normalize_ign(value->>'name') loop
      v_values := coalesce(v_row->'values', '[]'::jsonb);
      insert into shadowbringers_mount_progress (sort_order, character_name, titania, innocence, hades, ruby, wol, emerald, diamond)
      values (v_sort_order, coalesce(v_row->>'name', ''), coalesce((v_values->>0)::boolean, false), coalesce((v_values->>1)::boolean, false), coalesce((v_values->>2)::boolean, false), coalesce((v_values->>3)::boolean, false), coalesce((v_values->>4)::boolean, false), coalesce((v_values->>5)::boolean, false), coalesce((v_values->>6)::boolean, false));
      v_sort_order := v_sort_order + 1;
    end loop;
  elsif p_expansion_id = 'endwalker' then
    delete from endwalker_mount_progress where true;
    v_sort_order := 1;
    for v_row in select value from jsonb_array_elements(p_rows) order by normalize_ign(value->>'name') loop
      v_values := coalesce(v_row->'values', '[]'::jsonb);
      insert into endwalker_mount_progress (sort_order, character_name, zodiark, hydaelyn, endsinger, barbariccia, rubicante, golbez, zeromus)
      values (v_sort_order, coalesce(v_row->>'name', ''), coalesce((v_values->>0)::boolean, false), coalesce((v_values->>1)::boolean, false), coalesce((v_values->>2)::boolean, false), coalesce((v_values->>3)::boolean, false), coalesce((v_values->>4)::boolean, false), coalesce((v_values->>5)::boolean, false), coalesce((v_values->>6)::boolean, false));
      v_sort_order := v_sort_order + 1;
    end loop;
  elsif p_expansion_id = 'dawntrail' then
    delete from dawntrail_mount_progress where true;
    v_sort_order := 1;
    for v_row in select value from jsonb_array_elements(p_rows) order by normalize_ign(value->>'name') loop
      v_values := coalesce(v_row->'values', '[]'::jsonb);
      insert into dawntrail_mount_progress (sort_order, character_name, valigarmanda, zoraal_ja, sphene, zelenia, necron, doomtrain, enuo, arkveld)
      values (v_sort_order, coalesce(v_row->>'name', ''), coalesce((v_values->>0)::boolean, false), coalesce((v_values->>1)::boolean, false), coalesce((v_values->>2)::boolean, false), coalesce((v_values->>3)::boolean, false), coalesce((v_values->>4)::boolean, false), coalesce((v_values->>5)::boolean, false), coalesce((v_values->>6)::boolean, false), coalesce((v_values->>7)::boolean, false));
      v_sort_order := v_sort_order + 1;
    end loop;
  else
    raise exception 'Unknown mount expansion.';
  end if;

  return jsonb_build_object('savedCount', jsonb_array_length(p_rows));
end;
$$;
