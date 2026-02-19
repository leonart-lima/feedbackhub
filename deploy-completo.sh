#!/bin/bash

################################################################################
# Script de Deploy Completo - FeedbackHub
# Este script guia você por todo o processo de deploy na Azure
################################################################################

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

clear

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║           🚀 DEPLOY COMPLETO - FEEDBACKHUB 🚀               ║"
echo "║                                                              ║"
echo "║        Deploy Automatizado para Azure Cloud                 ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# FUNÇÃO: Verificar pré-requisitos
# ============================================================================

verificar_prerequisitos() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 1: Verificando Pré-requisitos${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Java
    echo -n "Verificando Java 21... "
    if ! command -v java &> /dev/null; then
        echo -e "${RED}❌ Java não encontrado${NC}"
        echo "Instale o Java 21 primeiro."
        exit 1
    fi

    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" != "21" ]; then
        echo -e "${YELLOW}⚠️  Java $JAVA_VERSION (recomendado: Java 21)${NC}"
    else
        echo -e "${GREEN}✅ Java 21${NC}"
    fi

    # Maven
    echo -n "Verificando Maven... "
    if ! command -v mvn &> /dev/null; then
        echo -e "${RED}❌ Maven não encontrado${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Maven instalado${NC}"

    # Azure CLI
    echo -n "Verificando Azure CLI... "
    if ! command -v az &> /dev/null; then
        echo -e "${RED}❌ Azure CLI não encontrado${NC}"
        echo ""
        echo "Instale com: brew install azure-cli"
        exit 1
    fi
    echo -e "${GREEN}✅ Azure CLI instalado${NC}"

    echo ""
}

# ============================================================================
# FUNÇÃO: Login no Azure
# ============================================================================

fazer_login() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 2: Login no Azure${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Verificar se já está logado
    if az account show &> /dev/null; then
        ACCOUNT=$(az account show --query "name" -o tsv)
        echo -e "${GREEN}✅ Já está logado na conta: $ACCOUNT${NC}"
        echo ""
        read -p "Deseja fazer login novamente? (s/N): " RELOGIN
        if [[ "$RELOGIN" =~ ^[Ss]$ ]]; then
            az login
        fi
    else
        echo "Abrindo navegador para login..."
        az login
    fi

    echo ""
    echo -e "${GREEN}✅ Login realizado com sucesso!${NC}"
    echo ""
}

# ============================================================================
# FUNÇÃO: Verificar/Registrar Providers
# ============================================================================

verificar_providers() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 3: Verificando Azure Providers${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    PROVIDERS=(
        "Microsoft.Sql"
        "Microsoft.Storage"
        "Microsoft.Web"
        "Microsoft.Insights"
        "Microsoft.Communication"
        "microsoft.operationalinsights"
    )

    ALL_REGISTERED=true

    for PROVIDER in "${PROVIDERS[@]}"; do
        echo -n "  Verificando $PROVIDER... "
        STATUS=$(az provider show --namespace "$PROVIDER" --query "registrationState" -o tsv 2>/dev/null || echo "NotFound")

        if [ "$STATUS" == "Registered" ]; then
            echo -e "${GREEN}✅ Registrado${NC}"
        else
            echo -e "${YELLOW}⏳ Não registrado${NC}"
            ALL_REGISTERED=false
        fi
    done

    echo ""

    if [ "$ALL_REGISTERED" = false ]; then
        echo -e "${YELLOW}⚠️  Alguns providers não estão registrados.${NC}"
        echo ""
        read -p "Deseja registrar todos agora? (S/n): " REGISTER

        if [[ ! "$REGISTER" =~ ^[Nn]$ ]]; then
            echo ""
            echo "Registrando providers..."
            ./register-all-providers.sh
            echo ""
            echo -e "${GREEN}✅ Providers registrados! Aguarde 5-10 minutos antes de criar recursos.${NC}"
            echo ""
            read -p "Deseja continuar agora mesmo? (s/N): " CONTINUE
            if [[ ! "$CONTINUE" =~ ^[Ss]$ ]]; then
                echo ""
                echo "Execute este script novamente quando os providers estiverem prontos."
                echo "Verifique com: ./check-status.sh"
                exit 0
            fi
        fi
    else
        echo -e "${GREEN}✅ Todos os providers estão registrados!${NC}"
    fi

    echo ""
}

# ============================================================================
# FUNÇÃO: Criar recursos na Azure
# ============================================================================

