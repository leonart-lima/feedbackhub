#!/bin/bash
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Status dos Providers Azure                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
ALL_READY=true
check_provider() {
    local provider=$1
    local status=$(az provider show --namespace $provider --query "registrationState" -o tsv 2>/dev/null)
    if [ "$status" == "Registered" ]; then
        echo "✅ $provider: Registered"
    elif [ "$status" == "Registering" ]; then
        echo "⏱️  $provider: Registering (aguardando...)"
        ALL_READY=false
    else
        echo "❌ $provider: $status"
        ALL_READY=false
    fi
}
check_provider "Microsoft.Sql"
check_provider "Microsoft.Storage"
check_provider "Microsoft.Web"
check_provider "Microsoft.Insights"
check_provider "microsoft.operationalinsights"
check_provider "Microsoft.Communication"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ "$ALL_READY" = true ]; then
    echo "🎉 Todos os providers estão prontos!"
    echo ""
    echo "Execute agora: ./azure-setup.sh"
else
    echo "⏱️  Aguarde mais um pouco e execute: bash check-status.sh"
fi
echo ""
