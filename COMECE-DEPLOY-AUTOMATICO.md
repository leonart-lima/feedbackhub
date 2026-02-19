# 🚀 COMECE AQUI: Deploy Automático em 3 Passos

## ✅ Pré-requisito: Tudo Já Está Configurado!

O workflow do GitHub Actions já está criado e otimizado em `.github/workflows/deploy.yml`

---

## 📋 3 Passos para Ativar

### 🔐 PASSO 1: Obter Credenciais do Azure (1 minuto)

Execute este comando:

```bash
./get-publish-profile.sh
```

✅ O conteúdo será **copiado automaticamente** para sua área de transferência!

---

### 🔑 PASSO 2: Configurar Secrets no GitHub (3 minutos)

1. Acesse seu repositório no GitHub
2. Vá em: **Settings** → **Secrets and variables** → **Actions**
3. Clique em: **New repository secret**
4. Adicione cada secret abaixo:

#### Secret 1: AZURE_FUNCTIONAPP_PUBLISH_PROFILE
```
Name: AZURE_FUNCTIONAPP_PUBLISH_PROFILE
Value: [Cole o conteúdo copiado do Passo 1]
```

#### Secret 2: DB_URL
```
Name: DB_URL
Value: jdbc:sqlserver://feedbackhub-server.database.windows.net:1433;database=feedbackhub-db;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
```

#### Secret 3: DB_USERNAME
```
Name: DB_USERNAME
Value: feedbackadmin
```

#### Secret 4: DB_PASSWORD
```
Name: DB_PASSWORD
Value: [Sua senha do banco de dados]
```

#### Secret 5: AZURE_STORAGE_CONNECTION_STRING
```
Name: AZURE_STORAGE_CONNECTION_STRING
Value: [Connection string do Azure Storage]
```
💡 **Como obter**: Azure Portal → Storage Account → Access keys → Connection string

#### Secret 6: SENDGRID_API_KEY
```
Name: SENDGRID_API_KEY
Value: [Sua API Key do SendGrid]
```
💡 **Como obter**: SendGrid Dashboard → Settings → API Keys

#### Secret 7: ADMIN_EMAILS
```
Name: ADMIN_EMAILS
Value: admin@fiap.com.br,gestor@fiap.com.br
```
💡 **Formato**: E-mails separados por vírgula

#### Secret 8: REPORT_EMAILS
```
Name: REPORT_EMAILS
Value: relatorios@fiap.com.br,gestao@fiap.com.br
```
💡 **Formato**: E-mails separados por vírgula

---

### 🧪 PASSO 3: Testar Deploy Automático (1 minuto)

Execute estes comandos:

```bash
# Adicionar alterações
git add .

# Fazer commit
git commit -m "feat: configurar deploy automático"

# Fazer push (isso irá disparar o deploy!)
git push origin main
```

---

## 👀 Acompanhar Execução

1. Acesse: `https://github.com/SEU_USUARIO/feedbackhub/actions`
2. Clique em: **Deploy Azure Functions** (workflow em execução)
3. Aguarde: ~3-5 minutos
4. Resultado: ✅ Deploy Concluído!

---

## 🎯 O Que Acontece Automaticamente

```
┌────────────────────────┐
│  Você faz git push     │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│  GitHub Actions        │
│  1. Build com Maven    │
│  2. Executar Testes    │
│  3. Deploy no Azure    │
│  4. Configurar App     │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│  ✅ Aplicação LIVE!    │
│  feedbackhub-func      │
│  .azurewebsites.net    │
└────────────────────────┘

Tempo total: 3-5 minutos
```

---

## 🔍 Verificar Sucesso

### No GitHub
✅ Status verde no workflow
✅ Todos os steps concluídos

### No Azure
```bash
# Verificar status
az functionapp show \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --query "state"

# Testar API
curl https://feedbackhub-func.azurewebsites.net/api/avaliacoes
```

---

## 🎉 Pronto! Agora Todo Push Faz Deploy Automático

```bash
# Seu novo fluxo de trabalho:
git add .
git commit -m "feat: nova funcionalidade"
git push origin main
# ✨ Deploy automático acontece!
# ⏱️ Aguarde 3-5 minutos
# ✅ Feature no ar!
```

---

## 🛠️ Scripts Úteis

### Menu Interativo
```bash
./deploy-commands.sh
```

### Verificar Pré-requisitos
```bash
./check-deploy-ready.sh
```

### Obter Novo Publish Profile
```bash
./get-publish-profile.sh
```

---

## 📚 Documentação Completa

- 📖 **[DEPLOY-AUTOMATICO-QUICKSTART.md](DEPLOY-AUTOMATICO-QUICKSTART.md)** - Quick start detalhado
- 📘 **[CONFIGURAR-DEPLOY-AUTOMATICO.md](CONFIGURAR-DEPLOY-AUTOMATICO.md)** - Guia completo
- 📊 **[DEPLOY-AUTOMATICO-RESUMO.md](DEPLOY-AUTOMATICO-RESUMO.md)** - Resumo visual
- 📋 **[DEPLOY-AUTOMATICO-INDEX.md](DEPLOY-AUTOMATICO-INDEX.md)** - Índice completo

---

## 🆘 Problemas?

### Workflow não executa
- Verifique se está na branch `main` ou `master`
- Verifique se Actions está habilitado no GitHub

### Build falha
```bash
# Testar localmente
mvn clean package
```

### Deploy falha
- Verifique se `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` está correto
- Execute `./get-publish-profile.sh` novamente

### Secrets faltando
- Verifique se todos os 8 secrets foram adicionados
- Nomes devem estar EXATAMENTE como mostrado acima

---

## ✅ Checklist Rápido

- [ ] Executei `./get-publish-profile.sh`
- [ ] Adicionei os 8 secrets no GitHub
- [ ] Fiz commit e push para `main`
- [ ] Vi o workflow executar
- [ ] Deploy foi bem-sucedido
- [ ] API está respondendo

---

**🎉 Parabéns! Deploy automático configurado com sucesso!**

**Próximo deploy**: Basta fazer `git push origin main` 🚀

