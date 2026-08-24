# Workflow 14 - Multi-Agent Supervisor (Orquestração de Agentes)

## 🎯 Objetivo

Criar um sistema onde um **agente Supervisor** (gerente) delega tarefas para
**agentes Workers** (funcionários especializados) e coordena suas respostas.

**Diferença dos workflows anteriores:**
- Workflow 11 (Sequential): A → B → C (ordem fixa)
- Workflow 12 (Condicional): Classificador → um dos agentes
- **Workflow 14 (Supervisor): Gerente decide QUAL worker ativar, podendo chamar VÁRIOS e ITERAR**

**Caso de uso:** Equipe de marketing virtual — o Supervisor recebe o pedido e
delega para o Redator, Designer ou Analista conforme necessário.

---

## 📐 Arquitetura do Fluxo

```
                                         ┌──────────────────────┐
                                    ┌───▶│  Worker: REDATOR      │───┐
                                    │    │  Cria textos e copy   │   │
                                    │    └──────────────────────┘   │
                                    │                                │
┌───────┐   ┌─────────────────┐    │    ┌──────────────────────┐   │    ┌───────┐
│ START │──▶│   SUPERVISOR     │────┼───▶│  Worker: ANALISTA     │───┼───▶│  END  │
│       │   │                  │    │    │  Analisa dados e KPIs │   │    │       │
└───────┘   │ "Quem deve       │    │    └──────────────────────┘   │    └───────┘
            │  trabalhar        │    │                                │
            │  nesta tarefa?"   │◀───┤    ┌──────────────────────┐   │
            │                  │    └───▶│  Worker: PLANEJADOR   │───┘
            │ Pode delegar     │         │  Cria estratégias     │
            │ para 1 ou mais   │         └──────────────────────┘
            │ workers          │
            └─────────────────┘
                    ▲                    Workers RETORNAM resultado
                    │                    ao Supervisor que pode:
                    └────────────────── - Aceitar e finalizar
                                        - Pedir revisão
                                        - Delegar para outro worker
```

---

## 🆕 Conceito: Supervisor vs Sequential vs Conditional

