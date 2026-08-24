# Flowise Agents — Workflows Didaticos + Projeto Multi-Agente

Repositorio de estudo e desenvolvimento com **Flowise AI**: 15 workflows progressivos
para aprender a criar chatbots e agentes, e um projeto de sistema multi-agente de
desenvolvimento de software.

## O que tem aqui

```
flowise-Agents/
├── workflows/               ← 15 workflows importaveis no Flowise (JSON + docs)
│   ├── README.md            ← Guia completo de instalacao e conceitos
│   ├── COMO-IMPORTAR.md     ← Passo-a-passo para importar no Flowise
│   ├── iniciar.ps1          ← Script que sobe o ambiente (Ollama + Podman + Flowise)
│   ├── 01-chatbot-simples/
│   ├── 02-chatbot-com-memoria/
│   ├── ...
│   └── 15-chatbot-fullstack-deploy/
│
└── multi-Agente-Project/    ← Projeto: time de 12 agentes IA de desenvolvimento
    └── multi-Agente-Project.md
```

## Inicio Rapido

### Pre-requisitos

- [Ollama](https://ollama.com/download) (modelos locais, gratuito)
- [Podman](https://podman.io) (containers, alternativa ao Docker)

### Subir o ambiente

```powershell
# Primeira vez (baixa modelos llama3.2 e nomic-embed-text)
.\workflows\iniciar.ps1 -Instalar

# Uso diario (inicia Ollama + Podman + Flowise e abre o navegador)
.\workflows\iniciar.ps1

# Ver status
.\workflows\iniciar.ps1 -Status

# Parar tudo
.\workflows\iniciar.ps1 -Parar
```

Flowise abre em **http://localhost:3000**

### Importar um workflow

1. No Flowise, va em **Chatflows** (ou Agentflows para 11-14)
2. Clique **+ Add New**
3. No canvas, clique no menu **⋮** → **Load Chatflow**
4. Selecione o `.json` da pasta do workflow desejado
5. Salve e teste no chat

Guia detalhado em [`workflows/COMO-IMPORTAR.md`](workflows/COMO-IMPORTAR.md)

## Workflows (ordem de estudo)

### Basico (dia 1-2)

| # | Workflow | Conceito |
|---|---------|----------|
| 01 | Chatbot Simples | Prompt + Modelo + Chain |
| 02 | Chatbot com Memoria | Buffer Memory |
| 03 | RAG com Documentos | Embeddings + Vector Store |
| 04 | Agente com Tools | Function Calling + Calculator |
| 05 | Custom Tool | Criar ferramentas (API ViaCEP) |

### Intermediario (dia 3-4)

| # | Workflow | Conceito |
|---|---------|----------|
| 06 | RAG Multiplas Fontes | PDF + Web + Texto |
| 07 | Structured Output | Respostas em JSON |
| 08 | RAG + Agent | Retriever Tool |
| 09 | Moderacao e Filtros | Protecao contra jailbreak |
| 10 | Multiplas Custom Tools | CEP + Clima + Crypto |

### Avancado (dia 5-7)

| # | Workflow | Conceito |
|---|---------|----------|
| 11 | Sequential Agents | Pipeline multi-agente |
| 12 | Roteamento Condicional | If/Else com agentes |
| 13 | RAG + Reranker | LLM Filter Retriever |
| 14 | Multi-Agent Supervisor | Gerente + Workers com loop |
| 15 | Full-Stack Deploy | Chatbot pronto para producao |

## Projeto Multi-Agente

O objetivo final e criar um **time de 12 agentes IA** que funciona como equipe de
desenvolvimento. Voce da a ideia e eles refinam, projetam, codificam, testam e entregam.

Detalhes completos em [`multi-Agente-Project/multi-Agente-Project.md`](multi-Agente-Project/multi-Agente-Project.md)

**Agentes planejados:**
Chatbot | Lider | PO | Arquiteto | DBA | Desenvolvedor | QA | DevOps | Designer UX/UI | Auditor | Technical Writer | Suporte

## Stack

| Componente | Tecnologia |
|------------|-----------|
| Orquestracao | Flowise AI (Agentflow) |
| LLM | Ollama (llama3.2 + nomic-embed-text) |
| Containers | Podman |
| Versionamento | Git + GitHub |

## Configuracao dos Workflows

Todos os workflows usam **Ollama** (gratuito, local). Nenhuma API key necessaria.

No Flowise, os nodes ChatOllama e Ollama Embeddings usam:
- **Base URL:** `http://host.containers.internal:11434`
- **Chat Model:** `llama3.2`
- **Embeddings Model:** `nomic-embed-text`

## Licenca

Uso pessoal e educacional.
