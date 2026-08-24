# ============================================================================
# FLOWISE + OLLAMA - Script de Inicialização
# ============================================================================
# Este script inicia todo o ambiente necessário para os workflows:
#   1. Ollama (servidor local de LLMs)
#   2. Podman Machine (runtime de containers)
#   3. Flowise (plataforma de chatbots)
#
# USO:
#   .\iniciar.ps1          → Inicia tudo
#   .\iniciar.ps1 -Parar   → Para tudo
#   .\iniciar.ps1 -Status  → Mostra status dos serviços
#
# PRIMEIRA VEZ? Execute: .\iniciar.ps1 -Instalar
# ============================================================================

param(
    [switch]$Parar,
    [switch]$Status,
    [switch]$Instalar
)

$ErrorActionPreference = "Continue"

# --- Cores para output ---
function Write-OK { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "[..] $msg" -ForegroundColor Cyan }
function Write-Erro { param($msg) Write-Host "[!!] $msg" -ForegroundColor Red }
function Write-Aviso { param($msg) Write-Host "[**] $msg" -ForegroundColor Yellow }

# --- Configurações ---
$FLOWISE_VERSION = "2.2.7"
$FLOWISE_PORT = 3000
$OLLAMA_PORT = 11434
$OLLAMA_MODEL = "llama3.2"
$OLLAMA_EMBED_MODEL = "nomic-embed-text"

# ============================================================================
# MODO: STATUS
# ============================================================================
if ($Status) {
    Write-Host ""
    Write-Host "========== STATUS DO AMBIENTE ==========" -ForegroundColor White
    Write-Host ""

    # Ollama
    $ollamaRunning = Get-Process ollama -ErrorAction SilentlyContinue
    if ($ollamaRunning) {
        Write-OK "Ollama: Rodando (PID $($ollamaRunning.Id))"
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:$OLLAMA_PORT/api/tags" -TimeoutSec 5
            $models = $response.models | ForEach-Object { $_.name }
            Write-Host "       Modelos: $($models -join ', ')" -ForegroundColor Gray
        } catch {
            Write-Aviso "Ollama: Processo existe mas API nao responde"
        }
    } else {
        Write-Erro "Ollama: Parado"
    }

    # Podman
    $podmanMachine = podman machine list --format "{{.Name}} {{.Running}}" 2>$null
    if ($podmanMachine -match "true") {
        Write-OK "Podman Machine: Rodando"
    } else {
        Write-Erro "Podman Machine: Parada"
    }

    # Flowise
    $flowiseContainer = podman ps --filter "name=flowise" --format "{{.Status}}" 2>$null
    if ($flowiseContainer) {
        Write-OK "Flowise: $flowiseContainer"
        Write-Host "       URL: http://localhost:$FLOWISE_PORT" -ForegroundColor Gray
    } else {
        Write-Erro "Flowise: Parado"
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor White
    exit 0
}

# ============================================================================
# MODO: PARAR
# ============================================================================
if ($Parar) {
    Write-Host ""
    Write-Info "Parando todos os servicos..."

    # Parar Flowise
    Write-Info "Parando Flowise..."
    podman stop flowise 2>$null | Out-Null
    Write-OK "Flowise parado"

    # Parar Ollama
    Write-Info "Parando Ollama..."
    Stop-Process -Name "ollama" -Force -ErrorAction SilentlyContinue
    Write-OK "Ollama parado"

    # Parar Podman (opcional - mantém rodando para não demorar na próxima vez)
    Write-Aviso "Podman Machine mantida rodando (para parar: podman machine stop)"

    Write-Host ""
    Write-OK "Ambiente parado com sucesso!"
    exit 0
}

# ============================================================================
# MODO: INSTALAR (primeira vez)
# ============================================================================
if ($Instalar) {
    Write-Host ""
    Write-Host "========== INSTALACAO INICIAL ==========" -ForegroundColor White
    Write-Host ""

    # Verificar Ollama
    if (Get-Command ollama -ErrorAction SilentlyContinue) {
        Write-OK "Ollama ja instalado"
    } else {
        Write-Erro "Ollama nao encontrado. Instale em: https://ollama.com/download"
        exit 1
    }

    # Verificar Podman
    if (Get-Command podman -ErrorAction SilentlyContinue) {
        Write-OK "Podman ja instalado"
    } else {
        Write-Erro "Podman nao encontrado. Instale em: https://podman.io/getting-started/installation"
        exit 1
    }

    # Iniciar Ollama para baixar modelos
    Write-Info "Iniciando Ollama..."
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 5

    # Baixar modelos
    Write-Info "Baixando modelo $OLLAMA_MODEL (pode demorar alguns minutos)..."
    ollama pull $OLLAMA_MODEL

    Write-Info "Baixando modelo de embeddings $OLLAMA_EMBED_MODEL..."
    ollama pull $OLLAMA_EMBED_MODEL

    Write-Host ""
    Write-OK "Instalacao concluida! Agora execute: .\iniciar.ps1"
    exit 0
}

