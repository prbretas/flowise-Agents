# Sistema Multi-Agente de Desenvolvimento de Software

## Visão Geral

Um **time de 12 agentes IA** que funciona como uma equipe de desenvolvimento real.
Você dá a ideia, e os agentes refinam, planejam, arquitetam, desenvolvem, testam e entregam
o sistema pronto — com sua aprovação em cada etapa (human-in-the-loop).

**Fluxo simplificado:**
```
VOCÊ (ideia) → Chatbot → Líder → [PO refina] → [Arquiteto projeta] → [DBA modela dados]
                                → [Issues criadas] → [Dev codifica] → [QA revisa]
                                → [DevOps monitora] → [UX melhora] → [Auditor valida]
                                → [Tech Writer documenta] → [Suporte atende usuário final]
                                → ENTREGA (com sua aprovação)
```

---

## Princípios do Sistema

| Princípio | Descrição |
|-----------|-----------|
| **Human-in-the-Loop** | Nada é implementado sem sua aprovação. Você valida cada etapa. |
| **Especialização** | Cada agente faz UMA coisa bem. Sem sobreposição de funções. |
| **Rastreabilidade** | Todo trabalho é documentado em issues com histórico completo. |
| **Qualidade** | Nenhum código passa sem review (QA) e validação (DevOps). |
| **Iterativo** | Ciclos curtos: planejar → fazer → revisar → aprovar → próximo ciclo. |

---

## Agentes e seus Papéis (12 agentes)

### 1. Agente Chatbot (Ponto de Entrada — Interface com VOCÊ)

**Função:** Sua interface de comunicação com o time. O "recepcionista".

**Responsabilidades:**
- Receber suas ideias, dúvidas e comandos em linguagem natural
- Esclarecer requisitos ambíguos antes de repassar ao Líder
- Responder perguntas sobre o projeto (status, histórico, decisões)
- Traduzir linguagem técnica em linguagem acessível
- Notificar sobre aprovações pendentes

**NÃO faz:** Não atende usuários finais do sistema (isso é do Suporte).

**Entradas:** Mensagens do usuário (você)
**Saídas:** Comandos estruturados para o Líder, respostas ao usuário

**Exemplo de interação:**
```
Você: "Quero um app de controle financeiro pessoal"
Chatbot: "Entendi! Para refinar, me diga:
  1. Web, mobile ou ambos?
  2. Funcionalidades essenciais na primeira versão?
  3. Tem alguma referência visual que goste?
  Vou repassar ao time assim que tivermos clareza."
```

---

### 2. Agente Líder (Coordenador/Scrum Master)

**Função:** Orquestra todo o time. Delega, prioriza e garante que o fluxo funcione.

**Responsabilidades:**
- Receber requisitos refinados e transformar em **issues** com critérios de aceite
- Definir prioridade e ordem de execução das issues
- Estimar esforço de desenvolvimento (story points/horas)
- Distribuir tarefas para os agentes corretos
- Monitorar progresso e identificar bloqueios
- Organizar sprints/ciclos de desenvolvimento
- Reportar status ao usuário via Chatbot

**NÃO faz:** Não codifica, não projeta arquitetura, não modela banco.

**Entradas:** Requisitos do PO, feedback do QA/DevOps, comandos do usuário
**Saídas:** Issues criadas, tarefas atribuídas, relatórios de progresso

**Regras de negócio:**
- Toda issue deve ter: título, descrição, critérios de aceite, prioridade, estimativa
- Nenhuma issue vai para Dev sem aprovação do usuário
- Se QA reprova, reabre a issue e envia de volta ao Dev com detalhes
- Mantém um backlog organizado e priorizado

---

### 3. Agente Product Owner (Estratégia de Produto)

**Função:** Refina ideias em requisitos claros e busca melhorias para o produto.

**Responsabilidades:**
- Transformar ideias vagas em **user stories** com critérios de aceite
- Pesquisar funcionalidades que agreguem valor ao produto
- Sugerir melhorias baseadas em boas práticas de mercado
- Definir MVP (Minimum Viable Product) vs funcionalidades futuras
- Priorizar o backlog junto com o Líder
- Manter o PRD (Product Requirements Document) atualizado

