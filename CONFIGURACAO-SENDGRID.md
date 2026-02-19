# 🔧 Configuração do SendGrid - Guia Completo

## ✅ Mudanças Realizadas

### 1. Dependências (pom.xml)
- ✅ **Removido**: `azure-communication-email`
- ✅ **Adicionado**: `sendgrid-java` (versão 4.10.2)

### 2. Configuração (application.yml)
- ✅ **Removido**: Configurações do Azure Communication Services
- ✅ **Adicionado**: Configurações do SendGrid

### 3. Código (EmailService.java)
- ✅ **Já está implementado** com SendGrid!

---

## 📋 Pré-requisitos

### 1. Criar Conta no SendGrid
1. Acesse: https://signup.sendgrid.com/
2. Crie uma conta gratuita (100 emails/dia grátis)
3. Verifique seu email

### 2. Criar API Key
1. Faça login no SendGrid
2. Vá em **Settings** → **API Keys**
3. Clique em **Create API Key**
4. Nome: `FeedbackHub Production`
5. Permissão: **Full Access** (ou pelo menos **Mail Send**)
6. **IMPORTANTE**: Copie a API Key (você só verá ela uma vez!)

### 3. Verificar Sender Identity (Remetente)

#### Opção A: Single Sender Verification (Mais Rápido)
1. Vá em **Settings** → **Sender Authentication** → **Single Sender Verification**
2. Clique em **Create New Sender**
3. Preencha:
   - **From Name**: FeedbackHub
   - **From Email Address**: seu-email@gmail.com (use seu email real)
   - **Reply To**: mesmo email
   - Preencha outros campos obrigatórios
4. Verifique o email de confirmação enviado pelo SendGrid
5. Clique no link de verificação

#### Opção B: Domain Authentication (Profissional - Requer Domínio)
1. Vá em **Settings** → **Sender Authentication** → **Authenticate Your Domain**
2. Siga as instruções para adicionar registros DNS
3. **Nota**: Requer que você tenha um domínio próprio

---

## 🔧 Configuração Local

### 1. Atualizar `local.settings.json`
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "java",
    
    "SENDGRID_API_KEY": "SG.sua-api-key-aqui",
    "SENDGRID_FROM_EMAIL": "seu-email-verificado@gmail.com",
    "SENDGRID_FROM_NAME": "FeedbackHub",
    
    "ADMIN_EMAILS": "leonart16@gmail.com",
    "REPORT_EMAILS": "leonart16@gmail.com",
    
    "DB_URL": "jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;",
    "DB_USERNAME": "azureuser",
    "DB_PASSWORD": "FeedbackHub@2026!",
    
    "AZURE_STORAGE_CONNECTION_STRING": "sua-connection-string",
    "AZURE_QUEUE_NAME": "feedback-urgencia-queue"
  }
}
```

### 2. Recompilar o Projeto
```bash
mvn clean package -DskipTests
```

---

## ☁️ Configuração no Azure

### Método 1: Via Azure Portal (Interface Gráfica)

1. Acesse o [Azure Portal](https://portal.azure.com)
2. Navegue até seu **Function App** (`feedbackhub-func`)
3. No menu lateral, clique em **Configuration**
4. Em **Application settings**, adicione/atualize:

| Nome | Valor |
|------|-------|
| `SENDGRID_API_KEY` | SG.sua-api-key-aqui |
| `SENDGRID_FROM_EMAIL` | seu-email-verificado@gmail.com |
| `SENDGRID_FROM_NAME` | FeedbackHub |
| `ADMIN_EMAILS` | leonart16@gmail.com |
| `REPORT_EMAILS` | leonart16@gmail.com |

5. Clique em **Save** no topo da página
6. **Aguarde** o Function App reiniciar

### Método 2: Via Azure CLI (Linha de Comando)

```bash
# Configurar SendGrid API Key
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
  "SENDGRID_API_KEY=SG.sua-api-key-aqui" \
  "SENDGRID_FROM_EMAIL=seu-email-verificado@gmail.com" \
  "SENDGRID_FROM_NAME=FeedbackHub" \
  "ADMIN_EMAILS=leonart16@gmail.com" \
  "REPORT_EMAILS=leonart16@gmail.com"
```

### Método 3: Via Script Automatizado

Crie um arquivo `configure-sendgrid.sh`:

```bash
#!/bin/bash

# Variáveis de configuração
RESOURCE_GROUP="feedbackhub-rg"
FUNCTION_APP="feedbackhub-func"

# ATENÇÃO: Substitua estes valores pelos seus!
SENDGRID_API_KEY="SG.sua-api-key-aqui"
SENDGRID_FROM_EMAIL="seu-email-verificado@gmail.com"
SENDGRID_FROM_NAME="FeedbackHub"
ADMIN_EMAILS="leonart16@gmail.com"
REPORT_EMAILS="leonart16@gmail.com"

echo "🔧 Configurando SendGrid no Azure Function App..."

