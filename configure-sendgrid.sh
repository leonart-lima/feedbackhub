#!/bin/bash

# Script de Configuração do SendGrid no Azure Function App

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Configuração SendGrid - FeedbackHub${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Variáveis de configuração do Azure
RESOURCE_GROUP="feedbackhub-rg"
FUNCTION_APP="feedbackhub-func"

echo -e "${YELLOW}⚠️  ATENÇÃO: Você precisa configurar os valores abaixo!${NC}"
echo ""
echo "1. Crie uma conta no SendGrid: https://signup.sendgrid.com/"
echo "2. Crie uma API Key em: Settings → API Keys"
echo "3. Verifique seu email remetente em: Settings → Sender Authentication → Single Sender Verification"
echo ""

# Solicitar informações do usuário
read -p "🔑 Digite sua SendGrid API Key: " SENDGRID_API_KEY
echo ""

read -p "📧 Digite o email remetente VERIFICADO no SendGrid: " SENDGRID_FROM_EMAIL
echo ""

read -p "👤 Digite o nome do remetente (ex: FeedbackHub): " SENDGRID_FROM_NAME
echo ""

read -p "📨 Digite os emails dos administradores (separados por vírgula): " ADMIN_EMAILS
echo ""

read -p "📊 Digite os emails para receber relatórios (separados por vírgula): " REPORT_EMAILS
echo ""

# Confirmar configurações
echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${BLUE}Confirmação das Configurações:${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "Function App: $FUNCTION_APP"
echo "SendGrid API Key: ${SENDGRID_API_KEY:0:10}..."
echo "From Email: $SENDGRID_FROM_EMAIL"
echo "From Name: $SENDGRID_FROM_NAME"
echo "Admin Emails: $ADMIN_EMAILS"
echo "Report Emails: $REPORT_EMAILS"
echo ""

read -p "Confirma as configurações acima? (s/n): " CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
    echo -e "${RED}❌ Configuração cancelada.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔧 Configurando SendGrid no Azure Function App...${NC}"
echo ""

# Configurar as variáveis de ambiente no Azure
az functionapp config appsettings set \
  --name "$FUNCTION_APP" \
  --resource-group "$RESOURCE_GROUP" \
  --settings \
  "SENDGRID_API_KEY=$SENDGRID_API_KEY" \
  "SENDGRID_FROM_EMAIL=$SENDGRID_FROM_EMAIL" \
  "SENDGRID_FROM_NAME=$SENDGRID_FROM_NAME" \
  "ADMIN_EMAILS=$ADMIN_EMAILS" \
  "REPORT_EMAILS=$REPORT_EMAILS" \
  --output none

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configurações aplicadas com sucesso!${NC}"
else
    echo -e "${RED}❌ Erro ao aplicar configurações.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}⏳ Aguardando reinicialização do Function App (30 segundos)...${NC}"
sleep 30

echo ""
echo -e "${BLUE}📊 Verificando configurações...${NC}"
echo ""

az functionapp config appsettings list \
  --name "$FUNCTION_APP" \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?contains(name, 'SENDGRID') || contains(name, 'ADMIN_EMAILS') || contains(name, 'REPORT_EMAILS')].{Name:name, Value:value}" \
  --output table

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ✅ Configuração Concluída!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}📋 Próximos Passos:${NC}"
echo ""
echo "1. Compile o projeto:"
echo "   mvn clean package -DskipTests"
echo ""
echo "2. Faça o deploy:"
echo "   mvn azure-functions:deploy"
echo ""
echo "3. Teste enviando uma avaliação crítica (nota ≤ 3)"
echo ""
echo "4. Verifique os emails no Activity Feed do SendGrid:"
echo "   https://app.sendgrid.com/email_activity"
echo ""
echo -e "${YELLOW}💡 Dica: Verifique os logs com:${NC}"
echo "   az functionapp log tail --name $FUNCTION_APP --resource-group $RESOURCE_GROUP"
echo ""

