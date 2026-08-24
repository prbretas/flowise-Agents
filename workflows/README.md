# 🤖 Flowise - Guia Completo para Iniciantes

## O que é o Flowise?

Flowise é uma ferramenta **open-source** que permite criar aplicações de IA (chatbots, agentes, RAG)
de forma visual, arrastando e conectando blocos (nodes) em um canvas. Ao final, você tem uma API
pronta para integrar em qualquer aplicação.

**Analogia simples:** Pense no Flowise como um "Lego de IA" — cada peça (node) tem uma função
específica e, ao conectá-las, você monta um sistema completo.

---

## 📋 Pré-requisitos

| Requisito | Versão Mínima | Para que serve |
|-----------|---------------|----------------|
| Node.js | 18.x ou superior | Rodar o Flowise |
| npm | 9.x ou superior | Instalar pacotes |
| Chave API OpenAI | — | Opcional (se quiser usar GPT além do Ollama) |
| Ollama | Instalado | Rodar modelos locais gratuitamente |

> **Nota:** Todos os workflows usam **Ollama** (gratuito, local) como padrão.
> Não precisa de API key! Basta ter o Ollama instalado com os modelos baixados.

---

## 🚀 Instalação do Flowise

### Opção 1: Podman (Recomendada — funciona em redes corporativas)

```powershell
# Iniciar a máquina Podman (apenas primeira vez ou após reinício)
podman machine start

# Baixar e rodar o Flowise (versão estável 2.2.7)
podman run -d --name flowise -p 3000:3000 -v flowise_data:/root/.flowise docker.io/flowiseai/flowise:2.2.7
```

**Comandos úteis:**
```powershell
# Ver se está rodando
podman ps

# Ver logs
podman logs flowise --tail 20

# Parar o Flowise
podman stop flowise

# Reiniciar o Flowise
podman start flowise

# Remover e recriar (limpa tudo)
podman stop flowise; podman rm flowise
podman run -d --name flowise -p 3000:3000 -v flowise_data:/root/.flowise docker.io/flowiseai/flowise:2.2.7
```

> **Nota:** O volume `flowise_data` persiste seus dados (chatflows, credentials, etc.)
> entre reinícios. Seus workflows não se perdem ao parar/iniciar o container.

### Opção 2: Docker (alternativa ao Podman)

```bash
docker run -d --name flowise -p 3000:3000 -v flowise_data:/root/.flowise flowiseai/flowise:2.2.7
```

### Opção 3: NPM (pode ter problemas em redes corporativas)

```bash
npm install -g flowise
npx flowise start
```

> ⚠️ Se encontrar erros de certificado SSL ou permissão, prefira Podman/Docker.

Após iniciar, acesse: **http://localhost:3000**

---

## ⚡ Script de Inicialização Rápida

Use o script `iniciar.ps1` para subir todo o ambiente com um comando:

```powershell
# Primeira vez (baixa os modelos Ollama)
.\iniciar.ps1 -Instalar

# Iniciar tudo (Ollama + Podman + Flowise) e abre o navegador
.\iniciar.ps1

# Ver status dos serviços
.\iniciar.ps1 -Status

# Parar tudo
.\iniciar.ps1 -Parar
```

O script faz automaticamente:
1. Inicia o Ollama (servidor de modelos locais)
2. Verifica se os modelos estão baixados (llama3.2 + nomic-embed-text)
3. Inicia a Podman Machine
4. Cria/inicia o container Flowise
5. Abre o navegador em http://localhost:3000

---

## 🧩 Conceitos Fundamentais

### Tipos de Fluxo no Flowise

| Tipo | Descrição | Quando usar |
|------|-----------|-------------|
| **Chatflow** | Fluxo linear para chatbots e pipelines simples | Chatbots, RAG simples, Q&A |
| **Agentflow** | Fluxo com agentes que decidem ações | Agentes com ferramentas, decisões complexas, multi-agent |

