#!/bin/bash
# COMANDOS RÁPIDOS - SENDGRID

echo "=========================================="
echo "   COMANDOS RÁPIDOS - SendGrid"
echo "=========================================="
echo ""

# 1. Compilar
echo "1️⃣  COMPILAR PROJETO:"
echo "   mvn clean package -DskipTests"
echo ""

# 2. Configurar Azure
echo "2️⃣  CONFIGURAR AZURE (Script Interativo):"
echo "   ./configure-sendgrid.sh"
echo ""

# 3. Configurar Azure Manual
echo "3️⃣  CONFIGURAR AZURE (Manual):"
cat << 'EOF'
   az functionapp config appsettings set \
     --name feedbackhub-func \
     --resource-group feedbackhub-rg \
     --settings \
     "SENDGRID_API_KEY=SG.sua-api-key" \
     "SENDGRID_FROM_EMAIL=seu-email@gmail.com" \
     "SENDGRID_FROM_NAME=FeedbackHub" \
     "ADMIN_EMAILS=leonart16@gmail.com" \
     "REPORT_EMAILS=leonart16@gmail.com"
EOF
echo ""

# 4. Deploy
echo "4️⃣  FAZER DEPLOY:"
echo "   mvn azure-functions:deploy"
echo ""

# 5. Ver Logs
echo "5️⃣  VER LOGS EM TEMPO REAL:"
cat << 'EOF'
   az functionapp log tail \
     --name feedbackhub-func \
     --resource-group feedbackhub-rg
EOF
echo ""

# 6. Testar API
echo "6️⃣  TESTAR API (Avaliação Crítica):"
cat << 'EOF'
   curl -X POST https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao \
     -H "Content-Type: application/json" \
     -d '{
       "avaliacaoId": 999,
       "nota": 2,
       "comentario": "TESTE - Serviço péssimo!",
       "nomeCliente": "João Teste",
       "emailCliente": "joao@teste.com",
       "dataAvaliacao": "2026-02-19T10:00:00"
     }'
EOF
echo ""

# 7. Testar Relatório
echo "7️⃣  TESTAR RELATÓRIO MANUAL:"
echo "   curl -X POST https://feedbackhub-func.azurewebsites.net/api/gerarRelatorioManual"
echo ""

# 8. Verificar Configurações
echo "8️⃣  VERIFICAR CONFIGURAÇÕES NO AZURE:"
cat << 'EOF'
   az functionapp config appsettings list \
     --name feedbackhub-func \
     --resource-group feedbackhub-rg \
     --query "[?contains(name, 'SENDGRID')].{Name:name, Value:value}" \
     --output table
EOF
echo ""

# 9. Links Úteis
echo "9️⃣  LINKS ÚTEIS:"
echo "   • SendGrid Signup: https://signup.sendgrid.com/"
echo "   • SendGrid Dashboard: https://app.sendgrid.com/"
echo "   • Activity Feed: https://app.sendgrid.com/email_activity"
echo "   • API Keys: https://app.sendgrid.com/settings/api_keys"
echo "   • Sender Auth: https://app.sendgrid.com/settings/sender_auth"
echo ""

# 10. Documentação
echo "🔟 DOCUMENTAÇÃO LOCAL:"
echo "   • Guia Completo: CONFIGURACAO-SENDGRID.md"
echo "   • Resumo: MIGRACAO-SENDGRID-RESUMO.md"
echo "   • Exemplo: local.settings.json.example"
echo ""

echo "=========================================="
echo "   ✅ SEQUÊNCIA RECOMENDADA:"
echo "=========================================="
echo "1. Criar conta SendGrid"
echo "2. Obter API Key"
echo "3. Verificar email remetente"
echo "4. Compilar: mvn clean package -DskipTests"
echo "5. Configurar: ./configure-sendgrid.sh"
echo "6. Deploy: mvn azure-functions:deploy"
echo "7. Testar: curl ... (comando 6 acima)"
echo "8. Verificar: Activity Feed do SendGrid"
echo ""