az functionapp config appsettings set \
  --name "$FUNCTION_APP" \
  --resource-group "$RESOURCE_GROUP" \
  --settings \
  "SENDGRID_API_KEY=$SENDGRID_API_KEY" \
  "SENDGRID_FROM_EMAIL=$SENDGRID_FROM_EMAIL" \
  "SENDGRID_FROM_NAME=$SENDGRID_FROM_NAME" \
  "ADMIN_EMAILS=$ADMIN_EMAILS" \
  "REPORT_EMAILS=$REPORT_EMAILS"

echo "✅ Configuração concluída!"
echo ""
echo "⏳ Aguardando reinicialização do Function App..."
sleep 30

echo ""
echo "📊 Verificando configurações..."
az functionapp config appsettings list \
  --name "$FUNCTION_APP" \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?contains(name, 'SENDGRID')].{Name:name, Value:value}" \
  --output table

echo ""
echo "✅ SendGrid configurado com sucesso!"
```

Executar:
```bash
chmod +x configure-sendgrid.sh
./configure-sendgrid.sh
```

---

## 🚀 Deploy das Mudanças

### 1. Recompilar e fazer Deploy
```bash
# Compilar
mvn clean package -DskipTests

# Deploy
mvn azure-functions:deploy
```

### 2. Verificar Deploy
```bash
# Verificar logs
az functionapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

---

## 🧪 Testar o Envio de Emails

### Teste 1: Criar Avaliação Crítica (Nota ≤ 3)
```bash
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
```

**Resultado esperado**:
- Mensagem enviada para fila
- Function `notificarUrgencia` é acionada
- Email enviado via SendGrid para os administradores

### Teste 2: Gerar Relatório Manual
```bash
curl -X POST https://feedbackhub-func.azurewebsites.net/api/gerarRelatorioManual
```

**Resultado esperado**:
- Relatório gerado
- Email enviado via SendGrid com o relatório

---

## 🔍 Verificar Status dos Emails no SendGrid

### Via SendGrid Dashboard
1. Faça login no SendGrid
2. Vá em **Activity** → **Activity Feed**
3. Veja o status dos emails enviados:
   - ✅ **Delivered**: Email entregue
   - ⏳ **Processed**: Email processado
   - ❌ **Dropped/Bounced**: Email rejeitado

### Via Azure Function Logs
```bash
# Ver logs em tempo real
az functionapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

Procure por mensagens como:
- `✅ E-mail enviado com sucesso para: leonart16@gmail.com`
- `❌ Erro ao enviar e-mail`

---

## 📊 Limites e Quotas do SendGrid

### Free Tier (Gratuito)
- **100 emails/dia**
- Perfeito para desenvolvimento e testes

### Essentials ($19.95/mês)
- **50,000 emails/mês**
- Para produção com volume moderado

### Pro ($89.95/mês)
- **100,000 emails/mês**
- Para produção com alto volume

---

## ❗ Troubleshooting

### Erro: "Forbidden - You do not have authorization"
**Causa**: API Key inválida ou sem permissões
**Solução**: 
1. Verifique se a API Key foi copiada corretamente
2. Crie uma nova API Key com permissão **Full Access**

### Erro: "The from address does not match a verified Sender Identity"
**Causa**: Email remetente não verificado no SendGrid
**Solução**: 
1. Vá em **Settings** → **Sender Authentication**
2. Verifique o email remetente via **Single Sender Verification**

### Emails não estão chegando
**Verificar**:
1. ✅ API Key configurada corretamente
2. ✅ Email remetente verificado no SendGrid
3. ✅ Verificar pasta de SPAM
4. ✅ Verificar **Activity Feed** no SendGrid
5. ✅ Verificar logs do Azure Function

### Erro: "Daily sending limit exceeded"
**Causa**: Excedeu 100 emails/dia (Free Tier)
**Solução**: 
1. Aguarde 24 horas
2. Ou faça upgrade do plano SendGrid

---

## 🎯 Próximos Passos

1. ✅ Compilar projeto: `mvn clean package -DskipTests`
2. ✅ Criar conta no SendGrid
3. ✅ Obter API Key
4. ✅ Verificar email remetente
5. ✅ Configurar variáveis no Azure
6. ✅ Fazer deploy: `mvn azure-functions:deploy`
7. ✅ Testar envio de email
8. ✅ Verificar Activity Feed no SendGrid

---

## 📚 Documentação Adicional

- [SendGrid Documentation](https://docs.sendgrid.com/)
- [SendGrid Java Library](https://github.com/sendgrid/sendgrid-java)
- [Single Sender Verification](https://docs.sendgrid.com/ui/sending-email/sender-verification)
- [Domain Authentication](https://docs.sendgrid.com/ui/account-and-settings/how-to-set-up-domain-authentication)

---

## 💡 Dicas

1. **Desenvolvimento**: Use Single Sender Verification
2. **Produção**: Use Domain Authentication para melhor reputação
3. **Monitore**: Sempre verifique o Activity Feed do SendGrid
4. **Teste**: Faça testes antes de ir para produção
5. **Quotas**: Fique de olho nos limites do seu plano

---

**Migração para SendGrid concluída! 🎉**

Agora seu sistema está usando o SendGrid para envio de emails, que é mais simples, confiável e tem melhor documentação que o Azure Communication Services.

