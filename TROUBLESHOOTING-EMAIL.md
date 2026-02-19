# 🔧 TROUBLESHOOTING: E-mails Não Chegam

## 🚨 PROBLEMA IDENTIFICADO

Você está com o log:
```
[INFO] Preparando envio de e-mail para: leonart16@gmail.com
```

Mas **NÃO aparece**:
```
[INFO] ✅ E-mail enviado com sucesso...
```

Isso significa que o código está **travando** no `waitForCompletion()` ou **falhando silenciosamente**.

---

## 🎯 CAUSAS PROVÁVEIS

### 1. ⚠️ Domínio de E-mail Não Verificado (MAIS PROVÁVEL)

O Azure Communication Services **exige verificação** do domínio remetente.

**E-mail remetente**: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`

**Problema**: Este domínio pode não estar ativo/verificado no Azure.

**Solução**: Verificar no Azure Portal

### 2. 🔒 Permissões/Quota Excedida

- Quota gratuita: 100 e-mails/mês
- Pode ter atingido o limite

### 3. 🌐 Timeout/Conectividade

- Conexão lenta com Azure
- Firewall bloqueando

---

## ✅ SOLUÇÃO 1: Verificar Domínio no Azure Portal

### Passo 1: Acessar Communication Services

1. Acesse: https://portal.azure.com
2. Procure: `Communication Services`
3. Selecione: `feedbackhub-comm-55878`

### Passo 2: Verificar Email Domains

1. No menu lateral: `Email` → `Domains`
2. Verifique se há um domínio listado
3. Status deve estar: **Verified** ✅

**Se não houver domínio ou estiver "Not Verified"**:
- Você precisa adicionar e verificar um domínio
- OU usar o domínio gratuito fornecido pelo Azure

### Passo 3: Verificar "From" Email Address

1. Menu: `Email` → `MailFrom addresses`
2. Verifique se `DoNotReply@...azurecomm.net` está listado
3. Status: **Active** ✅

### Passo 4: Verificar Logs de Envio

1. Menu: `Monitoring` → `Email Logs`
2. Procure por tentativas de envio recentes
3. Verifique status:
   - ✅ **Delivered** - OK!
   - ⏳ **Queued** - Aguardando
   - ❌ **Failed** - Veja o erro

---

## ✅ SOLUÇÃO 2: Testar com E-mail Azure Gratuito

O Azure fornece um e-mail gratuito no formato:
```
DoNotReply@[UUID].azurecomm.net
```

Você já tem: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`

**Verificar se está ativo**:

```bash
# Via Azure CLI
az communication email domain show \
  --email-service-name feedbackhub-comm-55878 \
  --domain-name d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net \
  --resource-group feedbackhub-rg
```

---

## ✅ SOLUÇÃO 3: Adicionar Logs Detalhados (JÁ FEITO!)

Atualizei o código `EmailService.java` para mostrar logs mais detalhados:

**Novos logs**:
```
📧 Preparando envio de e-mail para: leonart16@gmail.com
   De: DoNotReply@...azurecomm.net
   Assunto: ⚠️ URGENTE: ...
📤 Iniciando envio via Azure Communication Services...
⏳ Aguardando resposta do Azure (timeout: 30 segundos)...
📬 Resposta recebida do Azure
   Status: SUCCEEDED
   Message ID: xxxxx
✅ E-mail enviado com SUCESSO para: leonart16@gmail.com
```

**Se der erro**:
```
❌ EXCEÇÃO ao enviar e-mail para leonart16@gmail.com: ...
   Tipo da exceção: ...
   Stack trace: ...
```

---

## 🧪 TESTE AGORA COM LOGS MELHORADOS

### 1. Recompilar

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package -DskipTests
```

### 2. Executar

```bash
mvn azure-functions:run
```

### 3. Testar

```bash
# Em outro terminal
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste com logs detalhados", "nota": 1}'
```

### 4. Verificar Logs

Procure por:
```
📧 Preparando envio...
📤 Iniciando envio...
⏳ Aguardando resposta...
📬 Resposta recebida
   Status: ???
