# Exemplos de Chamadas cURL - FeedbackHub

Este documento contém exemplos de cURL para testar todas as Azure Functions do projeto FeedbackHub.

## Configuração

Antes de executar os comandos, configure as variáveis de ambiente:

```bash
# URL base das Azure Functions (local)
export FUNCTION_URL="http://localhost:7071"

# URL base das Azure Functions (Azure - após deploy)
export FUNCTION_URL="https://feedbackhub-func.azurewebsites.net"

# Function Key (obtenha no portal Azure ou local.settings.json)
export FUNCTION_KEY="sua-function-key-aqui"
```

---

## 1. Receber Avaliação (HTTP POST)

### Endpoint
`POST /api/avaliacao`

### Descrição
Função serverless que recebe avaliações de alunos. Valida os dados, classifica a urgência, salva no banco de dados e, se for crítica (nota 0-3), envia para fila de notificação.

### Exemplo 1: Avaliação Crítica (nota 0-3)

```bash
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula muito confusa, não consegui entender o conteúdo. Professor explicou muito rápido.",
    "nota": 2
  }'
```

**Resposta esperada:**
```json
{
  "id": 1,
  "descricao": "Aula muito confusa, não consegui entender o conteúdo. Professor explicou muito rápido.",
  "nota": 2,
  "urgencia": "CRITICA",
  "dataEnvio": "2026-02-18T22:30:15",
  "mensagem": "Avaliação registrada com sucesso!"
}
```

### Exemplo 2: Avaliação Média (nota 4-6)

```bash
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula boa, mas poderia ter mais exemplos práticos.",
    "nota": 5
  }'
```

**Resposta esperada:**
```json
{
  "id": 2,
  "descricao": "Aula boa, mas poderia ter mais exemplos práticos.",
  "nota": 5,
  "urgencia": "MEDIA",
  "dataEnvio": "2026-02-18T22:31:20",
  "mensagem": "Avaliação registrada com sucesso!"
}
```

### Exemplo 3: Avaliação Positiva (nota 7-10)

```bash
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Excelente aula! Conteúdo muito bem explicado e com ótimos exemplos.",
    "nota": 9
  }'
```

**Resposta esperada:**
```json
{
  "id": 3,
  "descricao": "Excelente aula! Conteúdo muito bem explicado e com ótimos exemplos.",
  "nota": 9,
  "urgencia": "POSITIVA",
  "dataEnvio": "2026-02-18T22:32:45",
  "mensagem": "Avaliação registrada com sucesso!"
}
```

### Exemplo 4: Teste de Validação - Nota Inválida

```bash
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Teste de validação",
    "nota": 15
  }'
```

**Resposta esperada (400 Bad Request):**
```json
{
  "error": "Nota deve estar entre 0 e 10"
}
```

### Exemplo 5: Teste de Validação - Campo Obrigatório Ausente

```bash
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "nota": 8
  }'
```

**Resposta esperada (400 Bad Request):**
```json
{
  "error": "Campo 'descricao' é obrigatório"
}
```

### Exemplo 6: Teste com Caracteres Especiais

```bash
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula sobre Java & Spring Boot - conceitos de @Annotations e <generics>. Excelente! 👍",
    "nota": 10
  }'
```

---

## 2. Gerar Relatório Manual (HTTP GET/POST)

### Endpoint
`GET /api/relatorio/manual` ou `POST /api/relatorio/manual`

### Descrição
Função serverless que gera relatório semanal sob demanda. Busca avaliações da última semana, calcula estatísticas (média, total, por urgência, por dia) e retorna JSON com os dados.

### Exemplo 1: GET Request

```bash
curl -X GET "${FUNCTION_URL}/api/relatorio/manual?code=${FUNCTION_KEY}" \
  -H "Accept: application/json"
```

### Exemplo 2: POST Request

```bash
curl -X POST "${FUNCTION_URL}/api/relatorio/manual?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json"
```

**Resposta esperada:**
```json
{
  "titulo": "Relatório Semanal de Avaliações - FeedbackHub",
  "dataInicio": "2026-02-10T00:00:00",
  "dataFim": "2026-02-16T23:59:59",
  "totalAvaliacoes": 45,
  "mediaNotas": 7.2,
  "quantidadePorDia": {
    "2026-02-10": 8,
    "2026-02-11": 12,
    "2026-02-12": 6,
    "2026-02-13": 9,
    "2026-02-14": 4,
    "2026-02-15": 3,
    "2026-02-16": 3
  },
  "quantidadePorUrgencia": {
    "CRITICA": 5,
    "MEDIA": 15,
    "POSITIVA": 25
  },
  "avaliacoesCriticas": 5,
  "avaliacoesMedias": 15,
  "avaliacoesPositivas": 25
}
```

### Exemplo 3: Salvar Relatório em Arquivo

```bash
curl -X GET "${FUNCTION_URL}/api/relatorio/manual?code=${FUNCTION_KEY}" \
  -H "Accept: application/json" \
  -o relatorio-$(date +%Y%m%d).json
```

### Exemplo 4: Pretty Print com jq

```bash
curl -X GET "${FUNCTION_URL}/api/relatorio/manual?code=${FUNCTION_KEY}" \
  -H "Accept: application/json" | jq '.'
```

---

## 3. Funções com Timer Trigger (Não HTTP)

### 3.1. Gerar Relatório Semanal (Timer)

