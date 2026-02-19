#!/bin/bash

# Script para diagnosticar e corrigir o erro 404 na API
# Uso: ./fix-404-error.sh

set -e

echo "============================================="
echo "🔍 Diagnóstico do Erro 404 - FeedbackHub"
echo "============================================="
echo ""

RESOURCE_GROUP="feedbackhub-rg"
FUNCTION_APP="feedbackhub-func"

# Verificar se está logado no Azure
echo "1️⃣ Verificando login no Azure..."
if ! az account show &> /dev/null; then
    echo "❌ Você não está logado no Azure CLI"
    echo "Execute: az login"
    exit 1
fi
echo "✅ Logado no Azure"
echo ""

# Verificar se o Function App existe
echo "2️⃣ Verificando se Function App existe..."
if ! az functionapp show --name $FUNCTION_APP --resource-group $RESOURCE_GROUP &> /dev/null; then
    echo "❌ Function App '$FUNCTION_APP' não encontrado no resource group '$RESOURCE_GROUP'"
    echo ""
    echo "Function Apps disponíveis:"
    az functionapp list --query "[].{name:name, resourceGroup:resourceGroup, state:state}" --output table
    exit 1
fi
echo "✅ Function App encontrado"
echo ""

# Listar variáveis de ambiente atuais
echo "3️⃣ Verificando variáveis de ambiente..."
echo "Variáveis atuais (sem valores sensíveis):"
az functionapp config appsettings list \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --query "[].name" \
  --output tsv | sort

echo ""

# Verificar variáveis SendGrid obrigatórias
echo "4️⃣ Verificando variáveis SendGrid obrigatórias..."
MISSING_VARS=()

if ! az functionapp config appsettings list \
     --name $FUNCTION_APP \
     --resource-group $RESOURCE_GROUP \
     --query "[?name=='SENDGRID_API_KEY'].value" \
     --output tsv | grep -q .; then
    MISSING_VARS+=("SENDGRID_API_KEY")
fi

if ! az functionapp config appsettings list \
     --name $FUNCTION_APP \
     --resource-group $RESOURCE_GROUP \
     --query "[?name=='SENDGRID_FROM_EMAIL'].value" \
     --output tsv | grep -q .; then
    MISSING_VARS+=("SENDGRID_FROM_EMAIL")
fi

if ! az functionapp config appsettings list \
     --name $FUNCTION_APP \
     --resource-group $RESOURCE_GROUP \
     --query "[?name=='SENDGRID_FROM_NAME'].value" \
     --output tsv | grep -q .; then
    MISSING_VARS+=("SENDGRID_FROM_NAME")
fi

