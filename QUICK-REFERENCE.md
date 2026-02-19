# ⚡ Referência Rápida - FeedbackHub

## 🎯 Comandos Mais Usados

### Deploy Completo (Zero to Hero)

```bash
# Passo 1: Login
az login

# Passo 2: Criar recursos Azure (executa apenas 1 vez)
./azure-setup.sh

# Passo 3: Configurar SendGrid (executa apenas 1 vez)
./azure-configure-sendgrid.sh

# Passo 4: Deploy da aplicação (executar sempre que atualizar código)
mvn clean package azure-functions:deploy
```

---

## 📝 Testar a API

```bash
# Substituir pelos seus valores
FUNCTION_URL="https://feedbackhub-func-XXXXXX.azurewebsites.net"
FUNCTION_KEY="sua-chave-aqui"

# Avaliação positiva
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Ótima aula!", "nota": 9}'

# Avaliação crítica (envia e-mail)
curl -X POST "${FUNCTION_URL}/api/avaliacao?code=${FUNCTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Não entendi nada", "nota": 2}'
```

---

## 🔑 Obter Informações Importantes

```bash
# Obter Function URL e Keys
az functionapp keys list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Ver configurações (variáveis de ambiente)
az functionapp config appsettings list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --output table

# Ver logs em tempo real
az functionapp log tail \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg
```

---

## 📊 Monitoramento

```bash
# Logs em tempo real
az functionapp log tail \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Abrir portal Azure
open "https://portal.azure.com"

# Abrir Application Insights
# Portal > Resource Groups > feedbackhub-rg > feedbackhub-insights
```

---

## 🔧 Gerenciamento

```bash
# Listar recursos criados
az resource list --resource-group feedbackhub-rg --output table

# Parar Function App (economizar)
az functionapp stop \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Iniciar Function App
az functionapp start \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Reiniciar Function App
az functionapp restart \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg
```

---

## 🗄️ SQL Database

```bash
# Pausar database (economizar)
az sql db pause \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub

# Retomar database
az sql db resume \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub

# Ver status
az sql db show \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server-XXXXXX \
  --name feedbackhub \
  --query "status"
```

---

## 📧 Testar SendGrid

```bash
SENDGRID_API_KEY="SG.xxxxx"
TO_EMAIL="seu@email.com"
FROM_EMAIL="noreply@feedbackhub.com"

curl -X POST "https://api.sendgrid.com/v3/mail/send" \
  -H "Authorization: Bearer ${SENDGRID_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"personalizations\": [{
      \"to\": [{\"email\": \"${TO_EMAIL}\"}]
    }],
    \"from\": {\"email\": \"${FROM_EMAIL}\"},
    \"subject\": \"Teste FeedbackHub\",
    \"content\": [{
      \"type\": \"text/plain\",
      \"value\": \"Email de teste\"
    }]
  }"
```

---

## 🧪 Invocar Funções Manualmente

```bash
# Invocar relatório semanal (sem esperar segunda-feira)
az functionapp function invoke \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --function-name gerarRelatorioSemanal
```

---

## 🧹 Limpeza

```bash
# CUIDADO: Deleta TODOS os recursos!
az group delete --name feedbackhub-rg --yes --no-wait
```

---

## 📋 Variáveis que Você Precisa

Após executar `./azure-setup.sh`, você terá um arquivo `azure-credentials.txt` com:

```
Resource Group: feedbackhub-rg
SQL Server: feedbackhub-server-XXXXXX.database.windows.net
SQL Database: feedbackhub
SQL Username: azureuser
SQL Password: FeedbackHub@2026!
Function App: feedbackhub-func-XXXXXX
Storage Account: feedbackhubstXXXXXXXX
```

**Anote esses valores! Você vai precisar deles.**

---

## 🆘 Problemas Comuns

### 1. Erro de compilação Maven

```bash
# Verificar Java 21
java -version

# Se não for 21, configurar:
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Limpar e recompilar
mvn clean install -U
```

### 2. Azure CLI não encontrado

```bash
# macOS
brew install azure-cli

# Verificar
az --version
```

### 3. Function não executa

```bash
# Ver logs
az functionapp log tail \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Verificar status
az functionapp show \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --query "state"
```

### 4. E-mail não chega

- Verifique spam/lixo eletrônico
- Confirme que SendGrid API Key está correta
- Confirme que e-mail remetente está verificado
- Veja logs no Application Insights

---

## 📁 Arquivos Importantes

```
feedbackhub/
├── azure-setup.sh                  ← Script de provisionamento
├── azure-configure-sendgrid.sh     ← Configurar SendGrid
├── azure-credentials.txt           ← Credenciais (NÃO COMMITAR!)
├── QUICKSTART-AZURE.md             ← Guia rápido ⭐
├── CHECKLIST.md                    ← Checklist de validação
├── EXECUTIVE-SUMMARY.md            ← Resumo executivo
├── ARCHITECTURE.md                 ← Diagramas de arquitetura
├── pom.xml                         ← Configuração Maven
└── src/                            ← Código-fonte
```

---

## 🔗 Links Diretos Portal Azure

```bash
# Abrir Resource Group
open "https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/feedbackhub-rg"
```

---

## 📞 Ajuda

- **Guia completo**: [QUICKSTART-AZURE.md](QUICKSTART-AZURE.md)
- **Comandos detalhados**: [docs/AZURE_COMMANDS.md](docs/AZURE_COMMANDS.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Checklist**: [CHECKLIST.md](CHECKLIST.md)

---

## ✅ Checklist Rápido

- [ ] Azure CLI instalado (`az --version`)
- [ ] Java 21 instalado (`java -version`)
- [ ] Login no Azure (`az login`)
- [ ] Executou `./azure-setup.sh`
- [ ] Criou conta SendGrid
- [ ] Executou `./azure-configure-sendgrid.sh`
- [ ] Fez deploy (`mvn clean package azure-functions:deploy`)
- [ ] Testou API (curl)
- [ ] Recebeu e-mail de teste
- [ ] Verificou logs no portal

---

**Tudo funcionando? Parabéns! 🎉**

Agora é só gravar o vídeo de demonstração e fazer a entrega do Tech Challenge!

