# UX Ops & Backlog Hub

Site estático (sem build). Dados no Supabase com Realtime; deploy na Vercel.

## 1. Supabase
1. Crie um projeto em supabase.com.
2. SQL Editor: cole e rode `supabase/schema.sql`.
3. Project Settings > API: copie **Project URL** e **anon public key** para `config.js`.

Na primeira abertura com a tabela vazia, os dados iniciais são inseridos automaticamente.

## 2. Vercel
1. Suba esta pasta para um repositório GitHub.
2. Na Vercel: Add New > Project > importe o repositório (Framework Preset: **Other**, sem build command, output = raiz).
3. Deploy. Cada `git push` republica.

Alternativa: `npx vercel` dentro da pasta.

## Teste local
`npx serve .` e abra o endereço. Sem `config.js` preenchido, funciona em modo local (localStorage).

## Login
O site exige e-mail e senha quando o Supabase está configurado.
1. Authentication > Providers > Email: desative **Allow new users to sign up** (e, se quiser, "Confirm email").
2. Authentication > Users > **Add user**: crie cada pessoa da equipe com e-mail e senha.

As policies (RLS) permitem leitura/escrita apenas para usuários autenticados.
Se você já tinha rodado o schema antigo, apague as policies `initiatives_*` e rode o `schema.sql` de novo.
