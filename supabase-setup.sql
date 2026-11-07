create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null default 'Untitled process',
  steps jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.projects enable row level security;

grant select on public.projects to anon, authenticated;
grant insert, update, delete on public.projects to authenticated;

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
on conflict (id) do update set public = true;

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