```

**Se travar em "⏳ Aguardando resposta..."**:
- Problema de conectividade ou domínio não verificado

**Se mostrar "❌ EXCEÇÃO"**:
- Veja a mensagem de erro completa

---

## 🔍 DIAGNÓSTICO RÁPIDO

### Cenário 1: Trava em "⏳ Aguardando resposta..."

**Causa**: Domínio não verificado ou Azure Communication Services não configurado corretamente

**Solução**:
1. Verifique no Azure Portal: Communication Services → Email → Domains
2. Certifique-se que o domínio está **Verified**
3. Verifique Connection String no `local.settings.json`

### Cenário 2: Mostra "Status: FAILED"

**Causa**: Azure rejeitou o envio

**Solução**:
1. Veja o erro detalhado nos logs
2. Verifique quota no Azure Portal
3. Verifique se o e-mail remetente está ativo

### Cenário 3: Mostra "✅ SUCESSO" mas não chega

**Causa**: E-mail foi para SPAM ou demora para entregar

**Solução**:
1. **Verifique pasta SPAM** no Gmail
2. Aguarde 5-10 minutos
3. Verifique logs no Azure Portal (Email Logs)

### Cenário 4: Exceção antes de "📤 Iniciando envio..."

**Causa**: Problema na criação da mensagem ou EmailClient

**Solução**:
1. Verifique `AZURE_COMMUNICATION_CONNECTION_STRING` no `local.settings.json`
2. Verifique `AZURE_COMMUNICATION_FROM_EMAIL` no `local.settings.json`
3. Teste connection string via Azure CLI

---

## 🛠️ COMANDOS ÚTEIS

### Verificar Communication Services

```bash
# Listar recursos
az communication list \
  --resource-group feedbackhub-rg

# Ver detalhes
az communication show \
  --name feedbackhub-comm-55878 \
  --resource-group feedbackhub-rg
```

### Verificar Email Service

```bash
# Listar email services
az communication email list \
  --resource-group feedbackhub-rg

# Ver domínios
az communication email domain list \
  --email-service-name feedbackhub-comm-55878 \
  --resource-group feedbackhub-rg
```

### Testar Connection String

```bash
# Testar se connection string é válida
az communication identity user create \
  --connection-string "endpoint=https://feedbackhub-comm-55878.unitedstates.communication.azure.com/;accesskey=..."
```

---

## 📊 CHECKLIST DE VERIFICAÇÃO

### No Azure Portal

- [ ] Communication Services existe: `feedbackhub-comm-55878`
- [ ] Email Service configurado
- [ ] Domínio verificado (status: Verified)
- [ ] MailFrom address ativo
- [ ] Quota não excedida (Email Logs)

### No Código

- [x] EmailService.java atualizado com logs detalhados
- [ ] Código recompilado: `mvn clean package`
- [ ] Azure Functions reiniciadas

### No local.settings.json

- [ ] `AZURE_COMMUNICATION_CONNECTION_STRING` correto
- [ ] `AZURE_COMMUNICATION_FROM_EMAIL` correto
- [ ] `ADMIN_EMAILS` com seu e-mail real

### Teste

- [ ] Executar: `mvn azure-functions:run`
- [ ] Enviar avaliação crítica (nota ≤ 3)
- [ ] Ver logs detalhados
- [ ] Verificar e-mail (inclusive SPAM)

---

## 🎯 PRÓXIMOS PASSOS

### 1. Execute o teste agora

```bash
# Terminal 1: Compilar e executar
mvn clean package -DskipTests && mvn azure-functions:run
```

```bash
# Terminal 2: Testar
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste diagnóstico", "nota": 1}'
```

### 2. Copie TODOS os logs

Procure por:
- `📧 Preparando envio...`
- `📤 Iniciando envio...`
- `⏳ Aguardando resposta...`
- `📬 Resposta recebida` ou `❌ EXCEÇÃO`

### 3. Verifique Azure Portal

- Email Logs no Communication Services
- Veja se há tentativas de envio

### 4. Se ainda não funcionar

**Me envie**:
1. Logs completos desde "📧 Preparando" até o final/erro
2. Screenshot do Azure Portal → Communication Services → Email → Domains
3. Confirme o valor de `AZURE_COMMUNICATION_FROM_EMAIL` no `local.settings.json`

---

## 💡 DICA IMPORTANTE

O problema mais comum é **domínio não verificado**. 

**Para resolver rapidamente**:
1. Acesse Azure Portal
2. Communication Services → Email
3. Se não houver domínio ativo, você precisa:
   - Adicionar um domínio personalizado (requer DNS)
   - OU usar o domínio gratuito do Azure (já deveria estar ativo)

---

**Executar agora e me mostrar os novos logs!** 📋

**Data**: 18 de fevereiro de 2026

