#!/bin/bash

# Script to fix WEBSITE_RUN_FROM_PACKAGE deployment issue
# This removes the WEBSITE_RUN_FROM_PACKAGE setting that conflicts with zip deployment

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FUNCTION_APP_NAME="feedbackhub-func"
RESOURCE_GROUP="feedbackhub-rg"

echo -e "${YELLOW}Fixing WEBSITE_RUN_FROM_PACKAGE deployment issue...${NC}"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Logging in...${NC}"
    az login
fi

echo "Current subscription:"
az account show --query "{Name:name, SubscriptionId:id}" -o table
echo ""

echo -e "${YELLOW}Step 1: Checking current WEBSITE_RUN_FROM_PACKAGE setting...${NC}"
CURRENT_VALUE=$(az functionapp config appsettings list \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?name=='WEBSITE_RUN_FROM_PACKAGE'].value" \
    -o tsv 2>/dev/null || echo "")

if [ -z "$CURRENT_VALUE" ]; then
    echo -e "${GREEN}✓ WEBSITE_RUN_FROM_PACKAGE is not set. Nothing to fix!${NC}"
    exit 0
fi

echo -e "${YELLOW}Current value: $CURRENT_VALUE${NC}"
echo ""

echo -e "${YELLOW}Step 2: Removing WEBSITE_RUN_FROM_PACKAGE setting...${NC}"
az functionapp config appsettings delete \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --setting-names WEBSITE_RUN_FROM_PACKAGE

echo -e "${GREEN}✓ Successfully removed WEBSITE_RUN_FROM_PACKAGE${NC}"
echo ""

echo -e "${YELLOW}Step 3: Verifying the setting was removed...${NC}"
VERIFY_VALUE=$(az functionapp config appsettings list \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?name=='WEBSITE_RUN_FROM_PACKAGE'].value" \
    -o tsv 2>/dev/null || echo "")

if [ -z "$VERIFY_VALUE" ]; then
    echo -e "${GREEN}✓ Verified: WEBSITE_RUN_FROM_PACKAGE has been removed${NC}"
else
    echo -e "${RED}✗ Warning: Setting still exists with value: $VERIFY_VALUE${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}SUCCESS! The deployment issue has been fixed.${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "You can now:"
echo "1. Re-run your GitHub Actions workflow"
echo "2. Or deploy manually using: ./deploy.sh"
echo ""

