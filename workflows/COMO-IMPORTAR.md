# Como Importar Workflows no Flowise

## Pre-requisitos

- Flowise rodando em http://localhost:3000
- Ollama rodando com modelos `llama3.2` e `nomic-embed-text`
- Os arquivos `.json` deste repositorio

> Use `.\iniciar.ps1` para subir tudo automaticamente.

---

## Importar um Chatflow (Workflows 01 a 10, 13 e 15)

### Passo 1 — Abrir o Flowise
Acesse `http://localhost:3000` no navegador.

### Passo 2 — Criar novo Chatflow
No menu lateral esquerdo, clique em **"Chatflows"**.
Depois clique no botao **"+ Add New"** (canto superior direito).

### Passo 3 — Carregar o JSON
Na tela do canvas (area branca com grid), olhe no canto superior esquerdo.
Clique no icone **"⋮" (tres pontos verticais)** → **"Load Chatflow"**.

### Passo 4 — Selecionar o arquivo
Navegue ate a pasta do workflow e selecione o `.json`.

### Passo 5 — Salvar
Clique no botao **💾 (disquete)** no canto superior direito.
De um nome ao chatflow (ex: "01 - Chatbot Simples").

### Passo 6 — Testar
Clique no icone **💬 (balao de chat)** no canto inferior direito.
Digite uma mensagem e veja a resposta.

---

## Importar um Agentflow (Workflows 11, 12 e 14)

Os workflows 11 (Sequential Agents), 12 (Roteamento Condicional) e 14 (Multi-Agent Supervisor)
sao **Agentflows** — usam nodes diferentes (Start, Agent, Condition, End).

### Passo 1 — Ir para Agentflows
No menu lateral esquerdo, clique em **"Agentflows"** (nao Chatflows!).

### Passo 2 — Criar novo Agentflow
Clique no botao **"+ Add New"**.

### Passo 3 — Carregar o JSON
No canvas, clique em **"⋮" (tres pontos)** → **"Load Chatflow"**.
(O botao tem o mesmo nome, mas funciona para Agentflows tambem.)

### Passo 4 — Selecionar, salvar e testar
Mesmo processo: selecione o JSON, salve, abra o chat.

---

## Tabela de Workflows

| # | Workflow | Tipo | Arquivo JSON |
|---|---------|------|-------------|
| 01 | Chatbot Simples | Chatflow | `01-chatbot-simples/chatbot-simples.json` |
| 02 | Chatbot com Memoria | Chatflow | `02-chatbot-com-memoria/chatbot-memoria.json` |
| 03 | RAG com Documentos | Chatflow | `03-rag-documentos/rag-documentos.json` |
| 04 | Agente com Tools | Chatflow | `04-agente-com-tools/agente-tools.json` |
| 05 | Agente Custom Tool | Chatflow | `05-agente-custom-tool/agente-custom-tool.json` |
| 06 | RAG Multiplas Fontes | Chatflow | `06-rag-multiplas-fontes/rag-multiplas-fontes.json` |
| 07 | Structured Output | Chatflow | `07-structured-output/structured-output.json` |
| 08 | RAG + Agent | Chatflow | `08-rag-agent-combinado/rag-agent-combinado.json` |
| 09 | Moderacao e Filtros | Chatflow | `09-moderacao-filtros/moderacao-filtros.json` |
| 10 | Multiplas Custom Tools | Chatflow | `10-multiplas-custom-tools/multiplas-custom-tools.json` |
| 11 | Sequential Agents | **Agentflow** | `11-sequential-agents/sequential-agents.json` |
| 12 | Roteamento Condicional | **Agentflow** | `12-roteamento-condicional/roteamento-condicional.json` |
| 13 | RAG Avancado Reranker | Chatflow | `13-rag-avancado-reranker/rag-avancado-reranker.json` |
| 14 | Multi-Agent Supervisor | **Agentflow** | `14-multi-agent-supervisor/multi-agent-supervisor.json` |
| 15 | Chatbot Full-Stack | Chatflow | `15-chatbot-fullstack-deploy/chatbot-fullstack.json` |

