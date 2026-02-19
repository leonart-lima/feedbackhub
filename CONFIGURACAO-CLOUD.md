# ✅ CONFIGURAÇÃO CLOUD COMPLETA

## 📋 O QUE FOI CONFIGURADO

Todos os arquivos estão apontando para os recursos **reais da Azure Cloud**:

### ✅ application.yml
- Profile ativo: `cloud`
- SQL Database: `feedbackhub-server-55878.database.windows.net`
- Todas as configurações com valores padrão da Azure

### ✅ local.settings.json
- SQL Server: Azure SQL Database (feedbackhub-server-55878)
- Storage Account: feedbackhubst1455878
- Communication Service: feedbackhub-comm-55878
- Todas as connection strings configuradas

---

## 🎯 RECURSOS DA AZURE CONFIGURADOS

### 1. SQL Database
```
Server: feedbackhub-server-55878.database.windows.net
Database: feedbackhub
User: azureuser
Password: FeedbackHub@2026!
```

### 2. Storage Account
```
Account Name: feedbackhubst1455878
Connection String: ✓ Configurada
Endpoints:
  - Blob: https://feedbackhubst1455878.blob.core.windows.net/
  - Queue: https://feedbackhubst1455878.queue.core.windows.net/
  - Table: https://feedbackhubst1455878.table.core.windows.net/
```

### 3. Communication Service
```
Name: feedbackhub-comm-55878
Endpoint: https://feedbackhub-comm-55878.unitedstates.communication.azure.com/
From Email: DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net
```

### 4. E-mails
```
Admin Emails: admin@feedbackhub.com
Report Emails: relatorios@feedbackhub.com
```

---

## 🚀 COMO TESTAR LOCALMENTE

### 1. Rodar localmente (conectando na Azure Cloud):

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

# Rodar com Maven
mvn clean package azure-functions:run
```

**Ou no IntelliJ**:
1. Abra a classe com `@FunctionName`
2. Clique com botão direito
3. **Run** ou **Debug**

### 2. Testar o endpoint local:

Quando rodar localmente, a URL será:
```
http://localhost:7071/api/avaliacao
```

**Teste**:
```bash
curl -X POST http://localhost:7071/api/avaliacao \
  -H "Content-Type: application/json" \
  -d '{
    "clienteId": 1,
    "produtoId": 101,
    "nota": 5,
    "comentario": "Teste local com Azure Cloud!",
    "categoria": "PRODUTO"
  }'
```

---

## 📊 VANTAGENS DESTA CONFIGURAÇÃO

✅ **Desenvolvimento local** com recursos reais da Azure  
✅ **Sem necessidade** de SQL Server local  
✅ **Mesmo banco** usado em produção (cuidado!)  
✅ **Testes de integração** completos  
✅ **E-mails reais** podem ser enviados  

---

## ⚠️ IMPORTANTE

### Conexão com Azure
- Você precisa de **internet** para conectar nos recursos Azure
- O **firewall do SQL Server** deve permitir seu IP
- As **connection strings** são sensíveis - não commitar no Git!

### Verificar Firewall do SQL
Se tiver erro de conexão, adicione seu IP:

```bash
# Obter seu IP público
curl -s ifconfig.me

# Adicionar regra de firewall
az sql server firewall-rule create \
  --server feedbackhub-server-55878 \
  --resource-group feedbackhub-rg \
  --name AllowMyIP \
  --start-ip-address $(curl -s ifconfig.me) \
  --end-ip-address $(curl -s ifconfig.me)
```

---

## 🔒 SEGURANÇA

### Arquivos com Credenciais:
- `local.settings.json` - **NÃO COMMITAR!**
- `app-settings.json` - **NÃO COMMITAR!**

### .gitignore deve conter:
```
local.settings.json
app-settings.json
*.json (que contenha credenciais)
```

---

## 🧪 TESTAR AGORA

### 1. Compilar o projeto:
```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package
```

### 2. Rodar localmente:
```bash
mvn azure-functions:run
```

### 3. Em outro terminal, testar:
```bash
curl -X POST http://localhost:7071/api/avaliacao \
  -H "Content-Type: application/json" \
  -d '{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste!","categoria":"PRODUTO"}'
```

---

## 🎯 PRÓXIMOS PASSOS

1. **Testar localmente** com os comandos acima
2. **Validar conexão** com SQL Database
3. **Testar envio de e-mails** (avaliação com nota <= 2)
4. **Verificar logs** para erros
5. **Deploy para produção** quando estiver OK:
   ```bash
   mvn clean package azure-functions:deploy
   ```

---

## 📝 ENDPOINTS DISPONÍVEIS

### Local (quando rodar mvn azure-functions:run):
- `http://localhost:7071/api/avaliacao` - POST - Criar avaliação

### Produção (Azure):
- `https://feedbackhub-func.azurewebsites.net/api/avaliacao?code=<FUNCTION_KEY>` - POST - Criar avaliação

**Function Key**: `vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==`

---

## ✅ CHECKLIST

- [x] application.yml configurado para cloud
- [x] local.settings.json com connection strings reais
- [x] SQL Database acessível
- [x] Storage Account configurado
- [x] Communication Service configurado
- [ ] Firewall do SQL liberado para seu IP
- [ ] Teste local executado
- [ ] Conexão com banco validada
- [ ] E-mails testados

---

**🎉 Configuração completa! Tudo apontando para a Azure Cloud!**

Execute agora:
```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package azure-functions:run
```

E em outro terminal:
```bash
curl -X POST http://localhost:7071/api/avaliacao \
  -H "Content-Type: application/json" \
  -d '{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste local!","categoria":"PRODUTO"}'
```

