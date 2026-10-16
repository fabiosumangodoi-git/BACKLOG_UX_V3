-- Rode no Supabase: SQL Editor > New query

create table if not exists public.initiatives (
  id         text primary key,
  data       jsonb not null,
  position   bigint not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.initiatives enable row level security;

-- Políticas públicas (permitem leitura e escrita direta sem exigir login)
drop policy if exists "initiatives_select" on public.initiatives;
drop policy if exists "initiatives_insert" on public.initiatives;
drop policy if exists "initiatives_update" on public.initiatives;
drop policy if exists "initiatives_delete" on public.initiatives;

create policy "initiatives_select" on public.initiatives for select using (true);
create policy "initiatives_insert" on public.initiatives for insert with check (true);
create policy "initiatives_update" on public.initiatives for update using (true) with check (true);
create policy "initiatives_delete" on public.initiatives for delete using (true);

-- Habilita atualização em tempo real
alter publication supabase_realtime add table public.initiatives;
