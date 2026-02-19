# Guia de Solução de Problemas - FeedbackHub

## Erro: Azure SQL Firewall Bloqueando Conexão

### Sintoma
```
Cannot open server 'feedbackhub-server-55878' requested by the login. 
Client with IP address '191.244.255.54' is not allowed to access the server.
```

### Causa
O Azure SQL Database possui firewall que bloqueia conexões de IPs não autorizados por padrão.

### Solução Automática (Recomendada)

Execute o script fornecido:

```bash
chmod +x fix-azure-sql-firewall.sh
./fix-azure-sql-firewall.sh
```

### Solução Manual

#### Opção 1: Via Azure CLI

```bash
# 1. Detectar seu IP público
MY_IP=$(curl -s https://api.ipify.org)
echo "Seu IP: $MY_IP"

# 2. Fazer login no Azure
az login

# 3. Adicionar regra de firewall
az sql server firewall-rule create \
    --resource-group feedbackhub-rg \
    --server feedbackhub-server-55878 \
    --name AllowMyIP \
    --start-ip-address $MY_IP \
    --end-ip-address $MY_IP

# 4. Verificar regras
az sql server firewall-rule list \
    --resource-group feedbackhub-rg \
    --server feedbackhub-server-55878 \
    --output table
```

#### Opção 2: Via Portal Azure

1. **Acesse o Portal Azure**: https://portal.azure.com

2. **Navegue até o SQL Server**:
   - Clique em "All resources"
   - Procure por: `feedbackhub-server-55878`
   - Clique no servidor SQL

3. **Configure o Firewall**:
   - No menu lateral esquerdo, em "Security", clique em **"Networking"**
   - Na seção "Firewall rules", clique em **"+ Add a firewall rule"**
   - Preencha:
     - **Rule name**: `AllowMyIP` (ou qualquer nome)
     - **Start IP**: `191.244.255.54` (seu IP atual)
     - **End IP**: `191.244.255.54` (mesmo IP)
   - Clique em **"Save"**

4. **Aguarde**: A regra pode levar até 5 minutos para entrar em vigor

5. **Teste a conexão** novamente

#### Opção 3: Permitir Serviços Azure

Se você estiver executando de dentro do Azure (Azure Functions no Azure):

```bash
az sql server firewall-rule create \
    --resource-group feedbackhub-rg \
    --server feedbackhub-server-55878 \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0
```

**Nota**: `0.0.0.0` é um valor especial que permite acesso de qualquer serviço Azure.

---

## Outros Problemas Comuns

### 1. ClassNotFoundException nas Azure Functions

**Sintoma:**
```
ClassNotFoundException: com.fiap.feedbackhub.functions.RecepcionarAvaliacaoFunction
```

**Solução:**
Recompilar o projeto com as configurações corretas do Maven:

```bash
mvn clean package -DskipTests
```

### 2. Spring Context não Inicializa

**Sintoma:**
```
NullPointerException no Service
```

**Solução:**
Verificar se o SpringContextLoader está sendo usado nas Functions.

### 3. Erro de Autenticação no Azure SQL

**Sintoma:**
```
Login failed for user 'feedbackhub-admin'
```

**Solução:**
Verificar credenciais no `application.yml` ou `local.settings.json`.

### 4. Azure Storage Queue não Conecta

**Sintoma:**
```
Unable to connect to Azure Storage Queue
```

**Solução:**
```bash
# Verificar connection string
az storage account show-connection-string \
    --name feedbackhubstorage55878 \
    --resource-group feedbackhub-rg
```

### 5. Azure Communication Services - Email Falha

**Sintoma:**
```
Email send failed
```

**Solução:**
1. Verificar se o domínio está verificado
2. Verificar connection string do ACS
3. Verificar se o e-mail remetente está correto

---

## Comandos Úteis

### Verificar Status dos Recursos Azure

```bash
# Listar todos os recursos
az resource list \
    --resource-group feedbackhub-rg \
    --output table

# Status do SQL Database
az sql db show \
    --resource-group feedbackhub-rg \
    --server feedbackhub-server-55878 \
    --name feedbackhub-db \
    --output table

# Status do Function App
az functionapp show \
    --name feedbackhub-func \
    --resource-group feedbackhub-rg \
    --output table

# Status do Storage Account
az storage account show \
    --name feedbackhubstorage55878 \
    --resource-group feedbackhub-rg \
    --output table
```

### Ver Logs em Tempo Real

```bash
# Logs do Function App
az webapp log tail \
    --name feedbackhub-func \
    --resource-group feedbackhub-rg

# Logs do SQL Database (query performance)
az sql db show \
    --resource-group feedbackhub-rg \
    --server feedbackhub-server-55878 \
    --name feedbackhub-db
```

### Testar Conectividade

```bash
# Testar conexão com SQL Server
telnet feedbackhub-server-55878.database.windows.net 1433

# Testar endpoint HTTP
curl https://feedbackhub-func.azurewebsites.net/api/avaliacao
```

---

## Configuração Local vs Azure

### Local (Desenvolvimento)

Arquivo: `local.settings.json`
```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "java",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "AZURE_STORAGE_CONNECTION_STRING": "DefaultEndpointsProtocol=https;AccountName=...",
    "SPRING_DATASOURCE_URL": "jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub-db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;",
    "SPRING_DATASOURCE_USERNAME": "feedbackhub-admin",
    "SPRING_DATASOURCE_PASSWORD": "SuaSenhaAqui"
  }
}
```

### Azure (Produção)

Configurar via Azure CLI:
```bash
az functionapp config appsettings set \
    --name feedbackhub-func \
    --resource-group feedbackhub-rg \
    --settings \
    SPRING_DATASOURCE_URL="jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub-db" \
    SPRING_DATASOURCE_USERNAME="feedbackhub-admin" \
    SPRING_DATASOURCE_PASSWORD="SuaSenhaAqui"
```

---

## Checklist de Troubleshooting

- [ ] Azure CLI instalado e autenticado (`az login`)
- [ ] Firewall do Azure SQL configurado com seu IP
- [ ] Connection strings corretas no `local.settings.json` ou Application Settings
- [ ] Credenciais do banco de dados corretas
- [ ] Azure Storage Queue criada e acessível
- [ ] Azure Communication Services configurado
- [ ] Domínio de e-mail verificado no ACS
- [ ] Projeto compilado sem erros (`mvn clean package`)
- [ ] Todas as dependências no `lib/` após build
- [ ] Java 21 instalado e configurado

---

## Obter Ajuda

### Logs Detalhados

```bash
# Habilitar logs verbosos
export JAVA_OPTS="-Dlogging.level.root=DEBUG"
mvn azure-functions:run
```

### Informações do Sistema

```bash
# Versão Java
java -version

# Versão Maven
mvn -version

# Versão Azure CLI
az version

# IP Público
curl https://api.ipify.org
```

### Suporte Azure

- **Portal**: https://portal.azure.com
- **Documentação**: https://docs.microsoft.com/azure
- **Status do Azure**: https://status.azure.com

---

**Última atualização:** 18/02/2026  
**Projeto:** FeedbackHub - Tech Challenge Fase 4

