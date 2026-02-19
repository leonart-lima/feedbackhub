# 🧪 TESTE RÁPIDO - FeedbackHub

## ✅ Status Atual

- ✅ Function App deployado: `feedbackhub-func`
- ✅ URL: https://feedbackhub-func.azurewebsites.net
- ✅ 4 funções deployadas
- ⏳ Configurando variáveis de ambiente...

---

## 🚀 TESTE IMEDIATO

### 1. Teste Simples (HTTP Trigger)

```bash
curl -X POST \
  "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
  -H "Content-Type: application/json" \
  -d '{
    "clienteId": 1,
    "produtoId": 101,
    "nota": 5,
    "comentario": "Excelente produto!",
    "categoria": "PRODUTO"
  }'
```

**Resposta Esperada** (200 OK):
```json
{
  "id": 1,
  "clienteId": 1,
  "produtoId": 101,
  "nota": 5,
  "comentario": "Excelente produto!",
  "categoria": "PRODUTO",
  "urgente": false,
  "dataAvaliacao": "2026-02-18T..."
}
```

### 2. Teste com Avaliação Urgente (nota baixa)

```bash
curl -X POST \
  "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
  -H "Content-Type: application/json" \
  -d '{
    "clienteId": 2,
    "produtoId": 102,
    "nota": 1,
    "comentario": "Péssimo atendimento!",
    "categoria": "ATENDIMENTO"
  }'
```

**O que deve acontecer**:
- ✅ Avaliação salva no banco
- ✅ Marcada como `urgente: true`
- ✅ Mensagem enviada para fila
- ✅ Notificação por e-mail (se configurado)

---

## 📊 VERIFICAR LOGS

### Ver logs em tempo real:
```bash
az webapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

### Ver últimos logs:
```bash
az webapp log download \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --log-file logs.zip
```

---

## 🔍 VERIFICAR CONFIGURAÇÕES

### Ver todas as configurações:
```bash
az functionapp config appsettings list \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --query "[].{Name:name, Value:value}" \
  -o table
```

### Verificar apenas configurações da aplicação:
```bash
az functionapp config appsettings list \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --query "[?starts_with(name, 'DB_') || contains(name, 'EMAIL') || contains(name, 'ADMIN')].{Name:name, Value:value}" \
  -o table
```

---

## 🐛 TROUBLESHOOTING

### Erro 500 Internal Server Error?

**Possíveis causas**:
1. Variáveis de ambiente não configuradas
2. Banco de dados não acessível
3. Tabelas não criadas

**Solução**:
```bash
# 1. Verificar configurações
az functionapp config appsettings list \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg | grep -E "DB_|AZURE_"

# 2. Ver logs detalhados
az webapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg

# 3. Verificar banco de dados
az sql db show \
  --name feedbackhub \
  --server feedbackhub-server-55878 \
  --resource-group feedbackhub-rg
```

### Erro 401 Unauthorized?

**Causa**: Function key incorreta

**Solução**:
```bash
# Obter a key correta
az functionapp keys list \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

### Erro de Connection String?

**Causa**: Variáveis de ambiente não configuradas

**Solução**:
```bash
# Configurar manualmente
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    DB_URL="jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true" \
    DB_USERNAME="azureuser" \
    DB_PASSWORD="FeedbackHub@2026!"
```

---

## 📱 MONITORAMENTO NO PORTAL

1. Acesse: https://portal.azure.com
2. Navegue: **Function App** > **feedbackhub-func**
3. Menu lateral:
   - **Functions** - Ver todas as funções
   - **Monitor** - Ver execuções e métricas
   - **Log stream** - Logs em tempo real
   - **Application Insights** - Análise detalhada

---

## ✅ CHECKLIST DE TESTE

- [ ] Curl de teste básico executado
- [ ] Resposta 200 OK recebida
- [ ] Dados salvos no banco
- [ ] Teste com avaliação urgente
- [ ] Fila de mensagens recebeu a notificação
- [ ] E-mail enviado (se configurado)
- [ ] Logs sem erros críticos
- [ ] Function App respondendo rápido (< 3s)

---

## 🎯 PRÓXIMOS PASSOS

Após os testes básicos funcionarem:

1. **Configurar E-mail** (se ainda não configurado)
   - Veja: `REFERENCIA-RAPIDA-EMAIL.md`

2. **Criar Tabelas** (se necessário)
   - Conectar ao SQL Database
   - Executar script de schema

3. **Testar Relatório Semanal**
   - Trigger manual ou aguardar segunda-feira 09:00

4. **Configurar Monitoramento**
   - Alertas no Application Insights
   - Dashboard de métricas

---

## 💡 DICAS

### Teste Rápido com Watch:
```bash
# Monitorar logs enquanto testa
watch -n 2 'curl -s https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q== | jq .'
```

### Teste de Carga:
```bash
# Enviar múltiplas requisições
for i in {1..10}; do
  curl -X POST \
    "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
    -H "Content-Type: application/json" \
    -d "{\"clienteId\":$i,\"produtoId\":101,\"nota\":5,\"comentario\":\"Teste $i\",\"categoria\":\"PRODUTO\"}" &
done
wait
echo "Teste de carga concluído!"
```

### Debug Local (antes de deployar):
```bash
# Rodar funções localmente
mvn clean package azure-functions:run
```

---

**🎉 Seu FeedbackHub está quase pronto para usar!**

Execute o primeiro teste agora:
```bash
curl -X POST "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" -H "Content-Type: application/json" -d '{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste!","categoria":"PRODUTO"}'
```

