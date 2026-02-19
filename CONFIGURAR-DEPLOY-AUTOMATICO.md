# 🚀 Configurar Deploy Automático com GitHub Actions

Este guia mostra como configurar o deploy automático do FeedbackHub para o Azure Functions sempre que você fizer push no GitHub.

## ✅ Pré-requisitos

- [ ] Repositório no GitHub
- [ ] Azure Function App criado (`feedbackhub-func`)
- [ ] Acesso ao portal Azure

---

## 📋 Passo a Passo

### 1️⃣ Obter o Publish Profile do Azure

O Publish Profile é um arquivo XML com as credenciais necessárias para fazer deploy na sua Function App.

#### Opção A: Via Portal Azure (Recomendado)

1. Acesse o [Portal Azure](https://portal.azure.com)
2. Navegue até sua Function App: **feedbackhub-func**
3. No menu lateral esquerdo, clique em **"Get publish profile"** ou **"Obter perfil de publicação"**
4. Um arquivo `.publishsettings` será baixado automaticamente
5. Abra o arquivo com um editor de texto e **copie todo o conteúdo XML**

#### Opção B: Via Azure CLI

```bash
# Fazer login no Azure
az login

# Obter o publish profile
az functionapp deployment list-publishing-profiles \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --xml
```

Copie toda a saída XML do comando.

---

### 2️⃣ Configurar Secrets no GitHub

Os secrets são variáveis secretas que o GitHub Actions usará para fazer deploy e configurar sua aplicação.

1. Acesse seu repositório no GitHub
2. Vá em **Settings** → **Secrets and variables** → **Actions**
3. Clique em **"New repository secret"**
4. Adicione os seguintes secrets:

#### Secret: `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`
- **Name**: `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`
- **Value**: Cole todo o conteúdo XML do publish profile obtido no passo 1
- Clique em **Add secret**

#### Secret: `DB_URL`
- **Name**: `DB_URL`
- **Value**: URL do banco de dados Azure SQL
- Exemplo: `jdbc:sqlserver://feedbackhub-server.database.windows.net:1433;database=feedbackhub-db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;`

#### Secret: `DB_USERNAME`
- **Name**: `DB_USERNAME`
- **Value**: Usuário do banco de dados
- Exemplo: `feedbackadmin`

#### Secret: `DB_PASSWORD`
- **Name**: `DB_PASSWORD`
- **Value**: Senha do banco de dados

#### Secret: `AZURE_STORAGE_CONNECTION_STRING`
- **Name**: `AZURE_STORAGE_CONNECTION_STRING`
- **Value**: Connection string do Azure Storage
- Exemplo: `DefaultEndpointsProtocol=https;AccountName=feedbackhubstorage;AccountKey=...;EndpointSuffix=core.windows.net`

#### Secret: `SENDGRID_API_KEY` (ou `AZURE_COMMUNICATION_CONNECTION_STRING`)
- **Name**: `SENDGRID_API_KEY` (se usar SendGrid)
- **Value**: Chave API do SendGrid
- Exemplo: `SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

**OU**

- **Name**: `AZURE_COMMUNICATION_CONNECTION_STRING` (se usar Azure Communication Services)
- **Value**: Connection string do ACS
- Exemplo: `endpoint=https://feedbackhub-communication.communication.azure.com/;accesskey=...`

#### Secret: `ADMIN_EMAILS`
- **Name**: `ADMIN_EMAILS`
- **Value**: E-mails dos administradores (separados por vírgula)
- Exemplo: `admin@fiap.com.br,gestor@fiap.com.br`

#### Secret: `REPORT_EMAILS`
- **Name**: `REPORT_EMAILS`
- **Value**: E-mails para receber relatórios (separados por vírgula)
- Exemplo: `relatorios@fiap.com.br,gestao@fiap.com.br`

---

### 3️⃣ Verificar Configuração do Workflow

O workflow já está configurado em `.github/workflows/deploy.yml` e foi otimizado para:

✅ Disparar automaticamente em push para branch `main` ou `master`
✅ Usar Java 21 (versão correta do projeto)
✅ Build com Maven
✅ Executar testes
✅ Deploy para Azure Functions
✅ Sincronizar configurações de ambiente

**Estrutura do Workflow:**
```yaml
on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:  # Permite execução manual
```

---

### 4️⃣ Testar o Deploy Automático

#### Teste 1: Push para Branch Principal

```bash
# Fazer uma alteração qualquer
echo "# Deploy automático configurado" >> README.md

# Adicionar ao git
git add .

# Fazer commit
git commit -m "test: testar deploy automático"

# Fazer push para disparar o workflow
git push origin main
```

#### Teste 2: Acompanhar Execução

1. Acesse seu repositório no GitHub
2. Vá na aba **Actions**
3. Você verá o workflow **"Deploy Azure Functions"** em execução
4. Clique nele para ver os logs em tempo real
5. Aguarde a conclusão (geralmente 3-5 minutos)

#### Teste 3: Verificar Deploy no Azure

```bash
# Verificar status da Function App
az functionapp show \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --query "state" -o table

# Testar endpoint
curl https://feedbackhub-func.azurewebsites.net/api/avaliacoes
```

---

### 5️⃣ Deploy Manual (Quando Necessário)

Se você quiser fazer deploy sem fazer push, use o workflow dispatch:

1. Acesse seu repositório no GitHub
2. Vá na aba **Actions**
3. Selecione **"Deploy Azure Functions"**
4. Clique em **"Run workflow"**
5. Escolha a branch (ex: `main`)
6. Clique em **"Run workflow"**

---

## 🔍 Monitoramento e Logs

### Ver Logs do GitHub Actions

```
GitHub → Actions → Selecione o workflow → Clique em um job
```

### Ver Logs no Azure

```bash
# Via Azure CLI
az functionapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

Ou acesse o Portal Azure:
```
Function App → Monitoring → Log stream
```

---

## 🛠️ Troubleshooting

### Erro: "AZURE_FUNCTIONAPP_PUBLISH_PROFILE not found"

❌ **Problema**: Secret não configurado
✅ **Solução**: Adicione o secret conforme passo 2

### Erro: "Build failed"

❌ **Problema**: Erro de compilação
✅ **Solução**: Execute localmente `mvn clean package` e corrija os erros

### Erro: "Package path not found"

❌ **Problema**: Caminho do pacote incorreto
✅ **Solução**: Já corrigido no workflow - path está como `target/azure-functions/feedbackhub-func`

### Erro: "Authentication failed"

❌ **Problema**: Publish profile expirado ou incorreto
✅ **Solução**: Baixe novo publish profile do Azure e atualize o secret

### Deploy não dispara automaticamente

❌ **Problema**: Branch incorreta ou workflow desabilitado
✅ **Solução**: 
- Verifique se está fazendo push para `main` ou `master`
- No GitHub, vá em Actions e habilite workflows se estiver desabilitado

---

## 📊 Workflow Completo

```
1. Push para GitHub (main/master)
   ↓
2. GitHub Actions detecta push
   ↓
3. Checkout do código
   ↓
4. Setup Java 21
   ↓
5. Maven Build (clean package)
   ↓
6. Maven Test
   ↓
7. Deploy para Azure Functions
   ↓
8. Sincronizar App Settings
   ↓
9. ✅ Deploy Concluído!
```

---

## 🔐 Segurança

✅ **Nunca commite secrets no código**
✅ **Use GitHub Secrets para dados sensíveis**
✅ **Rotate credentials periodicamente**
✅ **Use slot settings para secrets críticos**
✅ **Revise os logs de deploy regularmente**

---

## 📚 Recursos Adicionais

- [GitHub Actions Docs](https://docs.github.com/actions)
- [Azure Functions GitHub Actions](https://github.com/Azure/functions-action)
- [Azure Functions Deployment](https://docs.microsoft.com/azure/azure-functions/functions-continuous-deployment)

---

## ✨ Próximos Passos

Após configurar o deploy automático, você pode:

1. ✅ Configurar ambientes de staging/production
2. ✅ Adicionar testes de integração no workflow
3. ✅ Configurar notificações de deploy
4. ✅ Implementar rollback automático
5. ✅ Adicionar análise de código (SonarQube, CodeQL)

---

## 🎯 Checklist Final

- [ ] Publish profile obtido do Azure
- [ ] Todos os secrets configurados no GitHub
- [ ] Workflow testado com push
- [ ] Deploy verificado no Azure
- [ ] Endpoints testados e funcionando
- [ ] Logs verificados
- [ ] Documentação atualizada

---

**🎉 Parabéns! Seu deploy automático está configurado!**

Agora, toda vez que você fizer push para `main` ou `master`, sua aplicação será automaticamente:
- ✅ Compilada
- ✅ Testada
- ✅ Implantada no Azure
- ✅ Configurada com as variáveis de ambiente

**Fluxo de Desenvolvimento:**
```bash
git add .
git commit -m "feat: nova funcionalidade"
git push origin main
# 🚀 Deploy automático iniciado!
# ⏱️  Aguarde 3-5 minutos
# ✅ Aplicação atualizada no Azure!
```

