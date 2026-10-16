-- Rode no Supabase: SQL Editor > New query

create table if not exists public.initiatives (
  id         text primary key,
  data       jsonb not null,
  position   bigint not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.initiatives enable row level security;

-- Somente usuários logados (Supabase Auth) leem e escrevem.
create policy "initiatives_select" on public.initiatives for select to authenticated using (true);
create policy "initiatives_insert" on public.initiatives for insert to authenticated with check (true);
create policy "initiatives_update" on public.initiatives for update to authenticated using (true) with check (true);
create policy "initiatives_delete" on public.initiatives for delete to authenticated using (true);

-- Habilita atualização em tempo real
alter publication supabase_realtime add table public.initiatives;
