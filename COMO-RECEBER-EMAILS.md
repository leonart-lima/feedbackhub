# 📧 Como Receber os E-mails no SEU E-mail

## ⚠️ Problema Atual

Os e-mails estão configurados para endereços fictícios:
- `admin@feedbackhub.com` - NÃO EXISTE
- `relatorios@feedbackhub.com` - NÃO EXISTE

Por isso você não está recebendo nada!

---

## ✅ SOLUÇÃO: Coloque Seu E-mail Real

### Passo 1: Edite o arquivo `local.settings.json`

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub
vim local.settings.json
```

ou use qualquer editor (IntelliJ, VSCode, etc.)

### Passo 2: Altere as linhas 17 e 18

**ANTES** (fictício):
```json
"ADMIN_EMAILS": "admin@feedbackhub.com",
"REPORT_EMAILS": "relatorios@feedbackhub.com",
```

**DEPOIS** (seu e-mail real):
```json
"ADMIN_EMAILS": "seu-email@gmail.com",
"REPORT_EMAILS": "seu-email@gmail.com",
```

**Exemplos válidos:**
- Gmail: `leonart.lima@gmail.com`
- Outlook: `leonart@outlook.com`
- Hotmail: `leonart@hotmail.com`
- E-mail corporativo: `leonart@empresa.com.br`

### Passo 3: Salve o arquivo

### Passo 4: Reinicie as Azure Functions

```bash
# Se estiver rodando, pare com Ctrl+C
# Depois execute novamente:
mvn clean package -DskipTests
mvn azure-functions:run
```

### Passo 5: Teste

```bash
# Em outro terminal, envie uma avaliação crítica
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste de e-mail real", "nota": 1}'
```

### Passo 6: Verifique Seu E-mail

1. **Aguarde 30-60 segundos**
2. Verifique sua **Caixa de Entrada**
3. **IMPORTANTE**: Verifique também a **pasta SPAM/Lixo Eletrônico**

**Remetente**: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`  
**Assunto**: `⚠️ URGENTE: Avaliação Crítica Recebida - Nota 1`

---

## 🔍 Como Saber Se Funcionou

### Nos Logs da Aplicação

Procure por:
```
[INFO] E-mail enviado com sucesso para: seu-email@gmail.com
[INFO] Notificação de urgência enviada com sucesso para avaliação ID: X
```

### No Azure Portal

1. Acesse: https://portal.azure.com
2. `Communication Services` → `feedbackhub-comm-55878`
3. `Monitoring` → `Email Logs`
4. Veja se aparece:
   - **To**: `seu-email@gmail.com`
   - **Status**: `Delivered` ✅

---

## ❓ FAQ

### Não recebi o e-mail, o que fazer?

1. **Verifique SPAM** - 90% das vezes está lá!
2. **Aguarde 2-3 minutos** - Pode ter delay
3. **Verifique os logs** - Veja se foi enviado com sucesso
4. **Tente outro e-mail** - Use Gmail se estava usando Outlook, ou vice-versa

### Posso colocar múltiplos e-mails?

Sim! Separe por vírgula:
```json
"ADMIN_EMAILS": "email1@gmail.com,email2@outlook.com,email3@empresa.com",
```

### O remetente DoNotReply é seguro?

Sim! É o endereço oficial do Azure Communication Services. Ele não tem caixa de entrada porque é apenas para **envio**.

---

## 🎯 Resumo Visual

```
┌─────────────────────────────────────────┐
│ ANTES (Não funciona)                    │
├─────────────────────────────────────────┤
│ ADMIN_EMAILS: admin@feedbackhub.com     │
│ ❌ E-mail fictício                       │
│ ❌ Não recebe nada                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ DEPOIS (Funciona!)                      │
├─────────────────────────────────────────┤
│ ADMIN_EMAILS: seu-email@gmail.com       │
│ ✅ E-mail real                           │
│ ✅ Você recebe os e-mails!               │
└─────────────────────────────────────────┘
```

---

## 📝 Exemplo Completo de Alteração

**Arquivo**: `local.settings.json`

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "...",
    "FUNCTIONS_WORKER_RUNTIME": "java",
    "FUNCTIONS_EXTENSION_VERSION": "~4",
    
    "DB_URL": "...",
    "DB_USERNAME": "azureuser",
    "DB_PASSWORD": "FeedbackHub@2026!",
    "SHOW_SQL": "false",
    
    "AZURE_STORAGE_CONNECTION_STRING": "...",
    "AZURE_COMMUNICATION_CONNECTION_STRING": "...",
    "AZURE_COMMUNICATION_FROM_EMAIL": "DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net",
    
    "ADMIN_EMAILS": "leonart.lima@gmail.com",
    "REPORT_EMAILS": "leonart.lima@gmail.com",
    "WEBSITE_TIME_ZONE": "E. South America Standard Time"
  }
}
```

---

**Pronto! Agora você vai receber os e-mails de verdade! 📬**

