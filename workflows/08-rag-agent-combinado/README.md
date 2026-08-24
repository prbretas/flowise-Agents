# Workflow 08 - RAG + Agent Combinado

## 🎯 Objetivo

Combinar o poder do **RAG** (busca em documentos) com a **inteligência de um Agent**
(decidir quando buscar, quando calcular, quando responder direto). O agente usa o
vector store como uma **ferramenta** — ele decide QUANDO consultar os documentos.

**Diferença crucial do Workflow 03:** No RAG puro, toda pergunta vai para o vector store.
Aqui, o agente **decide** se precisa consultar os docs ou se pode responder sozinho.

---

## 📐 Arquitetura do Fluxo

```
┌────────────────────────────────────────────────────────┐
│                    PIPELINE RAG                          │
│                                                          │
│  [PDF] → [Splitter] → [Embeddings] → [Vector Store]    │
│                                                          │
└────────────────────────────────────┬─────────────────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │   Retriever Tool     │───────┐
                          │  "buscar_documentos" │       │
                          └─────────────────────┘       │
                                                         │
                          ┌─────────────────────┐       │    ┌──────────────────┐
                          │    Calculator        │───────┼───▶│  OpenAI Function │
                          │                     │       │    │  Agent           │
                          └─────────────────────┘       │    │                  │
                                                         │    │ DECIDE quando    │
                          ┌─────────────────────┐       │    │ usar cada tool   │
                          │    ChatOpenAI        │───────┼───▶│                  │
                          └─────────────────────┘       │    └──────────────────┘
                                                         │              ▲
                          ┌─────────────────────┐       │              │
                          │   Buffer Memory     │───────┘──────────────┘
                          └─────────────────────┘
```

---

## 🆕 Conceito-Chave: Retriever Tool

O **Retriever Tool** é a ponte entre RAG e Agent. Ele "embrulha" um vector store
retriever como uma ferramenta que o agente pode chamar quando quiser.

```
                 Workflow 03 (RAG Puro)              Workflow 08 (RAG + Agent)
                 ─────────────────────              ────────────────────────
Pergunta ──────▶ SEMPRE busca no vector ────▶ ✗     Pergunta ──────▶ Agent DECIDE ──▶ Buscar? Calcular? Direto?
                 store, mesmo se não precisa                              │
                                                                         ├── "O que é IA?" → Responde direto
                                                                         ├── "Política de férias?" → Busca docs
                                                                         └── "20% de R$5000?" → Calculator
```

---

## 🧩 Nodes Utilizados

### 1. Retriever Tool ⭐ NOVO!
- **O que faz:** Transforma um Vector Store Retriever em uma Tool do agente
- **Configuração:**
  - **Name:** `buscar_documentos` (o agente usa este nome)
  - **Description:** Explica QUANDO usar (fundamental para o agente decidir)
- **Analogia:** É como dar ao agente um "livro de consulta" que ele pode abrir quando quiser

### 2. Pipeline RAG (já conhecido)
- PDF → Splitter → Embeddings → Vector Store → (sai como Retriever)
- Igual ao Workflow 03, mas a saída vai para o Retriever Tool

### 3. OpenAI Function Agent + Calculator + Memory
- Igual ao Workflow 04, mas agora com a busca em documentos como tool adicional

---

## ⚙️ Como Configurar

1. **Importe** `rag-agent-combinado.json`
2. **API Key:** Configure em ChatOpenAI e OpenAI Embeddings
3. **Upload PDF:** Suba um documento no node PDF File
4. **Upsert:** Clique no botão Upsert para processar
5. **Teste:** O agente decide quando buscar nos docs vs responder direto

---

## 🧪 Testes Sugeridos

Use um PDF com informações de empresa. Exemplo de conteúdo:
```
Política de RH - Empresa ABC
- Férias: 30 dias por ano, após 12 meses de trabalho
- Vale Refeição: R$ 45,00 por dia útil
- Horário: 9h às 18h, com 1h de almoço
- Home Office: terças e quintas
- 13º salário: pago em novembro (1ª parcela) e dezembro (2ª parcela)
```

### Perguntas de teste

| Pergunta | Tool esperada | Por quê |
|----------|---------------|---------|
| "Quantos dias de férias eu tenho?" | buscar_documentos | Info está no PDF |
| "Quanto é 22 dias úteis x R$45 de VR?" | calculator | Cálculo puro |
| "Qual o valor mensal do vale refeição?" | buscar_documentos + calculator | Busca o valor e calcula |
| "O que é machine learning?" | Nenhuma (direto) | Conhecimento geral |
| "Posso trabalhar de casa na segunda?" | buscar_documentos | Precisa verificar política |

---

## 📊 RAG Puro vs RAG + Agent

| Cenário | RAG Puro (Workflow 03) | RAG + Agent (Workflow 08) |
|---------|----------------------|--------------------------|
| "Qual a política de férias?" | ✅ Busca e responde | ✅ Busca e responde |
| "O que é fotossíntese?" | ❌ Busca nos docs (acha nada) | ✅ Responde direto |
| "Calcule 20% de R$3000" | ❌ Não sabe calcular | ✅ Usa calculator |
| "Qual o VR diário e o mensal?" | ⚠️ Busca mas não calcula | ✅ Busca + Calcula |
| Custo de tokens | ⬆️ Sempre envia chunks | ⬇️ Só busca quando precisa |

---

## 🔄 Variações para Praticar

### 1. Adicionar mais Tools
- **Web Search:** Para perguntas que precisam de info atual
- **Custom Tool:** Para consultar sistemas internos

### 2. Múltiplos Retriever Tools
- Crie 2 vector stores separados (RH e Financeiro)
- Crie 2 Retriever Tools com nomes diferentes
- O agente decide em qual "departamento" buscar

### 3. Forçar citação de fonte
No System Message, adicione:
```
Quando usar buscar_documentos, SEMPRE cite o trecho exato que encontrou.
```

---

## 📖 Conceitos Aprendidos

- ✅ Como transformar um **Vector Store em Tool** com Retriever Tool
- ✅ A diferença entre RAG fixo e RAG como ferramenta do agente
- ✅ O agente **otimiza custos** buscando docs apenas quando necessário
- ✅ Como combinar **busca semântica + cálculos** em uma resposta
- ✅ A importância da **descrição** do Retriever Tool para decisões corretas

---

## ➡️ Próximo Passo

Vá para **Workflow 09 - Moderação e Filtros** para aprender a proteger
seu chatbot contra uso indevido e conteúdo impróprio!
