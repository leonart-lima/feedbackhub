#!/bin/bash

################################################################################
# Script para Registrar TODOS os Providers Azure Necessários
# Execute este script UMA vez e aguarde a conclusão
################################################################################

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Registrando TODOS os Providers Azure Necessários        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

PROVIDERS=(
    "Microsoft.Sql"
    "Microsoft.Storage"
    "Microsoft.Web"
    "Microsoft.Insights"
    "microsoft.operationalinsights"
    "Microsoft.Communication"
)

echo -e "${BLUE}Registrando providers...${NC}"
echo ""

for provider in "${PROVIDERS[@]}"; do
    echo -e "⏳ Registrando $provider..."
    az provider register --namespace $provider 2>&1 | grep -v "Registering is still on-going"
done

echo ""
echo -e "${GREEN}✅ Todos os comandos de registro foram enviados!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}⏱️  Aguarde 2-3 minutos para os registros serem processados...${NC}"
echo ""
echo "Para verificar o status:"
echo "  bash check-status.sh"
echo ""
echo "Ou aguarde automaticamente (trava até completar):"
echo "  az provider register --namespace Microsoft.Sql --wait"
echo ""

