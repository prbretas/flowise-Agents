# Workflow 10 - Agente com Múltiplas Custom Tools (CEP + Clima + Crypto)

## 🎯 Objetivo

Criar um agente "canivete suíço" com **4 ferramentas** diferentes que trabalham
juntas. O agente decide qual(is) usar e pode combinar resultados de múltiplas
tools em uma única resposta.

**Evolução do Workflow 05:** Lá usamos 1 custom tool. Aqui usamos 3 + Calculator,
demonstrando como um agente gerencia múltiplas capacidades simultaneamente.

---

## 📐 Arquitetura do Fluxo

```
┌───────────────────┐
│  Custom Tool 1    │
│  consultar_cep    │──────┐
│  (API ViaCEP)     │      │
└───────────────────┘      │
                           │
┌───────────────────┐      │
│  Custom Tool 2    │      │     ┌───────────────────────────┐
│  consultar_clima  │──────┼────▶│   OpenAI Function Agent    │
│  (API wttr.in)    │      │     │                           │
└───────────────────┘      │     │  MultiBot: decide qual     │
                           │     │  tool usar (ou várias!)     │
┌───────────────────┐      │     │                           │
│  Custom Tool 3    │──────┤     │  Max Iterations: 8        │
│  consultar_crypto │      │     └───────────────────────────┘
│  (CoinGecko API)  │      │              ▲        ▲
└───────────────────┘      │              │        │
                           │              │        │
┌───────────────────┐      │     ┌────────┘    ┌───┘
│   Calculator      │──────┘     │             │
└───────────────────┘            │             │
                           ┌─────┴──────┐  ┌───┴────────┐
                           │  ChatOpenAI │  │Buffer Memory│
                           └────────────┘  └────────────┘
```

---

## 🛠️ As 3 Custom Tools para Criar

### ⚠️ CRIE TODAS AS TOOLS ANTES de importar o workflow!

No Flowise, vá em **Tools → Add New** e crie cada uma:

---

### Tool 1: consultar_cep

**Nome:** `consultar_cep`

**Descrição:**
```
Consulta informações de endereço a partir de um CEP brasileiro de 8 dígitos. Retorna logradouro, bairro, cidade e estado. Use quando o usuário fornecer um CEP ou pedir informações de endereço.
```

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "cep": {
      "type": "string",
      "description": "CEP brasileiro com 8 dígitos. Exemplo: 01001000 ou 01001-000"
    }
  },
  "required": ["cep"]
}
```

**JavaScript Function:**
```javascript
const fetch = require('node-fetch');
const cepLimpo = $cep.replace(/\D/g, '');

if (cepLimpo.length !== 8) {
    return JSON.stringify({ erro: true, mensagem: "CEP inválido. Deve ter 8 dígitos." });
}

try {
    const response = await fetch(`https://viacep.com.br/ws/${cepLimpo}/json/`);
    const data = await response.json();
    
    if (data.erro) {
        return JSON.stringify({ erro: true, mensagem: `CEP ${cepLimpo} não encontrado.` });
    }
    
    return JSON.stringify({
        cep: data.cep,
        logradouro: data.logradouro || "Não informado",
        bairro: data.bairro || "Não informado",
        cidade: data.localidade,
        estado: data.uf,
        ddd: data.ddd
    });
} catch (error) {
    return JSON.stringify({ erro: true, mensagem: "Erro ao consultar CEP." });
}
```

---

### Tool 2: consultar_clima

**Nome:** `consultar_clima`

**Descrição:**
```
Consulta a previsão do tempo atual de uma cidade. Retorna temperatura, condição climática, umidade e vento. Use quando o usuário perguntar sobre clima, tempo, temperatura ou previsão de uma cidade.
```

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "cidade": {
      "type": "string",
      "description": "Nome da cidade. Exemplo: São Paulo, Rio de Janeiro, Curitiba"
    }
  },
  "required": ["cidade"]
}
```

