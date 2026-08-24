# Workflow 13 - RAG Avançado com Reranker e Hybrid Search

## 🎯 Objetivo

Melhorar drasticamente a **qualidade das respostas do RAG** usando técnicas avançadas:
- **Hybrid Search:** Combina busca semântica (vetores) + busca por keywords (BM25)
- **Reranker:** Reordena os resultados de busca por relevância usando um modelo dedicado
- **Multi-Query Retriever:** Gera variações da pergunta para buscar mais amplamente

**Problema que resolve:** RAG básico às vezes retorna chunks irrelevantes ou perde
informações importantes. Essas técnicas reduzem falhas de 30-40% para 5-10%.

---

## 📐 Arquitetura do Fluxo

```
                                    ┌─────────────────────────────────────────┐
                                    │         HYBRID SEARCH                    │
                                    │                                          │
                                    │  ┌─────────────┐   ┌─────────────────┐ │
Pergunta ──▶ Multi-Query ──────────▶│  │  Semantic    │ + │  Keyword (BM25)  │ │
             Retriever              │  │  Search      │   │  Search          │ │
             (gera 3 variações)     │  │  (vetores)   │   │  (palavras-chave)│ │
                                    │  └──────┬───────┘   └────────┬─────────┘ │
                                    │         │                     │           │
                                    │         └─────────┬───────────┘           │
                                    │                   │                       │
                                    │         ┌─────────▼────────────┐          │
                                    │         │  Resultados mesclados │          │
                                    │         │  (10-15 chunks)       │          │
                                    │         └─────────┬────────────┘          │
                                    └───────────────────┼──────────────────────┘
                                                        │
                                                        ▼
                                              ┌─────────────────────┐
                                              │     RERANKER         │
                                              │                     │
                                              │ Reordena por        │
                                              │ relevância real     │
                                              │                     │
                                              │ Entrada: 10 chunks  │
                                              │ Saída: Top 3-4      │
                                              └──────────┬──────────┘
                                                         │
                                                         ▼
                                              ┌─────────────────────┐
                                              │   LLM (gpt-4o-mini) │
                                              │                     │
                                              │  Gera resposta com  │
                                              │  base nos TOP chunks│
                                              └─────────────────────┘
```

---

## 🆕 Por que RAG Básico Falha (e como resolver)

### Problema 1: Busca semântica não encontra tudo
```
Documento: "O prazo de entrega para a região sudeste é de 3 dias úteis"
Pergunta: "Quanto tempo demora para chegar em São Paulo?"

Busca semântica PODE falhar porque:
- "tempo para chegar" ≠ "prazo de entrega" (semanticamente similar, mas nem sempre rankeia bem)

SOLUÇÃO: Hybrid Search (busca por keyword "prazo" + busca semântica por "tempo de entrega")
```

### Problema 2: Chunks irrelevantes no topo
```
Top 4 resultados da busca:
1. ✅ "Prazo de entrega: 3 dias para sudeste" (relevante!)
2. ❌ "Prazo de pagamento: 30 dias" (palavra "prazo" mas irrelevante)
3. ✅ "Frete para SP: R$ 15, entrega em 3 dias úteis" (relevante!)
4. ❌ "Promoção de 3 dias: frete grátis acima de R$100" (número "3 dias" mas irrelevante)

SOLUÇÃO: Reranker analisa CADA chunk vs a pergunta e reordena:
1. ✅ "Prazo de entrega: 3 dias para sudeste" (score: 0.95)
2. ✅ "Frete para SP: R$ 15, entrega em 3 dias úteis" (score: 0.91)
3. ❌ "Promoção de 3 dias..." (score: 0.23) ← removido!
4. ❌ "Prazo de pagamento..." (score: 0.15) ← removido!
```

### Problema 3: Pergunta mal formulada
```
Pergunta original: "Como faz pra mandar coisa pro sul?"

Multi-Query Retriever gera variações:
1. "Como enviar encomendas para a região sul do Brasil?"
2. "Qual o processo de envio para estados do sul?"
3. "Frete e entrega para o sul"

→ 3 buscas diferentes = mais chances de encontrar a resposta
```

---

## 🧩 Componentes Avançados

### 1. Multi-Query Retriever ⭐
- **O que faz:** Gera 3 variações da pergunta do usuário e busca com cada uma
- **Por quê:** Diferentes formulações encontram diferentes chunks
- **Custo:** 1 chamada extra ao LLM (barata, gera apenas variações curtas)
- **Configuração:** Automática — basta conectar ao retriever

### 2. Hybrid Search (Semantic + Keyword) ⭐
- **Busca Semântica:** Encontra textos com significado similar (embeddings)
- **Busca por Keyword (BM25):** Encontra textos com palavras-chave exatas
- **Combinação:** Usa algoritmo RRF (Reciprocal Rank Fusion) para mesclar resultados
- **Quando funciona melhor:** Documentos técnicos, legais, com termos específicos

