# Workflow 05 - Agente com Custom Tool (Ferramentas Personalizadas)

## 🎯 Objetivo

Criar suas **próprias ferramentas** para o agente usar. Neste exemplo, vamos criar
uma tool que **consulta CEPs** usando a API gratuita ViaCEP. Isso demonstra como
conectar qualquer API externa ao seu agente.

**Por que isso é poderoso:** Com Custom Tools você pode fazer o agente interagir com
qualquer sistema: banco de dados, APIs internas, ERPs, CRMs, etc.

---

## 📐 Arquitetura do Fluxo

```
┌───────────────────┐
│   Custom Tool     │──────┐
│  "consultar_cep"  │      │
│                   │      │     ┌──────────────────────────┐
│  Chama API do     │      ├────▶│  OpenAI Function Agent   │
│  ViaCEP           │      │     │                          │
└───────────────────┘      │     │  Decide quando usar      │
                           │     │  cada ferramenta          │
┌───────────────────┐      │     │                          │
│   Calculator      │──────┘     └──────────────────────────┘
│  (Cálculos)       │                     ▲        ▲
└───────────────────┘                     │        │
                                          │        │
┌───────────────────┐                     │        │
│    ChatOpenAI     │─────────────────────┘        │
│   (Cérebro)       │                              │
└───────────────────┘                              │
                                                   │
┌───────────────────┐                              │
│  Buffer Memory    │──────────────────────────────┘
│  (Histórico)      │
└───────────────────┘
```

---

## 🛠️ Criando a Custom Tool no Flowise (PASSO PRINCIPAL)

### ⚠️ IMPORTANTE: Crie a Tool ANTES de importar o workflow

A Custom Tool é criada **separadamente** no Flowise, e depois referenciada no flow.

### Passo a Passo para Criar a Tool

1. No Flowise, vá no menu lateral → **Tools**
2. Clique em **"+ Add New"** (canto superior direito)
3. Preencha os campos:

#### Nome da Tool
```
consultar_cep
```

#### Descrição da Tool
```
Consulta informações de endereço a partir de um CEP brasileiro. 
Retorna logradouro, bairro, cidade e estado. 
Use esta ferramenta quando o usuário fornecer um CEP ou pedir informações de endereço por CEP.
```

#### Input Schema (JSON Schema)
```json
{
  "type": "object",
  "properties": {
    "cep": {
      "type": "string",
      "description": "O CEP a ser consultado. Pode conter ou não o hífen. Exemplo: 01001000 ou 01001-000"
    }
  },
  "required": ["cep"]
}
```

