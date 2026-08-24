# Workflow 12 - Roteamento Condicional (If/Else com Agentes)

## 🎯 Objetivo

Criar um sistema que **classifica a intenção** do usuário e **roteia** para o
agente especialista correto. Como uma central de atendimento onde a URA
direciona para o departamento certo.

**Caso de uso:** Chatbot corporativo que atende 4 departamentos:
Vendas, Suporte Técnico, RH e Perguntas Gerais.

---

## 📐 Arquitetura do Fluxo

```
                                    ┌─────────────────────┐
                          ┌────────▶│ Agente VENDAS       │────┐
                          │         │ "Plano Pro: R$79..."│    │
                          │         └─────────────────────┘    │
                          │                                     │
┌───────┐  ┌────────────┐│         ┌─────────────────────┐    │  ┌───────┐
│ START │─▶│CLASSIFICADOR│├────────▶│ Agente SUPORTE      │────┼─▶│  END  │
│       │  │             ││         │ "Limpar cache..."   │    │  │       │
└───────┘  │ "VENDAS?    ││         └─────────────────────┘    │  └───────┘
           │  SUPORTE?   ││                                     │
           │  RH?        │├─ ─ ─ ─▶┌─────────────────────┐    │
           │  GERAL?"    ││         │ Agente RH            │────┤
           └────────────┘│         │ "30 dias férias..."  │    │
                  │       │         └─────────────────────┘    │
                  │       │                                     │
                  ▼       │         ┌─────────────────────┐    │
           ┌──────────┐  └────────▶│ Agente GERAL         │────┘
           │ CONDITION │            │ "Olá! Como posso..." │
           │ (If/Else) │            └─────────────────────┘
           └──────────┘
```

---

## 🆕 Conceito-Chave: Condition Node

O **Condition Node** é o "roteador" — ele avalia a saída do Classificador
e dirige o fluxo para o caminho correto.

```
Classificador Output: "VENDAS"
         │
         ▼
Condition avalia:
  - output contains "VENDAS"?  → ✅ Vai para Agente Vendas
  - output contains "SUPORTE"? → ❌ Skip
  - output contains "RH"?      → ❌ Skip
  - output contains "GERAL"?   → ❌ Skip (default)
```

### Diferença do Workflow 11

| Workflow 11 (Sequential) | Workflow 12 (Condicional) |
|-------------------------|--------------------------|
| Todos agentes executam em ordem | Apenas 1 agente executa (o correto) |
| A → B → C → End | A → Condição → B OU C OU D → End |
| Mais tokens (todos rodam) | Menos tokens (só 2 rodam: classificador + especialista) |
| Para tarefas multi-etapa | Para roteamento por intenção |

---

## 🧩 Nodes Utilizados

### 1. Agente Classificador (Primeiro na cadeia)
- **Função:** Recebe a mensagem e retorna APENAS a categoria
- **Output esperado:** Uma palavra: `VENDAS`, `SUPORTE`, `RH` ou `GERAL`
- **Max Iterations:** 1 (precisa ser rápido, só classifica)
- **Temperatura:** 0.3 (preciso, sem criatividade)

### 2. Condition Node ⭐ NOVO!
- **O que faz:** Avalia condições na saída do agente anterior e roteia
- **Condições configuradas:**
  - Se output contém "VENDAS" → rota para Agente Vendas
  - Se output contém "SUPORTE" → rota para Agente Suporte
  - Se output contém "RH" → rota para Agente RH
  - Default → rota para Agente Geral
- **Analogia:** Um `switch/case` ou `if/else` em programação

### 3. Agentes Especialistas (4 agentes paralelos)
- **Vendas:** Conhece produtos, preços, promoções
- **Suporte:** Troubleshooting técnico, passos de resolução
- **RH:** Políticas, benefícios, processos internos
- **Geral:** Saudações, redirecionamento, perguntas fora de escopo

### 4. End Node
- Recebe de QUALQUER um dos 4 agentes (todos conectam ao End)

---

## ⚙️ Como Configurar

1. **Importe** `roteamento-condicional.json`
2. **IMPORTANTE:** Crie como **Agentflow** (não Chatflow)
3. **API Key:** Configure no ChatOpenAI
4. **Ajuste condições:** No Condition Node, verifique se as condições estão corretas
5. **Salve** e teste com perguntas de diferentes departamentos

---

## 🧪 Testes Sugeridos

### Roteamento para VENDAS

