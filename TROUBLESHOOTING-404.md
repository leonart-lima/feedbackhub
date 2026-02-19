# Troubleshooting: Erro 404 na API

## Problema
Ao chamar `POST https://feedbackhub-func.azurewebsites.net/api/avaliacao?code=...`, retorna **404 Not Found**.

## Causa Raiz Mais Provável
O Spring Context **falha ao inicializar** porque faltam variáveis de ambiente obrigatórias no Azure Function App, causando:
1. Spring não consegue criar o bean `EmailService` (requer `SENDGRID_API_KEY`, `SENDGRID_FROM_EMAIL`, `SENDGRID_FROM_NAME`)
2. Function não carrega corretamente
3. Azure retorna 404 (em vez de 500) porque a rota não está registrada

## Solução: Adicionar as variáveis de ambiente faltantes

### Passo 1: Verificar quais variáveis estão faltando
No Portal Azure:
1. Vá em **Function App** → `feedbackhub-func`
2. **Settings** → **Environment variables** (ou **Configuration**)
3. Verifique se existem:

**Obrigatórias para o Spring inicializar:**
```
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=seu-email-verificado@dominio.com
SENDGRID_FROM_NAME=FeedbackHub
```

**Já existem (verificadas no local.settings.json):**
```
DB_URL=jdbc:sqlserver://...
DB_USERNAME=azureuser
DB_PASSWORD=FeedbackHub@2026!
AZURE_STORAGE_CONNECTION_STRING=...
ADMIN_EMAILS=leonart16@gmail.com
REPORT_EMAILS=leonart16@gmail.com
```

### Passo 2: Adicionar via Azure CLI

```bash
# Login
az login

# Adicionar as variáveis SendGrid
az functionapp config appsettings set \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --settings \
    "SENDGRID_API_KEY=SG.sua-api-key-aqui" \
    "SENDGRID_FROM_EMAIL=seu-email-verificado@gmail.com" \
    "SENDGRID_FROM_NAME=FeedbackHub"
```

### Passo 3: Verificar logs após adicionar

```bash
# Ver logs em tempo real
az functionapp log tail \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg
```

Procure por:
- ✅ `Spring Context inicializado com sucesso`
- ✅ `EmailService inicializado com SendGrid`

### Passo 4: Testar novamente

```bash
curl -i -X POST "https://feedbackhub-func.azurewebsites.net/api/avaliacao?code=Gpvd-wq3cOwa1it0Srk7oNHTKWqYR4gywH0s-TBy3iHiAzFuSIiQQQ==" \
  -H "Content-Type: application/json" \
  -d '{"descricao":"Teste após correção","nota":8}'
```

Esperado: **200 OK** com JSON de resposta.

---

## Outras Causas Possíveis (se não for variável de ambiente)

### 1. Método HTTP errado
- ❌ GET → retorna 404
- ✅ POST → funciona

Se você abriu no navegador, ele usa GET. Use curl/Postman com POST.

### 2. Function App errado ou desatualizado
Verifique se o nome está correto:
```bash
az functionapp list \
  --resource-group feedbackhub-rg \
  --query "[].{name:name, state:state}" \
  --output table
```

### 3. Deploy não aplicado
Faça redeploy:
```bash
mvn clean package azure-functions:deploy
```

### 4. Function Key errada
Pegue a key correta:
```bash
az functionapp function keys list \
  --name feedbackhub-func \
  --resource-group feedbackhub-rg \
  --function-name receberAvaliacao
```

---

## Como obter API Key do SendGrid

1. Acesse: https://app.sendgrid.com/
2. **Settings** → **API Keys**
3. **Create API Key**
   - Name: `feedbackhub-production`
   - Permissions: **Full Access** (ou pelo menos "Mail Send")
4. Copie a key (começa com `SG.`)
5. ⚠️ **Guarde em local seguro**, ela só aparece uma vez

### Verificar e-mail remetente
1. **Settings** → **Sender Authentication**
2. **Verify a Single Sender**
3. Adicione e verifique seu e-mail (ex: `leonart16@gmail.com`)
4. Use esse e-mail em `SENDGRID_FROM_EMAIL`

---

## Verificação Rápida (Checklist)

- [ ] Variáveis `SENDGRID_*` adicionadas no Function App
- [ ] E-mail remetente verificado no SendGrid
- [ ] Function App reiniciado (ou aguardado 1-2 min)
- [ ] Testado com **POST** (não GET)
- [ ] Function Key correta na URL
- [ ] Logs mostram "Spring Context inicializado"

---

## Próximos Passos após Correção

1. Testar avaliação positiva (nota 8)
2. Testar avaliação crítica (nota 2) → deve enviar e-mail
3. Verificar no SendGrid se e-mail foi enviado
4. Testar relatório manual: `GET /api/relatorio/manual?code=...`

