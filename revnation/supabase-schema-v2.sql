-- ============================================================
-- REV NATION JAIPUR — Supabase schema v2
-- Run this ONCE in your new Supabase project:
--   Dashboard → SQL Editor → New query → paste → Run
-- It creates all tables, security policies, storage buckets
-- and starter content for the live site + studio-gate-88.html
-- ============================================================

-- ---------------- Tables ----------------

create table if not exists public.leads (
  id         bigint generated always as identity primary key,
  name       text not null,
  phone      text not null,
  city       text,
  car        text,
  service    text,
  message    text,
  status     text not null default 'new' check (status in ('new','contacted','closed')),
  created_at timestamptz not null default now()
);

create table if not exists public.projects (
  id          bigint generated always as identity primary key,
  title       text not null,
  car_make    text,
  car_model   text,
  service_type text,
  cover_image text,
  before_url  text,
  after_url   text,
  published   boolean not null default true,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.services (
  id          bigint generated always as identity primary key,
  title       text not null,
  category    text,
  description text,
  image_url   text,
  published   boolean not null default true,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.testimonials (
  id         bigint generated always as identity primary key,
  name       text not null,
  city       text,
  car        text,
  quote      text not null,
  published  boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.stats (
  id         bigint generated always as identity primary key,
  label      text not null,
  value      integer not null default 0,
  suffix     text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.site_media (
  key        text primary key,
  url        text not null default '',
  label      text,
  updated_at timestamptz not null default now()
);

create table if not exists public.frame_sequences (
  id          bigint generated always as identity primary key,
  project_id  bigint references public.projects(id) on delete set null,
  folder_path text not null,
  frame_count integer not null default 0,
  section_key text not null,
  created_at  timestamptz not null default now()
);

-- Helpful indexes
create index if not exists leads_created_idx on public.leads (created_at desc);
create index if not exists leads_status_idx on public.leads (status);
create index if not exists projects_published_idx on public.projects (published, sort_order);
create index if not exists services_sort_idx on public.services (published, sort_order);
create index if not exists testimonials_sort_idx on public.testimonials (published, sort_order);
create unique index if not exists frame_seq_section_idx on public.frame_sequences (section_key);

-- ---------------- Row Level Security ----------------
-- anon (website visitors): can read published content + submit leads.
-- authenticated (you, signed into studio-gate-88.html): full access.

alter table public.leads          enable row level security;
alter table public.projects       enable row level security;
alter table public.services       enable row level security;
alter table public.testimonials   enable row level security;
alter table public.stats          enable row level security;
alter table public.site_media     enable row level security;
alter table public.frame_sequences enable row level security;

-- leads
drop policy if exists "leads_insert_public" on public.leads;
create policy "leads_insert_public" on public.leads
  for insert to anon, authenticated with check (true);
drop policy if exists "leads_admin_read" on public.leads;
create policy "leads_admin_read" on public.leads
  for select to authenticated using (true);
drop policy if exists "leads_admin_update" on public.leads;
create policy "leads_admin_update" on public.leads
  for update to authenticated using (true) with check (true);
drop policy if exists "leads_admin_delete" on public.leads;
create policy "leads_admin_delete" on public.leads
  for delete to authenticated using (true);

-- projects
drop policy if exists "projects_public_read" on public.projects;
create policy "projects_public_read" on public.projects
  for select to anon, authenticated using (published = true or auth.role() = 'authenticated');
drop policy if exists "projects_admin_write" on public.projects;
create policy "projects_admin_write" on public.projects
  for all to authenticated using (true) with check (true);

-- services
drop policy if exists "services_public_read" on public.services;
create policy "services_public_read" on public.services
  for select to anon, authenticated using (published = true or auth.role() = 'authenticated');
drop policy if exists "services_admin_write" on public.services;
create policy "services_admin_write" on public.services
  for all to authenticated using (true) with check (true);

-- testimonials
drop policy if exists "testimonials_public_read" on public.testimonials;
create policy "testimonials_public_read" on public.testimonials
  for select to anon, authenticated using (published = true or auth.role() = 'authenticated');
drop policy if exists "testimonials_admin_write" on public.testimonials;
create policy "testimonials_admin_write" on public.testimonials
  for all to authenticated using (true) with check (true);

-- stats
drop policy if exists "stats_public_read" on public.stats;
create policy "stats_public_read" on public.stats
  for select to anon, authenticated using (true);
drop policy if exists "stats_admin_write" on public.stats;
create policy "stats_admin_write" on public.stats
  for all to authenticated using (true) with check (true);

-- site_media
drop policy if exists "site_media_public_read" on public.site_media;
create policy "site_media_public_read" on public.site_media
  for select to anon, authenticated using (true);
drop policy if exists "site_media_admin_write" on public.site_media;
create policy "site_media_admin_write" on public.site_media
  for all to authenticated using (true) with check (true);

-- frame_sequences (admin only — the live site doesn't read these)
drop policy if exists "frames_admin_all" on public.frame_sequences;
create policy "frames_admin_all" on public.frame_sequences
  for all to authenticated using (true) with check (true);

-- ---------------- Storage buckets ----------------
-- Public to read, writable only by signed-in admin.

insert into storage.buckets (id, name, public)
values
  ('project-images',  'project-images',  true),
  ('site-assets',     'site-assets',     true),
  ('frame-sequences', 'frame-sequences', true)
on conflict (id) do nothing;

drop policy if exists "storage_public_read" on storage.objects;
create policy "storage_public_read" on storage.objects
  for select to anon, authenticated
  using (bucket_id in ('project-images','site-assets','frame-sequences'));

drop policy if exists "storage_admin_insert" on storage.objects;
create policy "storage_admin_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id in ('project-images','site-assets','frame-sequences'));

drop policy if exists "storage_admin_update" on storage.objects;
create policy "storage_admin_update" on storage.objects
  for update to authenticated
  using (bucket_id in ('project-images','site-assets','frame-sequences'))
  with check (bucket_id in ('project-images','site-assets','frame-sequences'));

drop policy if exists "storage_admin_delete" on storage.objects;
create policy "storage_admin_delete" on storage.objects
  for delete to authenticated
  using (bucket_id in ('project-images','site-assets','frame-sequences'));

-- ---------------- Starter content (matches the live site) ----------------

insert into public.stats (label, value, suffix, sort_order) values
  ('Vehicles Serviced', 4200, '+', 1),
  ('Sq.Ft Facility',    28,   'k', 2),
  ('Install Bays',      12,   '',  3),
  ('Years Active',      11,   '',  4)
on conflict do nothing;

insert into public.services (title, category, description, sort_order) values
  ('Modifications',   'modification', 'Wraps, alloy wheels, lighting upgrades, and custom interior builds.', 1),
  ('Protection Film', 'protection',   'Self-healing, optically clear defense against stone chips and abrasions.', 2),
  ('Ceramic Coating', 'protection',   'Chemical-resistant, deep gloss layer that locks in true paint depth.', 3),
  ('Detailing',       'detailing',    'Multi-stage machine correction that restores and perfects factory clarity.', 4)
on conflict do nothing;

insert into public.testimonials (name, car, city, quote, sort_order) values
  ('Aditya R.', 'Thar Wrap',     'Jaipur', 'The wrap and wheel swap turned heads. Cleanest install in Jaipur.', 1),
  ('Meher K.',  'Audi Q8 PPF',   'Jaipur', 'Edge work is cleaner than the factory finish.', 2),
  ('Karan V.',  'Mercedes GLE',  'Jaipur', 'Two years in Rajasthan heat, and the coating still beads water like day one.', 3),
  ('Priya M.',  'Porsche 911',   'Jaipur', 'Smooth integration that exceeded expectations. The results speak for themselves.', 4)
on conflict do nothing;

-- Create your admin login afterwards (does NOT live in SQL):
--   Dashboard → Authentication → Users → Add user → email + password
-- Then sign in at /studio-gate-88.html with that email/password.
