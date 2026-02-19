#!/bin/bash

################################################################################
# Script de Verificação de Providers Azure
# Verifica se todos os providers necessários estão registrados
################################################################################

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Verificando Providers Azure - FeedbackHub               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

PROVIDERS=("Microsoft.Sql" "Microsoft.Storage" "Microsoft.Web" "Microsoft.Insights" "Microsoft.Communication")

ALL_READY=true

for provider in "${PROVIDERS[@]}"; do
    STATUS=$(az provider show --namespace $provider --query "registrationState" -o tsv 2>/dev/null)

    if [ "$STATUS" == "Registered" ]; then
        echo -e "${GREEN}✅ $provider: $STATUS${NC}"
    elif [ "$STATUS" == "Registering" ]; then
        echo -e "${YELLOW}⏱️  $provider: $STATUS (aguardando...)${NC}"
        ALL_READY=false
    else
        echo -e "❌ $provider: $STATUS"
        ALL_READY=false
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$ALL_READY" = true ]; then
    echo -e "${GREEN}🎉 Todos os providers estão prontos!${NC}"
    echo ""
    echo "Execute agora:"
    echo "  ./azure-setup.sh"
    echo ""
else
    echo -e "${YELLOW}⏱️  Aguarde mais um pouco (1-2 minutos) e execute este script novamente:${NC}"
    echo "  ./check-providers.sh"
    echo ""
    echo "Ou aguarde com o comando:"
    echo "  watch -n 10 './check-providers.sh'"
    echo ""
fi

