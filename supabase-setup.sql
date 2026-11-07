create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null default 'Untitled process',
  steps jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.projects
  add column if not exists project_type text not null default 'model' check (project_type in ('model', 'presentation', 'gallery')),
  add column if not exists section text not null default 'Engineering',
  add column if not exists theme jsonb not null default '{"accent":"#bdff71","background":"#fbfbf9"}'::jsonb;

alter table public.projects enable row level security;

grant select on public.projects to anon, authenticated;
grant insert, update, delete on public.projects to authenticated;

create table if not exists public.project_comments (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null default 'Anonymous' check (char_length(btrim(name)) between 1 and 40),
  body text not null check (char_length(btrim(body)) between 1 and 1000),
  created_at timestamptz not null default now()
);

create index if not exists project_comments_project_created_idx
  on public.project_comments (project_id, created_at);

alter table public.project_comments enable row level security;
grant select, insert on public.project_comments to anon, authenticated;
grant delete on public.project_comments to authenticated;

drop policy if exists "Anyone can read project comments" on public.project_comments;
drop policy if exists "Anyone can post project comments" on public.project_comments;
drop policy if exists "Only the verified manager can delete comments" on public.project_comments;

create policy "Anyone can read project comments"
  on public.project_comments for select
  using (true);

create policy "Anyone can post project comments"
  on public.project_comments for insert to anon, authenticated
  with check (
    char_length(btrim(name)) between 1 and 40
    and char_length(btrim(body)) between 1 and 1000
  );

create policy "Only the verified manager can delete comments"
  on public.project_comments for delete to authenticated
  using (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

drop policy if exists "Anyone can review projects" on public.projects;
drop policy if exists "Only the verified manager can create projects" on public.projects;
drop policy if exists "Only the verified manager can update projects" on public.projects;
drop policy if exists "Only the verified manager can delete projects" on public.projects;

create policy "Anyone can review projects"
  on public.projects for select
  using (true);

create policy "Only the verified manager can create projects"
  on public.projects for insert to authenticated
  with check (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Only the verified manager can update projects"
  on public.projects for update to authenticated
  using (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  )
  with check (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Only the verified manager can delete projects"
  on public.projects for delete to authenticated
  using (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

insert into storage.buckets (id, name, public)
values ('formline-media', 'formline-media', true)
on conflict (id) do update set public = true, file_size_limit = 104857600;

drop policy if exists "Anyone can view project media" on storage.objects;
drop policy if exists "Only the verified manager can upload project media" on storage.objects;
drop policy if exists "Only the verified manager can update project media" on storage.objects;
drop policy if exists "Only the verified manager can delete project media" on storage.objects;

create policy "Anyone can view project media"
  on storage.objects for select
  using (bucket_id = 'formline-media');

create policy "Only the verified manager can upload project media"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'formline-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Only the verified manager can update project media"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'formline-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  )
  with check (
    bucket_id = 'formline-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Only the verified manager can delete project media"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'formline-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );
