# Workflow 07 - Structured Output (Respostas em JSON)

## 🎯 Objetivo

Fazer o chatbot responder em **formato JSON estruturado** em vez de texto livre.
Isso é essencial para integrações com outros sistemas (APIs, bancos de dados, dashboards).

**Caso de uso real:** Analisar avaliações de produtos e extrair automaticamente
sentimento, nota, pontos positivos e negativos em formato processável por código.

---

## 📐 Arquitetura do Fluxo

```
┌─────────────────────┐     ┌──────────────────────┐
│  Structured Output  │     │   Chat Prompt        │
│  Parser             │     │   Template           │
│                     │     │                      │
│  Define o formato   │     │ "Analise a avaliação │
│  JSON de saída      │     │  e extraia dados"    │
└─────────┬───────────┘     └──────────┬───────────┘
          │                            │
          ▼                            ▼
┌─────────────────────────────────────────────────────┐
│                    LLM Chain                         │
│                                                     │
│  Recebe: prompt + parser + modelo                   │
│  Saída: JSON estruturado (não texto livre)          │
└─────────────────────────────────────────────────────┘
                         ▲
                         │
              ┌──────────┴──────────┐
              │     ChatOpenAI      │
              │    (gpt-4o-mini)    │
              └─────────────────────┘
```

---

## 🆕 O que há de novo

| Aspecto | Workflows anteriores | Este Workflow |
|---------|---------------------|--------------|
| Formato da resposta | Texto livre | JSON estruturado |
| Previsibilidade | Resposta varia | Sempre mesmo formato |
| Integrabilidade | Difícil de parsear | Fácil de usar em código |
| Novo node | — | Structured Output Parser |

---

## 🧩 Nodes Utilizados

### 1. Structured Output Parser ⭐ NOVO!
- **O que faz:** Define a "forma" que a resposta deve ter (schema JSON)
- **Como funciona:** Gera instruções de formato que são injetadas no prompt
- **Autofix:** Se a primeira resposta não for JSON válido, tenta corrigir automaticamente
- **Schema configurado neste workflow:**

```json
{
  "produto": "string - Nome do produto",
  "sentimento": "string - positivo, negativo ou neutro",
  "nota": "number - Nota de 1 a 5",
  "pontos_positivos": "string - Lista separada por vírgula",
  "pontos_negativos": "string - Lista separada por vírgula",
  "resumo": "string - Resumo em uma frase"
}
```

### 2. Chat Prompt Template
- **System Message:** Instrui o modelo a analisar avaliações
- **Importante:** Inclui `{format_instructions}` — o parser injeta as regras de formato aqui

### 3. LLM Chain + ChatOpenAI
- Mesma função dos workflows anteriores, mas agora com Output Parser conectado
- O Output Parser VALIDA a resposta antes de devolvê-la

---

## ⚙️ Como Configurar

1. **Importe** o arquivo `structured-output.json`
2. **API Key:** Configure no ChatOpenAI
3. **Salve** e abra o chat
4. Envie avaliações de produtos e veja o JSON retornado

---

## 🧪 Testes Sugeridos

### Envie estas avaliações

**Teste 1 - Avaliação positiva:**
```
Comprei o fone JBL Tune 510BT e estou muito satisfeito! O som é 
excelente, a bateria dura mais de 40 horas e o conforto é incrível. 
Único ponto negativo é que não tem cancelamento de ruído ativo. 
Recomendo muito, especialmente pelo preço de R$ 199.
```

**Resposta esperada (JSON):**
```json
{
  "produto": "JBL Tune 510BT",
  "sentimento": "positivo",
  "nota": 4,
  "pontos_positivos": "som excelente, bateria de 40 horas, conforto, bom preço",
  "pontos_negativos": "não tem cancelamento de ruído ativo",
  "resumo": "Fone com excelente custo-benefício, ideal para quem não precisa de ANC"
}
```

**Teste 2 - Avaliação negativa:**
```
Péssima experiência com o Notebook XYZ. Travou 3 vezes na primeira 
semana, o teclado é desconfortável e a tela tem muito reflexo. 
A única coisa boa é que é leve para carregar. Não recomendo.
```

**Teste 3 - Avaliação neutra/mista:**
```
O celular Samsung A54 é ok. Câmera boa mas não excepcional, 
bateria razoável dura um dia, tela bonita. Porém o preço poderia 
ser menor pelo que oferece. Nem bom nem ruim, cumpre o básico.
```

---

## 📊 Outros Schemas para Praticar

### Schema: Extrator de Contatos
```json
[
  { "property": "nome", "type": "string", "description": "Nome completo da pessoa" },
  { "property": "email", "type": "string", "description": "Endereço de email" },
  { "property": "telefone", "type": "string", "description": "Número de telefone" },
  { "property": "empresa", "type": "string", "description": "Nome da empresa" },
  { "property": "cargo", "type": "string", "description": "Cargo ou função" }
]
```

### Schema: Classificador de Tickets de Suporte
```json
[
  { "property": "categoria", "type": "string", "description": "Categoria: bug, feature, duvida, reclamacao" },
  { "property": "prioridade", "type": "string", "description": "Prioridade: baixa, media, alta, critica" },
  { "property": "departamento", "type": "string", "description": "Departamento responsável: TI, Comercial, Financeiro, RH" },
  { "property": "resumo", "type": "string", "description": "Resumo do problema em até 50 palavras" },
  { "property": "acao_sugerida", "type": "string", "description": "Ação recomendada para resolver" }
]
```

### Schema: Analisador de Currículos
```json
[
  { "property": "nome", "type": "string", "description": "Nome do candidato" },
  { "property": "anos_experiencia", "type": "number", "description": "Total de anos de experiência" },
  { "property": "tecnologias", "type": "string", "description": "Tecnologias mencionadas, separadas por vírgula" },
  { "property": "nivel", "type": "string", "description": "Nível: junior, pleno, senior, especialista" },
  { "property": "fit_score", "type": "number", "description": "Score de adequação de 1 a 10" }
]
```

---

## 🔄 Variações para Praticar

### 1. Mudar o Schema
- Edite as propriedades no Structured Output Parser
- Adapte o System Message do prompt para o novo contexto

### 2. Usar a API para automação
- Depois de salvar, use a API do Flowise:
```bash
curl -X POST http://localhost:3000/api/v1/prediction/{chatflow-id} \
  -H "Content-Type: application/json" \
  -d '{"question": "Avaliação: O produto é ótimo..."}'
```
- A resposta vem em JSON pronto para processar!

### 3. Combinar com RAG
- Adicione um vector store para o modelo analisar documentos
  e retornar dados estruturados sobre eles

---

## 📖 Conceitos Aprendidos

- ✅ O que é **Structured Output** e por que é necessário para integrações
- ✅ Como o **Structured Output Parser** define e valida o formato
- ✅ O conceito de **format_instructions** no prompt
- ✅ A opção **Autofix** para recuperação de erros de formato
- ✅ Como criar **schemas customizados** para diferentes casos de uso
- ✅ A diferença entre resposta em texto livre vs JSON estruturado

---

## ➡️ Próximo Passo

Vá para **Workflow 08 - RAG + Agent** para combinar busca em documentos
com a capacidade de decisão de um agente!
