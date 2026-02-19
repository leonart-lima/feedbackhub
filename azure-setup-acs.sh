#!/bin/bash

################################################################################
# FeedbackHub - Script com Azure Communication Services
#
# Alternativa ao SendGrid usando serviço nativo da Microsoft Azure
#
# Vantagens:
# - 250 e-mails GRÁTIS/mês permanentemente
# - Serviço nativo Azure (mesma conta)
# - Sem necessidade de conta externa
# - Integração perfeita
################################################################################

set -e

# ============================================================================
# CONFIGURAÇÕES - ALTERE CONFORME NECESSÁRIO
# ============================================================================

RESOURCE_GROUP="feedbackhub-rg"
LOCATION="eastus"

# SQL Database
SQL_SERVER_NAME="feedbackhub-server-$(date +%s | tail -c 6)"
SQL_DB_NAME="feedbackhub"
SQL_ADMIN_USER="azureuser"
SQL_ADMIN_PASSWORD="FeedbackHub@2026!"

# Storage Account
STORAGE_ACCOUNT_NAME="feedbackhubst$(date +%s | tail -c 8)"
QUEUE_NAME="feedback-urgencia-queue"

# Function App
FUNCTION_APP_NAME="feedbackhub-func-$(date +%s | tail -c 6)"

# Application Insights
APP_INSIGHTS_NAME="feedbackhub-insights"

# Azure Communication Services (NOVO!)
COMMUNICATION_SERVICE_NAME="feedbackhub-comm-$(date +%s | tail -c 6)"
EMAIL_SERVICE_NAME="feedbackhub-email"

# E-mails de destino
ADMIN_EMAILS="admin@example.com"
REPORT_EMAILS="reports@example.com"

# ============================================================================
# CORES PARA OUTPUT
# ============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ============================================================================
# VERIFICAÇÕES INICIAIS
# ============================================================================

print_step "1/9 - Verificando Pré-requisitos"

if ! command -v az &> /dev/null; then
    print_error "Azure CLI não está instalado!"
    echo "Instale com: brew install azure-cli"
    exit 1
fi
print_success "Azure CLI instalado"

if ! az account show &> /dev/null; then
    print_error "Você não está logado no Azure!"
    echo "Execute: az login"
    exit 1
fi
print_success "Login Azure verificado"

SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "📋 Assinatura: $SUBSCRIPTION_NAME"
echo "🆔 ID: $SUBSCRIPTION_ID"

# ============================================================================
# CRIAR RESOURCE GROUP
# ============================================================================

print_step "2/9 - Criando Resource Group"

if az group exists --name $RESOURCE_GROUP | grep -q "true"; then
    print_warning "Resource Group '$RESOURCE_GROUP' já existe. Usando existente."
else
    az group create \
        --name $RESOURCE_GROUP \
        --location $LOCATION \
        --output table

    print_success "Resource Group criado: $RESOURCE_GROUP"
fi

# ============================================================================
# CRIAR AZURE SQL DATABASE (SERVERLESS)
# ============================================================================

print_step "3/9 - Criando Azure SQL Database (Serverless)"

echo "📦 Criando SQL Server..."
az sql server create \
    --name $SQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --admin-user $SQL_ADMIN_USER \
    --admin-password "$SQL_ADMIN_PASSWORD" \
    --output table

print_success "SQL Server criado: $SQL_SERVER_NAME"

echo "📦 Criando Database Serverless..."
az sql db create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name $SQL_DB_NAME \
    --edition GeneralPurpose \
    --family Gen5 \
    --capacity 1 \
    --compute-model Serverless \
    --auto-pause-delay 60 \
    --min-capacity 0.5 \
    --output table

print_success "Database criado: $SQL_DB_NAME (Serverless com auto-pause)"

echo "🔒 Configurando Firewall..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --output table

