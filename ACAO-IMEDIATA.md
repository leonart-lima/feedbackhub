# 🎯 AÇÃO IMEDIATA - FeedbackHub

## ✅ SITUAÇÃO ATUAL

Você rodou com sucesso:
1. ✅ `azure-setup.sh` - Criou toda infraestrutura Azure
2. ✅ `mvn clean package azure-functions:deploy` - Deployou as funções

**Resultado**: Function App `feedbackhub-func` está rodando!

---

## ⚠️ PROBLEMA DETECTADO

Os comandos Azure CLI estão muito lentos no momento. Isso pode ser:
- Latência da rede
- Azure CLI com cache desatualizado
- Muitas requisições simultâneas

---

## 🚀 SOLUÇÃO RÁPIDA

### Execute estes comandos agora (um por vez):

#### 1. Verificar se o Function App está rodando:
```bash
curl -I https://feedbackhub-func.azurewebsites.net
```

**Resposta esperada**: HTTP 200 ou 404 (qualquer coisa diferente de erro de conexão)

#### 2. Testar a API (pode demorar na primeira chamada - cold start):
```bash
curl -X POST \
  "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
  -H "Content-Type: application/json" \
  -d '{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste!","categoria":"PRODUTO"}' \
  --max-time 60 \
  -v
```

**Possíveis resultados**:

##### A) Sucesso (200 OK):
```json
{
  "id": 1,
  "clienteId": 1,
  ...
}
```
✅ **TUDO FUNCIONANDO! Pode começar a usar!**

##### B) Erro 500:
```
Internal Server Error
```
❌ **Variáveis de ambiente faltando**

**Solução**:
```bash
# Configurar manualmente
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    DB_URL="jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    DB_USERNAME="azureuser" \
    DB_PASSWORD="FeedbackHub@2026!" \
    WEBSITE_TIME_ZONE="E. South America Standard Time"
```

##### C) Timeout ou não responde:
❌ **Function App ainda está inicializando**

**Aguarde 2-3 minutos e tente novamente**

---

## 🔧 CONFIGURAR VARIÁVEIS MANUALMENTE

Se o teste retornar erro 500, configure agora:

### Passo 1: Configurar Banco de Dados
```bash
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    DB_URL="jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    DB_USERNAME="azureuser" \
    DB_PASSWORD="FeedbackHub@2026!"
```

### Passo 2: Obter Storage Connection String
```bash
az storage account show-connection-string \
  --name feedbackhubst1455878 \
  --resource-group feedbackhub-rg \
  --query connectionString \
  -o tsv
```

**Copie o resultado** e execute:
```bash
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    AZURE_STORAGE_CONNECTION_STRING="<COLE_AQUI>"
```

### Passo 3: Obter Communication Service Connection String
```bash
az communication list-key \
  --name feedbackhub-comm-55878 \
  --resource-group feedbackhub-rg \
  --query "primaryConnectionString" \
  -o tsv
```

**Copie o resultado** e execute:
```bash
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    AZURE_COMMUNICATION_CONNECTION_STRING="<COLE_AQUI>" \
    AZURE_COMMUNICATION_FROM_EMAIL="DoNotReply@feedbackhub-comm-55878.azurecomm.net"
```

### Passo 4: Configurar E-mails e Timezone
```bash
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    ADMIN_EMAILS="admin@feedbackhub.com" \
    REPORT_EMAILS="reports@feedbackhub.com" \
    WEBSITE_TIME_ZONE="E. South America Standard Time"
```

---

## 🎯 ALTERNATIVA: USAR O PORTAL AZURE

Se a CLI estiver muito lenta, use o Portal:

1. Acesse: https://portal.azure.com
2. Navegue: **Resource Groups** > **feedbackhub-rg** > **feedbackhub-func**
3. Menu lateral: **Configuration** > **Application settings**
4. Clique **+ New application setting** para cada variável:

| Nome | Valor |
|------|-------|
| `DB_URL` | `jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;` |
| `DB_USERNAME` | `azureuser` |
| `DB_PASSWORD` | `FeedbackHub@2026!` |
| `WEBSITE_TIME_ZONE` | `E. South America Standard Time` |
| `ADMIN_EMAILS` | `admin@feedbackhub.com` |
| `REPORT_EMAILS` | `reports@feedbackhub.com` |

5. Clique **Save**
6. Aguarde reinicialização do Function App (~1min)

---

## 📊 VERIFICAR SE ESTÁ FUNCIONANDO

### Ver logs em tempo real:
```bash
az webapp log tail --name feedbackhub-func --resource-group feedbackhub-rg
```

Ou no Portal:
1. **Function App** > **feedbackhub-func**
2. **Log stream** (menu lateral)

### Testar novamente:
```bash
curl -X POST \
  "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
  -H "Content-Type: application/json" \
  -d '{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste final!","categoria":"PRODUTO"}'
```

---

## 🔑 INFORMAÇÕES IMPORTANTES

### Function App Principal (USAR ESTE):
- **Nome**: `feedbackhub-func`
- **URL**: https://feedbackhub-func.azurewebsites.net
- **Function Key**: `vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==`

### Recursos do Azure:
- **SQL Server**: feedbackhub-server-55878
- **SQL Database**: feedbackhub
- **Storage Account**: feedbackhubst1455878
- **Communication Service**: feedbackhub-comm-55878
- **Resource Group**: feedbackhub-rg

---

## 🎉 RESUMO

1. ✅ **Deploy foi bem-sucedido!**
2. ⏳ **Configurações de ambiente precisam ser aplicadas**
3. 🧪 **Teste a API para ver o status**
4. 🔧 **Configure manualmente se necessário**

---

## 📞 ME AVISE

**Execute o teste agora** e me diga o resultado:

```bash
curl -X POST \
  "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
  -H "Content-Type: application/json" \
  -d '{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste!","categoria":"PRODUTO"}' \
  -w "\nStatus HTTP: %{http_code}\n"
```

**Me diga**:
- ✅ Funcionou (código 200)?
- ❌ Erro 500 (falta configuração)?
- ⏳ Timeout (ainda inicializando)?
- ❓ Outro erro?

Com essa informação, te ajudo a resolver! 🚀

