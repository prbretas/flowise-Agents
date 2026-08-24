# Workflow 04 - Agente com Tools (Calculator + Web Search)

## 🎯 Objetivo

Criar um **Agente** — uma IA que decide **sozinha** quais ferramentas usar
para responder sua pergunta. Diferente dos chatbots anteriores (que só geram texto),
um agente pode **agir**: calcular, buscar na web, consultar APIs, etc.

**A grande diferença:** Nos workflows anteriores, o fluxo era fixo (sempre faz a mesma coisa).
Um Agente **decide** o que fazer com base na sua pergunta.

---

## 📐 Arquitetura do Fluxo

```
┌───────────────┐
│  Calculator   │──────┐
│  (Matemática) │      │
└───────────────┘      │     ┌───────────────────────────┐
                       ├────▶│   OpenAI Function Agent    │
┌───────────────┐      │     │                           │
│  SearchApi    │──────┘     │  DECIDE qual tool usar    │
│  (Busca web)  │            │  com base na pergunta     │
└───────────────┘            │                           │
                             │  System: "Use calculator  │
┌───────────────┐            │  para math, search para   │
│  ChatOpenAI   │───────────▶│  info atual"             │
│  (Cérebro)    │            │                           │
└───────────────┘            └───────────────────────────┘
                                       ▲
┌───────────────┐                      │
│Buffer Memory  │──────────────────────┘
│(Histórico)    │
└───────────────┘
```

---

## 🤔 Chain vs Agent — Qual a Diferença?

| Aspecto | Chain (Workflows 01-03) | Agent (Este workflow) |
|---------|------------------------|----------------------|
| Fluxo | Fixo, sempre o mesmo | Dinâmico, decide a cada pergunta |
| Tools | Não usa | Usa ferramentas externas |
| Decisão | Sempre segue o mesmo caminho | Escolhe o melhor caminho |
| Analogia | Linha de produção | Funcionário que pensa |
| Exemplo | "Responda com base no PDF" | "Calcule 15% de 350 OU busque notícias" |

### Como o Agente "Pensa"

```
Pergunta: "Quanto é 15% de desconto em R$ 2.500?"

Pensamento do Agente:
1. "Preciso calcular 15% de 2500... vou usar a Calculator"
2. [Chama Calculator com: 2500 * 0.15]
3. [Calculator retorna: 375]
4. "O desconto é R$ 375, então o preço final é R$ 2.125"
5. [Responde ao usuário]

---

Pergunta: "Quais são as notícias de hoje sobre IA?"

Pensamento do Agente:
1. "Preciso de informação atual... vou usar SearchApi"
2. [Chama SearchApi com: "notícias inteligência artificial hoje"]
3. [SearchApi retorna resultados]
4. "Baseado nos resultados, as principais notícias são..."
5. [Responde ao usuário]

---

Pergunta: "O que é fotossíntese?"

Pensamento do Agente:
1. "Isso é conhecimento geral, não preciso de ferramentas"
2. [Responde diretamente sem usar tools]
```

---

## 🧩 Nodes Utilizados

### 1. OpenAI Function Agent ⭐ NOVO!
- **O que faz:** É o "gerente" que decide qual ferramenta usar
- **Como funciona:** Usa OpenAI Function Calling para escolher tools
- **System Message:** Instruções sobre quando usar cada tool
- **Max Iterations:** 5 (limite de tentativas para evitar loops infinitos)
- **Analogia:** Um gerente que sabe delegar tarefas

### 2. Calculator (Tool)
- **O que faz:** Executa operações matemáticas
- **Aceita:** Expressões como `2500 * 0.15`, `sqrt(144)`, `(100 + 50) / 3`
- **Não precisa de API Key:** Funciona localmente
- **Analogia:** Uma calculadora científica

