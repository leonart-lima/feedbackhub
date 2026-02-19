# 📋 Deploy Automático - Índice Completo

## 🎯 Visão Geral

Deploy automático configurado para FeedbackHub usando **GitHub Actions** + **Azure Functions**.

**Status**: ✅ Configurado e Pronto

---

## 📚 Documentação (Escolha por Necessidade)

### 🚀 Quer Começar Rápido? (5 min)
👉 **[DEPLOY-AUTOMATICO-QUICKSTART.md](DEPLOY-AUTOMATICO-QUICKSTART.md)**
- Setup rápido
- Tabela de secrets
- Comandos essenciais

### 📖 Quer Entender Tudo? (15 min)
👉 **[CONFIGURAR-DEPLOY-AUTOMATICO.md](CONFIGURAR-DEPLOY-AUTOMATICO.md)**
- Guia completo passo a passo
- Explicação detalhada
- Troubleshooting completo
- Boas práticas de segurança

### 📊 Quer um Resumo Visual?
👉 **[DEPLOY-AUTOMATICO-RESUMO.md](DEPLOY-AUTOMATICO-RESUMO.md)**
- Diagramas de fluxo
- Resumo executivo
- Melhorias futuras

---

## 🛠️ Scripts Utilitários

### Menu Interativo (RECOMENDADO)
```bash
./deploy-commands.sh
```
**Menu com todas operações:**
1. Obter publish profile
2. Ver status do deploy
3. Testar build local
4. Fazer deploy manual
5. Ver logs do Azure
6. Verificar Function App
7. Testar API
8. Abrir documentação

### Obter Credenciais do Azure
```bash
./get-publish-profile.sh
```
**O que faz:**
- Obtém publish profile automaticamente
- Copia para área de transferência
- Mostra próximos passos

---

## ⚡ Quick Start (3 Passos)

### 1️⃣ Obter Credenciais
```bash
./get-publish-profile.sh
```

### 2️⃣ Configurar GitHub Secrets
Acesse: `GitHub → Settings → Secrets and variables → Actions`

Adicione 8 secrets (veja tabela no [QUICKSTART](DEPLOY-AUTOMATICO-QUICKSTART.md))

### 3️⃣ Testar
```bash
git push origin main
```

---

## 📂 Estrutura de Arquivos

```
feedbackhub/
├── .github/
│   └── workflows/
│       └── deploy.yml                          ← Workflow GitHub Actions
│
├── 📚 DOCUMENTAÇÃO
│   ├── DEPLOY-AUTOMATICO-QUICKSTART.md         ← Quick Start (5 min)
│   ├── CONFIGURAR-DEPLOY-AUTOMATICO.md         ← Guia Completo (15 min)
│   ├── DEPLOY-AUTOMATICO-RESUMO.md             ← Resumo Visual
│   └── DEPLOY-AUTOMATICO-INDEX.md              ← Este arquivo
│
├── 🛠️ SCRIPTS
│   ├── deploy-commands.sh                      ← Menu interativo
│   └── get-publish-profile.sh                  ← Obter credenciais
│
└── README.md                                    ← Índice principal (atualizado)
```

---

## 🎯 Fluxo de Trabalho

```
┌─────────────────────────────────────────┐
│  1. Desenvolver Localmente              │
│     code .                              │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  2. Testar Localmente (Opcional)        │
│     mvn test                            │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  3. Commit e Push                       │
│     git add .                           │
│     git commit -m "feat: ..."          │
│     git push origin main                │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  4. GitHub Actions (AUTOMÁTICO)         │
│     ✅ Checkout código                  │
│     ✅ Setup Java 21                    │
│     ✅ Build Maven                      │
│     ✅ Run Tests                        │
│     ✅ Deploy Azure                     │
│     ✅ Sync Settings                    │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  5. Aplicação Live no Azure             │
│     ✅ https://feedbackhub-func         │
│        .azurewebsites.net               │
└─────────────────────────────────────────┘

⏱️  Tempo total: 3-5 minutos
```

---

## 🔑 Secrets Necessários (GitHub)

| # | Secret Name | Onde Encontrar |
|---|-------------|----------------|
| 1 | `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` | `./get-publish-profile.sh` |
| 2 | `DB_URL` | Azure Portal → SQL Database |
| 3 | `DB_USERNAME` | Setup inicial |
| 4 | `DB_PASSWORD` | Setup inicial |
| 5 | `AZURE_STORAGE_CONNECTION_STRING` | Azure Portal → Storage |
| 6 | `SENDGRID_API_KEY` | SendGrid Dashboard |
| 7 | `ADMIN_EMAILS` | `admin@fiap.com.br` |
| 8 | `REPORT_EMAILS` | `reports@fiap.com.br` |

**Como adicionar:**
`GitHub → Settings → Secrets and variables → Actions → New repository secret`

---

## 🧪 Como Testar

### Teste 1: Build Local
```bash
mvn clean package
```
Se passar, o deploy também passará.

### Teste 2: Push para GitHub
```bash
git add .
git commit -m "test: deploy automático"
git push origin main
```

### Teste 3: Verificar no GitHub Actions
```
https://github.com/SEU_USUARIO/feedbackhub/actions
```

### Teste 4: Verificar API
```bash
curl https://feedbackhub-func.azurewebsites.net/api/avaliacoes
```

---

## 📊 Monitoramento

### GitHub Actions
```
GitHub → Actions → Deploy Azure Functions → Ver logs
```

