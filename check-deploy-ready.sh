#!/bin/bash

# Script de verificação pré-deploy
# Valida se tudo está configurado corretamente antes do primeiro deploy

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     🔍 VERIFICAÇÃO PRÉ-DEPLOY - FEEDBACKHUB              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
checks_passed=0
checks_failed=0
checks_total=0

check_item() {
    checks_total=$((checks_total + 1))
    local description=$1
    local command=$2

    echo -n "[$checks_total] $description... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        checks_passed=$((checks_passed + 1))
        return 0
    else
        echo -e "${RED}❌${NC}"
        checks_failed=$((checks_failed + 1))
        return 1
    fi
}

check_file() {
    checks_total=$((checks_total + 1))
    local description=$1
    local file=$2

    echo -n "[$checks_total] $description... "

    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC}"
        checks_passed=$((checks_passed + 1))
        return 0
    else
        echo -e "${RED}❌${NC}"
        checks_failed=$((checks_failed + 1))
        return 1
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 VERIFICANDO ARQUIVOS LOCAIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_file "Arquivo pom.xml existe" "pom.xml"
check_file "Workflow GitHub Actions existe" ".github/workflows/deploy.yml"
check_file "Host.json existe" "host.json"
check_file "Script get-publish-profile.sh existe" "get-publish-profile.sh"
check_file "Script deploy-commands.sh existe" "deploy-commands.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️ VERIFICANDO FERRAMENTAS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_item "Git instalado" "command -v git"
check_item "Maven instalado" "command -v mvn"
check_item "Azure CLI instalado" "command -v az"
check_item "Java instalado" "command -v java"

if command -v java > /dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" = "21" ]; then
        echo "   └─ Java 21 ✅"
    else
        echo -e "   └─ ${YELLOW}⚠️  Java $JAVA_VERSION (recomendado: 21)${NC}"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 VERIFICANDO AZURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_item "Autenticado no Azure CLI" "az account show"

if az account show > /dev/null 2>&1; then
    ACCOUNT_NAME=$(az account show --query "name" -o tsv)
    echo "   └─ Conta: $ACCOUNT_NAME"

    echo ""
    check_item "Resource Group existe" "az group show --name feedbackhub-rg"
    check_item "Function App existe" "az functionapp show --name feedbackhub-func --resource-group feedbackhub-rg"
    check_item "SQL Server existe" "az sql server show --name feedbackhub-server --resource-group feedbackhub-rg"
    check_item "Storage Account existe" "az storage account show --name feedbackhubstorage --resource-group feedbackhub-rg"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 VERIFICANDO BUILD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Executando build Maven (isso pode demorar alguns minutos)..."
if mvn clean package -DskipTests > /dev/null 2>&1; then
    echo -e "[$((checks_total + 1))] Build Maven... ${GREEN}✅${NC}"
    checks_passed=$((checks_passed + 1))
    checks_total=$((checks_total + 1))

    if [ -d "target/azure-functions/feedbackhub-func" ]; then
        echo -e "[$((checks_total + 1))] Diretório de deploy existe... ${GREEN}✅${NC}"
        checks_passed=$((checks_passed + 1))
        checks_total=$((checks_total + 1))
    else
        echo -e "[$((checks_total + 1))] Diretório de deploy existe... ${RED}❌${NC}"
        checks_failed=$((checks_failed + 1))
        checks_total=$((checks_total + 1))
    fi
else
    echo -e "[$((checks_total + 1))] Build Maven... ${RED}❌${NC}"
    checks_failed=$((checks_failed + 1))
    checks_total=$((checks_total + 1))
    echo -e "${YELLOW}⚠️  Execute 'mvn clean package' para ver os erros${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔗 VERIFICANDO GIT E GITHUB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_item "Repositório Git inicializado" "git rev-parse --git-dir"

if git rev-parse --git-dir > /dev/null 2>&1; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
    echo "   └─ Branch atual: $CURRENT_BRANCH"

    if git remote -v | grep -q "github.com"; then
        echo -e "[$((checks_total + 1))] Remote GitHub configurado... ${GREEN}✅${NC}"
        checks_passed=$((checks_passed + 1))
        checks_total=$((checks_total + 1))

        REMOTE_URL=$(git remote get-url origin 2>/dev/null)
        echo "   └─ Remote: $REMOTE_URL"
    else
        echo -e "[$((checks_total + 1))] Remote GitHub configurado... ${RED}❌${NC}"
        checks_failed=$((checks_failed + 1))
        checks_total=$((checks_total + 1))
        echo -e "${YELLOW}⚠️  Configure o remote: git remote add origin <URL>${NC}"
    fi
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                     📊 RESULTADO FINAL                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

PERCENTAGE=$((checks_passed * 100 / checks_total))

echo "Total de verificações: $checks_total"
echo -e "Passou: ${GREEN}$checks_passed ✅${NC}"
echo -e "Falhou: ${RED}$checks_failed ❌${NC}"
echo "Percentual de sucesso: $PERCENTAGE%"
echo ""

if [ $checks_failed -eq 0 ]; then
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo -e "║  ${GREEN}✅ TUDO PRONTO PARA DEPLOY AUTOMÁTICO! ✅${NC}              ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo "📋 Próximos passos:"
    echo ""
    echo "1️⃣  Obter Publish Profile:"
    echo "    ./get-publish-profile.sh"
    echo ""
    echo "2️⃣  Configurar Secrets no GitHub:"
    echo "    GitHub → Settings → Secrets and variables → Actions"
    echo "    - AZURE_FUNCTIONAPP_PUBLISH_PROFILE"
    echo "    - DB_URL, DB_USERNAME, DB_PASSWORD"
    echo "    - AZURE_STORAGE_CONNECTION_STRING"
    echo "    - SENDGRID_API_KEY"
    echo "    - ADMIN_EMAILS, REPORT_EMAILS"
    echo ""
    echo "3️⃣  Fazer push e testar:"
    echo "    git add ."
    echo "    git commit -m \"test: deploy automático\""
    echo "    git push origin main"
    echo ""
    echo "📚 Documentação: DEPLOY-AUTOMATICO-QUICKSTART.md"
    echo ""
    exit 0
else
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo -e "║  ${YELLOW}⚠️  ALGUMAS VERIFICAÇÕES FALHARAM${NC}                    ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo "Por favor, resolva os problemas acima antes de continuar."
    echo ""
    echo "📚 Consulte a documentação:"
    echo "   - CONFIGURAR-DEPLOY-AUTOMATICO.md"
    echo "   - TROUBLESHOOTING.md"
    echo ""
    exit 1
fi

