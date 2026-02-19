#!/bin/bash

# Script para coletar todos os valores dos secrets necessários
# Uso: ./collect-secrets.sh

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     🔑 COLETAR VALORES PARA SECRETS DO GITHUB            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variáveis
RESOURCE_GROUP="feedbackhub-rg"
SERVER_NAME="feedbackhub-server"
DB_NAME="feedbackhub-db"
STORAGE_NAME="feedbackhubstorage"
FUNCTION_APP_NAME="feedbackhub-func"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 CONFIGURAÇÃO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Resource Group: $RESOURCE_GROUP"
echo "SQL Server: $SERVER_NAME"
echo "Database: $DB_NAME"
echo "Storage: $STORAGE_NAME"
echo "Function App: $FUNCTION_APP_NAME"
echo ""

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI não encontrado!${NC}"
    echo "Instale em: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar autenticação
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Não autenticado no Azure${NC}"
    echo "Executando login..."
    az login
fi

ACCOUNT=$(az account show --query "name" -o tsv)
echo -e "${GREEN}✅ Autenticado no Azure${NC}"
echo "   Conta: $ACCOUNT"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 COLETANDO VALORES DOS SECRETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Arquivo de saída
OUTPUT_FILE="github-secrets-values.txt"
rm -f $OUTPUT_FILE

echo "# GitHub Secrets - FeedbackHub" > $OUTPUT_FILE
echo "# Gerado em: $(date)" >> $OUTPUT_FILE
echo "# ⚠️  IMPORTANTE: Não commite este arquivo! Contém informações sensíveis!" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 1. AZURE_FUNCTIONAPP_PUBLISH_PROFILE
echo -e "${BLUE}[1/8]${NC} AZURE_FUNCTIONAPP_PUBLISH_PROFILE"
echo "      Obtendo publish profile..."

PUBLISH_PROFILE=$(az functionapp deployment list-publishing-profiles \
    --name $FUNCTION_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --xml 2>/dev/null)

if [ ! -z "$PUBLISH_PROFILE" ]; then
    echo -e "      ${GREEN}✅ Obtido${NC}"
    echo "## 1. AZURE_FUNCTIONAPP_PUBLISH_PROFILE" >> $OUTPUT_FILE
    echo "Name: AZURE_FUNCTIONAPP_PUBLISH_PROFILE" >> $OUTPUT_FILE
    echo "Value:" >> $OUTPUT_FILE
    echo "$PUBLISH_PROFILE" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
else
    echo -e "      ${RED}❌ Erro ao obter${NC}"
    echo "## 1. AZURE_FUNCTIONAPP_PUBLISH_PROFILE" >> $OUTPUT_FILE
    echo "Name: AZURE_FUNCTIONAPP_PUBLISH_PROFILE" >> $OUTPUT_FILE
    echo "Value: ⚠️  Execute: ./get-publish-profile.sh" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
fi

# 2. DB_URL
echo -e "${BLUE}[2/8]${NC} DB_URL"
echo "      Obtendo connection string do banco..."

DB_URL=$(az sql db show-connection-string \
    --client jdbc \
    --server $SERVER_NAME \
    --name $DB_NAME 2>/dev/null | tr -d '"')

if [ ! -z "$DB_URL" ]; then
    echo -e "      ${GREEN}✅ Obtido${NC}"
    echo "## 2. DB_URL" >> $OUTPUT_FILE
    echo "Name: DB_URL" >> $OUTPUT_FILE
    echo "Value: $DB_URL" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
else
    echo -e "      ${RED}❌ Erro ao obter${NC}"
    echo "## 2. DB_URL" >> $OUTPUT_FILE
    echo "Name: DB_URL" >> $OUTPUT_FILE
    echo "Value: ⚠️  Obtenha no Portal Azure → SQL Database → Connection strings" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
fi

# 3. DB_USERNAME
echo -e "${BLUE}[3/8]${NC} DB_USERNAME"
echo "      Obtendo usuário do banco..."

DB_USER=$(az sql server show \
    --name $SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "administratorLogin" -o tsv 2>/dev/null)

if [ ! -z "$DB_USER" ]; then
    echo -e "      ${GREEN}✅ Obtido: $DB_USER${NC}"
    echo "## 3. DB_USERNAME" >> $OUTPUT_FILE
    echo "Name: DB_USERNAME" >> $OUTPUT_FILE
    echo "Value: $DB_USER" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
else
    echo -e "      ${RED}❌ Erro ao obter${NC}"
    echo "## 3. DB_USERNAME" >> $OUTPUT_FILE
    echo "Name: DB_USERNAME" >> $OUTPUT_FILE
    echo "Value: ⚠️  Verifique no Portal Azure ou scripts de setup" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
fi