### Azure Portal
```
Portal → Function App → Monitoring → Log stream
```

### Azure CLI
```bash
# Status
az functionapp show --name feedbackhub-func --resource-group feedbackhub-rg

# Logs
az functionapp log tail --name feedbackhub-func --resource-group feedbackhub-rg
```

---

## 🆘 Troubleshooting

| Problema | Solução |
|----------|---------|
| Workflow não dispara | Verifique branch (main/master) |
| Build falha | Execute `mvn clean package` localmente |
| Deploy falha | Verifique publish profile no GitHub |
| 401/403 error | Regenere publish profile |
| Secrets não encontrados | Adicione todos os 8 secrets |

**Guia completo**: [CONFIGURAR-DEPLOY-AUTOMATICO.md](CONFIGURAR-DEPLOY-AUTOMATICO.md#-troubleshooting)

---

## 🎓 Recursos de Aprendizado

### GitHub Actions
- [Documentação Oficial](https://docs.github.com/actions)
- [Sintaxe de Workflow](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions)
- [Secrets e Variáveis](https://docs.github.com/actions/security-guides/encrypted-secrets)

### Azure Functions
- [Deploy com GitHub Actions](https://docs.microsoft.com/azure/azure-functions/functions-how-to-github-actions)
- [Publish Profile](https://docs.microsoft.com/azure/azure-functions/functions-deployment-technologies#publish-profile)
- [App Settings](https://docs.microsoft.com/azure/azure-functions/functions-how-to-use-azure-function-app-settings)

### CI/CD Best Practices
- [The Twelve-Factor App](https://12factor.net/)
- [CI/CD Pipeline](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)

---

## ✅ Checklist de Configuração

### Pré-Deploy
- [ ] Azure Function App criada (`feedbackhub-func`)
- [ ] Banco de dados SQL configurado
- [ ] Storage Account configurado
- [ ] SendGrid ou ACS configurado
- [ ] Repositório no GitHub

### Configuração CI/CD
- [ ] Executado `./get-publish-profile.sh`
- [ ] Adicionado `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` no GitHub
- [ ] Adicionado `DB_URL` no GitHub
- [ ] Adicionado `DB_USERNAME` no GitHub
- [ ] Adicionado `DB_PASSWORD` no GitHub
- [ ] Adicionado `AZURE_STORAGE_CONNECTION_STRING` no GitHub
- [ ] Adicionado `SENDGRID_API_KEY` no GitHub
- [ ] Adicionado `ADMIN_EMAILS` no GitHub
- [ ] Adicionado `REPORT_EMAILS` no GitHub

### Teste e Validação
- [ ] Push realizado para `main`
- [ ] Workflow executado com sucesso
- [ ] Aplicação acessível no Azure
- [ ] API testada e funcionando
- [ ] E-mails sendo enviados
- [ ] Logs verificados

### Documentação
- [ ] Lido o Quick Start
- [ ] Revisado guia completo
- [ ] Scripts testados
- [ ] Equipe treinada

---

## 🎯 Próximos Passos (Opcional)

### Nível 1: Básico (Atual) ✅
- ✅ Deploy automático em push
- ✅ Build e testes
- ✅ Secrets gerenciados

### Nível 2: Intermediário
- [ ] Deploy em múltiplos ambientes (staging/prod)
- [ ] Testes de integração automatizados
- [ ] Notificações (Slack, Email)
- [ ] Badge de status no README

### Nível 3: Avançado
- [ ] Code quality (SonarQube)
- [ ] Security scanning (CodeQL)
- [ ] Performance testing
- [ ] Rollback automático
- [ ] Blue-Green deployment

---

## 🔐 Segurança

### ✅ Implementado
- ✅ Secrets no GitHub (não no código)
- ✅ Publish profile com acesso limitado
- ✅ Logs sanitizados
- ✅ HTTPS obrigatório

### 📋 Recomendações
- 🔄 Rotate secrets a cada 90 dias
- 👁️ Review logs regularmente
- 🔒 Use Azure Key Vault para production
- 👥 Limite acesso ao repositório
- 📝 Documente mudanças de configuração

---

## 📞 Suporte

### Problemas?
1. Consulte [Troubleshooting](CONFIGURAR-DEPLOY-AUTOMATICO.md#-troubleshooting)
2. Execute `./deploy-commands.sh` para diagnóstico
3. Verifique logs no GitHub Actions
4. Verifique logs no Azure Portal

### Comandos de Diagnóstico
```bash
# Menu interativo
./deploy-commands.sh

# Status Azure
az functionapp show --name feedbackhub-func --resource-group feedbackhub-rg

# Logs em tempo real
az functionapp log tail --name feedbackhub-func --resource-group feedbackhub-rg

# Teste API
curl https://feedbackhub-func.azurewebsites.net/api/avaliacoes
```

---

## 🎉 Conclusão

**Deploy automático está 100% configurado!**

### O Que Você Tem Agora
✅ CI/CD profissional
✅ Deploy em minutos
✅ Testes automáticos
✅ Secrets seguros
✅ Documentação completa
✅ Scripts auxiliares

### Como Usar
```bash
# Desenvolvimento normal
code .
git add .
git commit -m "feat: minha feature"
git push origin main

# ✨ Deploy acontece automaticamente!
# ⏱️  3-5 minutos depois...
# ✅ Live no Azure!
```

---

**Documentação Criada em**: 2026-02-19
**Versão**: 1.0.0
**Status**: ✅ Production Ready

**🚀 Happy Coding!**

