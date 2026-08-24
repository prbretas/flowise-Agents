# Workflow 11 - Sequential Agents (Pipeline de Agentes)

## 🎯 Objetivo

Criar um **pipeline de múltiplos agentes** que trabalham em sequência, como uma
"linha de montagem" onde cada agente é especialista em uma etapa.

**Caso de uso:** Um sistema de criação de artigos com 3 agentes:
1. **Pesquisador** → Cria o outline/estrutura
2. **Escritor** → Transforma em artigo completo
3. **Revisor** → Corrige e formata para publicação

---

## 📐 Arquitetura do Fluxo

```
                         ChatOpenAI (compartilhado entre todos)
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌─────────┐
│  START   │──▶│PESQUISADOR│──▶│ ESCRITOR  │──▶│ REVISOR   │──▶│   END   │
│          │   │           │   │           │   │           │   │         │
│ Recebe o │   │ Cria      │   │ Escreve o │   │ Revisa e  │   │ Retorna │
│ tema     │   │ outline   │   │ artigo    │   │ formata   │   │ final   │
└─────────┘   └──────────┘   └──────────┘   └──────────┘   └─────────┘
                    │               │               │
                    ▼               ▼               ▼
              "Seções:        "Artigo com      "Artigo final
               1. Intro        3 parágrafos    revisado com
               2. Conceitos    por seção..."   markdown..."
               3. Exemplos"
```

---

## 🆕 Conceito: Sequential Agents vs Agent Único

| Aspecto | Agent Único (Workflows 04-10) | Sequential Agents (Workflow 11) |
|---------|------------------------------|--------------------------------|
| Quem trabalha | 1 agente faz tudo | Vários agentes especializados |
| Qualidade | Boa para tarefas simples | Superior para tarefas complexas |
| Analogia | Um funcionário multitarefa | Equipe com especialistas |
| Resultado | Direto, rápido | Elaborado, multi-etapa |
| Custo tokens | Menor | Maior (cada agente é uma chamada) |
| Controle | Difícil de debugar | Cada etapa visível separadamente |

### Por que dividir em agentes?

```
PROMPT ÚNICO (ruim para tarefas complexas):
"Pesquise sobre IA, escreva um artigo e revise o texto"
→ Resultado: medíocre em tudo

PIPELINE (excelente para tarefas complexas):
Agente 1: "Foque APENAS em pesquisar e estruturar"
Agente 2: "Foque APENAS em escrever bem"
Agente 3: "Foque APENAS em revisar"
→ Resultado: excelente em cada etapa
```

---

## 🧩 Nodes Utilizados

### 1. Start Node ⭐ NOVO!
- **O que faz:** Ponto de entrada — recebe a mensagem do usuário
- **Analogia:** A "porta de entrada" da fábrica
- **Config:** Nenhuma (é apenas o ponto inicial)

### 2. Agent Nodes (3x) ⭐ NOVO!
- **O que faz:** Cada um é um agente especializado com seu próprio System Prompt
- **Diferencial:** Recebe a saída do agente anterior como contexto
- **Cada agente tem:**
  - `agentName` — Identificador (Pesquisador, Escritor, Revisor)
  - `systemPrompt` — Instruções específicas da especialidade
  - `model` — ChatOpenAI compartilhado
  - `tools` — Ferramentas opcionais
  - `sequentialNode` — Quem vem antes (conexão)

### 3. End Node ⭐ NOVO!
- **O que faz:** Marca o fim do pipeline e retorna o resultado ao usuário
- **Importante:** A resposta do ÚLTIMO agente é o que o usuário vê

### 4. ChatOpenAI (compartilhado)
- **Um modelo para todos:** Conectado aos 3 agentes
- **Alternativa:** Usar modelos diferentes (ex: gpt-4o para Pesquisador, gpt-4o-mini para Revisor)

---

## 🧠 Como os Agentes se Comunicam

```
Usuário: "Escreva um artigo sobre inteligência artificial"
         │
         ▼
┌─ PESQUISADOR ──────────────────────────────────┐
│ Input: "Escreva um artigo sobre IA"             │
│ Output: "Título: O Futuro da IA                 │
│          1. O que é IA                          │
│          2. Machine Learning vs Deep Learning   │
│          3. Aplicações no dia-a-dia             │
│          4. Desafios éticos                     │
│          Conclusão: Impacto no futuro"          │
└────────────────────────────────────────────────┘
         │ (output vira input do próximo)
         ▼
┌─ ESCRITOR ─────────────────────────────────────┐
│ Input: outline do Pesquisador                   │
│ Output: Artigo completo com 4 seções,           │
│         cada uma com 2-3 parágrafos bem         │
│         escritos e envolventes                  │
└────────────────────────────────────────────────┘
         │ (output vira input do próximo)
         ▼
┌─ REVISOR ──────────────────────────────────────┐
│ Input: artigo do Escritor                       │
│ Output: Artigo final revisado, formatado em     │
│         markdown, com gramática corrigida       │
│         ✅ Artigo revisado e aprovado           │
└────────────────────────────────────────────────┘
         │
         ▼
     [Retorna ao usuário]
```

