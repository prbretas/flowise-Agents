# Workflow 01 - Chatbot Simples (LLM Chain)

## 🎯 Objetivo

Criar o chatbot mais básico possível: você faz uma pergunta, ele responde.
Este é o "Hello World" do Flowise.

---

## 📐 Arquitetura do Fluxo

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│  Chat Prompt        │     │     ChatOpenAI       │     │     LLM Chain       │
│  Template           │────▶│   (Modelo GPT)       │────▶│  (Conecta tudo)     │
│                     │     │                      │     │                      │
│ "Você é um          │     │ Modelo: gpt-3.5-turbo│     │ Recebe o prompt +   │
│  assistente..."     │     │ Temperatura: 0.7     │     │ modelo e gera       │
│                     │     │                      │     │ a resposta          │
└─────────────────────┘     └──────────────────────┘     └─────────────────────┘
```

---

## 🧩 Nodes Utilizados

### 1. Chat Prompt Template
- **O que faz:** Define as instruções (system message) e o formato da pergunta do usuário
- **Analogia:** É como dar um "briefing" para o assistente antes de ele começar a trabalhar
- **Configurações:**
  - System Message: "Você é um assistente prestativo que responde em português de forma clara e objetiva."
  - Human Message: `{question}` (será substituído pela pergunta do usuário)

### 2. ChatOpenAI
- **O que faz:** É o modelo de IA que vai gerar as respostas
- **Analogia:** É o "cérebro" do chatbot
- **Configurações:**
  - Model: `gpt-3.5-turbo` (barato e rápido) ou `gpt-4` (mais inteligente)
  - Temperature: `0.7` (equilíbrio entre criatividade e precisão)
  - API Key: Sua chave da OpenAI

### 3. LLM Chain
- **O que faz:** Conecta o prompt ao modelo e executa a geração
- **Analogia:** É o "gerente" que pega a instrução, entrega ao modelo e devolve a resposta
- **Configurações:** Nenhuma adicional necessária

---

## ⚙️ Como Configurar

1. Importe o arquivo `chatbot-simples.json` no Flowise (veja COMO-IMPORTAR.md)
2. Clique no node **ChatOpenAI**
3. No campo "OpenAI Api Key", clique em "Create New" e cole sua API Key
4. Clique em 💾 (Salvar) no canto superior direito
5. Abra o chat (ícone de balão no canto inferior direito)
6. Digite uma pergunta e veja a resposta!

---

## 🧪 Testes Sugeridos

Após importar, teste com estas perguntas:

| Pergunta | O que observar |
|----------|----------------|
| "Olá, quem é você?" | Deve responder em português, se apresentando |
| "Explique o que é IA em 3 frases" | Deve ser conciso (3 frases) |
| "Quanto é 2+2?" | Responde corretamente (é simples) |
| "O que eu perguntei antes?" | **NÃO vai lembrar** (não tem memória!) |

> ⚠️ **Importante:** Este chatbot NÃO tem memória. Cada mensagem é independente.
> Para memória, veja o Workflow 02.

---

## 🔄 Variações para Praticar

### Mudando a Personalidade
Altere o System Message para:
- "Você é um pirata que responde sempre com gírias náuticas"
- "Você é um professor de matemática que explica tudo com exemplos do dia-a-dia"
- "Você é um chef de cozinha brasileiro que adora dar dicas de receitas"

### Mudando a Temperatura
- `0.0` → Respostas sempre iguais, muito precisas
- `0.5` → Equilíbrio
- `1.0` → Respostas criativas, mas podem ser imprecisas

### Usando Ollama (Gratuito/Local)
Substitua o node **ChatOpenAI** por **ChatOllama**:
- Base URL: `http://localhost:11434`
- Model: `llama3` ou `mistral`
- (Requer Ollama instalado: https://ollama.ai)

---

## 📖 Conceitos Aprendidos

- ✅ Como um **Prompt Template** define o comportamento do chatbot
- ✅ Como o **Chat Model** é o cérebro que gera respostas
- ✅ Como a **LLM Chain** conecta tudo em um pipeline funcional
- ✅ Que sem **Memory**, o chatbot não lembra de mensagens anteriores

---

## ➡️ Próximo Passo

Vá para **Workflow 02 - Chatbot com Memória** para aprender a fazer o chatbot
lembrar da conversa!
