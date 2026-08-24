# Workflow 06 - RAG com Múltiplas Fontes (PDF + Web + Texto)

## 🎯 Objetivo

Evolução do Workflow 03: agora o chatbot busca informação de **várias fontes ao mesmo tempo** —
PDFs, páginas da web e arquivos de texto. Ele indica **de qual fonte** veio cada resposta.

**Caso de uso real:** Base de conhecimento corporativa que combina manuais internos (PDF),
documentação online (web) e notas de reunião (texto).

---

## 📐 Arquitetura do Fluxo

```
┌──────────────┐
│  PDF Loader  │──────────┐
│ (Manuais)    │          │
└──────────────┘          │
                          │
┌──────────────┐          │     ┌──────────────────┐     ┌─────────────────────┐
│ Web Scraper  │──────────┼────▶│  In-Memory       │────▶│  Conversational     │
│ (Docs online)│          │     │  Vector Store    │     │  Retrieval QA Chain │
└──────────────┘          │     └──────────────────┘     └─────────────────────┘
                          │              ▲                       ▲    ▲
┌──────────────┐          │              │                      │    │
│ Text File    │──────────┘     ┌────────┴────────┐    ┌───────┘    │
│ (Notas .txt) │                │ OpenAI Embeddings│    │            │
└──────────────┘                └─────────────────┘    │            │
                                                       │            │
         ┌──────────────────────┐     ┌────────────────┘    ┌──────┴──────┐
         │ Recursive Text       │     │ ChatOpenAI          │Buffer Memory│
         │ Splitter (compartilhado)   │ (gpt-4o-mini)       │(Histórico)  │
         └──────────────────────┘     └─────────────────────┘└─────────────┘
```

---

## 🆕 O que há de novo vs Workflow 03

| Aspecto | Workflow 03 | Workflow 06 |
|---------|-------------|-------------|
| Fontes | 1 PDF apenas | PDF + Web + Texto |
| Metadata | Não usa | Identifica a fonte de cada chunk |
| Source Tracking | Não | Sim — mostra de onde veio a info |
| Text Splitter | 1 para 1 loader | 1 compartilhado para 3 loaders |
| Complexidade | Básica | Intermediária |

---

## 🧩 Nodes Utilizados

### 1. PDF File Loader
- **Igual ao Workflow 03**, mas agora com **metadata** personalizada
- **Metadata:** `{"source": "pdf-manual"}` — identifica a origem dos chunks

### 2. Cheerio Web Scraper ⭐ NOVO!
- **O que faz:** Extrai texto de páginas web
- **Como funciona:** Acessa a URL, faz parse do HTML e extrai o conteúdo textual
- **Configuração:**
  - URL: A página que deseja indexar
  - Relative Links: Pode seguir links internos (crawl)
  - Limit: Máximo de páginas a seguir
- **Metadata:** `{"source": "web-flowise-docs"}`
- **Analogia:** Um robô que lê páginas web e copia o texto

### 3. Text File Loader ⭐ NOVO!
- **O que faz:** Carrega arquivos .txt, .md ou .csv
- **Quando usar:** Notas, transcrições, FAQs em texto puro
- **Metadata:** `{"source": "arquivo-texto"}`

### 4. Recursive Character Text Splitter (Compartilhado)
- **Diferencial:** Um único splitter alimenta TODOS os 3 loaders
- **Por que compartilhar:** Garante chunking consistente entre fontes
- **Config:** Chunk Size 1000, Overlap 200

### 5. Demais Nodes
- OpenAI Embeddings, In-Memory Vector Store, ChatOpenAI, Buffer Memory,
  Conversational Retrieval QA Chain — mesma função do Workflow 03

---

## ⚙️ Como Configurar

1. **Importe** o arquivo `rag-multiplas-fontes.json`
2. **API Key:** Configure no ChatOpenAI e OpenAI Embeddings
3. **PDF:** Clique no PDF File Loader e faça upload de um PDF
4. **Web:** No Cheerio Web Scraper, coloque a URL desejada
   - Sugestão: `https://docs.flowiseai.com/getting-started`
5. **Texto:** Clique no Text File Loader e faça upload de um .txt
6. **Upsert:** Clique no botão Upsert para processar TODAS as fontes
7. **Teste:** Abra o chat e pergunte sobre os conteúdos

---

## 🧪 Testes Sugeridos

### Preparando os dados de teste

Crie um arquivo `notas-reuniao.txt` com:
```
Reunião 15/01/2025 - Projeto Alpha
- Decisão: migrar para microsserviços até março
- Responsável: equipe backend (João e Maria)
- Orçamento aprovado: R$ 50.000
- Próxima reunião: 22/01/2025

Reunião 22/01/2025 - Projeto Alpha
- Status: 30% concluído
- Bloqueio: falta acesso ao ambiente de staging
- Ação: TI vai liberar até 25/01
```

### Perguntas para testar

| Pergunta | Fonte esperada | Resposta esperada |
|----------|----------------|-------------------|
| "Qual o orçamento do Projeto Alpha?" | arquivo-texto | R$ 50.000 |
| (Sobre conteúdo do PDF) | pdf-manual | Resposta do PDF |
| (Sobre a página web) | web-flowise-docs | Info da documentação |
| "De onde veio essa informação?" | — | Deve indicar a fonte |

---

## 🔑 Conceito-Chave: Metadata para Rastreabilidade

Metadata são "etiquetas" que você coloca nos documentos para saber de onde
veio cada pedaço de informação.

```json
// Chunk do PDF terá:
{ "source": "pdf-manual", "page": 3, "content": "..." }

// Chunk da Web terá:
{ "source": "web-flowise-docs", "url": "https://...", "content": "..." }

// Chunk do Texto terá:
{ "source": "arquivo-texto", "content": "..." }
```

Quando "Return Source Documents" está ativado, o chain retorna esses metadados
junto com a resposta, permitindo rastrear a origem.

---

## 🔄 Variações para Praticar

### 1. Adicionar um 4º Loader (CSV)
- Use o node "CSV File" para carregar planilhas
- Metadata: `{"source": "planilha-vendas"}`

### 2. Web Crawl completo
- No Cheerio Web Scraper, ative "Web Crawl"
- Defina limit: 20 (vai buscar 20 páginas do mesmo domínio)
- Útil para indexar documentação inteira de um site

### 3. Usar ChromaDB para persistência
- Substitua In-Memory por Chroma
- Dados sobrevivem ao reinício do Flowise

---

## 📖 Conceitos Aprendidos

- ✅ Como alimentar o RAG com **múltiplas fontes** de dados
- ✅ O uso de **Metadata** para rastrear a origem da informação
- ✅ Como **compartilhar** um Text Splitter entre múltiplos loaders
- ✅ O node **Cheerio Web Scraper** para extrair conteúdo de sites
- ✅ Como configurar **Return Source Documents** para transparência

---

## ➡️ Próximo Passo

Vá para **Workflow 07 - Structured Output** para aprender a fazer o chatbot
responder em **formato JSON estruturado** (útil para integrações com outros sistemas)!
