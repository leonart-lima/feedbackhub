# 📧 Configurar Domínio de E-mail - Azure Communication Services

## ⚠️ Configuração Manual Necessária

O Azure Communication Services exige que o domínio de e-mail seja configurado **manualmente** via Portal Azure (a CLI não suporta todas as opções).

---

## 🎯 Passo a Passo Completo

### 1️⃣ Acessar o Portal Azure

Abra: **https://portal.azure.com**

### 2️⃣ Navegar até o Email Service

1. No menu lateral, clique em **Resource groups**
2. Selecione: **feedbackhub-rg**
3. Na lista de recursos, procure e clique em: **feedbackhub-email** (tipo: Email Service)

### 3️⃣ Provisionar Domínio Gerenciado

1. No menu lateral do Email Service, procure por:
   - **"Provision Domains"** OU
   - **"Try Email"** OU
   - **"Domains"**

2. Clique no botão **"Add domain"** ou **"Setup"**

3. Selecione: **"Add an Azure managed domain"**
   - ✅ É **GRATUITO**
   - ✅ Não precisa verificar DNS
   - ✅ Pronto para usar imediatamente

4. Clique em **"Add"** ou **"Configure"**

5. Aguarde 1-2 minutos para o provisionamento

### 4️⃣ Copiar o Endereço de E-mail

Após o provisionamento, você verá um domínio criado com formato:

```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.azurecomm.net
```

O endereço de e-mail padrão será:

```
DoNotReply@xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.azurecomm.net
```

**Copie este endereço completo!**

### 5️⃣ Conectar ao Communication Service

1. Ainda na página do domínio, procure por **"Connect domain"** ou **"Link to Communication Service"**

2. Selecione o Communication Service: **feedbackhub-comm-XXXXXX**

3. Clique em **"Connect"** ou **"Link"**

4. Aguarde a confirmação (verde ✅)

### 6️⃣ Atualizar Variável de Ambiente

Abra o terminal e execute:

```bash
# Substitua YOUR-EMAIL pelo endereço copiado
az functionapp config appsettings set \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --settings "AZURE_COMMUNICATION_FROM_EMAIL=DoNotReply@xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.azurecomm.net"
```

**Substitua**:
- `feedbackhub-func-XXXXXX` → Nome do seu Function App (veja em `azure-credentials.txt`)
- `DoNotReply@xxxxx...` → E-mail copiado do Portal

---

## ✅ Verificar se Está Funcionando

### No Portal Azure:

1. Vá para **Communication Services** > **feedbackhub-comm-XXXXXX**
2. No menu lateral, clique em **"Email" > "Domains"**
3. Deve mostrar o domínio com status **"Connected" ou "Verified"** ✅

### Testar Envio:

No Portal Azure, há uma opção de teste:

1. Ainda em **Communication Services**
2. Clique em **"Try Email"** ou **"Send test email"**
3. Preencha:
   - **To**: Seu e-mail pessoal
   - **From**: O endereço do domínio
   - **Subject**: Teste FeedbackHub
   - **Body**: E-mail de teste
4. Clique em **"Send"**
5. Verifique sua caixa de entrada (ou spam)

---

## 📸 Capturas de Tela de Referência

### Como Encontrar o Email Service:

```
Portal Azure → Resource Groups → feedbackhub-rg → feedbackhub-email
```

### Menu do Email Service:

```
Email Communications Service
├── Overview
├── Provision Domains  ← CLIQUE AQUI
├── Settings
└── ...
```

### Provisionar Domínio:

```
Add domain
├─ Add an Azure managed domain  ← SELECIONE ESTA
└─ Add a custom domain
```

---

## 🔍 Troubleshooting

### "Não encontro 'Provision Domains'"

Tente procurar por:
- **"Domains"**
- **"Try Email"**
- **"Email Domains"**
- **"Quick setup"**

### "Botão 'Add domain' está desabilitado"

Aguarde 1-2 minutos. O Email Service pode estar ainda sendo provisionado.

### "Erro ao conectar ao Communication Service"

1. Verifique se o Communication Service existe: **feedbackhub-comm-XXXXXX**
2. Devem estar no mesmo Resource Group
3. Tente recarregar a página

### "E-mail de teste não chega"

1. Verifique **spam/lixo eletrônico**
2. Aguarde até 5 minutos
3. Tente enviar para outro e-mail

---

## 📝 Arquivo de Credenciais

Após configurar, anote no arquivo `azure-credentials.txt`:

```
AZURE_COMMUNICATION_FROM_EMAIL=DoNotReply@xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.azurecomm.net
```

---

## 🚀 Após Configurar

Quando o domínio estiver configurado e a variável atualizada:

1. Continue com o deploy:
```bash
mvn clean package azure-functions:deploy
```

2. Teste uma avaliação crítica para ver o e-mail chegar!

---

## 💡 Dicas

- O domínio Azure Managed é **gratuito** e **imediato**
- Você pode ter **apenas 1 domínio gerenciado** por Email Service
- Para domínios personalizados (custom), precisa configurar DNS
- O limite gratuito é de **250 e-mails/mês**

---

**Tempo total desta configuração: 3-5 minutos** ⏱️