### Componentes Principais (Nodes)

| Categoria | Exemplos | Função |
|-----------|----------|--------|
| **Chat Models** | ChatOpenAI, ChatOllama, ChatAnthropic | O "cérebro" — modelo de linguagem |
| **Memory** | Buffer Memory, Window Memory | Lembrar conversas anteriores |
| **Chains** | LLM Chain, Conversational Chain | Conectar prompt + modelo + saída |
| **Vectors/Embeddings** | Pinecone, ChromaDB, FAISS | Armazenar e buscar documentos |
| **Document Loaders** | PDF, TXT, Web Scraper | Carregar dados externos |
| **Tools** | Calculator, Web Search, Custom Tool | Ferramentas que o agente pode usar |
| **Agents** | OpenAI Function Agent, Sequential Agents | Agentes que decidem qual tool usar |
| **Prompts** | Chat Prompt Template, System Message | Instruções para o modelo |
| **Output Parsers** | Structured Output Parser | Forçar formato JSON na resposta |
| **Moderation** | OpenAI Moderation, Deny List | Filtrar conteúdo impróprio |

### Como os Nodes se Conectam

```
[Prompt Template] ──→ [LLM Chain] ←── [Chat Model]
                          │
                          ▼
                      [Resposta]
```

Cada node tem:
- **Inputs (entradas):** Pontos de conexão à esquerda
- **Outputs (saídas):** Pontos de conexão à direita
- **Parâmetros:** Configurações internas (ex: temperatura, modelo)

---

## 📁 Estrutura deste Repositório

```
FLOWISE/
├── README.md                              ← Este arquivo (guia principal)
├── COMO-IMPORTAR.md                       ← Guia passo-a-passo para importar workflows
│
├── workflows/
│   │
│   │── ─── NÍVEL BÁSICO (01-05) ─────────────────────────────────────
│   │
│   ├── 01-chatbot-simples/                ← Prompt + Modelo + LLM Chain
│   │   ├── README.md
│   │   └── chatbot-simples.json
│   │
│   ├── 02-chatbot-com-memoria/            ← Conversation Chain + Buffer Memory
│   │   ├── README.md
│   │   └── chatbot-memoria.json
│   │
│   ├── 03-rag-documentos/                 ← RAG: PDF → Embeddings → Vector Store → QA
│   │   ├── README.md
│   │   └── rag-documentos.json
│   │
│   ├── 04-agente-com-tools/               ← Agent + Calculator + Web Search
│   │   ├── README.md
│   │   └── agente-tools.json
│   │
│   ├── 05-agente-custom-tool/             ← Agent + Custom Tool (API ViaCEP)
│   │   ├── README.md
│   │   └── agente-custom-tool.json
│   │
│   │── ─── NÍVEL INTERMEDIÁRIO (06-10) ───────────────────────────────
│   │
│   ├── 06-rag-multiplas-fontes/           ← RAG com PDF + Web Scraper + Text
│   │   ├── README.md
│   │   └── rag-multiplas-fontes.json
│   │
│   ├── 07-structured-output/             ← Respostas em formato JSON estruturado
│   │   ├── README.md
│   │   └── structured-output.json
│   │
│   ├── 08-rag-agent-combinado/            ← RAG como Tool de um Agent
│   │   ├── README.md
│   │   └── rag-agent-combinado.json
│   │
│   ├── 09-moderacao-filtros/              ← Proteção contra jailbreak e conteúdo impróprio
│   │   ├── README.md
│   │   └── moderacao-filtros.json
│   │
│   ├── 10-multiplas-custom-tools/         ← Agent com 3 APIs (CEP + Clima + Crypto)
│   │   ├── README.md
│   │   └── multiplas-custom-tools.json
│   │
│   │── ─── NÍVEL AVANÇADO (11-15) ────────────────────────────────────
│   │
│   ├── 11-sequential-agents/             ← Pipeline: Pesquisador → Escritor → Revisor
│   │   ├── README.md
│   │   └── sequential-agents.json
│   │
│   ├── 12-roteamento-condicional/         ← Classificador → If/Else → Especialistas
│   │   ├── README.md
│   │   └── roteamento-condicional.json
│   │
│   ├── 13-rag-avancado-reranker/          ← Hybrid Search + Reranker + Multi-Query
│   │   └── README.md                      (guia conceitual, montar manualmente)
│   │
│   ├── 14-multi-agent-supervisor/         ← Supervisor delega para Workers
│   │   └── README.md                      (guia com prompts prontos)
│   │
│   └── 15-chatbot-fullstack-deploy/       ← API + Embed + Deploy + WhatsApp
│       └── README.md                      (guia completo de produção)
```