---

## Configuracao por Workflow (Ollama)

Todos os workflows ja vem configurados para Ollama. Nao precisa de API key.

Os nodes **ChatOllama** e **Ollama Embeddings** usam:
- **Base URL:** `http://host.containers.internal:11434`
- **Chat Model:** `llama3.2`
- **Embeddings Model:** `nomic-embed-text`
- **Temperature:** varia por workflow (indicado em cada README)

> **Se rodar Flowise FORA do container** (direto no Windows), troque
> `host.containers.internal` por `localhost` nos nodes.

### Workflows com configuracao extra

| Workflow | O que configurar alem do padrao |
|----------|--------------------------------|
| 03 (RAG) | Upload de PDF + clicar Upsert |
| 05 (Custom Tool) | Criar a tool ANTES em Tools → Add New (ver README do 05) |
| 06 (Multiplas Fontes) | Upload PDF + Upload TXT + URL do web scraper + Upsert |
| 08 (RAG + Agent) | Upload de PDF + Upsert |
| 10 (Multi Tools) | Criar 3 custom tools ANTES (CEP, Clima, Crypto) |
| 13 (Reranker) | Upload de PDF + Upsert |

---

## O que e "Upsert"?

Nos workflows com RAG (03, 06, 08, 13), apos fazer upload do documento:

1. Clique no icone **↑ (seta para cima)** ou botao **"Upsert"** no topo do canvas
2. Isso processa o documento: divide em chunks → gera embeddings → armazena no vector store
3. **Sem isso, o chatbot nao tera acesso ao conteudo do documento**

Voce precisa fazer Upsert novamente se:
- Trocar o documento
- Reiniciar o Flowise (pois usa In-Memory Vector Store)

---

## Como saber se esta funcionando

- ✅ Todos os nodes conectados (linhas entre eles)
- ✅ Nenhum node com borda vermelha
- ✅ Chat abre sem erro ao clicar no icone de balao
- ✅ Resposta aparece em alguns segundos (Ollama local pode demorar 5-15s)

---

## Problemas Comuns

| Problema | Causa | Solucao |
|----------|-------|---------|
| "Unable to load chatflow" | JSON mal formado | Baixe novamente do repo |
| Nodes desconectados | Versao diferente do Flowise | Reconecte manualmente as linhas |
| Erro no ChatOllama | Ollama nao rodando | Execute `ollama serve` ou `.\iniciar.ps1` |
| "Model not found" | Modelo nao baixado | Execute `ollama pull llama3.2` |
| Resposta vazia no RAG | PDF nao processado | Clique em "Upsert" apos upload |
| Custom Tool nao aparece | Tool nao criada ainda | Crie em Tools → Add New primeiro |
| Timeout / muito lento | Modelo pesado + pouca RAM | Use `llama3.2` (leve) em vez de modelos maiores |
| "Connection refused" no ChatOllama | URL errada | Use `http://host.containers.internal:11434` |
| Agentflow nao importa em Chatflow | Tipo errado | Use menu "Agentflows" para workflows 11, 12, 14 |

---

## Ordem Recomendada

```
.\iniciar.ps1 -Instalar     ← primeira vez (baixa modelos)
.\iniciar.ps1               ← sobe tudo
         │
         ▼
Workflow 01 (Chatbot Simples)         ← comece aqui
         │
         ▼
Workflow 02 (Com Memoria)             ← adiciona memoria
         │
         ▼
Workflow 03 (RAG)                     ← chat com seus PDFs
         │
         ▼
Workflow 04 (Agent + Tools)           ← agente com calculadora
         │
         ▼
Workflow 05 (Custom Tool)             ← crie suas ferramentas
         │
         ▼
Workflows 06-10 (Intermediarios)      ← aprofundamento
         │
         ▼
Workflows 11-15 (Avancados)           ← multi-agent, deploy
```