---

## ⚙️ Como Configurar

1. **Importe** `sequential-agents.json`
2. **IMPORTANTE:** Este é um **Agentflow** (não Chatflow)!
   - No Flowise, crie via **Agentflows → Add New** (não Chatflows)
   - Ou ao importar, selecione "Load Agentflow"
3. **API Key:** Configure no ChatOpenAI (um para todos)
4. **Salve** e teste com temas de artigo

---

## 🧪 Testes Sugeridos

### Temas para testar

| Seu input | O que observar |
|-----------|----------------|
| "Escreva um artigo sobre inteligência artificial" | Pipeline completo: outline → artigo → revisão |
| "Crie um texto sobre alimentação saudável" | Pesquisador estrutura, Escritor expande, Revisor formata |
| "Artigo sobre o mercado de criptomoedas em 2025" | Observe cada etapa agregando valor |
| "Texto curto sobre home office" | Mesmo com tema simples, pipeline executa |

### O que observar em cada etapa

No Flowise, após rodar, você pode ver o **log de cada agente** clicando no ícone
de debug. Compare:
- **Pesquisador:** Output é um outline com bullets
- **Escritor:** Output é prosa completa
- **Revisor:** Output é texto polido com markdown

---

## 📊 Quando Usar Sequential Agents

| Cenário | Recomendado? | Por quê |
|---------|-------------|---------|
| Geração de conteúdo (blog, artigo) | ✅ Sim | Pesquisa → Escrita → Revisão |
| Análise de dados | ✅ Sim | Coleta → Análise → Relatório |
| Atendimento ao cliente simples | ❌ Não | Um agente basta |
| Code Review | ✅ Sim | Análise → Sugestões → Implementação |
| FAQ simples | ❌ Não | Overkill para perguntas diretas |
| Relatórios executivos | ✅ Sim | Dados → Análise → Formatação |

---

## 🔄 Variações para Praticar

### 1. Pipeline de Análise de Sentimento
```
[Coletor] → [Analisador] → [Gerador de Relatório]
- Coletor: recebe reviews/feedback
- Analisador: classifica sentimento e extrai insights
- Gerador: cria relatório executivo
```

### 2. Pipeline de Email Profissional
```
[Rascunhador] → [Refinador] → [Tradutor]
- Rascunhador: cria versão inicial do email
- Refinador: melhora tom e clareza
- Tradutor: traduz para inglês se necessário
```

### 3. Adicionar Tools a agentes específicos
- Dê ao Pesquisador acesso a SearchApi (pesquisa web real)
- Dê ao Revisor acesso a uma tool de verificação ortográfica
- Mantenha o Escritor sem tools (foca em criatividade)

### 4. Pipeline com 5+ agentes
```
[Pesquisador] → [Estruturador] → [Escritor] → [Revisor] → [SEO Optimizer]
```

---

## ⚠️ Diferença: Chatflow vs Agentflow

| Aspecto | Chatflow | Agentflow |
|---------|----------|-----------|
| Onde criar | Menu "Chatflows" | Menu "Agentflows" |
| Nodes disponíveis | Chains, LLMs, Memory | Sequential Agents, Start/End, Conditions |
| Tipo de fluxo | Linear (input → output) | Grafo dirigido (loops, condições) |
| Quando usar | Chatbots, RAG, LLM simples | Multi-agent, workflows complexos |

> **IMPORTANTE:** Sequential Agents SÓ funcionam em Agentflows!
> Se importar em Chatflow, não vai funcionar.

---

## 📖 Conceitos Aprendidos

- ✅ O que são **Sequential Agents** e quando usar
- ✅ A arquitetura **Start → Agent → Agent → ... → End**
- ✅ Como agentes **passam informação** de um para o outro
- ✅ A diferença entre **Chatflow e Agentflow** no Flowise
- ✅ O princípio de **especialização** (cada agente faz uma coisa bem)
- ✅ Como dividir tarefas complexas em **etapas menores**
- ✅ Trade-off: qualidade superior vs custo de tokens maior

---

## ➡️ Próximo Passo

Vá para **Workflow 12 - Roteamento Condicional** para aprender a criar
agentes que tomam DECISÕES e seguem caminhos diferentes baseados na entrada!
