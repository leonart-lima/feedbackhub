# 🔧 Comandos Úteis - FeedbackHub Azure

Coleção de comandos úteis para gerenciar seu projeto na Azure.

---

## 🔐 Login e Configuração

```bash
# Login no Azure
az login

# Listar assinaturas
az account list --output table

# Selecionar assinatura
az account set --subscription "NOME_OU_ID"

# Mostrar assinatura atual
az account show

# Logout
az logout
```

---

## 📦 Resource Groups

```bash
# Listar resource groups
az group list --output table

# Criar resource group
az group create --name feedbackhub-rg --location eastus

# Verificar se existe
az group exists --name feedbackhub-rg

# Deletar resource group (CUIDADO!)
az group delete --name feedbackhub-rg --yes --no-wait

# Listar recursos em um group
az resource list --resource-group feedbackhub-rg --output table
```

---

## 🗄️ SQL Database

```bash
# Listar SQL Servers
az sql server list --resource-group feedbackhub-rg --output table

# Mostrar detalhes do server
az sql server show --name feedbackhub-server-XXXXXX --resource-group feedbackhub-rg

# Listar databases
az sql db list --resource-group feedbackhub-rg --server feedbackhub-server-XXXXXX --output table

# Mostrar detalhes do database
az sql db show \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub

# Pausar database (economizar)
az sql db pause \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub

# Resumir database
az sql db resume \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub

# Listar regras de firewall
az sql server firewall-rule list \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --output table

# Adicionar regra de firewall (seu IP)
az sql server firewall-rule create \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name MyHomeIP \
  --start-ip-address SEU_IP \
  --end-ip-address SEU_IP

# Obter connection string
az sql db show-connection-string \
  --client jdbc \
  --name feedbackhub \
  --server feedbackhub-server-XXXXXX
```

---

## 💾 Storage Account

```bash
# Listar storage accounts
az storage account list --resource-group feedbackhub-rg --output table

# Mostrar detalhes
az storage account show \
  --name feedbackhubstXXXXXXXX \
  --resource-group feedbackhub-rg

# Obter connection string
az storage account show-connection-string \
  --name feedbackhubstXXXXXXXX \
  --resource-group feedbackhub-rg

# Listar keys
az storage account keys list \
  --account-name feedbackhubstXXXXXXXX \
  --resource-group feedbackhub-rg

# Listar queues
az storage queue list \
  --account-name feedbackhubstXXXXXXXX \
  --connection-string "CONN_STRING"

# Ver mensagens na queue (peek)
az storage message peek \
  --queue-name feedback-urgencia-queue \
  --account-name feedbackhubstXXXXXXXX \
  --num-messages 5

# Purgar queue (deletar todas as mensagens)
az storage queue clear \
  --name feedback-urgencia-queue \
  --account-name feedbackhubstXXXXXXXX
```

---

## ⚡ Function App

```bash
# Listar function apps
az functionapp list --resource-group feedbackhub-rg --output table

# Mostrar detalhes
az functionapp show \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Listar funções
az functionapp function list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Listar function keys
az functionapp keys list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Obter function key específica
az functionapp function keys list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --function-name receberAvaliacao

# Listar app settings
az functionapp config appsettings list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --output table

# Adicionar/atualizar app setting
az functionapp config appsettings set \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --settings "NOVA_CONFIG=valor"

# Deletar app setting
az functionapp config appsettings delete \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --setting-names "NOME_CONFIG"

# Ver logs em tempo real
az functionapp log tail \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Iniciar function app
az functionapp start \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Parar function app
az functionapp stop \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Reiniciar function app
az functionapp restart \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Invocar função manualmente
az functionapp function invoke \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --function-name gerarRelatorioSemanal

# Obter publish profile (para CI/CD)
az functionapp deployment list-publishing-profiles \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --xml
```

---

## 📊 Application Insights

```bash
# Listar app insights
az monitor app-insights component list \
  --resource-group feedbackhub-rg \
  --output table

# Mostrar detalhes
az monitor app-insights component show \
  --app feedbackhub-insights \
  --resource-group feedbackhub-rg

# Obter instrumentation key
az monitor app-insights component show \
  --app feedbackhub-insights \
  --resource-group feedbackhub-rg \
  --query instrumentationKey \
  --output tsv

# Obter app ID
az monitor app-insights component show \
  --app feedbackhub-insights \
  --resource-group feedbackhub-rg \
  --query appId \
  --output tsv
```

---

## 🚀 Deploy

```bash
# Build local
mvn clean package

# Deploy via Maven plugin
mvn azure-functions:deploy

# Deploy com profile específico
mvn azure-functions:deploy -P production

# Deploy de função específica
mvn azure-functions:deploy -DfunctionAppName=feedbackhub-func-XXXXXX

# Rodar localmente (para testes)
mvn azure-functions:run
```

---

## 🧪 Testes via cURL

```bash
# Definir variáveis
FUNCTION_URL="https://feedbackhub-func-XXXXXX.azurewebsites.net"
FUNCTION_KEY="sua-function-key-aqui"

# Teste: Avaliação Positiva
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula excelente, muito didática!",
    "nota": 9
  }' | jq

# Teste: Avaliação Média
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula razoável, pode melhorar",
    "nota": 5
  }' | jq

# Teste: Avaliação Crítica (envia e-mail)
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Não entendi nada da aula",
    "nota": 2
  }' | jq

# Teste: Validação - Sem descrição
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "nota": 5
  }'

# Teste: Validação - Nota inválida
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Teste",
    "nota": 15
  }'

# Teste: Health check (se implementado)
curl -X GET "${FUNCTION_URL}/api/health"
```