---

## 🎯 Ordem Recomendada de Estudo

### Nível Básico — Fundamentos (1-2 dias)

| # | Workflow | O que aprende | Dificuldade |
|---|---------|---------------|-------------|
| 01 | Chatbot Simples | Prompt + Modelo + Chain | ⭐ |
| 02 | Chatbot com Memória | Buffer Memory, conversas contínuas | ⭐ |
| 03 | RAG com Documentos | Embeddings, Vector Store, busca semântica | ⭐⭐ |
| 04 | Agente com Tools | Function Calling, decisão autônoma | ⭐⭐ |
| 05 | Custom Tool | Criar ferramentas com JavaScript/API | ⭐⭐ |

### Nível Intermediário — Aprofundamento (2-3 dias)

| # | Workflow | O que aprende | Dificuldade |
|---|---------|---------------|-------------|
| 06 | RAG Múltiplas Fontes | PDF + Web + Texto no mesmo Vector Store | ⭐⭐ |
| 07 | Structured Output | Forçar respostas em JSON para integrações | ⭐⭐ |
| 08 | RAG + Agent | RAG como Tool (busca sob demanda) | ⭐⭐⭐ |
| 09 | Moderação e Filtros | Segurança, jailbreak prevention | ⭐⭐ |
| 10 | Múltiplas Custom Tools | Orquestrar 3+ APIs em um agente | ⭐⭐⭐ |

### Nível Avançado — Produção (3-5 dias)

| # | Workflow | O que aprende | Dificuldade |
|---|---------|---------------|-------------|
| 11 | Sequential Agents | Pipeline multi-agente (Agentflow) | ⭐⭐⭐ |
| 12 | Roteamento Condicional | If/Else, classificação de intenção | ⭐⭐⭐ |
| 13 | RAG Avançado + Reranker | Hybrid Search, Reranker, Multi-Query | ⭐⭐⭐⭐ |
| 14 | Multi-Agent Supervisor | Gerente + Workers, loops iterativos | ⭐⭐⭐⭐ |
| 15 | Full-Stack Deploy | API, Embed, Docker, WhatsApp, produção | ⭐⭐⭐⭐ |

---

## 🔑 Configuração do Ollama (GRATUITO)

Todos os workflows usam **Ollama** como modelo padrão. Configuração:

### No Flowise, ao usar ChatOllama:
- **Base URL:** `http://host.containers.internal:11434`
- **Model Name:** `llama3.2`
- **Temperature:** Depende do workflow (indicado em cada README)

### Para Embeddings (workflows RAG):
- **Base URL:** `http://host.containers.internal:11434`
- **Model Name:** `nomic-embed-text`

### Primeiro uso? Execute:
```powershell
.\iniciar.ps1 -Instalar
```
Isso baixa os modelos necessários automaticamente.

> **Nota:** A URL `host.containers.internal` é o endereço que o container Flowise
> usa para acessar o Ollama que roda na sua máquina Windows. Se rodar Flowise
> SEM container (direto no Windows), use `http://localhost:11434`.

---

## 🆘 Problemas Comuns