**Endpoint:** Não aplicável - executado automaticamente  
**Schedule:** Toda segunda-feira às 9h UTC (6h Brasília)  
**CRON:** `0 0 9 * * MON`

Esta função **não pode ser chamada via cURL** pois é acionada automaticamente pelo timer. O relatório é gerado e enviado por e-mail aos gestores.

**Para testar localmente:**
- Use a função manual: `GET /api/relatorio/manual`
- Ou ajuste o CRON para teste: `0 */1 * * * *` (a cada minuto)

### 3.2. Notificar Urgência (Queue Trigger)

**Endpoint:** Não aplicável - acionado por fila  
**Queue:** `feedback-urgencia-queue`  
**Connection:** `AZURE_STORAGE_CONNECTION_STRING`

Esta função **não pode ser chamada via cURL** pois é acionada automaticamente quando uma mensagem é adicionada à fila Azure Storage Queue.

**Como é acionada:**
1. Avaliação crítica (nota 0-3) é recebida via POST /api/avaliacao
2. Sistema envia mensagem para a fila automaticamente
3. Azure Functions detecta nova mensagem e executa a função
4. E-mail de notificação é enviado para administradores

---

## Testes Completos

### Script de Teste Completo (Bash)

Crie um arquivo `test-functions.sh`:

```bash
#!/bin/bash

# Configurações
FUNCTION_URL="http://localhost:7071"
FUNCTION_KEY="sua-function-key-aqui"

echo "=== Testando Azure Functions - FeedbackHub ==="
echo ""

# Teste 1: Avaliação Crítica
echo "1. Enviando avaliação CRÍTICA (nota 2)..."
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Aula muito confusa", "nota": 2}' \
  -w "\nStatus: %{http_code}\n\n"

sleep 2

# Teste 2: Avaliação Média
echo "2. Enviando avaliação MÉDIA (nota 6)..."
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Aula razoável", "nota": 6}' \
  -w "\nStatus: %{http_code}\n\n"

sleep 2

# Teste 3: Avaliação Positiva
echo "3. Enviando avaliação POSITIVA (nota 9)..."
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Excelente aula!", "nota": 9}' \
  -w "\nStatus: %{http_code}\n\n"

sleep 2

# Teste 4: Gerar Relatório
echo "4. Gerando relatório manual..."
curl -X GET "${FUNCTION_URL}/api/relatorio/manual?code=${FUNCTION_KEY}" \
  -H "Accept: application/json" \
  -w "\nStatus: %{http_code}\n\n" | jq '.'

echo ""
echo "=== Testes concluídos ==="
```

Execute:
```bash
chmod +x test-functions.sh
./test-functions.sh
```

---

## Testes com PowerShell (Windows)

```powershell
# Configurações
$FUNCTION_URL = "http://localhost:7071"
$FUNCTION_KEY = "sua-function-key-aqui"

# Teste 1: Avaliação Crítica
Write-Host "1. Enviando avaliação CRÍTICA..."
Invoke-RestMethod -Uri "$FUNCTION_URL/api/avaliacao?code=$FUNCTION_KEY" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"descricao": "Aula muito confusa", "nota": 2}'

# Teste 2: Gerar Relatório
Write-Host "2. Gerando relatório..."
Invoke-RestMethod -Uri "$FUNCTION_URL/api/relatorio/manual?code=$FUNCTION_KEY" `
  -Method GET
```

---

## Testando em Ambiente Local

### 1. Iniciar Azure Functions localmente:

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package -DskipTests
mvn azure-functions:run
```

### 2. Em outro terminal, execute os testes:

```bash
# Sem autenticação em ambiente local
export FUNCTION_URL="http://localhost:7071"

# Teste rápido
curl -X POST "${FUNCTION_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste local", "nota": 8}'
```

---

## Testando em Ambiente Azure

### 1. Obter a Function Key:

```bash
# Via Azure CLI
az functionapp keys list \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --query "functionKeys.default" -o tsv
```

### 2. Configurar variáveis:

```bash
export FUNCTION_URL="https://feedbackhub-func.azurewebsites.net"
export FUNCTION_KEY="sua-function-key-do-azure"
```

### 3. Testar:

```bash
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste em produção", "nota": 10}'
```

---

## Monitoramento e Logs

### Ver logs das funções (Azure):

```bash
# Stream de logs em tempo real
az webapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

### Verificar execuções recentes:

```bash
# Via portal Azure
# https://portal.azure.com -> Function App -> Monitor -> Invocations
```

---

## Troubleshooting

### Erro 401 Unauthorized
- Verifique se a Function Key está correta
- Em ambiente local, pode não precisar de key

### Erro 404 Not Found
- Verifique se as funções estão rodando: `mvn azure-functions:run`
- Confirme a URL e rota

### Erro 500 Internal Server Error
- Verifique os logs da aplicação
- Confirme se o banco de dados está acessível
- Verifique as configurações no `local.settings.json`

### Timeout
- Aumente o timeout: `curl --max-time 60 ...`
- Verifique se o banco de dados está respondendo

---

## Referências

- **Documentação Azure Functions:** https://docs.microsoft.com/azure/azure-functions/
- **cURL Documentation:** https://curl.se/docs/
- **jq (JSON processor):** https://stedolan.github.io/jq/

---

**Última atualização:** 18/02/2026  
**Projeto:** FeedbackHub - Tech Challenge Fase 4  
**Autor:** FIAP