| Aspecto | Sequential (#11) | Conditional (#12) | Supervisor (#14) |
|---------|-----------------|-------------------|------------------|
| Quem decide | Ninguém (ordem fixa) | Condition Node (regras) | LLM (inteligente) |
| Workers ativados | Todos, em ordem | Apenas 1 (o correto) | 1 ou mais, iterativo |
| Loops/iteração | Não | Não | **Sim** (pode pedir revisão) |
| Complexidade | Baixa | Média | Alta |
| Qualidade resultado | Boa | Boa | Excelente (refina) |
| Custo tokens | Médio | Baixo | Alto (múltiplas rodadas) |
| Analogia | Esteira de fábrica | Central telefônica | Gerente + equipe |

### O Loop do Supervisor

```
Pedido: "Crie uma campanha de Black Friday"
         │
         ▼
Supervisor pensa: "Vou precisar de estratégia primeiro"
         │
         ▼
[PLANEJADOR] → "Estratégia: desconto progressivo, foco em email + redes sociais"
         │
         ▼
Supervisor pensa: "Agora preciso do texto da campanha"
         │
         ▼
[REDATOR] → "Copy: '🖤 Black Friday XYZ: até 60% OFF! Só até domingo...'"
         │
         ▼
Supervisor pensa: "Preciso de métricas de referência"
         │
         ▼
[ANALISTA] → "Benchmarks: taxa de abertura email 25%, conversão 3-5%..."
         │
         ▼
Supervisor pensa: "Tenho tudo. Vou compilar a resposta final."
         │
         ▼
[RESPOSTA FINAL]: Compila estratégia + copy + métricas em um plano completo
```

---

## 🧩 Nodes Utilizados (Agentflow)

### 1. Supervisor Agent ⭐ NOVO!
- **O que faz:** Recebe a tarefa e DECIDE qual worker ativar
- **System Prompt:** Define o papel de gerente e lista os workers disponíveis
- **Diferencial:** Pode chamar workers múltiplas vezes e em qualquer ordem
- **Usa "routing":** Após cada worker retornar, o Supervisor decide o próximo passo

### 2. Worker Agents (3x)
- **Redator:** Especialista em textos, copywriting, emails
- **Analista:** Especialista em dados, métricas, KPIs
- **Planejador:** Especialista em estratégia e planejamento

### 3. Loop Control
- **Max iterations:** Evita loops infinitos (limite de rodadas)
- **FINISH condition:** O Supervisor pode dizer "FINISH" para encerrar

---

## ⚙️ Como Configurar

### Passo a passo

1. **Crie um Agentflow** (NÃO Chatflow) no Flowise
2. **Adicione os nodes:**
   - 1x Start
   - 1x Agent (Supervisor)
   - 3x Agent (Workers)
   - 1x End
3. **Configure o Supervisor** com o System Prompt abaixo
4. **Configure cada Worker** com sua especialidade
5. **Conecte:** Start → Supervisor → Workers → Supervisor (loop) → End
6. **API Key:** Configure em todos os ChatOpenAI

### System Prompt do Supervisor

```
Você é um SUPERVISOR de uma equipe de marketing. Sua função é:
1. Receber a tarefa do usuário
2. Decidir QUAL worker ativar para cada parte da tarefa
3. Compilar o resultado final

Workers disponíveis:
- REDATOR: Cria textos, copies, emails, posts para redes sociais
- ANALISTA: Analisa dados, fornece métricas, benchmarks, KPIs
- PLANEJADOR: Cria estratégias, planos de ação, cronogramas

Regras:
- Ative os workers na ordem que fizer sentido para a tarefa
- Você pode ativar o mesmo worker mais de uma vez (para revisão)
- Quando tiver toda a informação necessária, responda "FINISH" seguido da resposta final compilada
- Responda sempre em português do Brasil
- Seja eficiente — não ative workers desnecessariamente

Para delegar, responda APENAS com o nome do worker: REDATOR, ANALISTA ou PLANEJADOR
Para finalizar, responda: FINISH seguido do resultado compilado
```

### System Prompt do Redator

```
Você é um REDATOR CRIATIVO especialista em marketing digital.
Crie textos persuasivos, envolventes e profissionais.

Formatos que você domina:
- Emails marketing
- Posts para Instagram/LinkedIn
- Headlines e CTAs
- Descrições de produto
- Newsletters

Regras:
- Sempre em português do Brasil
- Adapte o tom ao público-alvo indicado
- Inclua CTAs (Call-to-Action) quando relevante
- Seja conciso mas impactante
```

### System Prompt do Analista

```
Você é um ANALISTA DE DADOS de marketing.
Forneça insights baseados em dados e benchmarks do mercado.

Sua expertise:
- Métricas de email (taxa abertura, clique, conversão)
- Métricas de redes sociais (engajamento, alcance, crescimento)
- ROI de campanhas
- Benchmarks por indústria
- Sugestões de metas realistas

Regras:
- Use números e porcentagens sempre que possível
- Cite benchmarks de mercado quando relevante
- Sugira KPIs para acompanhar
- Seja objetivo e data-driven
```

### System Prompt do Planejador

```
Você é um PLANEJADOR ESTRATÉGICO de marketing.
Crie planos de ação estruturados e cronogramas.

Sua expertise:
- Estratégias de campanha
- Cronogramas e timelines
- Definição de público-alvo
- Canais de distribuição
- Orçamento e alocação

Regras:
- Estruture com bullets e numeração
- Inclua timeline quando relevante
- Defina responsáveis e prazos
- Seja prático e executável
```

---

## 🧪 Testes Sugeridos

### Teste 1: Tarefa que ativa TODOS os workers

```
"Crie uma campanha completa de lançamento de produto para um app de fitness.
Preciso da estratégia, dos textos e das métricas de sucesso."
```

**Esperado:** Supervisor ativa Planejador → Redator → Analista → FINISH

### Teste 2: Tarefa que ativa apenas 1 worker

```
"Escreva um email marketing para o Dia das Mães com tema de joias"
```

**Esperado:** Supervisor ativa apenas Redator → FINISH

### Teste 3: Tarefa com iteração/revisão

```
"Crie um post para LinkedIn sobre IA no RH. Quero dados e números no texto."
```

**Esperado:** Supervisor ativa Analista (dados) → Redator (escreve com dados) → FINISH

### Teste 4: Tarefa complexa multi-etapa

```
"Planeje uma estratégia de conteúdo para 3 meses focada em SEO, 
incluindo cronograma, temas de posts e metas de crescimento"
```

**Esperado:** Planejador → Redator (temas) → Analista (metas) → FINISH com plano completo

---

## 📊 Vantagens e Desvantagens

### Vantagens
- ✅ Resultado muito superior (especialização + iteração)
- ✅ Flexível — lida com qualquer combinação de tarefa
- ✅ Escalável — adicione novos workers sem alterar o Supervisor
- ✅ Cada worker pode ter tools próprias (RAG, APIs, etc.)
- ✅ O Supervisor pode pedir REVISÃO a um worker

### Desvantagens
- ❌ Custo alto de tokens (múltiplas chamadas ao LLM)
- ❌ Mais lento (cada worker é uma roundtrip)
- ❌ Pode ter loops (mitigue com max iterations)
- ❌ Mais complexo para debugar
- ❌ Requer bons prompts para funcionar bem

---

## 🔄 Variações para Praticar

### 1. Equipe de Desenvolvimento de Software
```
Supervisor: Tech Lead
Workers:
- Arquiteto: Define stack e design
- Desenvolvedor: Escreve código
- QA: Cria testes e revisa
```

### 2. Equipe Jurídica
```
Supervisor: Sócio
Workers:
- Pesquisador: Busca jurisprudência
- Redator: Redige petições
- Revisor: Verifica conformidade
```

### 3. Dar tools aos Workers
- **Analista** com tool de consulta de API de analytics
- **Redator** com tool de verificação de SEO
- **Planejador** com tool de calendário

---

## 📖 Conceitos Aprendidos

- ✅ O padrão **Supervisor/Worker** para orquestração de agentes
- ✅ Como o Supervisor **decide dinamicamente** quem ativar
- ✅ O conceito de **loops e iteração** entre Supervisor e Workers
- ✅ Como ter **workers especializados** com prompts focados
- ✅ A condição de **FINISH** para encerrar o ciclo
- ✅ Trade-offs: qualidade vs custo vs latência
- ✅ Diferença entre Sequential, Conditional e Supervisor

---

## ➡️ Próximo Passo

Vá para **Workflow 15 - Chatbot Full-Stack Deploy** para aprender a
publicar seu chatbot como API e embeddá-lo em um site real!
