-- Rode no Supabase: SQL Editor > New query

create table if not exists public.initiatives (
  id         text primary key,
  data       jsonb not null,
  position   bigint not null default 0,
  updated_at timestamptz not null default now()
);

-- 1. Desativa RLS: o acesso é controlado pelo login da interface (nome + senha da equipe)
alter table public.initiatives disable row level security;

-- 2. Permissão total para a chave anon (usada pelo site na Vercel)
grant all on table public.initiatives to anon, authenticated, service_role;

-- 3. Habilita Realtime (ignora erro se a tabela já estiver na publicação)
do $$
begin
  alter publication supabase_realtime add table public.initiatives;
exception when duplicate_object then
  null;
end $$;