### 3. Reranker (Cohere/bge-reranker) ⭐
- **O que faz:** Recebe N chunks e reordena por relevância REAL à pergunta
- **Como funciona:** Usa um modelo cross-encoder (mais preciso que bi-encoder)
- **Diferença do embedding:** Embedding compara vetores separadamente; Reranker analisa chunk+pergunta JUNTOS
- **Resultado:** Remove "lixo" e mantém apenas os chunks realmente úteis

### 4. Compression Retriever
- **O que faz:** Combina retriever + reranker em um nó só
- **Saída:** Apenas os Top K chunks após reranking

---

## ⚙️ Como Configurar

### Opção A: Reranker com Cohere (recomendado)

1. Crie conta em https://cohere.com (tem plano gratuito)
2. Pegue a API Key
3. No Flowise:
   - Adicione node "Cohere Reranker"
   - Configure a credential com a API key
   - Model: `rerank-english-v3.0` ou `rerank-multilingual-v3.0`
   - Top N: 3 (retorna os 3 melhores chunks)

### Opção B: Reranker local (sem API key)

Use o modelo `bge-reranker-base` via HuggingFace:
- Node: "HuggingFace Inference Embeddings" como reranker
- Mais lento, mas gratuito e privado

### Configuração do Workflow

1. **Importe** o JSON (este workflow é mais conceitual — monte manualmente para praticar)
2. **Pipeline:**
   - PDF Loader → Splitter → Embeddings → Vector Store (igual Workflow 03)
   - Adicione "Cohere Reranker" entre o Retriever e a Chain
3. **Conecte:**
   - Vector Store → Retriever → Cohere Reranker → QA Chain

---

## 🧪 Testes Comparativos

### Preparação
Use um PDF longo (>20 páginas) com informações variadas. Quanto mais conteúdo, mais visível a diferença.

### Teste A vs B

| Pergunta | RAG Básico (Workflow 03) | RAG + Reranker (Workflow 13) |
|----------|-------------------------|------------------------------|
| Pergunta específica | Pode trazer chunks irrelevantes | Traz os mais relevantes |
| Pergunta ambígua | Pode falhar | Multi-query ajuda |
| Pergunta com termos técnicos | Depende do embedding | Keyword search ajuda |
| Qualidade geral | 70-80% | 90-95% |

### Métricas para avaliar

1. **Precisão:** A resposta está correta?
2. **Completude:** Cobriu todos os pontos?
3. **Relevância dos sources:** Os chunks retornados são realmente sobre o tema?
4. **Ausência de alucinação:** Não inventou dados?

---

## 📊 Comparativo de Técnicas

| Técnica | Melhoria | Custo adicional | Quando usar |
|---------|----------|-----------------|-------------|
| Multi-Query | +15-20% recall | ~$0.001/query | Sempre (baixo custo) |
| Hybrid Search | +10-15% para termos técnicos | Nenhum | Docs técnicos/legais |
| Reranker | +20-30% precisão | ~$0.002/query (Cohere) | Docs grandes (>50 páginas) |
| Todos juntos | +40-50% qualidade total | ~$0.003/query | Produção séria |

---

## 🔧 Configurações Recomendadas por Caso

### Documentação técnica (manuais, APIs)
```
Chunk Size: 800
Chunk Overlap: 200
Search: Hybrid (semântico + keyword)
Reranker: Cohere rerank-multilingual-v3.0
Top K inicial: 10
Top N final (após rerank): 4
```

### Documentos jurídicos (contratos, leis)
```
Chunk Size: 1200 (parágrafos legais são maiores)
Chunk Overlap: 300
Search: Hybrid (termos jurídicos específicos)
Reranker: Obrigatório (precisão é crítica)
Top K inicial: 15
Top N final: 5
```

### FAQ / Base de conhecimento
```
Chunk Size: 500 (perguntas/respostas são curtas)
Chunk Overlap: 100
Search: Semântico (significado importa mais que keywords)
Reranker: Opcional (FAQ já é bem estruturado)
Top K: 3
```

---

## 🔄 Variações para Praticar

### 1. Comparar com e sem Reranker
- Monte o mesmo RAG duas vezes
- Um com Reranker, outro sem
- Teste as mesmas 10 perguntas e compare qualidade

### 2. Ajustar Top K e Top N
- Top K = 20, Top N = 3 → Busca muito, filtra agressivamente
- Top K = 5, Top N = 4 → Busca pouco, quase não filtra
- Observe o trade-off

### 3. Testar com documentos em português
- Cohere `rerank-multilingual-v3.0` funciona em PT-BR
- Compare com `rerank-english-v3.0` em docs em português

---

## 📖 Conceitos Aprendidos

- ✅ Por que RAG básico falha e como **Hybrid Search** resolve
- ✅ O que é **Reranker** e por que é superior a embedding simples
- ✅ Como **Multi-Query Retriever** amplia a busca com variações
- ✅ O conceito de **cross-encoder vs bi-encoder** para relevância
- ✅ Métricas de qualidade: precisão, recall, relevância
- ✅ Trade-offs entre qualidade e custo/latência
- ✅ Configurações ideais para diferentes tipos de documento

---

## ➡️ Próximo Passo

Vá para **Workflow 14 - Multi-Agent Supervisor** para aprender a orquestrar
múltiplos agentes com um "gerente" que delega tarefas!