MY_IP=$(curl -s https://api.ipify.org)
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER_NAME \
    --name AllowMyIP \
    --start-ip-address $MY_IP \
    --end-ip-address $MY_IP \
    --output table

print_success "Firewall configurado (Azure Services + Seu IP: $MY_IP)"

# ============================================================================
# CRIAR STORAGE ACCOUNT + QUEUE
# ============================================================================

print_step "4/9 - Criando Storage Account e Queue"

echo "📦 Criando Storage Account..."
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --output table

print_success "Storage Account criado: $STORAGE_ACCOUNT_NAME"

STORAGE_CONNECTION=$(az storage account show-connection-string \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query connectionString \
    --output tsv)

echo "📦 Criando Queue..."
az storage queue create \
    --name $QUEUE_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --connection-string "$STORAGE_CONNECTION" \
    --output table

print_success "Queue criada: $QUEUE_NAME"

# ============================================================================
# CRIAR APPLICATION INSIGHTS
# ============================================================================

print_step "5/9 - Criando Application Insights"

az monitor app-insights component create \
    --app $APP_INSIGHTS_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --application-type web \
    --output table

APPINSIGHTS_KEY=$(az monitor app-insights component show \
    --app $APP_INSIGHTS_NAME \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey \
    --output tsv)

print_success "Application Insights criado: $APP_INSIGHTS_NAME"

# ============================================================================
# CRIAR AZURE COMMUNICATION SERVICES (NOVO!)
# ============================================================================

print_step "6/9 - Criando Azure Communication Services"

echo "📧 Criando Communication Service..."
az communication create \
    --name $COMMUNICATION_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP \
    --data-location "United States" \
    --location global \
    --output table

print_success "Communication Service criado: $COMMUNICATION_SERVICE_NAME"

echo "📧 Criando Email Communication Service..."
az communication email create \
    --name $EMAIL_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP \
    --data-location "United States" \
    --output table

print_success "Email Communication Service criado"

echo "📧 Criando domínio de e-mail gerenciado pela Azure..."
az communication email domain create \
    --domain-name AzureManagedDomain \
    --email-service-name $EMAIL_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP \
    --output table

# Obter o endereço de e-mail gerado
FROM_EMAIL=$(az communication email domain show \
    --domain-name AzureManagedDomain \
    --email-service-name $EMAIL_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "fromSenderDomain" \
    --output tsv 2>/dev/null || echo "DoNotReply@xxxxxxxx.azurecomm.net")

print_success "Domínio de e-mail criado: $FROM_EMAIL"

# Obter connection string
COMM_CONNECTION_STRING=$(az communication list-key \
    --name $COMMUNICATION_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "primaryConnectionString" \
    --output tsv)

print_success "Connection String obtida"

# Conectar Email Service ao Communication Service
echo "🔗 Conectando serviços..."
az communication email domain link \
    --domain-name AzureManagedDomain \
    --email-service-name $EMAIL_SERVICE_NAME \
    --communication-service-name $COMMUNICATION_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP \
    --output table 2>/dev/null || print_warning "Link pode ser feito manualmente no portal"

print_success "Azure Communication Services configurado!"
print_warning "✉️  E-mail remetente: $FROM_EMAIL"
print_warning "📊 250 e-mails GRÁTIS/mês permanentemente"

# ============================================================================
# CRIAR FUNCTION APP
# ============================================================================

print_step "7/9 - Criando Function App"

az functionapp create \
    --resource-group $RESOURCE_GROUP \
    --consumption-plan-location $LOCATION \
    --runtime java \
    --runtime-version 21 \
    --functions-version 4 \
    --name $FUNCTION_APP_NAME \
    --storage-account $STORAGE_ACCOUNT_NAME \
    --os-type Linux \
    --app-insights $APP_INSIGHTS_NAME \
    --app-insights-key $APPINSIGHTS_KEY \
    --output table

print_success "Function App criado: $FUNCTION_APP_NAME"

# ============================================================================
# CONFIGURAR VARIÁVEIS DE AMBIENTE
# ============================================================================

print_step "8/9 - Configurando Variáveis de Ambiente"

SQL_CONNECTION_STRING="jdbc:sqlserver://${SQL_SERVER_NAME}.database.windows.net:1433;database=${SQL_DB_NAME};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"

echo "📝 Configurando App Settings..."
az functionapp config appsettings set \
    --name $FUNCTION_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "DB_URL=$SQL_CONNECTION_STRING" \
        "DB_USERNAME=$SQL_ADMIN_USER" \
        "DB_PASSWORD=$SQL_ADMIN_PASSWORD" \
        "AZURE_STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION" \
        "AZURE_COMMUNICATION_CONNECTION_STRING=$COMM_CONNECTION_STRING" \
        "AZURE_COMMUNICATION_FROM_EMAIL=$FROM_EMAIL" \
        "ADMIN_EMAILS=$ADMIN_EMAILS" \
        "REPORT_EMAILS=$REPORT_EMAILS" \
        "WEBSITE_TIME_ZONE=E. South America Standard Time" \
    --output table

print_success "Variáveis de ambiente configuradas"

# ============================================================================
# RESUMO E PRÓXIMOS PASSOS
# ============================================================================

print_step "9/9 - Provisionamento Concluído!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 RESUMO DOS RECURSOS CRIADOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Resource Group:           $RESOURCE_GROUP"
echo "✅ Location:                 $LOCATION"
echo ""
echo "🗄️  SQL Server:               $SQL_SERVER_NAME.database.windows.net"
echo "🗄️  Database:                 $SQL_DB_NAME (Serverless)"
echo "👤 Admin User:               $SQL_ADMIN_USER"
echo "🔑 Admin Password:           $SQL_ADMIN_PASSWORD"
echo ""
echo "💾 Storage Account:          $STORAGE_ACCOUNT_NAME"
echo "📬 Queue:                    $QUEUE_NAME"
echo ""
echo "⚡ Function App:             $FUNCTION_APP_NAME"
echo "🔗 URL:                      https://${FUNCTION_APP_NAME}.azurewebsites.net"
echo ""
echo "📊 Application Insights:     $APP_INSIGHTS_NAME"
echo ""
echo "📧 Communication Service:    $COMMUNICATION_SERVICE_NAME"
echo "📧 Email Service:            $EMAIL_SERVICE_NAME"
echo "✉️  E-mail Remetente:        $FROM_EMAIL"
echo "📊 E-mails Grátis:           250/mês (permanente)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 PRÓXIMOS PASSOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Atualizar e-mails de destino:"
echo "   az functionapp config appsettings set \\"
echo "     --name $FUNCTION_APP_NAME \\"
echo "     --resource-group $RESOURCE_GROUP \\"
echo "     --settings \"ADMIN_EMAILS=seu@email.com\" \"REPORT_EMAILS=seu@email.com\""
echo ""
echo "2️⃣  Adicionar dependência no pom.xml:"
echo "   <dependency>"
echo "     <groupId>com.azure</groupId>"
echo "     <artifactId>azure-communication-email</artifactId>"
echo "     <version>1.0.7</version>"
echo "   </dependency>"
echo ""
echo "3️⃣  Atualizar EmailService.java para usar Azure Communication Services"
echo "   (Ver: docs/EMAIL_ALTERNATIVES.md)"
echo ""
echo "4️⃣  Fazer deploy da aplicação:"
echo "   mvn clean package azure-functions:deploy"
echo ""
echo "5️⃣  Testar a API:"
echo "   curl -X POST https://${FUNCTION_APP_NAME}.azurewebsites.net/api/avaliacao?code=FUNCTION_KEY \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"descricao\": \"Teste\", \"nota\": 8}'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 VANTAGENS DO AZURE COMMUNICATION SERVICES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Serviço nativo da Microsoft Azure (mesma conta)"
echo "✅ 250 e-mails GRÁTIS/mês permanentemente"
echo "✅ Sem necessidade de conta externa (SendGrid, etc)"
echo "✅ Integração perfeita com Azure Functions"
echo "✅ Domínio de e-mail gerenciado pela Azure (sem verificação)"
echo "✅ Suporta também SMS, voz e vídeo"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 CREDENCIAIS (Salve em local seguro!)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "SQL_SERVER=$SQL_SERVER_NAME.database.windows.net"
echo "SQL_DATABASE=$SQL_DB_NAME"
echo "SQL_USER=$SQL_ADMIN_USER"
echo "SQL_PASSWORD=$SQL_ADMIN_PASSWORD"
echo "STORAGE_CONNECTION=$STORAGE_CONNECTION"
echo "COMM_CONNECTION=$COMM_CONNECTION_STRING"
echo "FROM_EMAIL=$FROM_EMAIL"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Salvar credenciais
CREDENTIALS_FILE="azure-credentials-acs.txt"
cat > $CREDENTIALS_FILE <<EOF
FeedbackHub - Credenciais Azure (com Communication Services)
Gerado em: $(date)

═══════════════════════════════════════════════════════════════
RESOURCE GROUP
═══════════════════════════════════════════════════════════════
Resource Group: $RESOURCE_GROUP
Location: $LOCATION

═══════════════════════════════════════════════════════════════
AZURE SQL DATABASE
═══════════════════════════════════════════════════════════════
SQL Server: $SQL_SERVER_NAME.database.windows.net
Database: $SQL_DB_NAME
Username: $SQL_ADMIN_USER
Password: $SQL_ADMIN_PASSWORD

Connection String:
$SQL_CONNECTION_STRING

═══════════════════════════════════════════════════════════════
STORAGE ACCOUNT
═══════════════════════════════════════════════════════════════
Storage Account: $STORAGE_ACCOUNT_NAME
Queue Name: $QUEUE_NAME

Connection String:
$STORAGE_CONNECTION

═══════════════════════════════════════════════════════════════
FUNCTION APP
═══════════════════════════════════════════════════════════════
Function App: $FUNCTION_APP_NAME
URL: https://${FUNCTION_APP_NAME}.azurewebsites.net

═══════════════════════════════════════════════════════════════
APPLICATION INSIGHTS
═══════════════════════════════════════════════════════════════
Name: $APP_INSIGHTS_NAME
Instrumentation Key: $APPINSIGHTS_KEY

═══════════════════════════════════════════════════════════════
AZURE COMMUNICATION SERVICES
═══════════════════════════════════════════════════════════════
Communication Service: $COMMUNICATION_SERVICE_NAME
Email Service: $EMAIL_SERVICE_NAME
From Email: $FROM_EMAIL
Connection String: $COMM_CONNECTION_STRING

E-mails Grátis: 250/mês (permanente)
Após free tier: \$0.25 por 1.000 e-mails

═══════════════════════════════════════════════════════════════
CONFIGURAR MANUALMENTE
═══════════════════════════════════════════════════════════════
1. Admin Emails: [Atualizar com e-mails reais]
2. Report Emails: [Atualizar com e-mails reais]

EOF

print_success "Credenciais salvas em: $CREDENTIALS_FILE"
print_warning "⚠️  IMPORTANTE: Adicione '$CREDENTIALS_FILE' ao .gitignore!"

echo ""
echo -e "${GREEN}🎉 Provisionamento concluído com Azure Communication Services!${NC}"
echo -e "${BLUE}📚 Veja docs/EMAIL_ALTERNATIVES.md para atualizar o código${NC}"
echo ""

d