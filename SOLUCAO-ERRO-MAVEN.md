# ✅ SOLUÇÃO DO ERRO - Maven Deploy

## 📋 Problema Encontrado

```
[ERROR] Failed to execute goal com.microsoft.azure:azure-functions-maven-plugin:1.34.0:package (package-functions) on project feedbackhub: generate configuration files and prepare staging directory: <appName> is not configured in pom
```

**Causa**: O Maven não consegue ler variáveis de ambiente (`$FUNC_NAME`) diretamente no comando `-DfunctionAppName`.

---

## ✅ Solução Implementada

Criei um **script de deploy automatizado** que resolve tudo:

### **`deploy.sh`** ⭐ (NOVO!)

Este script:
1. ✅ Descobre o Function App automaticamente
2. ✅ Atualiza o `pom.xml` temporariamente
3. ✅ Faz o deploy
4. ✅ Restaura o `pom.xml` original

---

## 🚀 Como Usar (MUITO MAIS FÁCIL!)

### Passo 1: Criar Function App (se ainda não criou)
```bash
./create-function-app-only.sh
```
**Aguarde** 2-3 minutos até o comando terminar.

### Passo 2: Deploy Automatizado
```bash
./deploy.sh
```

**Pronto!** O script faz tudo automaticamente! 🎉

---

## 📖 O Que o Script Faz

```bash
./deploy.sh
```

1. **Descobre** o nome do Function App:
   ```bash
   az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv
   ```

2. **Atualiza** temporariamente o `pom.xml` com o nome correto

3. **Faz deploy**:
   ```bash
   mvn clean package azure-functions:deploy
   ```

4. **Restaura** o `pom.xml` original

---

## ⚠️ IMPORTANTE

Você precisa **AGUARDAR** o script `create-function-app-only.sh` terminar antes de executar `deploy.sh`!

### Como Saber se Terminou?

O terminal vai mostrar algo como:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ FUNCTION APP CRIADO COM SUCESSO!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Function App: feedbackhub-func-XXXXXX
URL: https://feedbackhub-func-XXXXXX.azurewebsites.net
```

---

## 🆘 Se o Script Ainda Está Rodando

Abra **outro terminal** e execute:

```bash
# Verificar se Function App foi criado
az functionapp list --resource-group feedbackhub-rg --output table

# Se aparecer na lista, você pode executar:
./deploy.sh
```

---

## 📊 Monitorar Criação do Function App

Em outro terminal:

```bash
watch -n 5 'az functionapp list --resource-group feedbackhub-rg --query "[].{Name:name, State:state}" -o table'
```

Quando aparecer o Function App com `State: Running`, está pronto!

---

## 🎯 Resumo da Solução

### ❌ Antes (NÃO FUNCIONA):
```bash
FUNC_NAME=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv) && \
mvn clean package azure-functions:deploy -DfunctionAppName=$FUNC_NAME
```

### ✅ Agora (FUNCIONA):
```bash
./deploy.sh
```

---

## 📋 Checklist

- [ ] `create-function-app-only.sh` executado
- [ ] Aguardou o Function App ser criado (2-3 min)
- [ ] Verificou que o Function App existe: `az functionapp list --resource-group feedbackhub-rg --output table`
- [ ] Executou `./deploy.sh`
- [ ] Deploy concluído com sucesso! ✅

---

## 💡 Outras Opções (Se Preferir)

### Opção 1: Atualizar pom.xml Manualmente

1. Descubra o nome:
```bash
az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv
```

2. Edite `pom.xml` linha 32:
```xml
<functionAppName>feedbackhub-func-XXXXXX</functionAppName>
```

3. Deploy:
```bash
mvn clean package azure-functions:deploy
```

### Opção 2: Executar o Script Principal (Vai Duplicar Recursos)

```bash
./azure-setup.sh
```

⚠️ Vai criar NOVOS recursos (custos extras)

---

## ⏰ Tempo Total

- Criar Function App: 2-3 min (aguardar!)
- Deploy: 3-5 min
- **TOTAL: 5-8 minutos**

---

**Execute agora: `./deploy.sh` (depois que o Function App estiver pronto!)** 🚀

