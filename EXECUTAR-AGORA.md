# ⚡ EXECUTAR AGORA - Configuração Final

## 🎯 SITUAÇÃO

Você tem:
- ✅ Function App `feedbackhub-func` deployado e rodando
- ✅ Function App `feedbackhub-func-55878` (antigo) com todas as configurações
- ✅ Todos os recursos Azure criados (SQL, Storage, Communication Service)

**Falta apenas**: Copiar as configurações do antigo para o novo!

---

## 🚀 SOLUÇÃO EM 3 COMANDOS

Execute estes comandos **um de cada vez** no terminal:

### 1️⃣ Exportar configurações do Function App antigo

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

az functionapp config appsettings list \
  --name feedbackhub-func-55878 \
  --resource-group feedbackhub-rg \
  --query "[?starts_with(name, 'DB_') || starts_with(name, 'AZURE_STORAGE_CONNECTION') || starts_with(name, 'AZURE_COMMUNICATION') || starts_with(name, 'ADMIN_') || starts_with(name, 'REPORT_') || name == 'WEBSITE_TIME_ZONE'].{name:name, value:value}" \
  -o json > app-settings.json
```

**Aguarde terminar** (pode demorar 30-60 segundos)

### 2️⃣ Ver as configurações exportadas

```bash
cat app-settings.json | jq .
```

**Você deve ver**: DB_URL, DB_USERNAME, DB_PASSWORD, AZURE_STORAGE_CONNECTION_STRING, etc.

### 3️⃣ Aplicar configurações no novo Function App

```bash
# Método A: Via Azure Portal (MAIS RÁPIDO) ⭐
echo "Acesse: https://portal.azure.com"
echo "Navegue: Resource Groups > feedbackhub-rg > feedbackhub-func > Configuration"
echo "Copie manualmente cada variável do arquivo app-settings.json"
echo ""
echo "Ou use o Método B abaixo..."

# Método B: Via CLI (se o Portal estiver lento)
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings @app-settings.json
```

---

## 🎯 MÉTODO RECOMENDADO: AZURE PORTAL

Se a Azure CLI estiver lenta, use o Portal (é mais rápido):

### Passo a Passo:

1. **Abra o arquivo de configurações**:
   ```bash
   cat app-settings.json
   ```

2. **Copie os valores** (anote num papel ou deixe o terminal aberto)

3. **Acesse o Portal Azure**:
   - URL: https://portal.azure.com
   - Login com suas credenciais

4. **Navegue até o Function App**:
   - **Resource Groups** > **feedbackhub-rg**
   - Clique em **feedbackhub-func** (o novo)

5. **Abra Configuration**:
   - Menu lateral: **Settings** > **Configuration**
   - Aba: **Application settings**

6. **Adicione cada variável**:
   - Clique **+ New application setting**
   - Copie `name` e `value` do app-settings.json
   - Clique **OK**

   **Variáveis para adicionar**:
   - `DB_URL`
   - `DB_USERNAME`
   - `DB_PASSWORD`
   - `AZURE_STORAGE_CONNECTION_STRING`
   - `AZURE_COMMUNICATION_CONNECTION_STRING`
   - `AZURE_COMMUNICATION_FROM_EMAIL`
   - `ADMIN_EMAILS`
   - `REPORT_EMAILS`
   - `WEBSITE_TIME_ZONE`

7. **Salvar**:
   - Clique **Save** no topo
   - Clique **Continue** na confirmação
   - Aguarde ~30 segundos para aplicar

---

## 🧪 TESTAR APÓS CONFIGURAÇÃO

### Aguarde 1-2 minutos após salvar, então teste:

```bash
curl -X POST \
  "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \
  -H "Content-Type: application/json" \
  -d '{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste final!","categoria":"PRODUTO"}' \
  -w "\n\nHTTP Status: %{http_code}\n"
```

### Resultado Esperado:

```json
{
  "id": 1,
  "clienteId": 1,
  "produtoId": 101,
  "nota": 5,
  "comentario": "Teste final!",
  "categoria": "PRODUTO",
  "urgente": false,
  "dataAvaliacao": "2026-02-18T..."
}

HTTP Status: 200
```

✅ **SE DER 200**: Tudo funcionando! Pode começar a usar!

❌ **SE DER 500**: Verifique os logs:
```bash
az webapp log tail --name feedbackhub-func --resource-group feedbackhub-rg
```

---

## 📋 CHECKLIST RÁPIDO

Execute e marque:

- [ ] Comando 1 executado (exportar configurações)
- [ ] Arquivo `app-settings.json` criado
- [ ] Configurações visualizadas com `cat app-settings.json`
- [ ] Portal Azure aberto
- [ ] Navegado até feedbackhub-func > Configuration
- [ ] Todas as variáveis adicionadas
- [ ] Clicado em Save
- [ ] Aguardado 1-2 minutos
- [ ] Teste com curl executado
- [ ] Resposta 200 OK recebida ✅

---

## 🔑 INFORMAÇÕES IMPORTANTES

### URLs:
- **Portal Azure**: https://portal.azure.com
- **Function App URL**: https://feedbackhub-func.azurewebsites.net
- **API Endpoint**: https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao

### Credenciais:
- **Function Key**: `vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==`
- **Resource Group**: feedbackhub-rg
- **SQL Server**: feedbackhub-server-55878
- **SQL User**: azureuser
- **SQL Password**: FeedbackHub@2026!

---

## 💡 DICA PROFISSIONAL

Você tem 2 Function Apps agora:

1. **feedbackhub-func-55878** (antigo) - Funcionando com configurações
2. **feedbackhub-func** (novo) - Código mais recente, sem configurações

**Opções**:

### A) Manter ambos (para teste/produção)
- Antigo: Produção temporária
- Novo: Teste até validar

### B) Usar apenas o novo (recomendado)
- Configure o novo
- Teste
- Delete o antigo para economizar recursos:
  ```bash
  az functionapp delete --name feedbackhub-func-55878 --resource-group feedbackhub-rg
  ```

---

## 🆘 SE TUDO MAIS FALHAR

Execute este comando all-in-one:

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    DB_URL="jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" \
    DB_USERNAME="azureuser" \
    DB_PASSWORD="FeedbackHub@2026!" \
    WEBSITE_TIME_ZONE="E. South America Standard Time" \
    ADMIN_EMAILS="admin@feedbackhub.com" \
    REPORT_EMAILS="reports@feedbackhub.com"
```

**Nota**: Isso configura o básico. Você ainda precisará das connection strings do Storage e Communication Service.

---

## 🎉 PRÓXIMOS PASSOS APÓS FUNCIONAR

1. ✅ Testar todas as funções
2. ✅ Validar envio de e-mails
3. ✅ Testar avaliações urgentes
4. ✅ Verificar relatórios
5. ✅ Configurar monitoramento
6. ✅ Deletar Function App antigo (opcional)

---

**🚀 COMECE AGORA! Execute o comando 1 e siga o checklist!**

