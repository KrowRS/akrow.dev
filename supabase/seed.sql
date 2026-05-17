insert into expansions (id, name, short_name, release_order)
values
  ('arr', 'A Realm Reborn', 'ARR', 10),
  ('heavensward', 'Heavensward', 'HW', 20),
  ('stormblood', 'Stormblood', 'SB', 30),
  ('shadowbringers', 'Shadowbringers', 'ShB', 40),
  ('endwalker', 'Endwalker', 'EW', 50),
  ('dawntrail', 'Dawntrail', 'DT', 60)
on conflict (id) do update set
  name = excluded.name,
  short_name = excluded.short_name,
  release_order = excluded.release_order,
  is_active = true;

insert into content_categories (id, name, sort_order)
values
  ('ultimate', 'Ultimate Raids', 10),
  ('extreme_trial', 'Extreme Trials', 20),
  ('savage_raid', 'Savage Raids', 30)
on conflict (id) do update set
  name = excluded.name,
  sort_order = excluded.sort_order,
  is_active = true;

insert into content (id, expansion_id, category_id, name, short_name, sort_order)
values
  ('ucob', 'stormblood', 'ultimate', 'The Unending Coil of Bahamut (Ultimate)', 'UCOB', 10),
  ('uwu', 'stormblood', 'ultimate', 'The Weapon''s Refrain (Ultimate)', 'UWU', 20),
  ('tea', 'shadowbringers', 'ultimate', 'The Epic of Alexander (Ultimate)', 'TEA', 30),
  ('dsr', 'endwalker', 'ultimate', 'Dragonsong''s Reprise (Ultimate)', 'DSR', 40),
  ('top', 'endwalker', 'ultimate', 'The Omega Protocol (Ultimate)', 'TOP', 50),
  ('fru', 'dawntrail', 'ultimate', 'Futures Rewritten (Ultimate)', 'FRU', 60),
  ('dt-ex1', 'dawntrail', 'extreme_trial', 'Worqor Lar Dor (Extreme)', 'EX1', 10),
  ('dt-ex2', 'dawntrail', 'extreme_trial', 'Everkeep (Extreme)', 'EX2', 20),
  ('dt-ex3', 'dawntrail', 'extreme_trial', 'The Minstrel''s Ballad: Sphene''s Burden', 'EX3', 30),
  ('dt-ex4', 'dawntrail', 'extreme_trial', 'Recollection (Extreme)', 'EX4', 40),
  ('dt-ex5', 'dawntrail', 'extreme_trial', 'The Minstrel''s Ballad: Necron''s Embrace', 'EX5', 50),
  ('dt-ex6', 'dawntrail', 'extreme_trial', 'The Windward Wilds (Extreme)', 'EX6', 60),
  ('dt-ex7', 'dawntrail', 'extreme_trial', 'Hell on Rails (Extreme)', 'EX7', 70),
  ('dt-ex8', 'dawntrail', 'extreme_trial', 'The Unmaking (Extreme)', 'EX8', 80),
  ('m1s', 'dawntrail', 'savage_raid', 'AAC Light-heavyweight M1 (Savage)', 'M1S', 10),
  ('m2s', 'dawntrail', 'savage_raid', 'AAC Light-heavyweight M2 (Savage)', 'M2S', 20),
  ('m3s', 'dawntrail', 'savage_raid', 'AAC Light-heavyweight M3 (Savage)', 'M3S', 30),
  ('m4s', 'dawntrail', 'savage_raid', 'AAC Light-heavyweight M4 (Savage)', 'M4S', 40),
  ('m5s', 'dawntrail', 'savage_raid', 'AAC Cruiserweight M1 (Savage)', 'M5S', 50),
  ('m6s', 'dawntrail', 'savage_raid', 'AAC Cruiserweight M2 (Savage)', 'M6S', 60),
  ('m7s', 'dawntrail', 'savage_raid', 'AAC Cruiserweight M3 (Savage)', 'M7S', 70),
  ('m8s', 'dawntrail', 'savage_raid', 'AAC Cruiserweight M4 (Savage)', 'M8S', 80),
  ('m9s', 'dawntrail', 'savage_raid', 'AAC Heavyweight M1 (Savage)', 'M9S', 90),
  ('m10s', 'dawntrail', 'savage_raid', 'AAC Heavyweight M2 (Savage)', 'M10S', 100),
  ('m11s', 'dawntrail', 'savage_raid', 'AAC Heavyweight M3 (Savage)', 'M11S', 110),
  ('m12s', 'dawntrail', 'savage_raid', 'AAC Heavyweight M4 (Savage)', 'M12S', 120)
on conflict (id) do update set
  expansion_id = excluded.expansion_id,
  category_id = excluded.category_id,
  name = excluded.name,
  short_name = excluded.short_name,
  sort_order = excluded.sort_order,
  is_active = true;
