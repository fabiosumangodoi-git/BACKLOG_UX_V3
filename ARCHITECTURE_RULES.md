# REGRAS IMUTÁVEIS DA ARQUITETURA - LEIA ANTES DE EDITAR

Este documento estabelece as diretrizes fundamentais e invioláveis de arquitetura, persistência e interface do projeto **AD • UX Ops & Backlog Hub**. Qualquer agente de IA ou desenvolvedor deve seguir rigorosamente estas regras.

---

## REGRA 1: IMUTABILIDADE DO DESIGN SYSTEM E UI
- É **estritamente proibido** alterar cores, fontes, espaçamentos, layout de componentes existentes, cabeçalho, filtros de navegação ou estrutura de abas sem solicitação explícita no prompt.
- Nenhuma modificação em estilos Tailwind, tema ou estrutura de apresentação deve ser feita como "efeito colateral" de correções de lógica ou persistência.
- A experiência visual da interface (design system, componentes, ícones, modais e responsividade) é sagrada e deve permanecer 100% preservada.

---

## REGRA 2: CONSTANTES GLOBAIS INTOCÁVEIS
- Nunca remova, renomeie ou altere o escopo das constantes globais essenciais:
  - `OWNER_NAMES` (e `window.OWNER_NAMES`): mapeamento dos designers responsáveis.
  - `OWNER_COLORS` (e `window.OWNER_COLORS`): paleta de cores dos owners.
  - `STATUS_LIST`: ordem e nomenclatura das colunas do Kanban.
  - `PI_OPTIONS`, `BRAND_OPTIONS`, `TYPE_OPTIONS`, `STREAM_OPTIONS`, `JOURNEY_OPTIONS`, `METRIC_OPTIONS`, `SPRINT_OPTIONS`.
  - Credenciais e configurações em `config.js` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `window.APP_CONFIG`).

---

## REGRA 3: PERSISTÊNCIA UNIVERSAL JSONB NO SUPABASE
- A tabela `public.initiatives` no Supabase possui o seguinte esquema:
  - `id` (text, Primary Key)
  - `data` (jsonb)
  - `position` (int8)
  - `updated_at` (timestamptz)
- **Proibido criar filtros de descarte:** É expressamente proibido criar funções de mapeamento (`normalize`, `sanitize`, `toSupabase`, etc.) que filtrem, limpem ou omitam propriedades do objeto do card.
- **Gravação (Upsert):** Todo salvamento DEVE enviar o objeto completo `{ ...card }` encapsulado dentro da coluna `data`:
  ```javascript
  await supabaseClient.from('initiatives').upsert({
    id: String(card.id),
    data: { ...card, updatedAt: new Date().toISOString() },
    position: Number(card.position) || 0,
    updated_at: new Date().toISOString()
  }, { onConflict: 'id' });
  ```
- **Leitura (Select):** Todo carregamento do Supabase DEVE mesclar o objeto padrão com os dados salvos em `row.data`, preservando 100% das chaves gravadas no banco:
  ```javascript
  const card = { ...baseCard, ...(row.data || {}), id: String(row.id) };
  ```
- Propriedades como `macrotemas`, `acompanhaDados`, `startDate`, `endDate`, `sprints`, `piConclusaoUp`, `piConclusaoDown`, `dataProducao`, `productionDate`, `comments` e campos executivos NUNCA devem ser descartados ou resetados para valores vazios/padrão durante o ciclo de vida da aplicação.

---

## REGRA 4: FONTE DA VERDADE (SUPABASE FIRST)
- Dados retornados de `public.initiatives` no Supabase SEMPRE têm **prioridade absoluta** sobre o `localStorage` e sobre qualquer array inicial de seed (`DEFAULT_INITIATIVES` / `INITIAL_DATA`).
- Ao carregar a página (Refresh / F5):
  1. O Supabase é consultado imediatamente (`select('*')`).
  2. Havendo registros no Supabase, eles são adotados como o estado oficial e gravados no `localStorage` como cache de leitura.
  3. Nunca sobrescreva registros do Supabase com dados locais antigos ou com sementes padrão.
  4. O `localStorage` atua exclusivamente como cache offline / fallback quando não há conexão com o Supabase.
