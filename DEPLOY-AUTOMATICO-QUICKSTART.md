# ⚡ Quick Start: Deploy Automático GitHub → Azure

## 🎯 Objetivo
Configurar deploy automático em **5 minutos**

---

## 🚀 Comando Rápido

```bash
# 1. Obter publish profile
./get-publish-profile.sh

# 2. O conteúdo já está na área de transferência!
# 3. Vá para GitHub → Settings → Secrets → Actions
# 4. Crie: AZURE_FUNCTIONAPP_PUBLISH_PROFILE
# 5. Cole (Cmd+V) e salve
```

---

## 📦 Secrets Necessários

Configure estes secrets no GitHub (Settings → Secrets and variables → Actions):

| Secret Name | Onde Encontrar | Exemplo |
|------------|----------------|---------|
| `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` | Execute `./get-publish-profile.sh` | `<publishData>...</publishData>` |
| `DB_URL` | Azure Portal → SQL Database → Connection strings | `jdbc:sqlserver://...` |
| `DB_USERNAME` | Usuário do banco | `feedbackadmin` |
| `DB_PASSWORD` | Senha do banco | `****` |
| `AZURE_STORAGE_CONNECTION_STRING` | Azure Portal → Storage Account → Access keys | `DefaultEndpointsProtocol=https;...` |
| `SENDGRID_API_KEY` | SendGrid Dashboard → API Keys | `SG.xxxxxxx` |
| `ADMIN_EMAILS` | Definir manualmente | `admin@fiap.com.br` |
| `REPORT_EMAILS` | Definir manualmente | `reports@fiap.com.br` |

---

## 🔄 Como Funciona

```
┌─────────────────┐
│  git push main  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ GitHub Actions  │  ← Detecta push
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Build Maven    │  ← mvn clean package
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Run Tests     │  ← mvn test
└────────┬────────��
         │
         ▼
┌─────────────────┐
│ Deploy Azure    │  ← Azure Functions Action
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  ✅ LIVE!       │  ← https://feedbackhub-func.azurewebsites.net
└─────────────────┘
```

**Tempo total**: ~3-5 minutos

---

## 📝 Testar Deploy

```bash
# Fazer uma mudança
echo "# Deploy automático" >> README.md

# Commit e push
git add .
git commit -m "test: deploy automático"
git push origin main

# Acompanhar no GitHub
# GitHub → Actions → Deploy Azure Functions
```

---

## 🔍 Verificar Status

### GitHub
```
https://github.com/SEU_USUARIO/SEU_REPO/actions
```

### Azure CLI
```bash
az functionapp show \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --query "state"
```

### Testar API
```bash
curl https://feedbackhub-func.azurewebsites.net/api/avaliacoes
```

---

## ⚠️ Troubleshooting Rápido

| Erro | Solução |
|------|---------|
| Secret not found | Adicione o secret no GitHub |
| Build failed | Execute `mvn clean package` localmente |
| Deploy failed | Verifique publish profile |
| 401/403 error | Regenere o publish profile |

---

## 📚 Documentação Completa

Para mais detalhes, consulte:
- [CONFIGURAR-DEPLOY-AUTOMATICO.md](./CONFIGURAR-DEPLOY-AUTOMATICO.md)

---

## ✅ Checklist

- [ ] Executei `./get-publish-profile.sh`
- [ ] Adicionei `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` no GitHub
- [ ] Adicionei todos os outros secrets
- [ ] Fiz push para `main`
- [ ] Vi o workflow executar no GitHub Actions
- [ ] Testei a API no Azure

---

**🎉 Pronto! Agora todo push vai gerar deploy automático!**