**NÃO faz:** Não escreve documentação de usuário (isso é do Technical Writer).
Não codifica, não projeta arquitetura.

**Entradas:** Ideia bruta do usuário (via Chatbot/Líder)
**Saídas:** User stories formatadas, PRD, sugestões de melhoria

**Exemplo de output:**
```markdown
## User Story
**Como** usuário do app financeiro
**Quero** categorizar minhas despesas automaticamente
**Para** entender onde estou gastando sem esforço manual

### Critérios de Aceite:
- [ ] Ao cadastrar despesa, sugere categoria baseada na descrição
- [ ] Permite criar categorias personalizadas
- [ ] Mostra gráfico de gastos por categoria no dashboard
```

---

### 4. Agente Arquiteto de Software (Design Técnico)

**Função:** Define a "planta da casa" antes de construir. Projeta a estrutura técnica.

**Responsabilidades:**
- Definir a **stack tecnológica** (linguagem, framework, banco, infra)
- Projetar a **arquitetura do sistema** (monolito, microsserviços, camadas)
- Definir **patterns** a serem seguidos (MVC, Clean Architecture, etc.)
- Criar **diagramas de componentes** e suas interações
- Definir **contratos de API** (endpoints, payloads, autenticação)
- Avaliar **trade-offs** técnicos e documentar decisões (ADRs)
- Definir estratégia de **escalabilidade** e **performance**

**NÃO faz:** Não codifica (isso é do Dev). Não modela banco (isso é do DBA).
Não configura infra (isso é do DevOps).

**Entradas:** User stories do PO, restrições técnicas, requisitos não-funcionais
**Saídas:** Documento de arquitetura, diagramas, ADRs, contratos de API

**Exemplo de output:**
```markdown
## Decisão Arquitetural - ADR-001

**Contexto:** App financeiro pessoal com 1 usuário inicialmente, potencial multiusuário.

**Decisão:** Monolito com separação em camadas (API REST + SPA).
- Backend: Node.js + Express
- Frontend: React
- Banco: PostgreSQL
- Autenticação: JWT

**Motivo:** Simplicidade para MVP. Pode evoluir para microsserviços se necessário.

**Consequências:** Menos complexidade operacional, deploy simples, refactoring futuro se escalar.
```

---

### 5. Agente DBA (Modelagem de Dados)

**Função:** Especialista em banco de dados. Projeta, otimiza e mantém a camada de dados.

**Responsabilidades:**
- Criar o **modelo de dados** (entidades, relacionamentos, cardinalidade)
- Definir **schemas, tabelas, índices** e constraints
- Escrever **migrations** para evolução do banco
- Otimizar **queries** complexas para performance
- Definir estratégia de **backup e recuperação**
- Avaliar **normalização vs desnormalização** conforme o caso
- Garantir **integridade referencial** e consistência dos dados

**NÃO faz:** Não codifica a aplicação (isso é do Dev). Não define a arquitetura
da aplicação (isso é do Arquiteto). Não configura servidor de banco (DevOps).

**Entradas:** Modelo de domínio do Arquiteto, user stories do PO
**Saídas:** Diagrama ER, scripts de criação, migrations, queries otimizadas

**Exemplo de output:**
```sql
-- Migration: criar tabela de transações
CREATE TABLE transacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(12,2) NOT NULL,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('receita', 'despesa')),
    categoria_id UUID REFERENCES categorias(id),
    data_transacao DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_transacoes_usuario ON transacoes(usuario_id);
CREATE INDEX idx_transacoes_data ON transacoes(data_transacao);
CREATE INDEX idx_transacoes_categoria ON transacoes(categoria_id);
```

---

### 6. Agente Desenvolvedor (Codificação)

**Função:** Escreve o código. Implementa o que foi definido nas issues.

**Responsabilidades:**
- Implementar funcionalidades conforme issues e critérios de aceite
- Escrever código limpo, documentado e com boas práticas
- Seguir a **arquitetura definida pelo Arquiteto**
- Usar o **schema definido pelo DBA** (não cria tabelas por conta)
- Desenvolver APIs, frontend, backend conforme a stack definida
- Escrever testes unitários para o código produzido
- Corrigir bugs reportados pelo QA ou DevOps

