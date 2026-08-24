# Workflow 15 - Chatbot Full-Stack: API, Embed e Deploy

## 🎯 Objetivo

Pegar qualquer workflow que você construiu nos Workflows 01-14 e **colocar em produção**:
expor como API, embeddar em um site, configurar autenticação, e fazer deploy.

**Este não é um workflow para importar** — é um guia prático de como publicar
seu chatbot para o mundo real.

---

## 📐 Arquitetura Full-Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SEU SITE / APP                                 │
│                                                                       │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────────┐ │
│  │  Widget Embed   │  │  React/Next.js   │  │  WhatsApp/Telegram │ │
│  │  (bubble chat)  │  │  (custom UI)     │  │  (integração)      │ │
│  └────────┬────────┘  └────────┬─────────┘  └────────┬───────────┘ │
│           │                     │                      │             │
└───────────┼─────────────────────┼──────────────────────┼─────────────┘
            │                     │                      │
            ▼                     ▼                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     FLOWISE API (Backend)                             │
│                                                                       │
│  POST /api/v1/prediction/{chatflow-id}                               │
│  Headers: Authorization: Bearer {api-key}                            │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Chatflow/Agentflow (qualquer workflow 01-14)                 │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  Rodando em: Docker / VPS / Railway / Render                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Índice deste Guia