#### JavaScript Function (O código da tool)
```javascript
const fetch = require('node-fetch');

// Remove caracteres não numéricos do CEP
const cepLimpo = $cep.replace(/\D/g, '');

// Valida se o CEP tem 8 dígitos
if (cepLimpo.length !== 8) {
    return JSON.stringify({
        erro: true,
        mensagem: "CEP inválido. O CEP deve conter exatamente 8 dígitos."
    });
}

try {
    // Chama a API gratuita ViaCEP
    const response = await fetch(`https://viacep.com.br/ws/${cepLimpo}/json/`);
    const data = await response.json();
    
    // Verifica se o CEP existe
    if (data.erro) {
        return JSON.stringify({
            erro: true,
            mensagem: `CEP ${cepLimpo} não encontrado. Verifique se o CEP está correto.`
        });
    }
    
    // Retorna os dados formatados
    return JSON.stringify({
        cep: data.cep,
        logradouro: data.logradouro || "Não informado",
        complemento: data.complemento || "Não informado",
        bairro: data.bairro || "Não informado",
        cidade: data.localidade,
        estado: data.uf,
        ibge: data.ibge,
        ddd: data.ddd
    });
} catch (error) {
    return JSON.stringify({
        erro: true,
        mensagem: "Erro ao consultar o CEP. Verifique sua conexão com a internet."
    });
}
```

4. Clique em **Save** (salvar a tool)

---

## ⚙️ Configurando o Workflow

### Após criar a Custom Tool:

1. **Importe** o arquivo `agente-custom-tool.json` no Flowise
2. **Configure a API Key** no node ChatOpenAI
3. **Selecione a Custom Tool:**
   - Clique no node "Custom Tool"
   - No dropdown "Select Tool", escolha "consultar_cep"
4. **Salve** o flow
5. **Abra o chat** e teste!

---

## 🧪 Testes Sugeridos

### Testando a Custom Tool (CEP)

| Sua mensagem | Resposta esperada |
|-------------|-------------------|
| "Qual o endereço do CEP 01001-000?" | Praça da Sé, São Paulo - SP |
| "Busque o CEP 20040-020" | Av. Rio Branco, Rio de Janeiro - RJ |
| "CEP 30130-000" | Praça Sete, Belo Horizonte - MG |
| "CEP 12345678" | "CEP não encontrado" |
| "CEP 123" | "CEP inválido, deve ter 8 dígitos" |

### Testando combinação de Tools

| Sua mensagem | Tools usadas |
|-------------|-------------|
| "Busque o CEP 01001-000 e calcule 15% de taxa de entrega sobre R$ 200" | consultar_cep + calculator |
| "Se o frete para o CEP 20040-020 é R$ 35, quanto fica 3 entregas?" | consultar_cep + calculator |

---

## 📝 Anatomia de uma Custom Tool

```
┌─────────────────────────────────────────────────────────┐
│                    CUSTOM TOOL                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  NOME: consultar_cep                                     │
│  ─────────────────                                       │
│  → Identificador único da tool                           │
│  → O agente usa esse nome para "chamar" a tool           │
│                                                          │
│  DESCRIÇÃO: "Consulta endereço a partir de CEP..."       │
│  ──────────────────────────────────────────────          │
│  → MUITO IMPORTANTE! O modelo lê esta descrição          │
│    para decidir QUANDO usar a tool                       │
│  → Seja claro e específico                               │
│                                                          │
│  INPUT SCHEMA: { "cep": "string" }                       │
│  ───────────────────────────────                         │
│  → Define quais parâmetros a tool aceita                 │
│  → O modelo extrai esses valores da mensagem do user     │
│  → Formato: JSON Schema                                  │
│                                                          │
│  FUNCTION: async (inputs) => { ... }                     │
│  ──────────────────────────────────                      │
│  → Código JavaScript que executa a ação                  │
│  → Recebe os inputs como variáveis ($cep, $nome, etc.)   │
│  → DEVE retornar uma string (JSON.stringify)             │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔑 Regras para Criar Boas Custom Tools

### 1. Descrição Clara
```
❌ RUIM: "Busca CEP"
✅ BOM: "Consulta informações de endereço (rua, bairro, cidade, estado) 
         a partir de um CEP brasileiro de 8 dígitos"
```
*O modelo usa a descrição para decidir quando chamar a tool!*

### 2. Input Schema Detalhado
```json
// ❌ RUIM - sem descrição
{ "type": "object", "properties": { "cep": { "type": "string" } } }

// ✅ BOM - com descrição clara
{
  "type": "object",
  "properties": {
    "cep": {
      "type": "string",
      "description": "CEP brasileiro com 8 dígitos. Exemplo: 01001000"
    }
  },
  "required": ["cep"]
}
```

### 3. Retorno Sempre em String
```javascript
// ❌ RUIM - retorna objeto
return { cidade: "São Paulo" };

// ✅ BOM - retorna JSON como string
return JSON.stringify({ cidade: "São Paulo" });
```

### 4. Tratamento de Erros
```javascript
// ✅ Sempre trate erros para o agente saber o que aconteceu
try {
    // ... código ...
} catch (error) {
    return JSON.stringify({ erro: true, mensagem: "Descrição do erro" });
}
```

---

## 🔄 Outros Exemplos de Custom Tools

### Exemplo 2: Consultar Preço de Criptomoeda

```javascript
// Nome: consultar_crypto
// Descrição: "Consulta o preço atual de uma criptomoeda em USD"
// Input Schema: { "moeda": { "type": "string", "description": "Nome da crypto. Ex: bitcoin, ethereum" } }

const fetch = require('node-fetch');
const url = `https://api.coingecko.com/api/v3/simple/price?ids=${$moeda}&vs_currencies=brl,usd`;

try {
    const response = await fetch(url);
    const data = await response.json();
    
    if (!data[$moeda]) {
        return JSON.stringify({ erro: true, mensagem: `Moeda '${$moeda}' não encontrada` });
    }
    
    return JSON.stringify({
        moeda: $moeda,
        preco_usd: data[$moeda].usd,
        preco_brl: data[$moeda].brl
    });
} catch (error) {
    return JSON.stringify({ erro: true, mensagem: "Erro ao consultar preço" });
}
```

### Exemplo 3: Verificar Status de Pedido (Simulado)

```javascript
// Nome: consultar_pedido
// Descrição: "Consulta o status de um pedido pelo número"
// Input Schema: { "numero_pedido": { "type": "string", "description": "Número do pedido" } }

