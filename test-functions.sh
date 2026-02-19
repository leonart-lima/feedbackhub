#!/bin/bash

################################################################################
# Script de Teste - Azure Functions FeedbackHub
# Testa todas as funções HTTP do sistema
################################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
FUNCTION_URL="${FUNCTION_URL:-http://localhost:7071}"
FUNCTION_KEY="${FUNCTION_KEY:-}"

# Adiciona code parameter se houver key
if [ -n "$FUNCTION_KEY" ]; then
    CODE_PARAM="?code=${FUNCTION_KEY}"
else
    CODE_PARAM=""
fi

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Testando Azure Functions - FeedbackHub                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}URL Base:${NC} $FUNCTION_URL"
echo ""

# Contador de testes
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para testar endpoint
test_endpoint() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_status=$5

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Teste $TOTAL_TESTS: $test_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -n "$data" ]; then
        echo -e "${YELLOW}Request:${NC}"
        echo "$data" | jq '.' 2>/dev/null || echo "$data"
        echo ""

        response=$(curl -s -w "\n%{http_code}" -X $method \
            "${FUNCTION_URL}${endpoint}${CODE_PARAM}" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method \
            "${FUNCTION_URL}${endpoint}${CODE_PARAM}" \
            -H "Accept: application/json")
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    echo -e "${YELLOW}Status Code:${NC} $http_code"
    echo -e "${YELLOW}Response:${NC}"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
    echo ""

    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FALHOU (esperado: $expected_status, recebido: $http_code)${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

################################################################################
# TESTES - Receber Avaliação
################################################################################

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Testando: POST /api/avaliacao                           ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Teste 1: Avaliação Crítica
test_endpoint \
    "Avaliação CRÍTICA (nota 2)" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Aula muito confusa, não consegui entender o conteúdo. Professor explicou muito rápido e não respondeu dúvidas.", "nota": 2}' \
    200

sleep 1

# Teste 2: Avaliação Média
test_endpoint \
    "Avaliação MÉDIA (nota 5)" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Aula razoável, mas poderia ter mais exemplos práticos e exercícios.", "nota": 5}' \
    200

sleep 1

# Teste 3: Avaliação Positiva
test_endpoint \
    "Avaliação POSITIVA (nota 9)" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Excelente aula! Conteúdo muito bem explicado, com ótimos exemplos e exercícios práticos.", "nota": 9}' \
    200

sleep 1

# Teste 4: Nota máxima
test_endpoint \
    "Avaliação POSITIVA (nota 10)" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Perfeito! Melhor aula do curso!", "nota": 10}' \
    200

sleep 1

# Teste 5: Nota mínima
test_endpoint \
    "Avaliação CRÍTICA (nota 0)" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Péssima aula, não aprendi nada.", "nota": 0}' \
    200

sleep 1

################################################################################
# TESTES DE VALIDAÇÃO
################################################################################

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Testando: Validações                                    ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Teste 6: Nota acima do limite
test_endpoint \
    "Validação: Nota acima de 10" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Teste", "nota": 15}' \
    400

sleep 1

# Teste 7: Nota negativa
test_endpoint \
    "Validação: Nota negativa" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Teste", "nota": -5}' \
    400

sleep 1

# Teste 8: Campo descrição ausente
test_endpoint \
    "Validação: Descrição ausente" \
    "POST" \
    "/api/avaliacao" \
    '{"nota": 8}' \
    400

sleep 1

# Teste 9: Campo nota ausente
test_endpoint \
    "Validação: Nota ausente" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Teste sem nota"}' \
    400

sleep 1

# Teste 10: Corpo vazio
test_endpoint \
    "Validação: Corpo vazio" \
    "POST" \
    "/api/avaliacao" \
    '' \
    400

sleep 1

# Teste 11: Descrição vazia
test_endpoint \
    "Validação: Descrição vazia" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "", "nota": 8}' \
    400

sleep 1

################################################################################
# TESTES - Relatório Manual
################################################################################

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Testando: GET /api/relatorio/manual                     ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Teste 12: Gerar relatório via GET
test_endpoint \
    "Gerar relatório via GET" \
    "GET" \
    "/api/relatorio/manual" \
    "" \
    200

sleep 1

# Teste 13: Gerar relatório via POST
test_endpoint \
    "Gerar relatório via POST" \
    "POST" \
    "/api/relatorio/manual" \
    "" \
    200

sleep 1

################################################################################
# TESTES COM CARACTERES ESPECIAIS
################################################################################

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Testando: Caracteres Especiais                          ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Teste 14: Caracteres especiais
test_endpoint \
    "Avaliação com caracteres especiais" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Aula sobre Java & Spring Boot - conceitos de @Annotations e <generics>. Excelente! 👍🎓", "nota": 10}' \
    200

sleep 1

# Teste 15: Texto longo
test_endpoint \
    "Avaliação com texto longo" \
    "POST" \
    "/api/avaliacao" \
    '{"descricao": "Esta é uma avaliação muito detalhada sobre a aula. O professor abordou diversos tópicos importantes, incluindo conceitos básicos e avançados. A didática foi excelente, com exemplos práticos que ajudaram muito no entendimento. Os exercícios propostos foram desafiadores mas alcançáveis. No geral, foi uma experiência de aprendizado muito positiva e recomendo para todos os interessados no assunto.", "nota": 9}' \
    200

################################################################################
# RESUMO
################################################################################

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                   RESUMO DOS TESTES                      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Total de testes:${NC} $TOTAL_TESTS"
echo -e "${GREEN}Testes passados:${NC} $PASSED_TESTS"
echo -e "${RED}Testes falhados:${NC} $FAILED_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ TODOS OS TESTES PASSARAM!${NC}"
    exit 0
else
    echo -e "${RED}❌ ALGUNS TESTES FALHARAM${NC}"
    exit 1
fi

