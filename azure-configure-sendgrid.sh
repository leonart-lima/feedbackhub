#!/bin/bash

################################################################################
# FeedbackHub - Configurar SendGrid
#
# Execute este script APÓS:
# 1. Criar conta no SendGrid (https://sendgrid.com)
# 2. Obter API Key
# 3. Verificar domínio/e-mail remetente
################################################################################

set -e

# ============================================================================
# CORES PARA OUTPUT
# ============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================================================
# OBTER INFORMAÇÕES DO USUÁRIO
# ============================================================================

echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   FeedbackHub - Configuração SendGrid${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}\n"

# Resource Group
read -p "Resource Group [feedbackhub-rg]: " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-feedbackhub-rg}

# Function App Name
echo ""
echo "Listando Function Apps disponíveis no Resource Group '$RESOURCE_GROUP':"
az functionapp list --resource-group $RESOURCE_GROUP --query "[].name" -o table
echo ""

read -p "Nome do Function App: " FUNCTION_APP_NAME

if [ -z "$FUNCTION_APP_NAME" ]; then
    echo -e "${RED}❌ Function App é obrigatório!${NC}"
    exit 1
fi

# SendGrid API Key
echo ""
echo -e "${YELLOW}⚠️  Obtenha sua API Key em: https://app.sendgrid.com/settings/api_keys${NC}"
read -p "SendGrid API Key: " SENDGRID_API_KEY

if [ -z "$SENDGRID_API_KEY" ]; then
    echo -e "${RED}❌ SendGrid API Key é obrigatória!${NC}"
    exit 1
fi

# E-mail remetente
echo ""
echo -e "${YELLOW}⚠️  Use um e-mail verificado no SendGrid${NC}"
read -p "E-mail remetente [noreply@feedbackhub.com]: " SENDGRID_FROM_EMAIL
SENDGRID_FROM_EMAIL=${SENDGRID_FROM_EMAIL:-noreply@feedbackhub.com}

# E-mails de administradores (notificações de urgência)
echo ""
read -p "E-mails dos administradores (separados por vírgula): " ADMIN_EMAILS

if [ -z "$ADMIN_EMAILS" ]; then
    echo -e "${RED}❌ E-mails dos administradores são obrigatórios!${NC}"
    exit 1
fi

# E-mails para relatórios
echo ""
read -p "E-mails para relatórios semanais (separados por vírgula): " REPORT_EMAILS
REPORT_EMAILS=${REPORT_EMAILS:-$ADMIN_EMAILS}

# ============================================================================
# ATUALIZAR CONFIGURAÇÕES
# ============================================================================

echo ""
echo -e "${BLUE}📝 Atualizando configurações...${NC}\n"

az functionapp config appsettings set \
    --name $FUNCTION_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "SENDGRID_API_KEY=$SENDGRID_API_KEY" \
        "SENDGRID_FROM_EMAIL=$SENDGRID_FROM_EMAIL" \
        "ADMIN_EMAILS=$ADMIN_EMAILS" \
        "REPORT_EMAILS=$REPORT_EMAILS" \
    --output table

echo ""
echo -e "${GREEN}✅ Configurações atualizadas com sucesso!${NC}"

# ============================================================================
# TESTAR SENDGRID (OPCIONAL)
# ============================================================================

echo ""
read -p "Deseja testar o SendGrid agora? (s/n): " TEST_SENDGRID

if [ "$TEST_SENDGRID" == "s" ] || [ "$TEST_SENDGRID" == "S" ]; then
    read -p "E-mail de destino para teste: " TEST_EMAIL

    echo ""
    echo -e "${BLUE}📧 Enviando e-mail de teste...${NC}"

    curl -X POST "https://api.sendgrid.com/v3/mail/send" \
        -H "Authorization: Bearer $SENDGRID_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"personalizations\": [{
                \"to\": [{\"email\": \"$TEST_EMAIL\"}],
                \"subject\": \"FeedbackHub - Teste de Configuração\"
            }],
            \"from\": {\"email\": \"$SENDGRID_FROM_EMAIL\"},
            \"content\": [{
                \"type\": \"text/plain\",
                \"value\": \"Este é um e-mail de teste do FeedbackHub. Se você recebeu esta mensagem, a integração com SendGrid está funcionando corretamente!\"
            }]
        }"

    echo ""
    echo -e "${GREEN}✅ E-mail enviado! Verifique a caixa de entrada de $TEST_EMAIL${NC}"
fi

# ============================================================================
# RESUMO
# ============================================================================

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Configuração Concluída${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}\n"
echo "Function App: $FUNCTION_APP_NAME"
echo "E-mail remetente: $SENDGRID_FROM_EMAIL"
echo "Administradores: $ADMIN_EMAILS"
echo "Relatórios: $REPORT_EMAILS"
echo ""
echo -e "${YELLOW}⚠️  Lembre-se de fazer deploy da aplicação:${NC}"
echo "   mvn clean package azure-functions:deploy"
echo ""