**NÃO faz:** Não decide arquitetura (Arquiteto decide). Não modela banco
(DBA modela). Não escreve documentação de usuário (Technical Writer faz).

**Entradas:** Issues com critérios de aceite, arquitetura definida, schema do DBA
**Saídas:** Código implementado, testes unitários

**Regras:**
- Segue padrões de código definidos no projeto (linting, formatação)
- Segue a arquitetura definida — se discorda, reporta ao Arquiteto
- Não implementa além do escopo da issue (sem gold plating)
- Se encontra impedimento técnico, reporta ao Líder antes de improvisar

---

### 7. Agente QA / Code Review (Qualidade)

**Função:** Revisa código e valida se a implementação atende os critérios.

**Responsabilidades:**
- Revisar código do Desenvolvedor (qualidade, legibilidade, segurança)
- Validar se os critérios de aceite da issue foram atendidos
- Executar testes e verificar se passam
- Verificar se a arquitetura definida foi respeitada
- Verificar se o schema do DBA foi usado corretamente
- Identificar bugs, vulnerabilidades ou problemas de performance
- Se reprovar: documentar exatamente o que está errado e devolver ao Dev
- Se aprovar: marcar issue como "pronta para deploy"

**NÃO faz:** Não corrige código (Dev corrige). Não testa em produção (DevOps faz).

**Entradas:** Código do Desenvolvedor + issue com critérios de aceite
**Saídas:** Aprovação ou reprovação com feedback detalhado

**Critérios de revisão:**
- [ ] Código atende todos os critérios de aceite?
- [ ] Segue a arquitetura definida?
- [ ] Usa o schema do DBA corretamente?
- [ ] Código está legível e bem documentado?
- [ ] Testes unitários existem e passam?
- [ ] Não introduz vulnerabilidades de segurança?
- [ ] Performance é aceitável?

---

### 8. Agente DevOps (Infraestrutura e Monitoramento)

**Função:** Cuida da saúde do sistema em execução. Detecta e reporta problemas.

**Responsabilidades:**
- Configurar ambiente de desenvolvimento/staging/produção
- Monitorar logs e detectar erros em tempo de execução
- Identificar problemas de performance, memória, conexão
- Abrir issues de bug quando encontra falhas no sistema rodando
- Configurar CI/CD (builds automáticos, deploy)
- Manter scripts de infraestrutura (Docker, configs)
- Garantir que o ambiente está funcional para o Dev trabalhar

**NÃO faz:** Não codifica features (Dev faz). Não define arquitetura (Arquiteto faz).
Não modela banco (DBA faz).

**Entradas:** Sistema em execução, logs, métricas
**Saídas:** Issues de bug, alertas, configs de infra, scripts de deploy

**Fluxo quando encontra erro:**
```
DevOps detecta erro → Abre issue de bug com log/reprodução → Líder prioriza
→ Dev corrige → QA valida → DevOps confirma fix em staging
```

---

### 9. Agente Designer UX/UI (Interface e Experiência)

**Função:** Melhora a experiência visual e de usabilidade do produto.

**Responsabilidades:**
- Sugerir layouts e fluxos de navegação
- Definir paleta de cores, tipografia e componentes visuais
- Avaliar acessibilidade (contraste, tamanho de fonte, navegação por teclado)
- Propor melhorias de fluidez e intuitividade
- Criar wireframes/mockups quando necessário
- Revisar o frontend implementado e sugerir ajustes visuais

**NÃO faz:** Não codifica frontend (Dev faz). Não escreve copy/textos do produto
(Technical Writer faz).

**Entradas:** User stories do PO, frontend implementado pelo Dev
**Saídas:** Wireframes, guia de estilo, issues de melhoria UX

**Princípios que segue:**
- Mobile-first
- Acessibilidade (WCAG 2.1 AA mínimo)
- Consistência visual
- Menos cliques = melhor
- Feedback visual para toda ação do usuário

---

### 10. Agente Auditor (Conformidade e Compliance)

**Função:** Garante que o sistema está em conformidade com normas e leis.

