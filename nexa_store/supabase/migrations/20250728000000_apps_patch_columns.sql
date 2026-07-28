-- Run in Supabase SQL editor if columns are missing.
alter table public.apps
  add column if not exists patch_url text,
  add column if not exists patch_sha256 text;

create unique index if not exists apps_package_name_key on public.apps (package_name);