1. [Expor como API REST](#1-expor-como-api-rest)
2. [Embed Widget no Site](#2-embed-widget-no-site)
3. [Frontend Custom (React)](#3-frontend-custom-react)
4. [Autenticação com API Key](#4-autenticação-com-api-key)
5. [Deploy em Produção](#5-deploy-em-produção)
6. [Monitoramento e Logs](#6-monitoramento-e-logs)
7. [Integração com WhatsApp](#7-integração-com-whatsapp)

---

## 1. Expor como API REST

Todo chatflow salvo no Flowise automaticamente vira uma API. Basta pegar o ID.

### Encontrando o Chatflow ID

1. Abra o chatflow no Flowise
2. Olhe a URL do navegador: `http://localhost:3000/canvas/{CHATFLOW_ID}`
3. Ou clique em ⚙️ → "API Endpoint" para ver a URL completa

### Fazendo uma requisição

```bash
# Requisição simples
curl -X POST http://localhost:3000/api/v1/prediction/{chatflow-id} \
  -H "Content-Type: application/json" \
  -d '{"question": "Olá, como você pode me ajudar?"}'
```

### Resposta da API

```json
{
  "text": "Olá! Sou um assistente virtual e posso ajudar com...",
  "chatId": "abc123",
  "chatMessageId": "msg456",
  "sourceDocuments": []
}
```

### Com histórico de conversa (sessionId)

```bash
# Primeira mensagem
curl -X POST http://localhost:3000/api/v1/prediction/{chatflow-id} \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Meu nome é Philippe",
    "overrideConfig": {
      "sessionId": "user-123"
    }
  }'

# Segunda mensagem (MESMA sessão = lembra da conversa)
curl -X POST http://localhost:3000/api/v1/prediction/{chatflow-id} \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Qual é meu nome?",
    "overrideConfig": {
      "sessionId": "user-123"
    }
  }'
# → "Seu nome é Philippe"
```

### Streaming (respostas em tempo real)

```bash
curl -X POST http://localhost:3000/api/v1/prediction/{chatflow-id} \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Conte uma história",
    "streaming": true
  }'
```

---

## 2. Embed Widget no Site

O Flowise oferece um widget pronto (bubble chat) que você cola no HTML.

### Código para colar no seu site

```html
<!-- No final do <body> do seu HTML -->
<script type="module">
  import Chatbot from 'https://cdn.jsdelivr.net/npm/flowise-embed/dist/web.js';
  Chatbot.init({
    chatflowid: 'SEU-CHATFLOW-ID-AQUI',
    apiHost: 'http://localhost:3000',  // URL do seu Flowise
    theme: {
      button: {
        backgroundColor: '#3B81F6',
        right: 20,
        bottom: 20,
        size: 48,
        iconColor: 'white',
      },
      chatWindow: {
        showTitle: true,
        title: 'Assistente Virtual',
        titleAvatarSrc: '',
        welcomeMessage: 'Olá! Como posso ajudar?',
        backgroundColor: '#ffffff',
        height: 700,
        width: 400,
        fontSize: 16,
        poweredByTextColor: '#999',
        botMessage: {
          backgroundColor: '#f7f8ff',
          textColor: '#303235',
        },
        userMessage: {
          backgroundColor: '#3B81F6',
          textColor: '#ffffff',
        },
        textInput: {
          placeholder: 'Digite sua mensagem...',
          backgroundColor: '#ffffff',
          textColor: '#303235',
          sendButtonColor: '#3B81F6',
        },
      },
    },
  });
</script>
```

### Embed Full Page (ocupa a tela inteira)

```html
<html>
<head><title>Chat</title></head>
<body>
<flowise-fullchatbot></flowise-fullchatbot>
<script type="module">
  import Chatbot from 'https://cdn.jsdelivr.net/npm/flowise-embed/dist/web.js';
  Chatbot.initFull({
    chatflowid: 'SEU-CHATFLOW-ID',
    apiHost: 'http://localhost:3000',
  });
</script>
</body>
</html>
```

### Personalização do Widget

| Propriedade | O que faz | Exemplo |
|-------------|-----------|---------|
| `backgroundColor` | Cor do botão | `'#3B81F6'` (azul) |
| `welcomeMessage` | Mensagem inicial | `'Olá! Pergunte-me algo'` |
| `title` | Título da janela | `'Suporte XYZ'` |
| `height` / `width` | Tamanho da janela | `700` / `400` |
| `placeholder` | Texto no input | `'Digite aqui...'` |

---

## 3. Frontend Custom (React)

Para controle total da UI, use a API diretamente:

### React Component Básico

```jsx
import { useState, useRef } from 'react';

const CHATFLOW_ID = 'seu-chatflow-id';
const API_HOST = 'http://localhost:3000';

function Chatbot() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const sessionId = useRef(`session-${Date.now()}`);

  const sendMessage = async () => {
    if (!input.trim()) return;
    
    const userMsg = { role: 'user', content: input };
    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setLoading(true);

    try {
      const response = await fetch(
        `${API_HOST}/api/v1/prediction/${CHATFLOW_ID}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            question: input,
            overrideConfig: { sessionId: sessionId.current }
          }),
        }
      );
      
      const data = await response.json();
      const botMsg = { role: 'bot', content: data.text };
      setMessages(prev => [...prev, botMsg]);
    } catch (error) {
      console.error('Erro:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="chatbot-container">
      <div className="messages">
        {messages.map((msg, i) => (
          <div key={i} className={`message ${msg.role}`}>
            {msg.content}
          </div>
        ))}
        {loading && <div className="message bot">Digitando...</div>}
      </div>
      <div className="input-area">
        <input
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyPress={e => e.key === 'Enter' && sendMessage()}
          placeholder="Digite sua mensagem..."
        />
        <button onClick={sendMessage} disabled={loading}>
          Enviar
        </button>
      </div>
    </div>
  );
}

export default Chatbot;
```

### Python (Backend-to-Backend)

```python
import requests

CHATFLOW_ID = "seu-chatflow-id"
API_HOST = "http://localhost:3000"

def chat(question: str, session_id: str = "default") -> str:
    response = requests.post(
        f"{API_HOST}/api/v1/prediction/{CHATFLOW_ID}",
        json={
            "question": question,
            "overrideConfig": {"sessionId": session_id}
        },
        headers={"Content-Type": "application/json"}
    )
    return response.json()["text"]

# Uso
resposta = chat("Qual a política de férias?", session_id="user-philippe")
print(resposta)
```

---

## 4. Autenticação com API Key

### Ativando API Key no Flowise

1. No chatflow, clique em ⚙️ (configurações)
2. Ative "API Key" protection
3. Crie uma API Key em Settings → API Keys → Create
4. Copie a key gerada

### Usando a API Key nas requisições

```bash
curl -X POST http://localhost:3000/api/v1/prediction/{chatflow-id} \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-XXXXX-sua-api-key" \
  -d '{"question": "Olá"}'
```

### Rate Limiting (proteção contra abuso)

Configure no Flowise (Settings):
- **Requests per minute:** 60 (padrão)
- **Requests per day:** 1000
- **Max message length:** 4000 caracteres

---

## 5. Deploy em Produção

### Opção A: Railway (mais fácil, $5/mês)

```bash
# 1. Crie conta em railway.app
# 2. New Project → Deploy from GitHub
# 3. Use a imagem Docker oficial:
#    Image: flowiseai/flowise
#    Port: 3000
# 4. Adicione variáveis de ambiente:
#    FLOWISE_USERNAME=admin
#    FLOWISE_PASSWORD=sua-senha-forte
#    DATABASE_PATH=/data
#    APIKEY_PATH=/data
```

### Opção B: Docker na VPS (mais controle)

```yaml
# docker-compose.yml
version: '3.1'
services:
  flowise:
    image: flowiseai/flowise
    restart: always
    ports:
      - "3000:3000"
    environment:
      - FLOWISE_USERNAME=admin
      - FLOWISE_PASSWORD=${FLOWISE_PASSWORD}
      - DATABASE_PATH=/root/.flowise
      - APIKEY_PATH=/root/.flowise
      - LOG_LEVEL=info
      - EXECUTION_MODE=main
    volumes:
      - flowise_data:/root/.flowise
    
volumes:
  flowise_data:
```

```bash
# Deploy
docker-compose up -d

# Ver logs
docker-compose logs -f flowise
```

### Opção C: Render (free tier disponível)

1. Crie conta em render.com
2. New → Web Service
3. Docker image: `flowiseai/flowise`
4. Port: 3000
5. Adicione env vars (FLOWISE_USERNAME, FLOWISE_PASSWORD)

### Opção D: Localhost + ngrok (testes rápidos)

```bash
# Instalar ngrok: https://ngrok.com
ngrok http 3000

# Expõe seu localhost na internet
# URL gerada: https://abc123.ngrok.io
# Use esta URL no embed widget para testes
```

---

## 6. Monitoramento e Logs

### Logs do Flowise

```bash
# Docker
docker logs -f flowise --tail 100

# Local
# Os logs aparecem no terminal onde flowise está rodando
```

### Métricas importantes

| Métrica | Como monitorar | Valor ideal |
|---------|---------------|-------------|
| Tempo de resposta | Logs do Flowise | < 5 segundos |
| Erros 500 | Logs de erro | 0 (zero!) |
| Uso de tokens | Dashboard OpenAI | Dentro do orçamento |
| Uptime | UptimeRobot (gratuito) | > 99.9% |
| Conversas/dia | Banco do Flowise | Depende do uso |

### Analytics do Flowise (built-in)

No Flowise, vá em **Chatflows → seu flow → Analytics** para ver:
- Total de mensagens
- Mensagens por dia
- Tempo médio de resposta
- Feedback dos usuários (thumbs up/down)

---

## 7. Integração com WhatsApp

### Via Evolution API (open-source)

```bash
# 1. Deploy da Evolution API
docker run -d --name evolution \
  -p 8080:8080 \
  -e AUTHENTICATION_API_KEY=sua-key \
  atendai/evolution-api

# 2. Conecte o WhatsApp (QR Code)
# 3. Configure o webhook para seu Flowise:
#    Webhook URL: http://seu-flowise:3000/api/v1/prediction/{id}
```

### Via Typebot (visual, low-code)

1. Crie conta em typebot.io (open-source)
2. Crie um fluxo com bloco "HTTP Request"
3. Configure para chamar sua API Flowise
4. Conecte Typebot ao WhatsApp via integração nativa

---

## 📋 Checklist de Deploy para Produção

### Segurança
- [ ] API Key ativada no chatflow
- [ ] FLOWISE_USERNAME e PASSWORD configurados
- [ ] HTTPS habilitado (certificado SSL)
- [ ] Rate limiting configurado
- [ ] CORS configurado (apenas seu domínio)
- [ ] Moderação ativa (Workflow 09)

### Performance
- [ ] Modelo adequado (gpt-4o-mini para custo, gpt-4o para qualidade)
- [ ] Temperature ajustada para o caso de uso
- [ ] Vector store persistente (não In-Memory!)
- [ ] Timeout configurado para requests longos

### Resiliência
- [ ] Docker com `restart: always`
- [ ] Volume persistente para banco de dados
- [ ] Backup periódico dos dados
- [ ] Monitoring/alertas configurados
- [ ] Plano de fallback se OpenAI ficar fora

### UX
- [ ] Mensagem de boas-vindas configurada
- [ ] Mensagem de erro amigável (quando API falha)
- [ ] Streaming habilitado (respostas aparecem em tempo real)
- [ ] Feedback buttons (thumbs up/down)
- [ ] Limite de caracteres no input

---

## 📊 Custos Estimados

### Infraestrutura

| Serviço | Free tier | Plano pago | Nota |
|---------|-----------|------------|------|
| Railway | 500h/mês | $5/mês | Melhor custo-benefício |
| Render | 750h/mês (sleep) | $7/mês | Free dorme após 15min |
| VPS (Hetzner) | — | €4/mês | Mais controle |
| ngrok | Limitado | $8/mês | Só para testes |

### API (OpenAI)

| Modelo | Custo/1K tokens | ~1000 msgs/mês | Nota |
|--------|----------------|-----------------|------|
| gpt-4o-mini | $0.00015 input | ~$2-5/mês | Recomendado |
| gpt-4o | $0.005 input | ~$30-80/mês | Para qualidade máxima |
| gpt-3.5-turbo | $0.0005 input | ~$3-8/mês | Legacy |

### Total estimado para projeto pequeno
- **Flowise hosting:** $5/mês (Railway)
- **OpenAI (gpt-4o-mini):** $3-10/mês (depende do volume)
- **Domínio:** $10/ano
- **Total:** ~$10-20/mês para até 1000 conversas/mês

---

## 🔄 Variações para Praticar

### 1. Deploy local com Docker
```bash
docker run -d -p 3000:3000 flowiseai/flowise
```
Acesse localhost:3000 e importe seus workflows.

### 2. Embed em um site HTML simples
Crie um `index.html` com o código do widget e abra no navegador.

### 3. Bot no Telegram
Use a API do Flowise com a biblioteca `python-telegram-bot`:
```python
from telegram import Update
from telegram.ext import Application, MessageHandler, filters
import requests

def chat_with_flowise(text):
    response = requests.post(
        "http://localhost:3000/api/v1/prediction/SEU-ID",
        json={"question": text}
    )
    return response.json()["text"]

async def handle_message(update: Update, context):
    resposta = chat_with_flowise(update.message.text)
    await update.message.reply_text(resposta)

app = Application.builder().token("SEU-TOKEN-TELEGRAM").build()
app.add_handler(MessageHandler(filters.TEXT, handle_message))
app.run_polling()
```

---

## 📖 Conceitos Aprendidos

- ✅ Como **expor** qualquer chatflow como **API REST**
- ✅ Como usar o **Embed Widget** no site (bubble chat)
- ✅ Como criar um **frontend custom** (React, Python)
- ✅ Como configurar **autenticação** com API Keys
- ✅ Opções de **deploy** (Railway, Docker, Render, ngrok)
- ✅ **Monitoramento** e métricas em produção
- ✅ Integração com **WhatsApp** e **Telegram**
- ✅ **Custos** estimados para projetos reais
- ✅ Checklist de **segurança** para produção

---

## 🎓 Parabéns! Jornada Completa!

Você completou todos os **15 workflows** e agora domina:

| Nível | Workflows | O que aprendeu |
|-------|-----------|----------------|
| **Básico** | 01-05 | Chatbots, memória, RAG, agents, custom tools |
| **Intermediário** | 06-10 | Multi-fonte, structured output, moderação, multi-tools |
| **Avançado** | 11-15 | Sequential agents, routing, reranker, supervisor, deploy |

### Próximos passos sugeridos:
1. **Combine** workflows (ex: RAG + Moderação + Supervisor)
2. **Explore** Agentflow V2 (nova arquitetura do Flowise)
3. **Integre** com seus sistemas reais (ERPs, CRMs, bancos)
4. **Publique** um chatbot real para clientes/usuários
5. **Contribua** com a comunidade Flowise (Discord, GitHub)