**Responsabilidades:**
- Verificar conformidade com LGPD (dados pessoais, consentimento, exclusão)
- Avaliar segurança (OWASP Top 10, criptografia, autenticação)
- Verificar acessibilidade (WCAG)
- Checar conformidade com normas do setor (ISO, regulações específicas)
- Emitir relatórios de conformidade
- Abrir issues de correção quando encontrar não-conformidades
- Validar termos de uso, políticas de privacidade

**NÃO faz:** Não corrige problemas (Dev corrige). Não implementa segurança (Dev + Arquiteto fazem).

**Entradas:** Sistema implementado, documentação, código
**Saídas:** Relatório de conformidade, issues de correção

**Checklist padrão:**
- [ ] LGPD: Coleta apenas dados necessários? Tem consentimento? Permite exclusão?
- [ ] Segurança: Senhas hasheadas? Inputs validados? SQL injection protegido?
- [ ] Acessibilidade: Contraste OK? Labels em formulários? Navegável por teclado?
- [ ] Dados sensíveis: Criptografados em trânsito e em repouso?

---

### 11. Agente Technical Writer (Documentação)

**Função:** Cria toda a documentação voltada para o usuário final e para manutenção do projeto.

**Responsabilidades:**
- Escrever **manual do usuário** (como usar cada funcionalidade)
- Criar **FAQ** (perguntas frequentes)
- Documentar **fluxos de uso** com passo-a-passo ilustrado
- Escrever **changelog** (o que mudou em cada versão)
- Criar **guias de onboarding** (primeiro uso do sistema)
- Manter **glossário** de termos do domínio
- Escrever **textos da interface** (labels, tooltips, mensagens de erro, empty states)
- Criar **API docs** voltados para integradores (se aplicável)

**NÃO faz:** Não define requisitos (PO faz). Não codifica (Dev faz).
Não cria wireframes (Designer faz).

**Entradas:** Sistema implementado, user stories do PO, decisões do Arquiteto
**Saídas:** Manual do usuário, FAQ, changelog, textos de interface, API docs

**Exemplo de output:**
```markdown
## Como cadastrar uma despesa

1. Na tela principal, toque no botão **"+ Nova Despesa"**
2. Preencha o valor e a descrição
3. O sistema sugere uma categoria automaticamente — aceite ou escolha outra
4. Toque em **"Salvar"**

> 💡 **Dica:** Despesas recorrentes (aluguel, streaming) podem ser
> cadastradas uma vez e repetidas automaticamente todo mês.

### Problemas comuns:
- **"Categoria não sugerida"** → Digite uma descrição mais detalhada
- **"Valor não aceito"** → Use ponto como separador decimal (ex: 45.90)
```

---

### 12. Agente Suporte (Interface com Usuário Final)

**Função:** Atende os usuários finais do sistema que foi construído. É o "SAC" do produto.

**Responsabilidades:**
- Responder dúvidas dos usuários finais sobre como usar o sistema
- Ajudar em problemas de **configuração** (guiar o usuário na solução)
- Identificar se o problema é **configuração** (resolve) ou **bug** (escala)
- Se for bug: abrir issue detalhada para o Líder avaliar e aprovar antes do desenvolvimento
- Coletar **feedback** dos usuários sobre o produto
- Reportar **padrões de reclamação** ao PO (se muitos reclamam do mesmo, vira melhoria)
- Consultar a documentação do Technical Writer para responder

**NÃO faz:** Não corrige bugs (Dev faz). Não decide se vai implementar
melhoria (PO decide). Não fala com VOCÊ — quem fala com você é o Chatbot.

**Entradas:** Mensagens de usuários finais, documentação do Technical Writer
**Saídas:** Respostas ao usuário, issues de bug (pré-aprovação), relatórios de feedback

**Fluxo de triagem:**
```
Usuário relata problema
         │
         ▼
É problema de configuração?
    SIM → Suporte guia na solução (usando docs do Tech Writer)
    NÃO → É bug?
            SIM → Suporte abre issue de bug → Líder avalia → ★ VOCÊ APROVA → Dev corrige
            NÃO → É sugestão de melhoria?
                    SIM → Suporte repassa ao PO para avaliar → ★ VOCÊ APROVA se quiser implementar
```

