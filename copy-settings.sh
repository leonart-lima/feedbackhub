#!/bin/bash
echo "🔄 Copiando configurações do feedbackhub-func-55878 para feedbackhub-func..."
# Exportar configurações do Function App antigo
echo "Exportando configurações..."
az functionapp config appsettings list \
  --name feedbackhub-func-55878 \
  --resource-group feedbackhub-rg \
  -o json > old-settings.json
# Filtrar apenas as configurações da aplicação
cat old-settings.json | jq -r '.[] | select(.name | test("^(DB_|AZURE_STORAGE_CONNECTION|AZURE_COMMUNICATION|ADMIN_|REPORT_|WEBSITE_TIME)")) | "--settings \(.name)=\"\(.value)\""' > settings-to-copy.txt
echo "✅ Configurações exportadas!"
cat settings-to-copy.txt
