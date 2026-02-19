#!/bin/bash

################################################################################
# Script para Configurar Firewall do Azure SQL Database
# Adiciona regra para permitir acesso do IP atual
################################################################################

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Configurar Firewall do Azure SQL Database              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Configurações (ajuste conforme seu ambiente)
RESOURCE_GROUP="feedbackhub-rg"
SQL_SERVER_NAME="feedbackhub-server-55878"
RULE_NAME="AllowClientIP-$(date +%Y%m%d-%H%M%S)"

# Detectar IP público atual
echo -e "${YELLOW}1. Detectando seu IP público...${NC}"
MY_IP=$(curl -s https://api.ipify.org)

if [ -z "$MY_IP" ]; then
    echo -e "${RED}❌ Erro ao detectar IP público${NC}"
    echo -e "${YELLOW}Tentando método alternativo...${NC}"
    MY_IP=$(curl -s https://checkip.amazonaws.com)
fi

if [ -z "$MY_IP" ]; then
    echo -e "${RED}❌ Não foi possível detectar o IP automaticamente${NC}"
    echo -e "${YELLOW}Por favor, informe seu IP manualmente:${NC}"
    read -p "IP: " MY_IP
fi

echo -e "${GREEN}✅ IP detectado: ${MY_IP}${NC}"
echo ""

# Verificar se Azure CLI está instalado
echo -e "${YELLOW}2. Verificando Azure CLI...${NC}"
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI não está instalado${NC}"
    echo -e "${YELLOW}Instale com: brew install azure-cli (macOS)${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Azure CLI encontrado${NC}"
echo ""

# Verificar login no Azure
echo -e "${YELLOW}3. Verificando login no Azure...${NC}"
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Realizando login no Azure...${NC}"
    az login
fi
echo -e "${GREEN}✅ Conectado ao Azure${NC}"
echo ""

# Adicionar regra de firewall
echo -e "${YELLOW}4. Adicionando regra de firewall...${NC}"
echo -e "${BLUE}   Resource Group: ${RESOURCE_GROUP}${NC}"
echo -e "${BLUE}   SQL Server: ${SQL_SERVER_NAME}${NC}"
echo -e "${BLUE}   Rule Name: ${RULE_NAME}${NC}"
echo -e "${BLUE}   IP: ${MY_IP}${NC}"
echo ""

az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER_NAME" \
    --name "$RULE_NAME" \
    --start-ip-address "$MY_IP" \
    --end-ip-address "$MY_IP"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Regra de firewall criada com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}A regra pode levar até 5 minutos para entrar em vigor.${NC}"
    echo ""

    # Listar regras existentes
    echo -e "${YELLOW}5. Regras de firewall atuais:${NC}"
    az sql server firewall-rule list \
        --resource-group "$RESOURCE_GROUP" \
        --server "$SQL_SERVER_NAME" \
        --output table

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Configuração concluída!                                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Próximos passos:${NC}"
    echo -e "  1. Aguarde até 5 minutos"
    echo -e "  2. Tente iniciar as Azure Functions novamente: ${BLUE}mvn azure-functions:run${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Erro ao criar regra de firewall${NC}"
    echo ""
    echo -e "${YELLOW}Solução alternativa - Via Portal Azure:${NC}"
    echo -e "  1. Acesse: https://portal.azure.com"
    echo -e "  2. Navegue para: SQL Server > ${SQL_SERVER_NAME}"
    echo -e "  3. No menu lateral, clique em: ${BLUE}Security > Networking${NC}"
    echo -e "  4. Adicione uma regra de firewall:"
    echo -e "     - Nome: ${RULE_NAME}"
    echo -e "     - IP inicial: ${MY_IP}"
    echo -e "     - IP final: ${MY_IP}"
    echo -e "  5. Clique em ${BLUE}Save${NC}"
    echo ""
    exit 1
fi