| Pergunta | Classificação | Agente ativado |
|----------|---------------|----------------|
| "Quanto custa o plano Pro?" | VENDAS | Especialista Vendas |
| "Quais são os planos disponíveis?" | VENDAS | Especialista Vendas |
| "Tem desconto para pagamento anual?" | VENDAS | Especialista Vendas |
| "Quero fazer upgrade do meu plano" | VENDAS | Especialista Vendas |

### Roteamento para SUPORTE

| Pergunta | Classificação | Agente ativado |
|----------|---------------|----------------|
| "Meu app está travando" | SUPORTE | Especialista Suporte |
| "Não consigo fazer login" | SUPORTE | Especialista Suporte |
| "O sistema está muito lento hoje" | SUPORTE | Especialista Suporte |
| "Recebi um erro 500" | SUPORTE | Especialista Suporte |

### Roteamento para RH

| Pergunta | Classificação | Agente ativado |
|----------|---------------|----------------|
| "Quantos dias de férias eu tenho?" | RH | Especialista RH |
| "Qual o valor do vale refeição?" | RH | Especialista RH |
| "Posso trabalhar de casa na segunda?" | RH | Especialista RH |
| "Quando cai o 13º salário?" | RH | Especialista RH |

### Roteamento para GERAL

| Pergunta | Classificação | Agente ativado |
|----------|---------------|----------------|
| "Olá, bom dia!" | GERAL | Assistente Geral |
| "Obrigado pela ajuda" | GERAL | Assistente Geral |
| "Qual é o horário de funcionamento?" | GERAL | Assistente Geral |

---

## 📊 Operações Disponíveis no Condition Node

| Operação | Descrição | Exemplo |
|----------|-----------|---------|
| `contains` | Output contém o texto | output contains "VENDAS" |
| `not contains` | Output NÃO contém | output not contains "ERRO" |
| `equals` | Exatamente igual | output equals "VENDAS" |
| `not equals` | Não é igual | output not equals "GERAL" |
| `starts with` | Começa com | output starts with "VEN" |
| `ends with` | Termina com | output ends with "DAS" |
| `is empty` | Está vazio | output is empty |
| `is not empty` | Não está vazio | output is not empty |

---

## 🔄 Variações para Praticar

### 1. Adicionar mais departamentos
- Financeiro, Jurídico, Marketing
- Ajuste as condições no Condition Node
- Crie um novo agente para cada departamento

### 2. Classificação por idioma
```
Classificador: detecta idioma → PT, EN, ES
Condition: 
  - PT → Agente em português
  - EN → Agente em inglês
  - ES → Agente em espanhol
```

### 3. Classificação por urgência
```
Classificador: avalia urgência → CRÍTICO, ALTO, MÉDIO, BAIXO
Condition:
  - CRÍTICO → Agente que sugere ligar para suporte
  - ALTO → Agente com respostas rápidas
  - MÉDIO/BAIXO → Agente padrão
```

### 4. Dar Tools específicas a cada agente
- Vendas: Tool de consulta de preços
- Suporte: Tool de consulta de status do sistema
- RH: Tool de consulta de saldo de férias

---

## 🏗️ Arquitetura para Produção

Em produção real, este pattern é muito comum:

```
         ┌─── Vendas (com RAG de catálogo) ──────┐
         │                                         │
User ──▶ Classificador ──▶ Condition ──┤                                         ├──▶ Resposta
         │                             │                                         │
         │                             ├─── Suporte (com RAG de FAQ) ────────────┤
         │                             │                                         │
         │                             ├─── RH (com RAG de políticas) ───────────┤
         │                             │                                         │
         │                             └─── Geral (sem RAG, resposta direta) ────┘
         │
         └── (classificação usando gpt-4o-mini = BARATO)
```

**Economia:** O classificador usa gpt-4o-mini (barato) e os especialistas
podem usar modelos melhores apenas quando necessário.

---

## 📖 Conceitos Aprendidos

- ✅ O que é **roteamento condicional** (dirigir fluxo por condições)
- ✅ O **Condition Node** como `if/else` visual no Flowise
- ✅ O padrão **Classificador → Condição → Especialistas**
- ✅ As operações disponíveis (`contains`, `equals`, `starts with`, etc.)
- ✅ Como ter **múltiplas saídas** de um mesmo Condition Node
- ✅ A economia de tokens usando classificação antes do processamento
- ✅ Diferença entre **sequential** (todos executam) e **conditional** (um executa)

---

## ➡️ Próximo Passo

Vá para **Workflow 13 - RAG Avançado com Reranker** para aprender técnicas
avançadas de busca que melhoram drasticamente a qualidade das respostas!