---

## Mapa de Responsabilidades (quem faz o quê)

| Atividade | Responsável | NÃO é responsável |
|-----------|-------------|-------------------|
| Definir o que construir | PO | Dev, DBA, Arquiteto |
| Projetar como construir | Arquiteto | Dev, PO, Líder |
| Modelar banco de dados | DBA | Dev, Arquiteto |
| Codificar | Dev | PO, DBA, QA |
| Revisar código | QA | Dev (não revisa o próprio) |
| Configurar infra | DevOps | Dev, Arquiteto |
| Desenhar interface | Designer UX/UI | Dev, Tech Writer |
| Escrever docs de usuário | Technical Writer | PO, Dev |
| Verificar conformidade | Auditor | Dev, QA |
| Atender usuário final | Suporte | Chatbot, Dev |
| Falar com você (dono) | Chatbot | Suporte |
| Coordenar o time | Líder | Todos os outros |

---

## Fluxo de Trabalho Completo

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CICLO DE DESENVOLVIMENTO                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. IDEAÇÃO                                                                  │
│     Você → Chatbot → "Quero um app de finanças"                             │
│                                                                              │
│  2. REFINAMENTO                                                              │
│     Chatbot → Líder → PO                                                    │
│     PO cria user stories e PRD                                              │
│     ★ APROVAÇÃO DO USUÁRIO                                                  │
│                                                                              │
│  3. PROJETO TÉCNICO                                                          │
│     Arquiteto define stack, patterns, componentes                           │
│     DBA modela o banco de dados                                             │
│     Designer sugere layouts/wireframes                                      │
│     ★ APROVAÇÃO DO USUÁRIO                                                  │
│                                                                              │
│  4. PLANEJAMENTO                                                             │
│     Líder cria issues com estimativas                                       │
│     Distribui para Dev (código), DBA (migrations), DevOps (infra)           │
│     ★ APROVAÇÃO DO USUÁRIO                                                  │
│                                                                              │
│  5. DESENVOLVIMENTO                                                          │
│     Dev implementa código (seguindo Arquiteto + DBA)                        │
│     DBA cria migrations e otimiza queries                                   │
│     DevOps configura ambiente                                               │
│                                                                              │
│  6. REVIEW E QUALIDADE                                                       │
│     QA revisa código e valida critérios                                     │
│     Se REPROVA → volta ao Dev (passo 5)                                     │
│     Se APROVA → continua                                                    │
│                                                                              │
│  7. VALIDAÇÃO                                                                │
│     DevOps verifica em staging                                              │
│     Auditor verifica conformidade                                           │
│     Designer valida UX/UI final                                             │
│     Se encontram problemas → abre issue → volta ao passo 5                 │
│                                                                              │
│  8. DOCUMENTAÇÃO                                                             │
│     Technical Writer cria/atualiza manual, FAQ, changelog                   │
│                                                                              │
│  9. ENTREGA                                                                  │
│     ★ APROVAÇÃO FINAL DO USUÁRIO                                            │
│     Deploy em produção                                                      │
│     Suporte pronto para atender usuários finais                             │
│     Próximo ciclo começa                                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