# ============================================================================
# MODO: INICIAR (padrão)
# ============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FLOWISE + OLLAMA - Iniciando...     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- PASSO 1: Iniciar Ollama ---
$ollamaRunning = Get-Process ollama -ErrorAction SilentlyContinue
if ($ollamaRunning) {
    Write-OK "Ollama ja esta rodando"
} else {
    Write-Info "Iniciando Ollama..."
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 3

    # Verificar se iniciou
    $ollamaRunning = Get-Process ollama -ErrorAction SilentlyContinue
    if ($ollamaRunning) {
        Write-OK "Ollama iniciado com sucesso"
    } else {
        Write-Erro "Falha ao iniciar Ollama"
        exit 1
    }
}

# Verificar se o modelo está disponível
Start-Sleep -Seconds 2
try {
    $response = Invoke-RestMethod -Uri "http://localhost:$OLLAMA_PORT/api/tags" -TimeoutSec 10
    $hasModel = $response.models | Where-Object { $_.name -like "$OLLAMA_MODEL*" }
    if ($hasModel) {
        Write-OK "Modelo '$OLLAMA_MODEL' disponivel"
    } else {
        Write-Aviso "Modelo '$OLLAMA_MODEL' nao encontrado. Baixando..."
        ollama pull $OLLAMA_MODEL
    }

    $hasEmbed = $response.models | Where-Object { $_.name -like "$OLLAMA_EMBED_MODEL*" }
    if ($hasEmbed) {
        Write-OK "Modelo embeddings '$OLLAMA_EMBED_MODEL' disponivel"
    } else {
        Write-Aviso "Modelo '$OLLAMA_EMBED_MODEL' nao encontrado. Baixando..."
        ollama pull $OLLAMA_EMBED_MODEL
    }
} catch {
    Write-Aviso "Nao foi possivel verificar modelos (Ollama pode estar iniciando...)"
}

# --- PASSO 2: Iniciar Podman Machine ---
Write-Info "Verificando Podman Machine..."
$machineStatus = podman machine list --format "{{.Running}}" 2>$null
if ($machineStatus -match "true") {
    Write-OK "Podman Machine ja esta rodando"
} else {
    Write-Info "Iniciando Podman Machine (pode demorar 15-30s)..."
    podman machine start 2>$null | Out-Null
    Start-Sleep -Seconds 5

    $machineStatus = podman machine list --format "{{.Running}}" 2>$null
    if ($machineStatus -match "true") {
        Write-OK "Podman Machine iniciada"
    } else {
        Write-Erro "Falha ao iniciar Podman Machine. Tente: podman machine stop; podman machine start"
        exit 1
    }
}

# --- PASSO 3: Iniciar Flowise ---
$flowiseRunning = podman ps --filter "name=flowise" --format "{{.Names}}" 2>$null
if ($flowiseRunning -eq "flowise") {
    Write-OK "Flowise ja esta rodando"
} else {
    # Verificar se container existe mas está parado
    $flowiseExists = podman ps -a --filter "name=flowise" --format "{{.Names}}" 2>$null
    if ($flowiseExists -eq "flowise") {
        Write-Info "Reiniciando Flowise..."
        podman start flowise 2>$null | Out-Null
    } else {
        Write-Info "Criando e iniciando Flowise v$FLOWISE_VERSION..."
        podman run -d --name flowise -p ${FLOWISE_PORT}:3000 -v flowise_data:/root/.flowise docker.io/flowiseai/flowise:$FLOWISE_VERSION 2>$null | Out-Null
    }

    # Aguardar inicialização
    Write-Info "Aguardando Flowise iniciar..."
    $attempts = 0
    $maxAttempts = 30
    while ($attempts -lt $maxAttempts) {
        Start-Sleep -Seconds 2
        try {
            $null = Invoke-RestMethod -Uri "http://localhost:$FLOWISE_PORT" -TimeoutSec 3
            break
        } catch {
            $attempts++
        }
    }

    if ($attempts -lt $maxAttempts) {
        Write-OK "Flowise iniciado com sucesso!"
    } else {
        # Pode ter iniciado mas sem responder no /
        $flowiseCheck = podman ps --filter "name=flowise" --format "{{.Status}}" 2>$null
        if ($flowiseCheck) {
            Write-OK "Flowise container rodando (aguarde mais alguns segundos)"
        } else {
            Write-Erro "Flowise nao iniciou. Verifique: podman logs flowise"
            exit 1
        }
    }
}

# --- RESULTADO FINAL ---
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   AMBIENTE PRONTO!                    " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Flowise:  http://localhost:$FLOWISE_PORT" -ForegroundColor White
Write-Host "  Ollama:   http://localhost:$OLLAMA_PORT" -ForegroundColor White
Write-Host "  Modelo:   $OLLAMA_MODEL" -ForegroundColor White
Write-Host ""
Write-Host "  Para parar:   .\iniciar.ps1 -Parar" -ForegroundColor Gray
Write-Host "  Ver status:   .\iniciar.ps1 -Status" -ForegroundColor Gray
Write-Host ""
Write-Host "  No Flowise, use ChatOllama com:" -ForegroundColor Yellow
Write-Host "    Base URL: http://host.containers.internal:$OLLAMA_PORT" -ForegroundColor Yellow
Write-Host "    Model:    $OLLAMA_MODEL" -ForegroundColor Yellow
Write-Host ""

# Abrir navegador automaticamente
Start-Process "http://localhost:$FLOWISE_PORT"
