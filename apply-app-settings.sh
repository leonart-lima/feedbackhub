#!/bin/bash

# Script to apply app settings from app-settings.json to Azure Function App
# Run this once to configure the Function App with all required settings

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

FUNCTION_APP_NAME="feedbackhub-func"
RESOURCE_GROUP="feedbackhub-rg"

echo -e "${YELLOW}Applying App Settings to Azure Function App...${NC}"
echo ""

# Check if logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Logging in...${NC}"
    az login
fi

echo "Current subscription:"
az account show --query "{Name:name, SubscriptionId:id}" -o table
echo ""

# Read settings from app-settings.json
if [ ! -f "app-settings.json" ]; then
    echo -e "${RED}Error: app-settings.json not found!${NC}"
    exit 1
fi

echo -e "${YELLOW}Applying settings from app-settings.json...${NC}"

# Apply all settings at once
az functionapp config appsettings set \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
    DB_URL="jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    DB_USERNAME="azureuser" \
    DB_PASSWORD="FeedbackHub@2026!" \
    AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=feedbackhubst1455878;AccountKey=ST/ty25cuNJ3ON610VI6EgFl5+Q4BZEUzSWatrSHG2xvzes0ZGMfUnezYB8VNa+qzNJXNbfDvQ8C+AStaP/b1A==;BlobEndpoint=https://feedbackhubst1455878.blob.core.windows.net/;FileEndpoint=https://feedbackhubst1455878.file.core.windows.net/;QueueEndpoint=https://feedbackhubst1455878.queue.core.windows.net/;TableEndpoint=https://feedbackhubst1455878.table.core.windows.net/" \
    AZURE_COMMUNICATION_CONNECTION_STRING="endpoint=https://feedbackhub-comm-55878.unitedstates.communication.azure.com/;accesskey=C7nAGjIV2yrUTzr3ptarTu7YBLkcmDbl4r3262ONS4dMgDdeEUuZJQQJ99CBACULyCp4YGpdAAAAAZCSqpwI" \
    AZURE_COMMUNICATION_FROM_EMAIL="DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net" \
    ADMIN_EMAILS="admin@example.com" \
    REPORT_EMAILS="reports@example.com" \
    WEBSITE_TIME_ZONE="E. South America Standard Time" \
    FUNCTIONS_WORKER_RUNTIME="java" \
    FUNCTIONS_EXTENSION_VERSION="~4" \
    > /dev/null

echo -e "${GREEN}✓ App settings applied successfully!${NC}"
echo ""

echo -e "${YELLOW}Verifying settings...${NC}"
az functionapp config appsettings list \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, Value:value}" \
    -o table | grep -E "(DB_|AZURE_|ADMIN_|REPORT_|WEBSITE_TIME_ZONE|FUNCTIONS_)"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}SUCCESS! All app settings have been applied.${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "These settings will persist across all deployments."
echo "You can now deploy using GitHub Actions without syncing settings."
echo ""