★ = Human-in-the-Loop (sua aprovação é obrigatória)
```

---

## Pontos de Aprovação (Human-in-the-Loop)

| Momento | O que você aprova | O que acontece se reprovar |
|---------|-------------------|---------------------------|
| Após refinamento | User stories e escopo do MVP | PO refina novamente |
| Após projeto técnico | Arquitetura, modelo de dados, layouts | Arquiteto/DBA/Designer revisam |
| Após planejamento | Issues, prioridades e estimativas | Líder reorganiza |
| Após desenvolvimento | Funcionalidade implementada (demo) | Dev ajusta |
| Antes de corrigir bugs do Suporte | Issue de bug aberta pelo Suporte | Descarta ou prioriza |
| Após review completo | Versão pronta para produção | Volta para correção |

---

## Documentação Gerada Automaticamente

Cada agente produz documentação como parte do seu trabalho:

| Agente | Documentos produzidos |
|--------|----------------------|
| PO | PRD, User Stories, Backlog priorizado |
| Arquiteto | Documento de arquitetura, ADRs, Diagramas, Contratos de API |
| DBA | Diagrama ER, Migrations, Scripts de índices, Dicionário de dados |
| Líder | Sprint Planning, Relatórios de progresso, Changelog técnico |
| Dev | Código documentado, Testes unitários |
| QA | Relatórios de review, Critérios de aceite validados |
| DevOps | Docs de infra, Scripts de deploy, Runbooks, Docker configs |
| Designer | Wireframes, Guia de estilo, Decisões de UX |
| Auditor | Relatório de conformidade, Checklist LGPD/Segurança |
| Technical Writer | Manual do usuário, FAQ, Changelog público, Guia de onboarding |
| Suporte | Relatórios de feedback, Issues de bug triadas |

---

## Stack Técnica Sugerida para o Sistema de Agentes

| Componente | Tecnologia | Por quê |
|------------|-----------|---------|
| Orquestração | **Flowise Agentflow** (Supervisor pattern) | Visual, configurável, local |
| LLM (texto) | **Ollama** (llama3.2) | Gratuito, local, privado |
| LLM (código) | **Ollama** (codellama ou deepseek-coder) | Especializado em código |
| Comunicação | **Issues em JSON/Markdown** | Estruturado, versionável |
| Armazenamento | **Vector Store** (docs do projeto) | RAG para contexto |
| Memória | **Buffer + Summary Memory** | Contexto de longo prazo |
| Código | **Git local** | Versionamento do output |
| Interface | **Flowise Chat** ou **API REST** | Seu ponto de entrada |

---

## Implementação por Fases

### Fase 1 — MVP (3 agentes) — Fluxo básico funciona
| Agente | Função no MVP |
|--------|---------------|
| Chatbot | Recebe suas ideias |
| Líder | Cria issues |
| Desenvolvedor | Codifica |

**Resultado:** Ideia → issues → código básico

---

### Fase 2 — Qualidade + Arquitetura (+ 4 agentes)
| Agente | O que adiciona |
|--------|----------------|
| QA | Review obrigatório antes de entregar |
| DevOps | Monitoramento e ambiente |
| Arquiteto | Decisões técnicas antes do Dev codificar |
| DBA | Modelagem de dados profissional |

**Resultado:** Código com qualidade, arquitetura pensada, banco bem modelado

---

### Fase 3 — Produto completo (+ 3 agentes)
| Agente | O que adiciona |
|--------|----------------|
| Product Owner | Refinamento profundo de requisitos |
| Designer UX/UI | Interface pensada para o usuário |
| Auditor | Conformidade com leis e normas |

**Resultado:** Produto completo com boa UX, seguro e em conformidade

---

### Fase 4 — Produção e manutenção (+ 2 agentes)
| Agente | O que adiciona |
|--------|----------------|
| Technical Writer | Documentação de usuário profissional |
| Suporte | Atendimento ao usuário final com triagem inteligente |

**Resultado:** Produto em produção com suporte e documentação

---

## Riscos e Mitigações

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| LLM alucina código errado | Alto | QA obrigatório + testes automatizados |
| Loop infinito entre agentes | Médio | Max iterations + timeout por ciclo |
| Perda de contexto em projetos longos | Alto | RAG com docs do projeto + Summary Memory |
| Agente foge do escopo | Médio | System prompts rígidos + validação do Líder |
| Qualidade baixa do Ollama local | Médio | Usar codellama para código + llama3.2 para texto |
| Sobreposição de funções | Médio | Definição clara do "NÃO faz" de cada agente |
| Muitos agentes = lento | Médio | Fases graduais + não ativar todos sempre |

---

## Próximos Passos

1. **Agora:** Aprender Flowise com os 15 workflows de estudo
2. **Depois:** Implementar Fase 1 (Chatbot + Líder + Dev) como Agentflow
3. **Evoluir:** Adicionar agentes da Fase 2 (QA, DevOps, Arquiteto, DBA)
4. **Completar:** Fase 3 (PO, Designer, Auditor) quando o básico estiver sólido
5. **Produção:** Fase 4 (Technical Writer, Suporte) quando tiver usuários reais
6. **Escalar:** Conectar a repositório Git real para output de código
