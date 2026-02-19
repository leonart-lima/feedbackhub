#!/bin/bash

# Script para obter o Publish Profile do Azure Function App
# Uso: ./get-publish-profile.sh

set -e

echo "=================================================="
echo "🔐 Obter Publish Profile do Azure Functions"
echo "=================================================="
echo ""

# Variáveis do projeto
RESOURCE_GROUP="feedbackhub-rg"
FUNCTION_APP_NAME="feedbackhub-func"

echo "📋 Configuração:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Function App: $FUNCTION_APP_NAME"
echo ""

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI não encontrado!"
    echo "   Instale em: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo "✅ Azure CLI encontrado"
echo ""

# Verificar se está logado
echo "🔍 Verificando autenticação no Azure..."
if ! az account show &> /dev/null; then
    echo "❌ Não autenticado no Azure"
    echo "   Executando login..."
    az login
else
    echo "✅ Já autenticado no Azure"
    ACCOUNT=$(az account show --query "name" -o tsv)
    echo "   Conta: $ACCOUNT"
fi
echo ""

# Verificar se a Function App existe
echo "🔍 Verificando se a Function App existe..."
if ! az functionapp show --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "❌ Function App não encontrada!"
    echo "   Nome: $FUNCTION_APP_NAME"
    echo "   Resource Group: $RESOURCE_GROUP"
    echo ""
    echo "   Verifique se o nome está correto ou crie a Function App primeiro:"
    echo "   ./azure-setup.sh"
    exit 1
fi

echo "✅ Function App encontrada"
echo ""

# Obter o publish profile
echo "📥 Obtendo publish profile..."
echo ""

PUBLISH_PROFILE=$(az functionapp deployment list-publishing-profiles \
    --name $FUNCTION_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --xml)

if [ -z "$PUBLISH_PROFILE" ]; then
    echo "❌ Erro ao obter publish profile"
    exit 1
fi

# Salvar em arquivo
OUTPUT_FILE="publish-profile.xml"
echo "$PUBLISH_PROFILE" > $OUTPUT_FILE

echo "✅ Publish profile obtido com sucesso!"
echo ""
echo "=================================================="
echo "📄 Arquivo salvo em: $OUTPUT_FILE"
echo "=================================================="
echo ""
echo "📋 Próximos passos:"
echo ""
echo "1️⃣  Copie o conteúdo do arquivo:"
echo "    cat $OUTPUT_FILE | pbcopy"
echo ""
echo "2️⃣  Acesse seu repositório no GitHub:"
echo "    Settings → Secrets and variables → Actions"
echo ""
echo "3️⃣  Crie um novo secret:"
echo "    Name: AZURE_FUNCTIONAPP_PUBLISH_PROFILE"
echo "    Value: [Cole o conteúdo copiado]"
echo ""
echo "4️⃣  Adicione os outros secrets necessários:"
echo "    - DB_URL"
echo "    - DB_USERNAME"
echo "    - DB_PASSWORD"
echo "    - AZURE_STORAGE_CONNECTION_STRING"
echo "    - SENDGRID_API_KEY (ou AZURE_COMMUNICATION_CONNECTION_STRING)"
echo "    - ADMIN_EMAILS"
echo "    - REPORT_EMAILS"
echo ""
echo "5️⃣  Faça um push para testar:"
echo "    git add ."
echo "    git commit -m \"test: deploy automático\""
echo "    git push origin main"
echo ""
echo "=================================================="
echo "⚠️  IMPORTANTE: Não commite o arquivo $OUTPUT_FILE"
echo "    Ele contém credenciais sensíveis!"
echo "=================================================="
echo ""

# Copiar automaticamente para clipboard no macOS
if command -v pbcopy &> /dev/null; then
    cat $OUTPUT_FILE | pbcopy
    echo "✅ Conteúdo copiado automaticamente para área de transferência!"
    echo ""
fi

echo "🔍 Para verificar o conteúdo:"
echo "   cat $OUTPUT_FILE"
echo ""
echo "🗑️  Para remover o arquivo após uso:"
echo "   rm $OUTPUT_FILE"
echo ""