**JavaScript Function:**
```javascript
const fetch = require('node-fetch');

try {
    // API wttr.in - gratuita, sem API key necessária
    const cidadeEncoded = encodeURIComponent($cidade);
    const response = await fetch(`https://wttr.in/${cidadeEncoded}?format=j1`);
    const data = await response.json();
    
    const current = data.current_condition[0];
    const area = data.nearest_area[0];
    
    return JSON.stringify({
        cidade: area.areaName[0].value,
        pais: area.country[0].value,
        temperatura_celsius: current.temp_C + "°C",
        sensacao_termica: current.FeelsLikeC + "°C",
        condicao: current.weatherDesc[0].value,
        umidade: current.humidity + "%",
        vento_kmh: current.windspeedKmph + " km/h",
        direcao_vento: current.winddir16Point,
        visibilidade_km: current.visibility + " km",
        indice_uv: current.uvIndex
    });
} catch (error) {
    return JSON.stringify({ 
        erro: true, 
        mensagem: `Não foi possível obter o clima para "${$cidade}". Verifique o nome da cidade.` 
    });
}
```

---

### Tool 3: consultar_crypto

**Nome:** `consultar_crypto`

**Descrição:**
```
Consulta o preço atual de uma criptomoeda em Reais (BRL) e Dólares (USD). Use quando o usuário perguntar sobre preço de Bitcoin, Ethereum ou qualquer criptomoeda.
```

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "moeda": {
      "type": "string",
      "description": "ID da criptomoeda em inglês e minúsculo. Exemplos: bitcoin, ethereum, solana, cardano, dogecoin"
    }
  },
  "required": ["moeda"]
}
```

**JavaScript Function:**
```javascript
const fetch = require('node-fetch');

try {
    const moedaLower = $moeda.toLowerCase().trim();
    const url = `https://api.coingecko.com/api/v3/simple/price?ids=${moedaLower}&vs_currencies=brl,usd&include_24hr_change=true&include_market_cap=true`;
    
    const response = await fetch(url);
    const data = await response.json();
    
    if (!data[moedaLower]) {
        return JSON.stringify({ 
            erro: true, 
            mensagem: `Criptomoeda "${$moeda}" não encontrada. Tente: bitcoin, ethereum, solana, cardano, dogecoin` 
        });
    }
    
    const info = data[moedaLower];
    
    return JSON.stringify({
        moeda: moedaLower,
        preco_brl: `R$ ${info.brl.toLocaleString('pt-BR', {minimumFractionDigits: 2})}`,
        preco_usd: `US$ ${info.usd.toLocaleString('en-US', {minimumFractionDigits: 2})}`,
        variacao_24h_brl: `${info.brl_24h_change?.toFixed(2)}%`,
        market_cap_brl: `R$ ${(info.brl_market_cap / 1000000000).toFixed(2)} bilhões`
    });
} catch (error) {
    return JSON.stringify({ erro: true, mensagem: "Erro ao consultar preço. API pode estar indisponível." });
}
```

---

## ⚙️ Como Configurar

1. **Crie as 3 Custom Tools** no Flowise (Tools → Add New) seguindo as instruções acima
2. **Importe** `multiplas-custom-tools.json`
3. **API Key:** Configure no ChatOpenAI
4. **Selecione as Tools:**
   - Clique em cada node "Custom Tool" e selecione a tool correspondente:
     - Custom Tool 1 → `consultar_cep`
     - Custom Tool 2 → `consultar_clima`
     - Custom Tool 3 → `consultar_crypto`
5. **Salve** e teste!

---

## 🧪 Testes Sugeridos

### Testes individuais (uma tool por vez)

| Mensagem | Tool esperada | Resultado |
|----------|---------------|-----------|
| "Qual endereço do CEP 01001-000?" | consultar_cep | Praça da Sé, SP |
| "Como está o tempo em Curitiba?" | consultar_clima | Temp + condição + vento |
| "Qual o preço do Bitcoin hoje?" | consultar_crypto | Preço em BRL e USD |
| "Quanto é 3.500 * 12?" | calculator | 42.000 |

### Testes combinados (múltiplas tools)

| Mensagem | Tools esperadas | O que testa |
|----------|----------------|-------------|
| "Qual o clima e o CEP de São Paulo centro (01001-000)?" | clima + cep | 2 tools em sequência |
| "Preço do Ethereum e quanto dá se eu tiver 5 ETH?" | crypto + calculator | Busca + Cálculo |
| "Está chovendo no Rio? E qual o endereço do CEP 20040-020?" | clima + cep | 2 consultas diferentes |
| "Se Bitcoin custa X e eu tenho R$10.000, quantos BTC compro?" | crypto + calculator | Multi-step reasoning |

### Teste de decisão (sem tool)

| Mensagem | Tool esperada |
|----------|---------------|
| "O que é blockchain?" | Nenhuma — responde direto |
| "Quem inventou o Bitcoin?" | Nenhuma — conhecimento geral |
| "Obrigado pela ajuda!" | Nenhuma — cortesia |

---

## 📊 APIs Utilizadas (Todas Gratuitas!)

| Tool | API | Limite | Key necessária? |
|------|-----|--------|-----------------|
| consultar_cep | viacep.com.br | Sem limite prático | ❌ Não |
| consultar_clima | wttr.in | ~200 req/hora | ❌ Não |
| consultar_crypto | CoinGecko | ~30 req/min | ❌ Não (free tier) |
| calculator | Local | Ilimitado | ❌ Não |

> ✅ Nenhuma das tools precisa de API key adicional (apenas a OpenAI para o modelo)!

---

## 🔄 Variações para Praticar

### 1. Adicionar Tool de Tradução
```javascript
// Nome: traduzir_texto
// Usa a API MyMemory (gratuita)
const fetch = require('node-fetch');
const url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent($texto)}&langpair=${$idioma_origem}|${$idioma_destino}`;
const response = await fetch(url);
const data = await response.json();
return JSON.stringify({ traducao: data.responseData.translatedText });
```