---

## 📧 SendGrid

```bash
# Testar SendGrid API
SENDGRID_API_KEY="SG.xxxxx"
FROM_EMAIL="noreply@feedbackhub.com"
TO_EMAIL="seu@email.com"

curl -X POST "https://api.sendgrid.com/v3/mail/send" \
  -H "Authorization: Bearer ${SENDGRID_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"personalizations\": [{
      \"to\": [{\"email\": \"${TO_EMAIL}\"}],
      \"subject\": \"Teste SendGrid\"
    }],
    \"from\": {\"email\": \"${FROM_EMAIL}\"},
    \"content\": [{
      \"type\": \"text/plain\",
      \"value\": \"Este é um e-mail de teste.\"
    }]
  }"

# Ver estatísticas SendGrid
# Acesse: https://app.sendgrid.com/statistics
```

---

## 📊 Monitoramento

```bash
# Ver logs em tempo real
az functionapp log tail \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Ver últimas 100 linhas de log
az functionapp log download \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --log-file app-logs.zip

# Abrir portal Azure
az functionapp browse \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Ver métricas
az monitor metrics list \
  --resource /subscriptions/SUB_ID/resourceGroups/feedbackhub-rg/providers/Microsoft.Web/sites/feedbackhub-func-XXXXXX \
  --metric-names Requests \
  --start-time 2026-02-15T00:00:00Z \
  --end-time 2026-02-15T23:59:59Z
```

---

## 🔍 Debugging

```bash
# Ver configurações de runtime
az functionapp config show \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Ver status das funções
az functionapp function show \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --function-name receberAvaliacao

# Verificar conectividade com SQL
az sql db show \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub \
  --query "status"

# Testar conexão de rede
az network watcher test-connectivity \
  --resource-group feedbackhub-rg \
  --source-resource feedbackhub-func-XXXXXX \
  --dest-address feedbackhub-server-XXXXXX.database.windows.net \
  --dest-port 1433
```

---

## 💰 Custos

```bash
# Ver custo estimado do resource group
az consumption usage list \
  --resource-group feedbackhub-rg

# Ver budget (se configurado)
az consumption budget list \
  --resource-group feedbackhub-rg

# Criar alerta de custo
az consumption budget create \
  --resource-group feedbackhub-rg \
  --name feedbackhub-budget \
  --amount 100 \
  --time-grain Monthly \
  --start-date 2026-02-01 \
  --end-date 2026-12-31
```

---

## 🧹 Limpeza

```bash
# Parar function app (economizar)
az functionapp stop \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Pausar SQL database (economizar)
az sql db pause \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub

# Deletar recursos específicos
az functionapp delete \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

az sql db delete \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub \
  --yes

# Deletar TUDO (resource group completo) - CUIDADO!
az group delete --name feedbackhub-rg --yes --no-wait
```

---

## 🔄 Backup e Restore

```bash
# Exportar banco de dados
az sql db export \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub \
  --admin-user azureuser \
  --admin-password "FeedbackHub@2026!" \
  --storage-key-type StorageAccessKey \
  --storage-key "STORAGE_KEY" \
  --storage-uri "https://feedbackhubstXXXXXXXX.blob.core.windows.net/backups/feedbackhub.bacpac"

# Importar banco de dados
az sql db import \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub-restored \
  --admin-user azureuser \
  --admin-password "FeedbackHub@2026!" \
  --storage-key-type StorageAccessKey \
  --storage-key "STORAGE_KEY" \
  --storage-uri "https://feedbackhubstXXXXXXXX.blob.core.windows.net/backups/feedbackhub.bacpac"
```

---

## 📱 Atalhos Úteis

```bash
# Alias úteis (adicione ao ~/.zshrc)
alias azlogin='az login'
alias azlist='az resource list --resource-group feedbackhub-rg --output table'
alias azlogs='az functionapp log tail --name feedbackhub-func-XXXXXX --resource-group feedbackhub-rg'
alias azdeploy='mvn clean package azure-functions:deploy'
alias azstop='az functionapp stop --name feedbackhub-func-XXXXXX --resource-group feedbackhub-rg'
alias azstart='az functionapp start --name feedbackhub-func-XXXXXX --resource-group feedbackhub-rg'

# Recarregar shell
source ~/.zshrc
```

---

## 🔗 Links Diretos

```bash
# Portal Azure
open "https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/feedbackhub-rg"

# Function App
open "https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/feedbackhub-rg/providers/Microsoft.Web/sites/feedbackhub-func-XXXXXX"

# SQL Database
open "https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/feedbackhub-rg/providers/Microsoft.Sql/servers/feedbackhub-server-XXXXXX/databases/feedbackhub"

# Application Insights
open "https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/feedbackhub-rg/providers/Microsoft.Insights/components/feedbackhub-insights"
```

---

**💡 Dica**: Salve os comandos mais usados em um arquivo `my-commands.sh` para referência rápida!

