# 🔑 Os 8 Secrets Necessários para Deploy Automático

## 📋 Lista Completa

Você precisa adicionar **8 secrets** no GitHub para o deploy automático funcionar.

---

## 🎯 Visão Geral Rápida

| # | Nome do Secret | O Que É | Como Obter |
|---|----------------|---------|------------|
| 1 | `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` | Credenciais do Azure | `./get-publish-profile.sh` |
| 2 | `DB_URL` | URL do banco de dados | Portal Azure ou CLI |
| 3 | `DB_USERNAME` | Usuário do banco | Definido no setup |
| 4 | `DB_PASSWORD` | Senha do banco | Você definiu |
| 5 | `AZURE_STORAGE_CONNECTION_STRING` | Storage connection | Portal Azure ou CLI |
| 6 | `SENDGRID_API_KEY` | API Key email | SendGrid Dashboard |
| 7 | `ADMIN_EMAILS` | E-mails admins | Você define |
| 8 | `REPORT_EMAILS` | E-mails relatórios | Você define |

---

## 🚀 Opção 1: Script Automático (Recomendado!)

Execute este script para obter a maioria dos valores automaticamente:

```bash
./collect-secrets.sh
```

**O que faz:**
- ✅ Obtém 5 valores automaticamente do Azure
- ⚠️ Pede para você definir 3 valores manualmente
- 📄 Salva tudo em `github-secrets-values.txt`
- 🔒 Adiciona o arquivo ao `.gitignore` automaticamente

**Depois:**
1. Abra o arquivo: `cat github-secrets-values.txt`
2. Copie os valores e adicione no GitHub
3. Complete os valores marcados com ⚠️

---

## 🔑 Detalhes de Cada Secret

### 1. AZURE_FUNCTIONAPP_PUBLISH_PROFILE

**O que é**: Arquivo XML com credenciais para fazer deploy no Azure Functions

**Como obter**:
```bash
./get-publish-profile.sh
```
✅ Conteúdo copiado automaticamente para área de transferência!

**Ou manualmente via Azure CLI**:
```bash
az functionapp deployment list-publishing-profiles \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --xml
```

**Formato**: XML completo (começando com `<publishData>`)

---

### 2. DB_URL

**O que é**: String JDBC de conexão com o banco de dados Azure SQL

**Como obter via Azure CLI**:
```bash
az sql db show-connection-string \
  --client jdbc \
  --server feedbackhub-server \
  --name feedbackhub-db
```

**Via Portal Azure**:
1. Azure Portal → SQL databases → feedbackhub-db
2. Connection strings
3. Copie a string JDBC

**Formato**:
```
jdbc:sqlserver://feedbackhub-server.database.windows.net:1433;database=feedbackhub-db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
```

⚠️ **Substitua** `feedbackhub-server` e `feedbackhub-db` pelos nomes reais!

---

### 3. DB_USERNAME

**O que é**: Nome de usuário administrador do SQL Server

**Como obter via Azure CLI**:
```bash
az sql server show \
  --name feedbackhub-server \
  --resource-group feedbackhub-rg \
  --query "administratorLogin" -o tsv
```

**Valor comum**: `feedbackadmin`

---

### 4. DB_PASSWORD

**O que é**: Senha do usuário administrador do SQL Server

**Como obter**: É a senha que você definiu ao criar o SQL Server

**Se não lembra**, pode resetar:
```bash
az sql server update \
  --name feedbackhub-server \
  --resource-group feedbackhub-rg \
  --admin-password "NovaSenhaSegura123!"
```

⚠️ **Importante**: Senha deve ter pelo menos 8 caracteres, incluindo maiúsculas, minúsculas e números

---

### 5. AZURE_STORAGE_CONNECTION_STRING

**O que é**: Connection string para acessar o Azure Storage Account

**Como obter via Azure CLI**:
```bash
az storage account show-connection-string \
  --name feedbackhubstorage \
  --resource-group feedbackhub-rg \
  --query "connectionString" -o tsv
```

**Via Portal Azure**:
1. Azure Portal → Storage accounts → feedbackhubstorage
2. Access keys
3. Clique em "Show keys"
4. Copie "Connection string" da key1

**Formato**:
```
DefaultEndpointsProtocol=https;AccountName=feedbackhubstorage;AccountKey=xxxxxxxx==;EndpointSuffix=core.windows.net
```

---

### 6. SENDGRID_API_KEY

**O que é**: Chave de API para enviar e-mails via SendGrid