# 4. DB_PASSWORD
echo -e "${BLUE}[4/8]${NC} DB_PASSWORD"
echo "      ${YELLOW}⚠️  Senha não pode ser obtida automaticamente${NC}"
echo "## 4. DB_PASSWORD" >> $OUTPUT_FILE
echo "Name: DB_PASSWORD" >> $OUTPUT_FILE
echo "Value: ⚠️  É a senha que você definiu ao criar o SQL Server" >> $OUTPUT_FILE
echo "       Se não lembra, reset com:" >> $OUTPUT_FILE
echo "       az sql server update --name $SERVER_NAME --resource-group $RESOURCE_GROUP --admin-password \"NovaSenha123!\"" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 5. AZURE_STORAGE_CONNECTION_STRING
echo -e "${BLUE}[5/8]${NC} AZURE_STORAGE_CONNECTION_STRING"
echo "      Obtendo connection string do storage..."

STORAGE_CONN=$(az storage account show-connection-string \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --query "connectionString" -o tsv 2>/dev/null)

if [ ! -z "$STORAGE_CONN" ]; then
    echo -e "      ${GREEN}✅ Obtido${NC}"
    echo "## 5. AZURE_STORAGE_CONNECTION_STRING" >> $OUTPUT_FILE
    echo "Name: AZURE_STORAGE_CONNECTION_STRING" >> $OUTPUT_FILE
    echo "Value: $STORAGE_CONN" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
else
    echo -e "      ${RED}❌ Erro ao obter${NC}"
    echo "## 5. AZURE_STORAGE_CONNECTION_STRING" >> $OUTPUT_FILE
    echo "Name: AZURE_STORAGE_CONNECTION_STRING" >> $OUTPUT_FILE
    echo "Value: ⚠️  Obtenha no Portal Azure → Storage Account → Access keys" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
fi

# 6. SENDGRID_API_KEY
echo -e "${BLUE}[6/8]${NC} SENDGRID_API_KEY"
echo "      ${YELLOW}⚠️  Deve ser obtido manualmente${NC}"
echo "## 6. SENDGRID_API_KEY" >> $OUTPUT_FILE
echo "Name: SENDGRID_API_KEY" >> $OUTPUT_FILE
echo "Value: ⚠️  Obtenha em: https://app.sendgrid.com/settings/api_keys" >> $OUTPUT_FILE
echo "       Ou use Azure Communication Services (ACS) se preferir" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 7. ADMIN_EMAILS
echo -e "${BLUE}[7/8]${NC} ADMIN_EMAILS"
echo "      ${YELLOW}⚠️  Deve ser definido manualmente${NC}"
echo "## 7. ADMIN_EMAILS" >> $OUTPUT_FILE
echo "Name: ADMIN_EMAILS" >> $OUTPUT_FILE
echo "Value: ⚠️  Defina os e-mails dos administradores (separados por vírgula)" >> $OUTPUT_FILE
echo "       Exemplo: admin@fiap.com.br,gestor@fiap.com.br" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 8. REPORT_EMAILS
echo -e "${BLUE}[8/8]${NC} REPORT_EMAILS"
echo "      ${YELLOW}⚠️  Deve ser definido manualmente${NC}"
echo "## 8. REPORT_EMAILS" >> $OUTPUT_FILE
echo "Name: REPORT_EMAILS" >> $OUTPUT_FILE
echo "Value: ⚠️  Defina os e-mails para relatórios (separados por vírgula)" >> $OUTPUT_FILE
echo "       Exemplo: relatorios@fiap.com.br,gestao@fiap.com.br" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ COLETA CONCLUÍDA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}📄 Valores salvos em: $OUTPUT_FILE${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PRÓXIMOS PASSOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Abra o arquivo com os valores:"
echo "    cat $OUTPUT_FILE"
echo ""
echo "2️⃣  Acesse GitHub:"
echo "    https://github.com/SEU_USUARIO/feedbackhub/settings/secrets/actions"
echo ""
echo "3️⃣  Para cada secret:"
echo "    • Clique em 'New repository secret'"
echo "    • Cole o Name (exatamente como está no arquivo)"
echo "    • Cole o Value (pegue do arquivo)"
echo "    • Clique em 'Add secret'"
echo ""
echo "4️⃣  Complete os valores marcados com ⚠️:"
echo "    • DB_PASSWORD (sua senha do banco)"
echo "    • SENDGRID_API_KEY (de https://app.sendgrid.com)"
echo "    • ADMIN_EMAILS (seus e-mails de admin)"
echo "    • REPORT_EMAILS (seus e-mails para relatórios)"
echo ""
echo "5️⃣  Teste o deploy:"
echo "    git push origin main"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  SEGURANÇA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${RED}⚠️  O arquivo $OUTPUT_FILE contém informações sensíveis!${NC}"
echo ""
echo "Para remover após uso:"
echo "    rm $OUTPUT_FILE"
echo ""
echo "Nunca commite este arquivo no Git!"
echo ""

# Adicionar ao .gitignore se não estiver
if ! grep -q "$OUTPUT_FILE" .gitignore 2>/dev/null; then
    echo "$OUTPUT_FILE" >> .gitignore
    echo -e "${GREEN}✅ Adicionado ao .gitignore${NC}"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