### 2. Adicionar Tool de Notícias
```javascript
// Nome: buscar_noticias
// Usa NewsAPI (precisa key gratuita em newsapi.org)
```

### 3. Adicionar Tool de Cotação de Moedas (Câmbio)
```javascript
// Nome: consultar_cambio
const fetch = require('node-fetch');
const url = `https://economia.awesomeapi.com.br/last/${$moeda}-BRL`;
const response = await fetch(url);
const data = await response.json();
const key = Object.keys(data)[0];
return JSON.stringify({
    moeda: $moeda,
    cotacao_compra: `R$ ${parseFloat(data[key].bid).toFixed(2)}`,
    cotacao_venda: `R$ ${parseFloat(data[key].ask).toFixed(2)}`,
    variacao: data[key].pctChange + "%"
});
```

---

## 🧠 Dicas para Múltiplas Tools

### 1. Descrições claras e sem ambiguidade
Se duas tools são parecidas, a descrição deve deixar claro QUANDO usar cada uma:
```
❌ "Consulta informações financeiras" (ambíguo)
✅ "Consulta preço de CRIPTOMOEDAS como Bitcoin e Ethereum" (específico)
```

### 2. Max Iterations adequado
- 3 tools → maxIterations: 5-6
- 5+ tools → maxIterations: 8-10
- Evite > 15 (gasta muitos tokens sem benefício)

### 3. System Message como "manual do operador"
Liste TODAS as tools e QUANDO usar cada uma. Quanto mais claro, melhor as decisões.

---

## 📖 Conceitos Aprendidos

- ✅ Como orquestrar **múltiplas Custom Tools** em um único agente
- ✅ Como usar **APIs gratuitas** (ViaCEP, wttr.in, CoinGecko)
- ✅ O agente pode usar **várias tools** em uma única pergunta
- ✅ A importância de **descrições precisas** para decisões corretas
- ✅ Como ajustar **maxIterations** para agents complexos
- ✅ Padrão: criar tools → importar workflow → selecionar tools → testar

---

## ➡️ Próximo Passo

Parabéns! Você completou os **5 workflows intermediários**! 🎉

Agora vamos para os **workflows avançados**:

Vá para **Workflow 11 - Sequential Agents** para aprender a criar
pipelines de múltiplos agentes que trabalham em sequência!
