#!/bin/bash

echo "🔬 Configurando Log Analytics para FeedbackHub"
echo "=============================================="
echo ""

# Variáveis
RESOURCE_GROUP="feedbackhub-rg"
FUNCTION_APP="feedbackhub-func-55878"
APP_INSIGHTS="feedbackhub-insights"
LOCATION="eastus"

# Login
echo "1️⃣ Fazendo login no Azure..."
az login --output none
if [ $? -ne 0 ]; then
    echo "❌ Erro no login. Execute manualmente: az login"
    exit 1
fi
echo "✅ Login realizado"
echo ""

# Verificar se já existe
echo "2️⃣ Verificando se Application Insights já existe..."
EXISTING=$(az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP 2>/dev/null)

if [ -n "$EXISTING" ]; then
    echo "✅ Application Insights já existe: $APP_INSIGHTS"
else
    echo "📦 Criando Application Insights..."
    az monitor app-insights component create \
      --app $APP_INSIGHTS \
      --location $LOCATION \
      --resource-group $RESOURCE_GROUP \
      --application-type web \
      --kind web \
      --output none

    if [ $? -eq 0 ]; then
        echo "✅ Application Insights criado: $APP_INSIGHTS"
    else
        echo "❌ Erro ao criar Application Insights"
        exit 1
    fi
fi
echo ""

# Obter Instrumentation Key
echo "3️⃣ Obtendo Instrumentation Key..."
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey \
  --output tsv)

if [ -z "$INSTRUMENTATION_KEY" ]; then
    echo "❌ Erro: Não foi possível obter Instrumentation Key"
    exit 1
fi

echo "✅ Instrumentation Key obtido: ${INSTRUMENTATION_KEY:0:20}..."
echo ""

# Obter Connection String
echo "4️⃣ Obtendo Connection String..."
CONNECTION_STRING=$(az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP \
  --query connectionString \
  --output tsv)

echo "✅ Connection String obtido"
echo ""

# Configurar Function App
echo "5️⃣ Configurando Function App..."
az functionapp config appsettings set \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --settings \
    "APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY" \
    "APPLICATIONINSIGHTS_CONNECTION_STRING=$CONNECTION_STRING" \
    "ApplicationInsightsAgent_EXTENSION_VERSION=~3" \
  --output none

if [ $? -eq 0 ]; then
    echo "✅ Function App configurado"
else
    echo "❌ Erro ao configurar Function App"
    exit 1
fi
echo ""

# Reiniciar
echo "6️⃣ Reiniciando Function App..."
az functionapp restart \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --output none

if [ $? -eq 0 ]; then
    echo "✅ Function App reiniciado"
else
    echo "⚠️ Aviso: Erro ao reiniciar Function App (pode não ser crítico)"
fi
echo ""

echo "🎉 Log Analytics configurado com sucesso!"
echo ""
echo "📊 Para ver os logs:"
echo "   1. Acesse: https://portal.azure.com"
echo "   2. Navegue: Application Insights → $APP_INSIGHTS"
echo "   3. Menu lateral → Logs"
echo ""
echo "💡 Aguarde 5-10 minutos para os primeiros logs aparecerem"
echo ""
echo "🧪 Para testar agora:"
echo "   1. Execute: mvn azure-functions:run"
echo "   2. Em outro terminal:"
echo "      curl -X POST \"http://localhost:7071/api/avaliacao\" \\"
echo "        -H \"Content-Type: application/json\" \\"
echo "        -d '{\"descricao\": \"Teste Log Analytics\", \"nota\": 1}'"
echo ""
echo "📝 Queries úteis em: COMO-ATIVAR-LOG-ANALYTICS.md"
echo ""

