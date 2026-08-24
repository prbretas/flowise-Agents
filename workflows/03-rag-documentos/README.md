# Workflow 03 - RAG com Documentos (Chat com seus PDFs)

## 🎯 Objetivo

Criar um chatbot que responde perguntas **baseado nos seus próprios documentos**.
Isso se chama **RAG** (Retrieval Augmented Generation) — o bot busca informação
relevante nos seus arquivos e usa isso para gerar a resposta.

**Exemplo prático:** Você sobe o manual da sua empresa e o bot responde
perguntas sobre políticas internas, processos, etc.

---

## 📐 Arquitetura do Fluxo

```
┌──────────────┐     ┌───────────────┐     ┌──────────────────┐
│  PDF Loader  │────▶│  Text Splitter │────▶│  OpenAI          │
│              │     │  (Divide em   │     │  Embeddings      │
│ Carrega PDF  │     │   pedaços)    │     │  (Vetoriza)      │
└──────────────┘     └───────────────┘     └────────┬─────────┘
                                                     │
                                                     ▼
┌──────────────┐     ┌───────────────┐     ┌──────────────────┐
│  ChatOpenAI  │────▶│  Conversational│◀────│  In-Memory       │
│  (Modelo)    │     │  Retrieval QA │     │  Vector Store    │
└──────────────┘     │  Chain        │     │  (Armazena       │
                     │               │     │   vetores)       │
┌──────────────┐     │  Responde com │     └──────────────────┘
│Buffer Memory │────▶│  base nos docs│
│(Histórico)   │     └───────────────┘
└──────────────┘
```

---

## 🧠 Como RAG Funciona (Explicação Simples)

### Fase 1: Preparação (acontece uma vez)
1. **Carrega** o documento (PDF, TXT, etc.)
2. **Divide** em pedaços pequenos (chunks) de ~1000 caracteres
3. **Transforma** cada pedaço em números (embeddings/vetores)
4. **Armazena** os vetores em um banco vetorial

### Fase 2: Pergunta (acontece a cada mensagem)
1. Usuário faz uma **pergunta**
2. A pergunta é transformada em **vetor**
3. O sistema **busca** os pedaços mais parecidos no banco vetorial
4. Os pedaços relevantes são enviados ao **modelo** junto com a pergunta
5. O modelo gera uma resposta **baseada nos documentos**

```
Pergunta do usuário: "Qual é a política de férias?"
         │
         ▼
[Busca vetorial] → Encontra chunks relevantes sobre férias
         │
         ▼
[Modelo recebe]: "Com base no seguinte contexto: {chunks}. Responda: Qual é a política de férias?"
         │
         ▼
[Resposta]: "Segundo o documento, a política de férias é..."
```

---

## 🧩 Nodes Utilizados

### 1. PDF File Loader (Document Loaders)
- **O que faz:** Lê um arquivo PDF e extrai o texto
- **Analogia:** É como um scanner que digitaliza um documento
- **Configuração:** Você faz upload do PDF diretamente no node
- **Alternativas:** Text File, CSV, Web Scraper, Notion, etc.

### 2. Recursive Character Text Splitter
- **O que faz:** Divide o texto grande em pedaços menores (chunks)
- **Por que:** Modelos têm limite de contexto. Chunks menores = busca mais precisa
- **Configurações:**
  - Chunk Size: `1000` (caracteres por pedaço)
  - Chunk Overlap: `200` (sobreposição entre pedaços para não perder contexto)
- **Analogia:** Cortar um livro em fichas de estudo

### 3. OpenAI Embeddings
- **O que faz:** Transforma texto em vetores numéricos (arrays de números)
- **Por que:** Computadores comparam números mais rápido que texto
- **Modelo:** `text-embedding-ada-002` (barato e eficiente)
- **Analogia:** Traduzir palavras para coordenadas em um mapa

### 4. In-Memory Vector Store
- **O que faz:** Armazena os vetores na memória RAM do servidor
- **Prós:** Rápido, zero configuração
- **Contras:** Perde tudo ao reiniciar o Flowise
- **Alternativas para produção:** Pinecone, ChromaDB, Qdrant, Supabase

### 5. Conversational Retrieval QA Chain
- **O que faz:** Combina busca vetorial + modelo + memória
- **Pipeline interno:**
  1. Recebe pergunta
  2. Busca chunks relevantes no vector store
  3. Monta prompt com contexto + pergunta
  4. Gera resposta com o ChatOpenAI
- **System Message:** Instrui o modelo a responder apenas com base nos docs

### 6. ChatOpenAI (Modelo)
- **O que faz:** Gera a resposta final com base no contexto encontrado
- **Configuração:** gpt-4o-mini, temperatura 0.3 (mais preciso para RAG)

