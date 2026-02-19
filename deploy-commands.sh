#!/bin/bash

# 🚀 COMANDOS RÁPIDOS - DEPLOY AUTOMÁTICO
# Referência rápida de comandos para CI/CD com GitHub Actions

echo "=================================================="
echo "🚀 Deploy Automático - Comandos Rápidos"
echo "=================================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Menu
show_section "📋 O QUE VOCÊ QUER FAZER?"

echo "1. 🔐 Obter Publish Profile do Azure"
echo "2. 📊 Ver status do último deploy"
echo "3. 🧪 Testar deploy local"
echo "4. 🚀 Fazer deploy manual (push)"
echo "5. 📝 Ver logs do Azure"
echo "6. 🔍 Verificar Function App no Azure"
echo "7. 🌐 Testar API no Azure"
echo "8. 📚 Abrir documentação"
echo "9. ❌ Sair"
echo ""

read -p "Escolha uma opção (1-9): " option

case $option in
    1)
        show_section "🔐 Obtendo Publish Profile"
        echo "Executando: ./get-publish-profile.sh"
        ./get-publish-profile.sh
        ;;

    2)
        show_section "📊 Status do Último Deploy"
        echo "Para ver no GitHub Actions:"
        echo "https://github.com/YOUR_USERNAME/feedbackhub/actions"
        echo ""
        echo "Verificando status no Azure..."
        az functionapp show \
            --name feedbackhub-func \
            --resource-group feedbackhub-rg \
            --query "{name:name, state:state, hostNames:defaultHostName}" \
            -o table
        ;;

    3)
        show_section "🧪 Testando Build Local"
        echo "Executando: mvn clean package"
        mvn clean package
        echo ""
        echo "✅ Build local concluído!"
        echo "Se passou, o deploy no GitHub também deve passar."
        ;;

    4)
        show_section "🚀 Deploy Manual (Push)"
        echo "Este comando fará commit e push, disparando o deploy automático."
        echo ""
        read -p "Mensagem do commit: " commit_msg

        if [ -z "$commit_msg" ]; then
            commit_msg="deploy: atualização automática"
        fi

        echo ""
        echo "Executando:"
        echo "  git add ."
        echo "  git commit -m \"$commit_msg\""
        echo "  git push origin main"
        echo ""
        read -p "Confirmar? (s/n): " confirm

        if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
            git add .
            git commit -m "$commit_msg"
            git push origin main
            echo ""
            echo "✅ Push realizado! Deploy automático iniciado."
            echo "Acompanhe em: https://github.com/YOUR_USERNAME/feedbackhub/actions"
        else
            echo "❌ Cancelado"
        fi
        ;;

    5)
        show_section "📝 Logs do Azure"
        echo "Mostrando logs em tempo real..."
        echo "Pressione Ctrl+C para sair"
        echo ""
        az functionapp log tail \
            --name feedbackhub-func \
            --resource-group feedbackhub-rg
        ;;

    6)
        show_section "🔍 Verificando Function App"
        echo "Detalhes da Function App:"
        echo ""
        az functionapp show \
            --name feedbackhub-func \
            --resource-group feedbackhub-rg \
            --query "{Name:name, State:state, URL:defaultHostName, Location:location, Runtime:siteConfig.linuxFxVersion}" \
            -o table
        echo ""
        echo "Application Settings:"
        az functionapp config appsettings list \
            --name feedbackhub-func \
            --resource-group feedbackhub-rg \
            --query "[].{Name:name, Value:value}" \
            -o table
        ;;

    7)
        show_section "🌐 Testando API"
        BASE_URL="https://feedbackhub-func.azurewebsites.net"

        echo "Testando endpoints..."
        echo ""

        echo "1️⃣ GET /api/avaliacoes"
        curl -s "$BASE_URL/api/avaliacoes" | jq '.' 2>/dev/null || curl -s "$BASE_URL/api/avaliacoes"
        echo ""
        echo ""

        echo "2️⃣ GET /api/avaliacoes/urgencia/ALTA"
        curl -s "$BASE_URL/api/avaliacoes/urgencia/ALTA" | jq '.' 2>/dev/null || curl -s "$BASE_URL/api/avaliacoes/urgencia/ALTA"
        echo ""
        echo ""

        echo "3️⃣ GET /api/relatorio/manual (se disponível)"
        curl -s "$BASE_URL/api/relatorio/manual" | jq '.' 2>/dev/null || curl -s "$BASE_URL/api/relatorio/manual"
        echo ""
        ;;

    8)
        show_section "📚 Documentação"
        echo "Abrindo documentos principais..."
        echo ""
        echo "Guias disponíveis:"
        echo "  📖 CONFIGURAR-DEPLOY-AUTOMATICO.md - Guia completo"
        echo "  ⚡ DEPLOY-AUTOMATICO-QUICKSTART.md - Quick start"
        echo "  📊 DEPLOY-AUTOMATICO-RESUMO.md - Resumo"
        echo ""

        if command -v open &> /dev/null; then
            read -p "Abrir DEPLOY-AUTOMATICO-QUICKSTART.md? (s/n): " open_doc
            if [ "$open_doc" = "s" ] || [ "$open_doc" = "S" ]; then
                open DEPLOY-AUTOMATICO-QUICKSTART.md
            fi
        else
            echo "Use seu editor favorito para abrir os arquivos."
        fi
        ;;

    9)
        echo "👋 Até logo!"
        exit 0
        ;;

    *)
        echo "❌ Opção inválida"
        ;;
esac

echo ""
echo "=================================================="
echo "✅ Operação concluída"
echo "=================================================="
echo ""