// Em produção, aqui você chamaria sua API real
// Este é um exemplo simulado para demonstração

const pedidos = {
    "12345": { status: "Enviado", previsao: "2 dias úteis", transportadora: "Correios" },
    "67890": { status: "Em separação", previsao: "4 dias úteis", transportadora: "Pending" },
    "11111": { status: "Entregue", previsao: "—", transportadora: "Jadlog" }
};

const pedido = pedidos[$numero_pedido];

if (!pedido) {
    return JSON.stringify({ 
        erro: true, 
        mensagem: `Pedido ${$numero_pedido} não encontrado. Verifique o número.` 
    });
}

return JSON.stringify({
    numero: $numero_pedido,
    status: pedido.status,
    previsao_entrega: pedido.previsao,
    transportadora: pedido.transportadora
});
```

### Exemplo 4: Gerar Resumo de Dados (POST para API)

```javascript
// Nome: enviar_feedback
// Descrição: "Registra feedback do usuário sobre o atendimento"
// Input Schema: { 
//   "nota": { "type": "number", "description": "Nota de 1 a 5" },
//   "comentario": { "type": "string", "description": "Comentário opcional" }
// }

const fetch = require('node-fetch');

if ($nota < 1 || $nota > 5) {
    return JSON.stringify({ erro: true, mensagem: "Nota deve ser entre 1 e 5" });
}

// Em produção, você faria um POST para sua API
// Aqui simulamos o registro
const feedback = {
    nota: $nota,
    comentario: $comentario || "Sem comentário",
    data: new Date().toISOString(),
    registrado: true
};

// Exemplo de como seria com uma API real:
// const response = await fetch('https://sua-api.com/feedback', {
//     method: 'POST',
//     headers: { 'Content-Type': 'application/json' },
//     body: JSON.stringify(feedback)
// });

return JSON.stringify({
    sucesso: true,
    mensagem: `Feedback registrado! Nota: ${$nota}/5. Obrigado!`
});
```

---

## 📊 Variáveis Disponíveis na Function

Dentro do código JavaScript da Custom Tool, você tem acesso a:

| Variável | Descrição |
|----------|-----------|
| `$nomeDoInput` | Valor do input definido no schema (ex: `$cep`, `$moeda`) |
| `$vars` | Variáveis globais definidas no Flowise |
| `$flow.sessionId` | ID da sessão atual |
| `$flow.chatId` | ID do chat atual |
| `$flow.chatflowId` | ID do chatflow |
| `$flow.input` | Mensagem original do usuário |

---

## 🏗️ Ideias de Custom Tools para Projetos Reais

| Caso de Uso | API/Serviço | O que faz |
|-------------|-------------|-----------|
| Suporte ao Cliente | Seu banco de dados | Consulta pedidos, status, dados do cliente |
| RH / People | API interna | Consulta dias de férias, holerite |
| E-commerce | API de frete | Calcula frete por CEP |
| Financeiro | API de câmbio | Converte moedas em tempo real |
| DevOps | API de monitoramento | Verifica status de servidores |
| Marketing | Google Analytics API | Busca métricas do site |
| Jurídico | API de tribunais | Consulta processos |

---

## 📖 Conceitos Aprendidos

- ✅ Como **criar Custom Tools** no Flowise (separado do chatflow)
- ✅ A importância da **descrição** da tool (o modelo lê para decidir)
- ✅ Como definir **Input Schema** com JSON Schema
- ✅ Como escrever a **função JavaScript** que executa a ação
- ✅ Como acessar **variáveis** dentro da function ($cep, $flow, etc.)
- ✅ A importância de **retornar strings** e **tratar erros**
- ✅ Como **conectar APIs externas** ao agente

---

## 🎓 Resumo do Aprendizado Completo

Parabéns! Com os 5 workflows, você aprendeu:

| # | Workflow | Conceito Principal |
|---|---------|-------------------|
| 01 | Chatbot Simples | Prompt + Modelo + Chain |
| 02 | Chatbot com Memória | Memory para conversas contínuas |
| 03 | RAG com Documentos | Busca vetorial + respostas baseadas em dados |
| 04 | Agente com Tools | IA que decide quais ferramentas usar |
| 05 | Custom Tool | Criar suas próprias ferramentas (APIs) |

### Próximos passos sugeridos:
1. Combine RAG + Agent (agente que busca em documentos E na web)
2. Explore **Sequential Agents** (múltiplos agentes que colaboram)
3. Integre com **WhatsApp** usando a API do Flowise
4. Publique seu chatbot usando o **Embed** widget do Flowise
