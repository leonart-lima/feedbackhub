#!/bin/bash

################################################################################
# Script de Deploy Automatizado - FeedbackHub
# Descobre o Function App automaticamente e faz o deploy
################################################################################

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           Deploy Automatizado - FeedbackHub                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# DESCOBRIR FUNCTION APP
# ============================================================================

echo -e "${BLUE}1/3 - Descobrindo Function App...${NC}"
echo ""

FUNCTION_APP_NAME=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv 2>/dev/null)

if [ -z "$FUNCTION_APP_NAME" ]; then
    echo -e "${RED}❌ Nenhum Function App encontrado no grupo 'feedbackhub-rg'${NC}"
    echo ""
    echo "Execute primeiro:"
    echo "  ./create-function-app-only.sh"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Function App encontrado: $FUNCTION_APP_NAME${NC}"
echo ""

# ============================================================================
# ATUALIZAR POM.XML TEMPORARIAMENTE
# ============================================================================

echo -e "${BLUE}2/3 - Preparando configuração...${NC}"
echo ""

# Criar backup do pom.xml
cp pom.xml pom.xml.backup

# Atualizar o nome do Function App no pom.xml
sed -i.tmp "s/<functionAppName>.*<\/functionAppName>/<functionAppName>$FUNCTION_APP_NAME<\/functionAppName>/" pom.xml
rm -f pom.xml.tmp

echo -e "${GREEN}✅ Configuração atualizada${NC}"
echo ""

# ============================================================================
# FAZER DEPLOY
# ============================================================================

echo -e "${BLUE}3/3 - Fazendo deploy...${NC}"
echo ""
echo -e "${YELLOW}Este passo pode demorar 3-5 minutos...${NC}"
echo ""

mvn clean package azure-functions:deploy

# ============================================================================
# RESTAURAR POM.XML
# ============================================================================

echo ""
echo -e "${BLUE}Restaurando pom.xml...${NC}"
mv pom.xml.backup pom.xml
echo -e "${GREEN}✅ pom.xml restaurado${NC}"
echo ""

# ============================================================================
# RESUMO
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ DEPLOY CONCLUÍDO COM SUCESSO!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Function App: $FUNCTION_APP_NAME"
echo "URL: https://${FUNCTION_APP_NAME}.azurewebsites.net"
echo ""
echo "Funções deployadas:"
echo "  - receberAvaliacao (HTTP POST /api/avaliacao)"
echo "  - notificarUrgencia (Queue Trigger)"
echo "  - gerarRelatorioSemanal (Timer Trigger)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PRÓXIMOS PASSOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Obter Function Key:"
echo "   az functionapp keys list --name $FUNCTION_APP_NAME --resource-group feedbackhub-rg"
echo ""
echo "2️⃣  Configurar domínio de e-mail:"
echo "   (Ver: REFERENCIA-RAPIDA-EMAIL.md)"
echo ""
echo "3️⃣  Testar a API:"
echo "   FUNC_KEY=\$(az functionapp keys list --name $FUNCTION_APP_NAME --resource-group feedbackhub-rg --query 'functionKeys.default' -o tsv)"
echo "   curl -X POST \"https://${FUNCTION_APP_NAME}.azurewebsites.net/api/avaliacao?code=\$FUNC_KEY\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"descricao\": \"Teste\", \"nota\": 9}'"
echo ""
echo "4️⃣  Ver logs:"
echo "   az functionapp log tail --name $FUNCTION_APP_NAME --resource-group feedbackhub-rg"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

