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
  add column if not exists collection text not null default '',
  add column if not exists document_html text not null default '<h1></h1>',
  add column if not exists document_line_height text not null default '1.65' check (document_line_height in ('1.4', '1.65', '1.9')),
  add column if not exists theme jsonb not null default '{"accent":"#bdff71","background":"#fbfbf9"}'::jsonb,
  add column if not exists is_private boolean not null default false,
  add column if not exists diagram_nodes jsonb not null default '[]'::jsonb,
  add column if not exists diagram_edges jsonb not null default '[]'::jsonb,
  add column if not exists code_source text not null default '';

alter table public.projects drop constraint if exists projects_project_type_check;
alter table public.projects add constraint projects_project_type_check
  check (project_type in ('model', 'presentation', 'gallery', 'document', 'mixed', 'diagram2d', 'diagram3d', 'code'));

create table if not exists public.project_sections (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (char_length(btrim(name)) between 1 and 50),
  created_at timestamptz not null default now()
);

create table if not exists public.project_collections (
  id uuid primary key default gen_random_uuid(),
  section_name text not null references public.project_sections(name) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 60),
  created_at timestamptz not null default now(),
  unique (section_name, name)
);

insert into public.project_sections (name)
select distinct btrim(section)
from public.projects
where btrim(section) <> ''
on conflict (name) do nothing;

insert into public.project_collections (section_name, name)
select distinct btrim(section), btrim(collection)
from public.projects
where btrim(section) <> '' and btrim(collection) <> ''
on conflict (section_name, name) do nothing;

alter table public.project_sections enable row level security;
alter table public.project_collections enable row level security;
grant select on public.project_sections, public.project_collections to anon, authenticated;
grant insert, delete on public.project_sections, public.project_collections to authenticated;

drop policy if exists "Anyone can read project sections" on public.project_sections;
drop policy if exists "Only the verified manager can add project sections" on public.project_sections;
drop policy if exists "Only the verified manager can delete empty project sections" on public.project_sections;
drop policy if exists "Anyone can read project collections" on public.project_collections;
drop policy if exists "Only the verified manager can add project collections" on public.project_collections;
drop policy if exists "Only the verified manager can delete unused project collections" on public.project_collections;

create policy "Anyone can read project sections"
  on public.project_sections for select using (true);
create policy "Only the verified manager can add project sections"
  on public.project_sections for insert to authenticated
  with check (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

drop policy if exists "Only the verified manager can access private project media" on storage.objects;
drop policy if exists "Only the verified manager can upload private project media" on storage.objects;
drop policy if exists "Only the verified manager can update private project media" on storage.objects;
drop policy if exists "Only the verified manager can delete private project media" on storage.objects;

create policy "Only the verified manager can access private project media"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'formline-private-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Only the verified manager can upload private project media"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'formline-private-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Only the verified manager can update private project media"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'formline-private-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  )
  with check (
    bucket_id = 'formline-private-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Only the verified manager can delete private project media"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'formline-private-media'
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );
create policy "Only the verified manager can delete empty project sections"
  on public.project_sections for delete to authenticated
  using (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
    and not exists (
      select 1 from public.projects
      where projects.section = project_sections.name
    )
  );
create policy "Anyone can read project collections"
  on public.project_collections for select using (true);
create policy "Only the verified manager can add project collections"
  on public.project_collections for insert to authenticated
  with check (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );
create policy "Only the verified manager can delete unused project collections"
  on public.project_collections for delete to authenticated
  using (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
    and not exists (
      select 1 from public.projects
      where projects.section = project_collections.section_name
        and projects.collection = project_collections.name
    )
  );

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
drop policy if exists "Only the verified manager can read private project comments" on public.project_comments;
drop policy if exists "Anyone can post project comments" on public.project_comments;
drop policy if exists "Only the verified manager can delete comments" on public.project_comments;

create policy "Anyone can read project comments"
  on public.project_comments for select
  using (
    exists (
      select 1 from public.projects
      where projects.id = project_comments.project_id and not projects.is_private
    )
  );

create policy "Only the verified manager can read private project comments"
  on public.project_comments for select to authenticated
  using (
    exists (
      select 1 from public.projects
      where projects.id = project_comments.project_id and projects.is_private
    )
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

create policy "Anyone can post project comments"
  on public.project_comments for insert to anon, authenticated
  with check (
    char_length(btrim(name)) between 1 and 40
    and char_length(btrim(body)) between 1 and 1000
    and exists (
      select 1 from public.projects
      where projects.id = project_comments.project_id and not projects.is_private
    )
  );

create policy "Only the verified manager can delete comments"
  on public.project_comments for delete to authenticated
  using (
    lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

drop policy if exists "Anyone can review projects" on public.projects;
drop policy if exists "Only the verified manager can read private projects" on public.projects;
drop policy if exists "Only the verified manager can create projects" on public.projects;
drop policy if exists "Only the verified manager can update projects" on public.projects;
drop policy if exists "Only the verified manager can delete projects" on public.projects;

create policy "Anyone can review projects"
  on public.projects for select
  using (not is_private);

create policy "Only the verified manager can read private projects"
  on public.projects for select to authenticated
  using (
    is_private
    and lower(auth.jwt() ->> 'email') = 'er275050@gmail.com'
    and auth.jwt() -> 'app_metadata' ->> 'provider' = 'google'
  );

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

insert into storage.buckets (id, name, public)
values ('formline-private-media', 'formline-private-media', false)
on conflict (id) do update set public = false, file_size_limit = 104857600;

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