### 7. Buffer Memory (Opcional)
- **O que faz:** Permite fazer perguntas de follow-up
- **Exemplo:** "E quanto tempo dura?" (referindo-se ao assunto anterior)

---

## ⚙️ Como Configurar

### Passo a Passo Detalhado

1. **Importe** o arquivo `rag-documentos.json` no Flowise
2. **Configure a API Key:** Clique no node ChatOpenAI → adicione sua key
3. **Upload do PDF:**
   - Clique no node "PDF File"
   - Clique em "Upload File"
   - Selecione qualquer PDF (manual, artigo, livro, etc.)
4. **Salve** o flow (💾)
5. **Primeiro uso:** Clique no botão "Upsert" (ícone de banco de dados ↑) para processar o PDF
6. **Abra o chat** e faça perguntas sobre o conteúdo do PDF

### ⚠️ Importante: O Passo "Upsert"

O **Upsert** processa o documento e armazena no vector store. Você precisa fazer
isso sempre que:
- Adicionar um novo documento
- Alterar o documento existente
- Reiniciar o Flowise (pois usa In-Memory Store)

---

## 🧪 Testes Sugeridos

### Usando um PDF de teste

Se não tiver um PDF, crie um arquivo de texto simples sobre qualquer tema.
Exemplo: salve como `empresa-teste.pdf`:

```
A empresa XYZ foi fundada em 2020.
O horário de trabalho é das 9h às 18h.
As férias são de 30 dias por ano.
O vale refeição é de R$ 40 por dia.
O home office é permitido às terças e quintas.
```

### Perguntas para testar

| Pergunta | Resposta esperada |
|----------|-------------------|
| "Qual o horário de trabalho?" | "9h às 18h" |
| "Quantos dias de férias?" | "30 dias por ano" |
| "Pode trabalhar de casa?" | "Sim, terças e quintas" |
| "Qual o salário?" | "Não encontrei essa informação" ← CORRETO! |
| "Quando foi fundada?" | "Em 2020" |

> ✅ A última pergunta ("Qual o salário?") deve ser respondida com
> "não encontrei" — isso prova que o RAG usa apenas os documentos!

---

## 📊 Parâmetros Importantes do RAG

### Chunk Size (Tamanho do pedaço)
| Valor | Efeito | Quando usar |
|-------|--------|-------------|
| 500 | Pedaços pequenos, busca mais precisa | Perguntas específicas |
| 1000 | Equilíbrio (recomendado) | Uso geral |
| 2000 | Pedaços grandes, mais contexto | Perguntas amplas |

### Chunk Overlap (Sobreposição)
- **0:** Nenhuma sobreposição (pode perder contexto entre chunks)
- **200:** Recomendado (garante que frases não sejam cortadas no meio)
- **500:** Muita sobreposição (mais custo, mais redundância)

### Temperature do Modelo para RAG
- **0.0-0.3:** Recomendado para RAG (respostas fiéis ao documento)
- **0.7+:** Não recomendado (pode "inventar" informações)

### Top K (Quantos chunks buscar)
- **3-4:** Padrão — busca os 3-4 pedaços mais relevantes
- **1:** Muito restritivo
- **10:** Pode incluir informação irrelevante

---

## 🔄 Variações para Praticar

### 1. Usar ChromaDB (persistente)
Substitua "In-Memory Vector Store" por "Chroma":
- Dados persistem entre reinícios
- Collection Name: "meus-documentos"

### 2. Múltiplos PDFs
- Adicione mais de um PDF File Loader
- Conecte todos ao mesmo Text Splitter
- O bot vai buscar em todos os documentos

### 3. Usar Web Scraper
Substitua PDF File por "Cheerio Web Scraper":
- URL: qualquer página web
- O bot vai responder sobre o conteúdo da página

### 4. Desabilitar "Return Source Documents"
No node Conversational Retrieval QA Chain:
- Ative "Return Source Documents: true"
- O bot vai mostrar DE ONDE tirou a informação

---

## 📖 Conceitos Aprendidos

- ✅ O que é **RAG** e por que é útil (responder com base em dados privados)
- ✅ O pipeline completo: Loader → Splitter → Embeddings → Vector Store → Chain
- ✅ O conceito de **Embeddings** (texto → vetores numéricos)
- ✅ Como **Vector Stores** permitem busca por similaridade
- ✅ O que é **Upsert** (processar e armazenar documentos)
- ✅ Trade-offs de chunk size e overlap
- ✅ Por que temperatura baixa é melhor para RAG

---

## ➡️ Próximo Passo

Vá para **Workflow 04 - Agente com Tools** para aprender a criar um agente
que pode usar ferramentas externas (calculadora, busca web, etc)!
