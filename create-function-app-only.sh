#!/bin/bash

################################################################################
# Script para Criar APENAS o Function App
# Use quando o script principal falhou no passo 7/9
# e você não quer duplicar os recursos 1-6
################################################################################

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║    Criar Function App com Recursos Existentes               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# DESCOBRIR RECURSOS EXISTENTES
# ============================================================================

echo -e "${BLUE}Descobrindo recursos já criados...${NC}"
echo ""

RESOURCE_GROUP="feedbackhub-rg"
LOCATION="brazilsouth"

# Obter Storage Account
STORAGE_ACCOUNT=$(az storage account list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv 2>/dev/null)
if [ -z "$STORAGE_ACCOUNT" ]; then
    echo -e "${RED}❌ Storage Account não encontrado no grupo $RESOURCE_GROUP${NC}"
    echo "Execute primeiro: ./azure-setup.sh"
    exit 1
fi
echo -e "${GREEN}✅ Storage Account: $STORAGE_ACCOUNT${NC}"

# Obter App Insights
APP_INSIGHTS=$(az monitor app-insights component list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv 2>/dev/null)
if [ -z "$APP_INSIGHTS" ]; then
    echo -e "${RED}❌ Application Insights não encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Application Insights: $APP_INSIGHTS${NC}"

# Obter Instrumentation Key
APPINSIGHTS_KEY=$(az monitor app-insights component show \
    --app $APP_INSIGHTS \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey \
    -o tsv)
echo -e "${GREEN}✅ Instrumentation Key obtida${NC}"

echo ""

# ============================================================================
# CRIAR FUNCTION APP
# ============================================================================

FUNCTION_APP_NAME="feedbackhub-func-$(date +%s | tail -c 6)"

echo -e "${BLUE}Criando Function App: $FUNCTION_APP_NAME${NC}"
echo ""

az functionapp create \
    --resource-group $RESOURCE_GROUP \
    --consumption-plan-location $LOCATION \
    --runtime java \
    --runtime-version 21.0 \
    --functions-version 4 \
    --name $FUNCTION_APP_NAME \
    --storage-account $STORAGE_ACCOUNT \
    --os-type Linux \
    --app-insights $APP_INSIGHTS \
    --app-insights-key $APPINSIGHTS_KEY \
    --output table

echo ""
echo -e "${GREEN}✅ Function App criado: $FUNCTION_APP_NAME${NC}"
echo ""

# ============================================================================
# CONFIGURAR VARIÁVEIS DE AMBIENTE
# ============================================================================

echo -e "${BLUE}Configurando variáveis de ambiente...${NC}"
echo ""

# Obter SQL Server
SQL_SERVER=$(az sql server list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv 2>/dev/null)
SQL_DB="feedbackhub"

# Obter Storage Connection String
STORAGE_CONNECTION=$(az storage account show-connection-string \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query connectionString \
    --output tsv)

# Obter Communication Service Connection String
COMM_SERVICE=$(az communication list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv 2>/dev/null)
if [ -n "$COMM_SERVICE" ]; then
    COMM_CONNECTION_STRING=$(az communication list-key \
        --name $COMM_SERVICE \
        --resource-group $RESOURCE_GROUP \
        --query "primaryConnectionString" \
        --output tsv)
fi

# SQL Connection String (você precisa substituir a senha!)
SQL_CONNECTION_STRING="jdbc:sqlserver://${SQL_SERVER}.database.windows.net:1433;database=${SQL_DB};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"

# Configurar App Settings
az functionapp config appsettings set \
    --name $FUNCTION_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "DB_URL=$SQL_CONNECTION_STRING" \
        "DB_USERNAME=azureuser" \
        "DB_PASSWORD=FeedbackHub@2026!" \
        "AZURE_STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION" \
        "AZURE_COMMUNICATION_CONNECTION_STRING=$COMM_CONNECTION_STRING" \
        "AZURE_COMMUNICATION_FROM_EMAIL=DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net" \
        "ADMIN_EMAILS=admin@example.com" \
        "REPORT_EMAILS=reports@example.com" \
        "WEBSITE_TIME_ZONE=E. South America Standard Time" \
    --output table

echo ""
echo -e "${GREEN}✅ Variáveis configuradas${NC}"
echo ""

# ============================================================================
# RESUMO
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ FUNCTION APP CRIADO COM SUCESSO!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Function App: $FUNCTION_APP_NAME"
echo "URL: https://${FUNCTION_APP_NAME}.azurewebsites.net"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  PRÓXIMOS PASSOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Configurar domínio de e-mail (ver: REFERENCIA-RAPIDA-EMAIL.md)"
echo ""
echo "2️⃣  Atualizar variável AZURE_COMMUNICATION_FROM_EMAIL:"
echo "   az functionapp config appsettings set \\"
echo "     --name $FUNCTION_APP_NAME \\"
echo "     --resource-group $RESOURCE_GROUP \\"
echo "     --settings \"AZURE_COMMUNICATION_FROM_EMAIL=069b97b6-4a8e-499b-84da-518ba567a161.azurecomm.net\""
echo ""
echo "3️⃣  Fazer deploy da aplicação:"
echo "   mvn clean install"
echo "   mvn clean package azure-functions:deploy"
echo ""
echo "4️⃣  Obter Function Key:"
echo "   az functionapp keys list \\"
echo "     --name $FUNCTION_APP_NAME \\"
echo "     --resource-group $RESOURCE_GROUP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

