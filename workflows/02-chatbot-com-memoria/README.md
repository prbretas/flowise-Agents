# Workflow 02 - Chatbot com Memória (Conversation Chain)

## 🎯 Objetivo

Criar um chatbot que **lembra** das mensagens anteriores na conversa.
A diferença do Workflow 01 é que aqui o bot mantém contexto — ele sabe
o que você disse antes e pode fazer referência.

---

## 📐 Arquitetura do Fluxo

```
┌─────────────────────┐
│    ChatOpenAI        │
│   (Modelo GPT)      │──────────────┐
│                     │              │
│ Modelo: gpt-4o-mini │              ▼
│ Temperatura: 0.7    │     ┌─────────────────────┐
└─────────────────────┘     │  Conversation Chain  │
                            │                      │
┌─────────────────────┐     │  System Message:     │
│   Buffer Memory     │────▶│  "Você é o FlowBot"  │
│                     │     │                      │
│ Guarda histórico    │     │  Gera resposta com   │
│ de mensagens        │     │  contexto completo   │
└─────────────────────┘     └──────────────────────┘
```

---

## 🧩 Nodes Utilizados

### 1. ChatOpenAI (Modelo)
- **O que faz:** Gera as respostas (o "cérebro")
- **Igual ao Workflow 01:** Mesmo modelo, mesma config
- **Configuração:** gpt-4o-mini, temperatura 0.7

### 2. Buffer Memory ⭐ NOVO!
- **O que faz:** Armazena TODAS as mensagens da conversa (pergunta + resposta)
- **Analogia:** É como um "caderno de anotações" onde o bot escreve tudo que foi dito
- **Como funciona:**
  - A cada mensagem sua, salva no buffer
  - A cada resposta do bot, salva no buffer
  - Na próxima pergunta, envia todo o histórico junto com a nova pergunta
- **Configurações:**
  - Memory Key: `chat_history` (nome interno do histórico)
  - Input Key: `input` (chave da mensagem do usuário)

### 3. Conversation Chain
- **O que faz:** É como a LLM Chain do Workflow 01, mas já vem preparada para receber memória
- **Diferença da LLM Chain:** Já tem um input de Memory integrado
- **System Message:** Define a personalidade do bot (aqui: "FlowBot")

---

## 🔍 Diferença: LLM Chain vs Conversation Chain

| Aspecto | LLM Chain (Workflow 01) | Conversation Chain (Workflow 02) |
|---------|------------------------|----------------------------------|
| Memória | ❌ Não suporta | ✅ Suporta nativamente |
| Contexto | Cada msg é isolada | Lembra de tudo |
| Input de Memory | Não tem | Tem (opcional) |
| Uso ideal | Perguntas únicas | Conversas longas |

---

## ⚙️ Como Configurar

1. Importe o arquivo `chatbot-memoria.json` no Flowise
2. Clique no node **ChatOpenAI** e configure sua API Key
3. (Opcional) Edite o System Message no node **Conversation Chain** para mudar a personalidade
4. Salve e abra o chat

---

## 🧪 Testes Sugeridos (Sequência Importante!)

Envie estas mensagens **na ordem** para testar a memória:

| # | Sua mensagem | Resposta esperada |
|---|-------------|-------------------|
| 1 | "Olá! Meu nome é Philippe" | Cumprimentar e reconhecer o nome |
| 2 | "Qual é o seu nome?" | "Me chamo FlowBot" |
| 3 | "Qual é o MEU nome?" | **"Philippe"** ← PROVA de que lembra! |
| 4 | "Quantas mensagens já troquei com você?" | Deve contar ~3 anteriores |
| 5 | "Resuma nossa conversa" | Deve resumir tudo que foi dito |

> ✅ Se o teste 3 funcionar, a memória está OK!
> ❌ Se não lembrar do nome, verifique se o Buffer Memory está conectado.

---

## 📊 Tipos de Memória no Flowise

| Tipo | Comportamento | Quando usar |
|------|--------------|-------------|
| **Buffer Memory** | Guarda TUDO | Conversas curtas (< 20 msgs) |
| **Buffer Window Memory** | Guarda últimas N mensagens | Conversas longas (economia de tokens) |
| **Conversation Summary Memory** | Faz resumo do histórico | Conversas muito longas |
| **Zep Memory** | Guarda em banco externo | Produção, múltiplos usuários |

### ⚠️ Cuidado com Buffer Memory em conversas longas!

Cada mensagem guardada é enviada ao modelo como contexto. Em conversas de
50+ mensagens, o custo de tokens sobe muito e pode estourar o limite do modelo.

**Solução:** Use **Buffer Window Memory** com `windowSize: 10` para guardar
apenas as últimas 10 mensagens.

---

## 🔄 Variações para Praticar

### 1. Trocar para Buffer Window Memory
- Substitua o node "Buffer Memory" por "Buffer Window Memory"
- Configure `Window Size: 5`
- Teste: após 6 mensagens, ele "esquece" a primeira

### 2. Mudar a Personalidade
Edite o System Message para:
- "Você é um tutor de inglês chamado Teacher Bot. Corrija erros gramaticais do usuário gentilmente."
- "Você é um personal trainer virtual. Lembre dos exercícios que o usuário já fez e sugira novos."

### 3. Usando Ollama (Gratuito/Local)
Substitua ChatOpenAI por ChatOllama:
- Base URL: `http://localhost:11434`
- Model: `llama3` ou `mistral`

---

## 📖 Conceitos Aprendidos

- ✅ O que é **Memory** e por que é essencial para chatbots conversacionais
- ✅ Diferença entre **LLM Chain** e **Conversation Chain**
- ✅ Como o **Buffer Memory** armazena histórico completo
- ✅ Trade-offs: memória completa vs economia de tokens
- ✅ Como o **System Message** define a personalidade do bot

---

## ➡️ Próximo Passo

Vá para **Workflow 03 - RAG com Documentos** para aprender a fazer o chatbot
responder perguntas baseadas nos SEUS documentos (PDFs, textos, etc)!