### 3. SearchApi (Tool)
- **O que faz:** Busca informações em tempo real na internet
- **Precisa:** API Key do SearchApi (https://www.searchapi.io)
- **Alternativas gratuitas:** SerpAPI, ou omita este node para testar só com Calculator
- **Analogia:** O Google do seu agente

### 4. ChatOpenAI (Modelo)
- **O que faz:** O modelo que o agente usa para raciocinar e decidir
- **Importante:** Para agents, use modelos com Function Calling (gpt-4o-mini, gpt-4o)
- **Temperature:** 0.5 (precisa pensar com clareza, mas sem ser robótico)

### 5. Buffer Memory
- **O que faz:** Lembra de conversas anteriores
- **Exemplo:** "Agora multiplique esse resultado por 3" ← precisa lembrar o resultado anterior

---

## ⚙️ Como Configurar

### Passo 1: Configuração Mínima (só Calculator)

1. Importe `agente-tools.json` no Flowise
2. Configure a API Key no node **ChatOpenAI**
3. **Opcional:** Se não tiver SearchApi, desconecte esse node (delete a edge)
4. Salve e teste

### Passo 2: Adicionar SearchApi (opcional)

1. Crie conta em https://www.searchapi.io (tem plano gratuito)
2. Pegue sua API Key
3. No Flowise, clique no node **SearchApi**
4. Em "Connect Credential", clique "Create New"
5. Cole a API Key
6. Salve

### ⚠️ Alternativa Gratuita para Busca Web

Se não quiser criar conta no SearchApi, substitua por:
- **SerpAPI** (100 buscas/mês grátis): https://serpapi.com
- **Brave Search** (precisa de API Key gratuita)
- **Ou simplesmente remova** o SearchApi e teste apenas com Calculator

---

## 🧪 Testes Sugeridos

### Testando a Calculator

| Sua mensagem | O que o agente deve fazer |
|-------------|---------------------------|
| "Quanto é 2500 * 0.15?" | Usar Calculator → responder 375 |
| "Se eu ganho R$ 8.000 e gasto 35% com aluguel, quanto sobra?" | Calculator: 8000 * 0.35 = 2800, depois 8000 - 2800 = 5200 |
| "Raiz quadrada de 144" | Calculator → 12 |
| "Converta 100 km/h para m/s" | Calculator: 100 / 3.6 ≈ 27.78 |

### Testando a SearchApi (se configurada)

| Sua mensagem | O que o agente deve fazer |
|-------------|---------------------------|
| "Qual é a cotação do dólar hoje?" | SearchApi → buscar cotação atual |
| "Quais são as notícias sobre IA hoje?" | SearchApi → buscar notícias |
| "Como está o clima em São Paulo?" | SearchApi → buscar previsão |

### Testando a Decisão do Agente

| Sua mensagem | Tool esperada |
|-------------|---------------|
| "O que é DNA?" | Nenhuma (conhecimento geral) |
| "Quanto é 17% de 3.400?" | Calculator |
| "Quem ganhou a eleição?" | SearchApi |
| "Calcule 20% de R$ 1.500 e me diga se esse valor é maior que o salário mínimo atual" | Calculator + SearchApi! |

> ✅ O último teste é especial: o agente deve usar DUAS tools na mesma pergunta!

---

## 🔄 Variações para Praticar

### 1. Adicionar mais Tools
Outras ferramentas disponíveis no Flowise:
- **Web Browser:** Navega em páginas web específicas
- **Wikipedia:** Busca na Wikipedia
- **Weather:** Previsão do tempo
- **Code Interpreter:** Executa código Python

### 2. Trocar o Agent
No lugar de "OpenAI Function Agent", tente:
- **Conversational Agent:** Mais conversacional, menos "técnico"
- **ReAct Agent:** Mostra o raciocínio passo-a-passo (Thought → Action → Observation)

### 3. Limitar as Iterations
- `maxIterations: 2` → Agente é forçado a ser rápido
- `maxIterations: 10` → Agente pode pensar mais, mas gasta mais tokens

---

## 📊 Como o Function Calling Funciona (Detalhes)

Quando o modelo GPT com Function Calling recebe uma pergunta:

```json
// O Flowise envia ao modelo algo assim:
{
  "messages": [{"role": "user", "content": "Quanto é 15% de 2500?"}],
  "functions": [
    {
      "name": "calculator",
      "description": "Perform calculations on response",
      "parameters": {"type": "object", "properties": {"input": {"type": "string"}}}
    },
    {
      "name": "searchAPI",
      "description": "Search the web for current information",
      "parameters": {"type": "object", "properties": {"query": {"type": "string"}}}
    }
  ]
}

// O modelo DECIDE chamar a calculator:
{
  "function_call": {
    "name": "calculator",
    "arguments": "{\"input\": \"2500 * 0.15\"}"
  }
}

// O Flowise executa a calculator e devolve o resultado ao modelo
// O modelo então formula a resposta final
```

---

## 📖 Conceitos Aprendidos

- ✅ O que é um **Agent** e como ele difere de uma Chain
- ✅ Como **Function Calling** permite ao modelo escolher tools
- ✅ O conceito de **Tools** como extensões das capacidades do modelo
- ✅ Como o agente **raciocina** (Thought → Action → Observation → Answer)
- ✅ Trade-off entre **maxIterations** e custo/tempo
- ✅ Que um agente pode usar **múltiplas tools** em uma única resposta
- ✅ A importância do **System Message** para guiar as decisões do agente

---

## ➡️ Próximo Passo

Vá para **Workflow 05 - Agente com Custom Tool** para aprender a criar
suas PRÓPRIAS ferramentas personalizadas (chamar APIs, consultar bancos, etc)!
