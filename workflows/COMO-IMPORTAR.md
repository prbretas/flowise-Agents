# 📥 Como Importar Workflows no Flowise

## Guia Passo-a-Passo (com imagens mentais)

Este guia ensina como pegar os arquivos `.json` deste repositório e carregá-los
no Flowise para executar imediatamente.

---

## Pré-requisitos

- ✅ Flowise instalado e rodando (http://localhost:3000)
- ✅ Ter os arquivos `.json` dos workflows (estão neste repositório)
- ✅ Ter uma API Key da OpenAI (ou Ollama instalado localmente)

---

## Método 1: Importar pelo Menu (Recomendado)

### Passo 1 — Abrir o Flowise
Acesse `http://localhost:3000` no seu navegador.

### Passo 2 — Ir para Chatflows
No menu lateral esquerdo, clique em **"Chatflows"**.

### Passo 3 — Criar novo Chatflow
Clique no botão **"+ Add New"** (canto superior direito).

### Passo 4 — Abrir o menu de configuração
Na tela do canvas (área branca com grid), olhe para o canto superior direito.
Clique no ícone de **⚙️ (engrenagem)** ou no menu **"⋮" (três pontos)**.

### Passo 5 — Selecionar "Load Chatflow"
No menu dropdown que aparecer, clique em **"Load Chatflow"**.

### Passo 6 — Selecionar o arquivo JSON
Na janela de seleção de arquivo, navegue até a pasta do workflow desejado e
selecione o arquivo `.json`:

| Workflow | Arquivo |
|----------|---------|
| 01 - Chatbot Simples | `workflows/01-chatbot-simples/chatbot-simples.json` |
| 02 - Chatbot com Memória | `workflows/02-chatbot-com-memoria/chatbot-memoria.json` |
| 03 - RAG com Documentos | `workflows/03-rag-documentos/rag-documentos.json` |
| 04 - Agente com Tools | `workflows/04-agente-com-tools/agente-tools.json` |
| 05 - Agente Custom Tool | `workflows/05-agente-custom-tool/agente-custom-tool.json` |

### Passo 7 — Configurar a API Key
Após a importação, os nodes aparecerão no canvas. Agora:

1. Clique no node **"ChatOpenAI"** (azul/roxo)
2. No campo **"Connect Credential"**, clique em **"Create New"**
3. Dê um nome (ex: "Minha OpenAI Key")
4. Cole sua API Key no campo (começa com `sk-...`)
5. Clique **"Add"**

### Passo 8 — Salvar
Clique no botão **💾 (disquete)** no canto superior direito para salvar.
Dê um nome ao chatflow (ex: "01 - Chatbot Simples").

### Passo 9 — Testar!
Clique no ícone de **💬 (balão de chat)** no canto inferior direito.
Uma janela de chat abrirá. Digite sua primeira mensagem e veja funcionar!

---

## Método 2: Importar pela API (Avançado)

Se preferir usar a API REST do Flowise:

```bash
curl -X POST http://localhost:3000/api/v1/chatflows \
  -H "Content-Type: application/json" \
  -d @workflows/01-chatbot-simples/chatbot-simples.json
```

> Nota: Este método é útil para automação, mas para aprendizado use o Método 1.

---

## Configuração por Workflow

### Workflow 01 — Chatbot Simples
| O que configurar | Onde | O que colocar |
|-----------------|------|---------------|
| API Key | Node "ChatOpenAI" → Connect Credential | Sua OpenAI Key |
| (Opcional) Modelo | Node "ChatOpenAI" → Model Name | gpt-4o-mini (padrão) |

### Workflow 02 — Chatbot com Memória
| O que configurar | Onde | O que colocar |
|-----------------|------|---------------|
| API Key | Node "ChatOpenAI" → Connect Credential | Sua OpenAI Key |
| (Opcional) Personalidade | Node "Conversation Chain" → System Message | Texto livre |

### Workflow 03 — RAG com Documentos
| O que configurar | Onde | O que colocar |
|-----------------|------|---------------|
| API Key (Chat) | Node "ChatOpenAI" → Connect Credential | Sua OpenAI Key |
| API Key (Embeddings) | Node "OpenAI Embeddings" → Connect Credential | Mesma OpenAI Key |
| PDF | Node "Pdf File" → Upload | Qualquer arquivo PDF |
| **Upsert** | Botão "Upsert" (ícone ↑) no topo | Clicar após upload |

> ⚠️ **IMPORTANTE:** Após fazer upload do PDF, clique no botão **"Upsert"** para
> processar o documento. Sem isso, o chatbot não terá acesso ao conteúdo!

### Workflow 04 — Agente com Tools
| O que configurar | Onde | O que colocar |
|-----------------|------|---------------|
| API Key (OpenAI) | Node "ChatOpenAI" → Connect Credential | Sua OpenAI Key |
| (Opcional) SearchApi Key | Node "SearchApi" → Connect Credential | Key do searchapi.io |

> Se não tiver SearchApi: delete a conexão (edge) entre SearchApi e o Agent.
> O workflow funcionará apenas com a Calculator.

### Workflow 05 — Agente com Custom Tool
| O que configurar | Onde | O que colocar |
|-----------------|------|---------------|
| API Key | Node "ChatOpenAI" → Connect Credential | Sua OpenAI Key |
| Custom Tool | **Criar ANTES** em Tools → Add New | Ver README do workflow 05 |
| Selecionar Tool | Node "Custom Tool" → Select Tool | Escolher "consultar_cep" |

> ⚠️ **IMPORTANTE:** Você precisa criar a Custom Tool separadamente ANTES de
> selecionar no workflow. Veja o README do workflow 05 para instruções detalhadas.

---

## Dicas Importantes

### 💡 Credential compartilhada
Após criar a credential da OpenAI uma vez, ela fica salva no Flowise.
Nos próximos workflows, basta selecionar a credential existente (não precisa criar de novo).

### 💡 Como saber se está funcionando
- ✅ Todos os nodes conectados (linhas entre eles)
- ✅ Nenhum node com borda vermelha (indica erro)
- ✅ Credential configurada (sem ícone de alerta no node)
- ✅ Chat abre sem erro ao clicar no ícone de balão

### 💡 Se der erro ao importar
1. Verifique se o arquivo JSON está completo (não truncado)
2. Verifique a versão do Flowise (>= 1.6.x recomendado)
3. Tente criar um chatflow vazio e adicionar os nodes manualmente

### 💡 Onde ficam os dados?
- **Credentials:** Ficam salvas no banco do Flowise (SQLite por padrão)
- **Chatflows:** Salvos no banco também
- **Vetores (RAG):** No In-Memory (perde ao reiniciar) ou em vector store externo
- **Histórico de chat:** Salvo no banco do Flowise

---

## Ordem de Execução Recomendada

```
┌─────────────────┐
│  INSTALAR        │
│  FLOWISE         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────────────────────────────┐
│  CRIAR           │     │  Acesse platform.openai.com              │
│  OPENAI KEY      │────▶│  Gere uma API Key                        │
└────────┬────────┘     │  Adicione créditos ($5 basta para testar)│
         │              └─────────────────────────────────────────┘
         ▼
┌─────────────────┐
│  WORKFLOW 01     │  ← Comece aqui! O mais simples.
│  Chatbot Simples│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  WORKFLOW 02     │  ← Adiciona memória ao chatbot.
│  Com Memória     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  WORKFLOW 03     │  ← Chatbot que responde sobre seus PDFs.
│  RAG Documentos  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  WORKFLOW 04     │  ← Agente que usa ferramentas (calculator, web).
│  Agente + Tools  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  WORKFLOW 05     │  ← Crie suas próprias ferramentas (APIs).
│  Custom Tool     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  PRÓXIMOS PASSOS │
│  - Sequential    │
│    Agents        │
│  - WhatsApp      │
│  - Deploy        │
└─────────────────┘
```

---

## Problemas Comuns na Importação

| Problema | Causa | Solução |
|----------|-------|---------|
| "Unable to load chatflow" | JSON mal formado | Redownload o arquivo |
| Nodes aparecem desconectados | Versão diferente do Flowise | Reconecte manualmente |
| "Credential not found" | API Key não configurada | Crie a credential no node |
| Chat não abre | Flow não salvo | Clique em 💾 primeiro |
| "Model not found" | Modelo não disponível na sua conta | Troque para gpt-4o-mini |
| "Rate limit exceeded" | Muitas requisições à OpenAI | Aguarde 1 minuto e tente de novo |
| Resposta vazia no RAG | PDF não processado | Clique em "Upsert" após upload |
| Custom Tool não aparece | Tool não criada ainda | Crie em Tools → Add New primeiro |

---

## Alternativa: Usar Ollama (100% Gratuito e Local)

Se não quiser gastar com OpenAI, use Ollama:

### 1. Instalar Ollama
- Windows: https://ollama.com/download
- Após instalar, abra o terminal e rode:
```bash
ollama pull llama3
```

### 2. Substituir o Node nos Workflows
Em vez de **ChatOpenAI**, use **ChatOllama**:
- Base URL: `http://localhost:11434`
- Model Name: `llama3` (ou `mistral`, `codellama`, etc.)
- Temperature: mesma configuração

### 3. Para Embeddings (Workflow 03)
Em vez de **OpenAI Embeddings**, use **Ollama Embeddings**:
- Base URL: `http://localhost:11434`
- Model: `nomic-embed-text`

```bash
# Baixar o modelo de embeddings
ollama pull nomic-embed-text
```

> **Prós do Ollama:** Grátis, privado (dados não saem da sua máquina)
> **Contras:** Mais lento que OpenAI, precisa de boa GPU para modelos grandes
