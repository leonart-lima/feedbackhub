# 🎯 PRÓXIMOS PASSOS - FeedbackHub

**Status Atual**: ✅ Function App deployado com sucesso!  
**Pendente**: Configurar recursos do Azure e variáveis de ambiente

---

## ⚠️ ATENÇÃO: Configurações Faltando

O seu Function App está rodando, mas **falta configurar**:

1. ❌ **SQL Database** - Para armazenar avaliações
2. ❌ **Azure Communication Service** - Para enviar e-mails
3. ❌ **Variáveis de Ambiente** - Conexões do banco e e-mail

---

## 🚀 OPÇÃO 1: Configuração Automática (RECOMENDADO)

### Execute o script de setup completo:

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

# Dar permissão de execução (se necessário):
chmod +x azure-setup.sh

# Executar:
./azure-setup.sh
```

**O que esse script faz**:
- ✅ Cria SQL Server e Database
- ✅ Configura firewall do SQL
- ✅ Cria Azure Communication Service
- ✅ Configura domínio de e-mail
- ✅ Atualiza todas as variáveis de ambiente no Function App
- ✅ Cria Storage Queue para notificações

**Tempo estimado**: 5-10 minutos

---

## 🔧 OPÇÃO 2: Configuração Manual

### 1️⃣ Criar SQL Database

```bash
# Criar SQL Server
az sql server create \
  --name feedbackhub-sql-$(date +%s | tail -c 6) \
  --resource-group feedbackhub-rg \
  --location brazilsouth \
  --admin-user azureuser \
  --admin-password "FeedbackHub@2026!"

# Guardar o nome do servidor:
SQL_SERVER=$(az sql server list --resource-group feedbackhub-rg --query "[0].name" -o tsv)

# Criar Database
az sql db create \
  --name feedbackhub \
  --server $SQL_SERVER \
  --resource-group feedbackhub-rg \
  --service-objective Basic \
  --max-size 2GB

# Configurar firewall (permitir serviços Azure):
az sql server firewall-rule create \
  --server $SQL_SERVER \
  --resource-group feedbackhub-rg \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Permitir seu IP:
az sql server firewall-rule create \
  --server $SQL_SERVER \
  --resource-group feedbackhub-rg \
  --name AllowMyIP \
  --start-ip-address $(curl -s ifconfig.me) \
  --end-ip-address $(curl -s ifconfig.me)
```

### 2️⃣ Criar Azure Communication Service

```bash
# Criar Communication Service
az communication create \
  --name feedbackhub-comm-$(date +%s | tail -c 6) \
  --resource-group feedbackhub-rg \
  --location global \
  --data-location brazil

# Guardar connection string:
COMM_SERVICE=$(az communication list --resource-group feedbackhub-rg --query "[0].name" -o tsv)
COMM_CONN_STRING=$(az communication list-key \
  --name $COMM_SERVICE \
  --resource-group feedbackhub-rg \
  --query "primaryConnectionString" -o tsv)

echo "Communication Connection String: $COMM_CONN_STRING"
```

### 3️⃣ Configurar Domínio de E-mail

**⚠️ IMPORTANTE**: Azure Communication Services requer um domínio verificado.

**Opções**:

#### A) Usar domínio Azure (mais simples):
```bash
# Criar Email Communication Service com domínio Azure
az communication email create \
  --name feedbackhub-email \
  --resource-group feedbackhub-rg \
  --location global \
  --data-location brazil

# O Azure fornecerá um domínio como:
# DoNotReply@xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.azurecomm.net
```

#### B) Usar seu próprio domínio:
Veja documentação completa: `REFERENCIA-RAPIDA-EMAIL.md`

#### C) Usar SendGrid (alternativa mais fácil):
```bash
# Criar SendGrid Account
az sendgrid account create \
  --name feedbackhub-sendgrid \
  --resource-group feedbackhub-rg \
  --location brazilsouth \
  --sku free

# Obter API Key no portal: https://portal.azure.com
```

### 4️⃣ Configurar Variáveis de Ambiente

```bash
# Obter nomes dos recursos:
SQL_SERVER=$(az sql server list --resource-group feedbackhub-rg --query "[0].name" -o tsv)
COMM_SERVICE=$(az communication list --resource-group feedbackhub-rg --query "[0].name" -o tsv)