if [ ${#MISSING_VARS[@]} -eq 0 ]; then
    echo "✅ Todas as variáveis SendGrid estão configuradas"
    echo ""
    echo "🤔 O erro 404 pode ter outra causa:"
    echo "   1. Método HTTP errado (deve ser POST, não GET)"
    echo "   2. Deploy desatualizado"
    echo "   3. Function Key incorreta"
    echo ""
    echo "Consulte: TROUBLESHOOTING-404.md"
else
    echo "❌ Variáveis faltando: ${MISSING_VARS[*]}"
    echo ""
    echo "⚠️ CAUSA DO 404 ENCONTRADA!"
    echo "O Spring Context falha ao inicializar sem essas variáveis."
    echo ""

    # Perguntar se quer adicionar
    read -p "Deseja adicionar as variáveis agora? (s/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo ""
        echo "📝 Insira os valores das variáveis SendGrid:"
        echo ""

        # SENDGRID_API_KEY
        if [[ " ${MISSING_VARS[*]} " =~ " SENDGRID_API_KEY " ]]; then
            echo "🔑 SENDGRID_API_KEY (começa com SG.):"
            read -r SENDGRID_API_KEY
        else
            SENDGRID_API_KEY=$(az functionapp config appsettings list \
                --name $FUNCTION_APP \
                --resource-group $RESOURCE_GROUP \
                --query "[?name=='SENDGRID_API_KEY'].value" \
                --output tsv)
        fi

        # SENDGRID_FROM_EMAIL
        if [[ " ${MISSING_VARS[*]} " =~ " SENDGRID_FROM_EMAIL " ]]; then
            echo "📧 SENDGRID_FROM_EMAIL (e-mail verificado no SendGrid):"
            read -r SENDGRID_FROM_EMAIL
        else
            SENDGRID_FROM_EMAIL=$(az functionapp config appsettings list \
                --name $FUNCTION_APP \
                --resource-group $RESOURCE_GROUP \
                --query "[?name=='SENDGRID_FROM_EMAIL'].value" \
                --output tsv)
        fi

        # SENDGRID_FROM_NAME
        if [[ " ${MISSING_VARS[*]} " =~ " SENDGRID_FROM_NAME " ]]; then
            echo "👤 SENDGRID_FROM_NAME (nome do remetente, ex: FeedbackHub):"
            read -r SENDGRID_FROM_NAME
        else
            SENDGRID_FROM_NAME=$(az functionapp config appsettings list \
                --name $FUNCTION_APP \
                --resource-group $RESOURCE_GROUP \
                --query "[?name=='SENDGRID_FROM_NAME'].value" \
                --output tsv)
        fi

        echo ""
        echo "5️⃣ Aplicando configurações..."

        az functionapp config appsettings set \
          --name $FUNCTION_APP \
          --resource-group $RESOURCE_GROUP \
          --settings \
            "SENDGRID_API_KEY=$SENDGRID_API_KEY" \
            "SENDGRID_FROM_EMAIL=$SENDGRID_FROM_EMAIL" \
            "SENDGRID_FROM_NAME=$SENDGRID_FROM_NAME" \
          --output none

        echo "✅ Variáveis aplicadas com sucesso!"
        echo ""
        echo "⏳ Aguarde 30-60 segundos para o Function App reiniciar..."
        sleep 5

        echo ""
        echo "6️⃣ Testando endpoint..."
        echo ""

        # Pegar URL e key
        FUNCTION_URL="https://${FUNCTION_APP}.azurewebsites.net/api/avaliacao"
        FUNCTION_KEY=$(az functionapp function keys list \
            --name $FUNCTION_APP \
            --resource-group $RESOURCE_GROUP \
            --function-name receberAvaliacao \
            --query "default" \
            --output tsv 2>/dev/null || echo "")

        if [ -z "$FUNCTION_KEY" ]; then
            echo "⚠️ Não foi possível obter a Function Key automaticamente"
            echo "Use este comando para testar:"
            echo ""
            echo "curl -i -X POST \"${FUNCTION_URL}?code=SUA_FUNCTION_KEY\" \\"
            echo "  -H \"Content-Type: application/json\" \\"
            echo "  -d '{\"descricao\":\"Teste\",\"nota\":8}'"
        else
            echo "Testando com curl..."
            curl -i -X POST "${FUNCTION_URL}?code=${FUNCTION_KEY}" \
              -H "Content-Type: application/json" \
              -d '{"descricao":"Teste após correção","nota":8}'

            echo ""
            echo ""
            echo "✅ Teste concluído!"
        fi
    else
        echo ""
        echo "❌ Configuração cancelada"
        echo ""
        echo "Para adicionar manualmente, execute:"
        echo ""
        echo "az functionapp config appsettings set \\"
        echo "  --name $FUNCTION_APP \\"
        echo "  --resource-group $RESOURCE_GROUP \\"
        echo "  --settings \\"
        echo "    \"SENDGRID_API_KEY=SG.sua-key\" \\"
        echo "    \"SENDGRID_FROM_EMAIL=seu-email@dominio.com\" \\"
        echo "    \"SENDGRID_FROM_NAME=FeedbackHub\""
    fi
fi

echo ""
echo "============================================="
echo "Para mais detalhes, consulte:"
echo "  - TROUBLESHOOTING-404.md"
echo "  - https://app.sendgrid.com (obter API Key)"
echo "============================================="