**Como obter**:
1. Acesse [SendGrid Dashboard](https://app.sendgrid.com)
2. Settings → API Keys
3. Create API Key
4. Nome: `feedbackhub-production`
5. Tipo: Full Access (ou pelo menos Mail Send)
6. ⚠️ **Importante**: A chave aparece apenas uma vez! Copie imediatamente

**Formato**:
```
SG.xxxxxxxxxxxxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

**Alternativa**: Azure Communication Services
```bash
az communication show \
  --name feedbackhub-communication \
  --resource-group feedbackhub-rg \
  --query "connectionString" -o tsv
```

---

### 7. ADMIN_EMAILS

**O que é**: E-mails dos administradores que receberão notificações de urgência

**Como definir**: Você escolhe os e-mails

**Formato**: E-mails separados por **vírgula SEM espaços**

**Exemplos válidos**:
```
admin@fiap.com.br
```
```
admin@fiap.com.br,gestor@fiap.com.br
```
```
admin@fiap.com.br,gestor@fiap.com.br,coordenador@fiap.com.br
```

❌ **ERRADO**: `admin@fiap.com.br, gestor@fiap.com.br` (tem espaço)  
✅ **CERTO**: `admin@fiap.com.br,gestor@fiap.com.br` (sem espaço)

**Quando são usados**: Notificações de feedbacks com urgência ALTA

---

### 8. REPORT_EMAILS

**O que é**: E-mails que receberão os relatórios semanais automáticos

**Como definir**: Você escolhe os e-mails

**Formato**: E-mails separados por **vírgula SEM espaços**

**Exemplos válidos**:
```
relatorios@fiap.com.br
```
```
relatorios@fiap.com.br,gestao@fiap.com.br
```
```
relatorios@fiap.com.br,gestao@fiap.com.br,diretoria@fiap.com.br
```

**Quando são usados**: Relatórios semanais (toda segunda-feira às 9h)

**Dica**: Podem ser os mesmos e-mails de ADMIN_EMAILS ou diferentes

---

## 📝 Como Adicionar no GitHub

### Passo 1: Acessar Configurações
```
1. Acesse: https://github.com/SEU_USUARIO/feedbackhub
2. Clique: Settings (configurações)
3. Menu lateral: Secrets and variables → Actions
4. Botão: New repository secret
```

### Passo 2: Adicionar Cada Secret
Para **cada um dos 8 secrets**:

1. Clique em: **New repository secret**
2. No campo **Name**: Cole o nome EXATO (ex: `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`)
3. No campo **Secret**: Cole o valor
4. Clique: **Add secret**
5. Repita para os próximos

⚠️ **IMPORTANTE**: 
- Nomes devem estar EXATAMENTE como mostrado (maiúsculas/minúsculas importam!)
- Copie/cole para evitar erros de digitação

---

## ✅ Validação

Após adicionar todos, você deve ver no GitHub:

```
Settings → Secrets and variables → Actions

Repository secrets (8)

✅ ADMIN_EMAILS
✅ AZURE_FUNCTIONAPP_PUBLISH_PROFILE
✅ AZURE_STORAGE_CONNECTION_STRING
✅ DB_PASSWORD
✅ DB_URL
✅ DB_USERNAME
✅ REPORT_EMAILS
✅ SENDGRID_API_KEY
```

Se tiver **exatamente 8 secrets**, está correto! ✅

---

## 🧪 Testar

Após configurar todos os 8 secrets:

```bash
git add .
git commit -m "test: secrets configurados para deploy automático"
git push origin main
```

Acompanhe em: **GitHub → Actions → Deploy Azure Functions**

---

## 🆘 Problemas Comuns

### "Secret XXX not found"
❌ **Problema**: Nome do secret está incorreto  
✅ **Solução**: Verifique maiúsculas/minúsculas, use os nomes exatos

### "Authentication failed"
❌ **Problema**: AZURE_FUNCTIONAPP_PUBLISH_PROFILE incorreto  
✅ **Solução**: Execute `./get-publish-profile.sh` novamente

### "Database connection failed"
❌ **Problema**: DB_URL, DB_USERNAME ou DB_PASSWORD incorretos  
✅ **Solução**: Verifique os valores com `./collect-secrets.sh`

### "Storage connection failed"
❌ **Problema**: AZURE_STORAGE_CONNECTION_STRING incorreto  
✅ **Solução**: Obtenha novamente do Portal Azure

### "Email send failed"
❌ **Problema**: SENDGRID_API_KEY incorreto ou expirado  
✅ **Solução**: Gere nova API Key no SendGrid

---

## 📚 Comandos Úteis

### Coletar todos os valores automaticamente
```bash
./collect-secrets.sh
```

### Obter apenas publish profile
```bash
./get-publish-profile.sh
```

### Ver valores coletados
```bash
cat github-secrets-values.txt
```

### Limpar arquivo de secrets (após uso)
```bash
rm github-secrets-values.txt
```

---

## 🔒 Segurança

### ✅ Boas Práticas

- ✅ Secrets ficam criptografados no GitHub
- ✅ Nunca commite secrets no código
- ✅ Use `.gitignore` para arquivos sensíveis
- ✅ Rotate credentials a cada 90 dias
- ✅ Use diferentes secrets para staging/production

### ⚠️ NUNCA Commite

❌ `github-secrets-values.txt`  
❌ `publish-profile.xml`  
❌ `local.settings.json`  
❌ `azure-credentials.txt`  

Todos esses arquivos já estão (ou devem estar) no `.gitignore`

---

## 🎯 Checklist Final

Antes do primeiro deploy:

- [ ] Executei `./collect-secrets.sh` ou `./get-publish-profile.sh`
- [ ] Adicionei os 8 secrets no GitHub
- [ ] Verifiquei que todos os nomes estão corretos
- [ ] Testei com `git push origin main`
- [ ] Vi o workflow executar no GitHub Actions
- [ ] Deploy foi bem-sucedido
- [ ] Deletei `github-secrets-values.txt`

---

## 📖 Documentação Relacionada

- **[COMECE-DEPLOY-AUTOMATICO.md](COMECE-DEPLOY-AUTOMATICO.md)** - Guia de 3 passos
- **[DEPLOY-AUTOMATICO-QUICKSTART.md](DEPLOY-AUTOMATICO-QUICKSTART.md)** - Quick start
- **[CONFIGURAR-DEPLOY-AUTOMATICO.md](CONFIGURAR-DEPLOY-AUTOMATICO.md)** - Guia completo

---

## 🎉 Conclusão

Após configurar os 8 secrets, seu deploy automático estará 100% funcional!

**Próximo push = Deploy automático! 🚀**

```bash
git push origin main  # ✨ Magic!
```

---

*Criado em: 19 de Fevereiro de 2026*  
*Versão: 1.0.0*  
*Status: ✅ Production Ready*

