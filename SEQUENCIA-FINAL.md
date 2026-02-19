# ⚡ SEQUÊNCIA FINAL - FeedbackHub Deploy

## ✅ Situação Atual

Você já tem criado na Azure:
- ✅ Resource Group
- ✅ SQL Database (Serverless)
- ✅ Storage Account + Queue
- ✅ Application Insights
- ✅ Communication Services + Email Service

Falta:
- ⏳ Function App (criar agora)
- ⏳ Domínio de e-mail (configurar manualmente)
- ⏳ Deploy da aplicação

---

## 🚀 Execute Estes 2 Comandos (EM ORDEM):

### 1️⃣ Criar Function App (2-3 min)
```bash
./create-function-app-only.sh
```
⏰ **AGUARDE** este comando terminar completamente antes de continuar!

### 2️⃣ Deploy Automatizado (3-5 min) ⭐ NOVO!
```bash
./deploy.sh
```
Este script descobre o Function App automaticamente e faz o deploy!

### 3️⃣ Obter Function Key
Após o deploy concluir, o script vai mostrar o comando. Ou execute:
```bash
FUNC_NAME=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv)
az functionapp keys list --name $FUNC_NAME --resource-group feedbackhub-rg
```

---

## ⚠️ Configuração do Domínio de E-mail (DEPOIS)

Após o deploy, configure o domínio de e-mail:

1. Acesse: https://portal.azure.com
2. Navegue: `feedbackhub-rg` → `feedbackhub-email`
3. Clique: "Provision Domains" → "Add an Azure managed domain"
4. Copie o e-mail gerado
5. Atualize a variável:

```bash
FUNC_NAME=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv)

az functionapp config appsettings set \
  --name $FUNC_NAME \
  --resource-group feedbackhub-rg \
  --settings "AZURE_COMMUNICATION_FROM_EMAIL=DoNotReply@xxxxx.azurecomm.net"
```

**Guia completo**: REFERENCIA-RAPIDA-EMAIL.md

---

## 🧪 Testar a API

```bash
# Obter nome e chave
FUNC_NAME=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv)
FUNC_KEY=$(az functionapp keys list --name $FUNC_NAME --resource-group feedbackhub-rg --query "functionKeys.default" -o tsv)

# Testar avaliação positiva
curl -X POST "https://${FUNC_NAME}.azurewebsites.net/api/avaliacao?code=${FUNC_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Ótima aula!", "nota": 9}'

# Testar avaliação crítica (vai enviar e-mail)
curl -X POST "https://${FUNC_NAME}.azurewebsites.net/api/avaliacao?code=${FUNC_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Não entendi nada", "nota": 2}'
```

---

## 📊 Monitorar

```bash
# Logs em tempo real
FUNC_NAME=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv)
az functionapp log tail --name $FUNC_NAME --resource-group feedbackhub-rg

# Ou ver no Portal
# https://portal.azure.com → feedbackhub-rg → feedbackhub-insights
```

---

## ⏰ Tempo Total Estimado

- Criar Function App: 2-3 min
- Deploy: 3-5 min
- Configurar e-mail: 3-5 min
- **TOTAL: 8-13 minutos**

---

## 📋 Checklist Final

- [ ] Function App criado (`./create-function-app-only.sh`)
- [ ] Deploy realizado (`mvn azure-functions:deploy -DfunctionAppName=...`)
- [ ] Domínio de e-mail configurado (Portal Azure)
- [ ] Variável atualizada (`AZURE_COMMUNICATION_FROM_EMAIL`)
- [ ] API testada (curl)
- [ ] E-mail recebido (verificar inbox)
- [ ] Logs verificados (Application Insights)

---

**Execute agora: `./create-function-app-only.sh`** 🚀

