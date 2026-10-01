-- JUMP_Hwangjun 사이트 편집 DB 설정 (Supabase > SQL Editor에 붙여넣고 Run)
-- 여러 번 실행해도 안전합니다.

create table if not exists public.site_config (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.site_history (
  id bigserial primary key,
  data jsonb not null,
  editor text,
  created_at timestamptz not null default now()
);

alter table public.site_config enable row level security;
alter table public.site_history enable row level security;

drop policy if exists "public read config" on public.site_config;
drop policy if exists "admin write config" on public.site_config;
drop policy if exists "admin update config" on public.site_config;
drop policy if exists "admin read history" on public.site_history;
drop policy if exists "admin write history" on public.site_history;

create policy "public read config" on public.site_config for select using (true);
create policy "admin write config" on public.site_config for insert to authenticated with check (true);
create policy "admin update config" on public.site_config for update to authenticated using (true) with check (true);
create policy "admin read history" on public.site_history for select to authenticated using (true);
create policy "admin write history" on public.site_history for insert to authenticated with check (true);

insert into storage.buckets (id, name, public) values ('site-images', 'site-images', true)
on conflict (id) do nothing;

drop policy if exists "public read images" on storage.objects;
drop policy if exists "admin upload images" on storage.objects;
drop policy if exists "admin update images" on storage.objects;

create policy "public read images" on storage.objects for select using (bucket_id = 'site-images');
create policy "admin upload images" on storage.objects for insert to authenticated with check (bucket_id = 'site-images');
create policy "admin update images" on storage.objects for update to authenticated using (bucket_id = 'site-images');

-- 다음 단계: Authentication > Users > Add user 에서
-- 관리자 이메일 + 비밀번호 계정을 만들고 (Auto Confirm 체크),
-- Authentication > Providers(Sign In / Providers) 에서 "Allow new users to sign up" 을 끄세요.