# Obter connection strings:
STORAGE_CONN=$(az storage account show-connection-string \
  --name feedbackhubfunc20028 \
  --resource-group feedbackhub-rg \
  --query connectionString -o tsv)

COMM_CONN=$(az communication list-key \
  --name $COMM_SERVICE \
  --resource-group feedbackhub-rg \
  --query "primaryConnectionString" -o tsv)

# Configurar todas as variáveis:
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    "DB_URL=jdbc:sqlserver://${SQL_SERVER}.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    "DB_USERNAME=azureuser" \
    "DB_PASSWORD=FeedbackHub@2026!" \
    "AZURE_STORAGE_CONNECTION_STRING=$STORAGE_CONN" \
    "AZURE_COMMUNICATION_CONNECTION_STRING=$COMM_CONN" \
    "AZURE_COMMUNICATION_FROM_EMAIL=DoNotReply@SEU-DOMINIO.azurecomm.net" \
    "ADMIN_EMAILS=admin@example.com" \
    "REPORT_EMAILS=reports@example.com" \
    "WEBSITE_TIME_ZONE=E. South America Standard Time"
```

### 5️⃣ Criar Tabelas no Banco de Dados

```bash
# Conectar e criar tabelas (você precisa ter um script SQL)
# Se você tem um schema.sql:
az sql db query \
  --server $SQL_SERVER \
  --database feedbackhub \
  --resource-group feedbackhub-rg \
  --username azureuser \
  --password "FeedbackHub@2026!" \
  --query-file schema.sql
```

---

## 🧪 TESTAR APÓS CONFIGURAÇÃO

### 1. Verificar configurações:
```bash
az functionapp config appsettings list \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --query "[].{Name:name, Value:value}" -o table
```

### 2. Testar função HTTP:
```bash
curl -X POST "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
  -H "Content-Type: application/json" \
  -d '{
    "clienteId": 1,
    "produtoId": 101,
    "nota": 5,
    "comentario": "Excelente produto!",
    "categoria": "PRODUTO"
  }'
```

### 3. Ver logs:
```bash
az webapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

---

## 📚 DOCUMENTAÇÃO ÚTIL

- `DEPLOYMENT-SUCCESS.md` - Informações do deployment
- `REFERENCIA-RAPIDA-EMAIL.md` - Configuração de e-mail
- `QUICKSTART-AZURE.md` - Guia rápido do Azure
- `TROUBLESHOOTING.md` - Solução de problemas

---

## 🆘 PROBLEMAS COMUNS

### ❓ "Qual opção escolher?"

**Recomendação**: Use a **OPÇÃO 1 (script automático)** - é mais rápido e menos propenso a erros.

### ❓ "Já tenho alguns recursos criados"

Se você rodou o `azure-setup.sh` anteriormente:
```bash
# Verificar recursos existentes:
az resource list --resource-group feedbackhub-rg -o table

# Se faltam recursos, pode rodar o script novamente
# (ele detecta recursos existentes e não duplica)
```

### ❓ "Preciso de ajuda com e-mail"

Veja o guia detalhado:
```bash
cat REFERENCIA-RAPIDA-EMAIL.md
```

---

## ✅ CHECKLIST DE CONFIGURAÇÃO

Marque conforme for completando:

- [ ] SQL Server criado
- [ ] SQL Database criado
- [ ] Firewall do SQL configurado
- [ ] Tabelas do banco criadas
- [ ] Azure Communication Service criado
- [ ] Domínio de e-mail configurado e verificado
- [ ] Variáveis de ambiente configuradas no Function App
- [ ] Storage Queue criada (`urgency-queue`)
- [ ] Teste HTTP funcionando
- [ ] E-mails sendo enviados
- [ ] Logs sem erros

---

## 🎯 RECOMENDAÇÃO FINAL

**Execute agora**:

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub
./azure-setup.sh
```

Esse script vai configurar tudo automaticamente e te deixar pronto para usar! 🚀

---

**Após configurar, volte para**: `DEPLOYMENT-SUCCESS.md` para testar! 🎉

