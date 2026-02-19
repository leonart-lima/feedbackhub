# 🔧 Atualizar pom.xml com Nome do Function App

## 📋 Problema

O `pom.xml` precisa saber o nome do seu Function App para fazer o deploy.

Atualmente está configurado como:
```xml
<functionAppName>feedbackhub-func</functionAppName>
```

Mas o Function App criado tem um nome diferente (com timestamp).

---

## ✅ Solução

### 1️⃣ Descobrir o Nome do Function App

Execute:
```bash
az functionapp list --resource-group feedbackhub-rg --query "[].name" -o tsv
```

Você verá algo como:
```
feedbackhub-func-123456
```

### 2️⃣ Atualizar o pom.xml

Edite o arquivo `pom.xml` e altere a linha 32:

**Antes:**
```xml
<functionAppName>feedbackhub-func</functionAppName>
```

**Depois** (substitua pelo nome real):
```xml
<functionAppName>feedbackhub-func-123456</functionAppName>
```

### 3️⃣ Fazer o Deploy

```bash
mvn clean package azure-functions:deploy
```

---

## 🚀 Forma Rápida (Comando Único)

```bash
# Obter o nome do Function App
FUNCTION_APP_NAME=$(az functionapp list --resource-group feedbackhub-rg --query "[0].name" -o tsv)

# Mostrar o nome
echo "Function App Name: $FUNCTION_APP_NAME"

# Fazer deploy usando o nome descoberto
mvn clean package azure-functions:deploy \
  -DfunctionAppName=$FUNCTION_APP_NAME \
  -DfunctionResourceGroup=feedbackhub-rg \
  -DfunctionAppRegion=brazilsouth
```

---

## 📝 Atualização Manual do pom.xml

Se preferir editar manualmente:

1. Abra `pom.xml`
2. Procure a linha 32
3. Altere `feedbackhub-func` para o nome descoberto
4. Salve o arquivo
5. Execute: `mvn clean package azure-functions:deploy`

---

## ✅ Verificar Após Deploy

```bash
# Ver funções deployadas
az functionapp function list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --output table

# Deve mostrar:
# - receberAvaliacao
# - notificarUrgencia
# - gerarRelatorioSemanal
```

---

## 💡 Dica

Use o comando com parâmetros `-D` para não precisar editar o arquivo:

```bash
mvn clean package azure-functions:deploy \
  -DfunctionAppName=feedbackhub-func-XXXXXX
```

---

**Recomendação**: Use a forma rápida (comando único) ⚡