| Problema | Solução |
|----------|---------|
| "Port 3000 already in use" | Use `npx flowise start --port 3001` |
| "API Key inválida" | Verifique se copiou a key completa (começa com `sk-`) |
| "Model not found" | Verifique se tem créditos na OpenAI ou use gpt-4o-mini |
| Flowise não abre | Verifique se Node.js está instalado: `node --version` |
| Import falha | Verifique se o arquivo JSON está completo (não truncado) |
| Chat não responde | Verifique se salvou o flow (💾) e configurou a credential |
| RAG não funciona | Lembre de clicar "Upsert" após upload do documento |
| Agent não usa tools | Verifique se tools estão conectadas E se descriptions são claras |
| Sequential Agents não funciona | Crie como **Agentflow** (não Chatflow) |

---

## � Mapa de Progressão de Conceitos

```
BÁSICO                    INTERMEDIÁRIO                 AVANÇADO
───────                   ──────────────               ────────

Prompt ──────────────────────────────────────────────────────────▶
Model ───────────────────────────────────────────────────────────▶
Chain ─────────┐
               └── Conversation Chain ──────────────────────────▶
Memory ────────────────────────── Buffer Window ────────────────▶
                                  Summary Memory
RAG ───────── Básico ──── Múltiplas Fontes ──── Reranker ──────▶
                                                 Hybrid Search
Agent ─────── Tools ──── Custom Tools ──── Multi-Tools ────────▶
                          Retriever Tool
                                    Structured Output ──────────▶
                                    Moderação ──────────────────▶
Agentflow ──────────────────────── Sequential ─── Conditional ──▶
                                                   Supervisor
Deploy ─────────────────────────────────────────── Full-Stack ──▶
```

---

## �📚 Recursos Adicionais

- [Documentação Oficial Flowise](https://docs.flowiseai.com)
- [GitHub do Flowise](https://github.com/FlowiseAI/Flowise)
- [Discord da Comunidade](https://discord.gg/jbaHfsRVBW)
- [Templates do Marketplace](https://flowiseai.com/marketplace)
- [API Reference](https://docs.flowiseai.com/api-reference)
- [Flowise YouTube](https://www.youtube.com/@FlowiseAI)

---

## 📝 Glossário

| Termo | Significado |
|-------|-------------|
| **LLM** | Large Language Model — modelo de linguagem grande (ex: GPT-4) |
| **RAG** | Retrieval Augmented Generation — buscar info antes de responder |
| **Chain** | Cadeia de operações (prompt → modelo → resposta) |
| **Agent** | IA que decide quais ferramentas usar para responder |
| **Embedding** | Representação numérica de texto para busca semântica |
| **Vector Store** | Banco de dados que armazena embeddings |
| **Node** | Bloco/componente visual no Flowise |
| **Edge** | Conexão entre dois nodes |
| **Tool** | Ferramenta que um agente pode usar (calculadora, busca, API) |
| **Memory** | Componente que guarda histórico da conversa |
| **Temperature** | Controla criatividade (0 = preciso, 1 = criativo) |
| **Token** | Unidade de texto (~4 caracteres em inglês) |
| **Chatflow** | Tipo de fluxo para chatbots e RAG simples |
| **Agentflow** | Tipo de fluxo para agentes sequenciais e condicionais |
| **Reranker** | Modelo que reordena resultados de busca por relevância |
| **Function Calling** | Capacidade do modelo de chamar funções/tools |
| **Upsert** | Processar e armazenar documentos no vector store |
| **Supervisor** | Agente gerente que delega para outros agentes |
| **Worker** | Agente especialista que executa tarefas delegadas |
| **Condition Node** | Node que roteia o fluxo baseado em condições (if/else) |
| **Hybrid Search** | Combina busca semântica + busca por palavras-chave |
| **Prompt Injection** | Tentativa maliciosa de manipular instruções do bot |
| **Jailbreak** | Tentativa de burlar limites/regras do chatbot |