criar_recursos() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 4: Criar Recursos na Azure${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Verificar se recursos já existem
    if az group show --name feedbackhub-rg &> /dev/null; then
        echo -e "${YELLOW}⚠️  Resource Group 'feedbackhub-rg' já existe.${NC}"
        echo ""
        read -p "Deseja recriar todos os recursos? Isso vai DELETAR os existentes! (s/N): " RECREATE

        if [[ "$RECREATE" =~ ^[Ss]$ ]]; then
            echo ""
            echo -e "${RED}Deletando recursos existentes...${NC}"
            az group delete --name feedbackhub-rg --yes --no-wait
            echo "Aguardando deleção (30 segundos)..."
            sleep 30
        else
            echo ""
            echo -e "${GREEN}✅ Usando recursos existentes${NC}"
            echo ""
            return
        fi
    fi

    echo -e "${YELLOW}⚠️  IMPORTANTE: Durante a execução, o script vai pausar para você${NC}"
    echo -e "${YELLOW}    configurar o domínio de e-mail manualmente no Portal Azure.${NC}"
    echo ""
    echo -e "${YELLOW}    Veja o guia: CONFIGURAR-EMAIL-DOMAIN.md${NC}"
    echo ""
    read -p "Pressione ENTER para iniciar a criação dos recursos..."

    echo ""
    echo -e "${BLUE}Criando recursos (isso pode levar 10-15 minutos)...${NC}"
    echo ""

    ./azure-setup.sh

    echo ""
    echo -e "${GREEN}✅ Recursos criados com sucesso!${NC}"
    echo ""
}

# ============================================================================
# FUNÇÃO: Build da aplicação
# ============================================================================

fazer_build() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 5: Build da Aplicação${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo "Compilando e empacotando a aplicação..."
    echo ""

    mvn clean package -DskipTests

    echo ""
    echo -e "${GREEN}✅ Build concluído com sucesso!${NC}"
    echo ""
}

# ============================================================================
# FUNÇÃO: Deploy na Azure
# ============================================================================

fazer_deploy() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 6: Deploy na Azure${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo "Fazendo deploy do Function App (3-5 minutos)..."
    echo ""

    ./deploy.sh

    echo ""
    echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
    echo ""
}

# ============================================================================
# FUNÇÃO: Obter informações de acesso
# ============================================================================

obter_informacoes() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 7: Informações de Acesso${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    FUNCTION_APP=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$FUNCTION_APP" ]; then
        echo -e "${RED}❌ Function App não encontrado${NC}"
        return
    fi

    FUNCTION_KEY=$(az functionapp keys list --name "$FUNCTION_APP" --resource-group feedbackhub-rg --query "functionKeys.default" -o tsv 2>/dev/null)

    echo -e "${GREEN}Function App:${NC} $FUNCTION_APP"
    echo -e "${GREEN}URL Base:${NC} https://${FUNCTION_APP}.azurewebsites.net"
    echo -e "${GREEN}Function Key:${NC} $FUNCTION_KEY"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}  Endpoint Principal:${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "POST https://${FUNCTION_APP}.azurewebsites.net/api/avaliacao?code=${FUNCTION_KEY}"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}  Exemplo de Teste com cURL:${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "curl -X POST \"https://${FUNCTION_APP}.azurewebsites.net/api/avaliacao?code=${FUNCTION_KEY}\" \\"
    echo "  -H \"Content-Type: application/json\" \\"
    echo "  -d '{\"descricao\": \"Teste de deploy\", \"nota\": 9}'"
    echo ""
}

# ============================================================================
# FUNÇÃO: Testar aplicação
# ============================================================================

testar_aplicacao() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ETAPA 8: Testar Aplicação${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    read -p "Deseja testar a aplicação agora? (S/n): " TESTAR

    if [[ "$TESTAR" =~ ^[Nn]$ ]]; then
        return
    fi

    FUNCTION_APP=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv 2>/dev/null)
    FUNCTION_KEY=$(az functionapp keys list --name "$FUNCTION_APP" --resource-group feedbackhub-rg --query "functionKeys.default" -o tsv 2>/dev/null)

    echo ""
    echo "Enviando avaliação de teste..."
    echo ""

    RESPONSE=$(curl -s -X POST "https://${FUNCTION_APP}.azurewebsites.net/api/avaliacao?code=${FUNCTION_KEY}" \
      -H "Content-Type: application/json" \
      -d '{"descricao": "Teste de deploy automatizado", "nota": 9}')

    echo -e "${GREEN}Resposta:${NC}"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
    echo ""

    echo -e "${GREEN}✅ Teste concluído!${NC}"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    verificar_prerequisitos
    fazer_login
    verificar_providers
    criar_recursos
    fazer_build
    fazer_deploy
    obter_informacoes
    testar_aplicacao

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           ✅ DEPLOY CONCLUÍDO COM SUCESSO! ✅               ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}🎉 Sua aplicação está rodando na Azure!${NC}"
    echo ""
    echo "📋 Próximos passos:"
    echo "  • Veja as credenciais em: azure-credentials.txt"
    echo "  • Ver logs ao vivo: az webapp log tail --name <function-app> --resource-group feedbackhub-rg"
    echo "  • Portal Azure: https://portal.azure.com"
    echo "  • Documentação completa: GUIA-DEPLOY-CLOUD.md"
    echo ""
}

# Executar
main

