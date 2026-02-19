# 📧 Configuração de E-mails - FeedbackHub

## 📍 E-mails Atualmente Configurados

### 🚨 Notificações de Urgência
**Variável**: `ADMIN_EMAILS`  
**E-mail configurado**: `admin@feedbackhub.com`  
**Quando recebe**: Quando uma avaliação com nota ≤ 3 é registrada  
**Tipo de e-mail**: Notificação urgente com HTML formatado

### 📊 Relatórios Semanais
**Variável**: `REPORT_EMAILS`  
**E-mail configurado**: `relatorios@feedbackhub.com`  
**Quando recebe**: Toda segunda-feira às 09:00 UTC (06:00 Brasília)  
**Tipo de e-mail**: Relatório semanal com estatísticas

### 📤 E-mail Remetente
**Variável**: `AZURE_COMMUNICATION_FROM_EMAIL`  
**E-mail configurado**: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`  
**Observação**: E-mail do Azure Communication Services

---

## ⚠️ IMPORTANTE: E-mails Fictícios

Os e-mails `admin@feedbackhub.com` e `relatorios@feedbackhub.com` são **fictícios** e configurados apenas para demonstração.

### Para Testar com E-mail Real

#### Opção 1: Alterar o `local.settings.json`
```json
{
  "Values": {
    "ADMIN_EMAILS": "SEU_EMAIL@REAL.COM",
    "REPORT_EMAILS": "SEU_EMAIL@REAL.COM"
  }
}
```

#### Opção 2: Alterar múltiplos destinatários
Você pode configurar múltiplos e-mails separados por vírgula:
```json
{
  "Values": {
    "ADMIN_EMAILS": "admin1@real.com,admin2@real.com,leonart@exemplo.com",
    "REPORT_EMAILS": "relatorio1@real.com,relatorio2@real.com"
  }
}
```

---

## 🔧 Como Alterar os E-mails

### 1. Para Ambiente Local (Development)

**Arquivo**: `/Users/leonartlima/IdeaProjects/feedbackhub/local.settings.json`

```bash
# Edite manualmente ou use este comando:
cat > local.settings.json << 'EOF'
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "...",
    "ADMIN_EMAILS": "seu-email@exemplo.com",
    "REPORT_EMAILS": "seu-email@exemplo.com"
  }
}
EOF
```

**Depois de alterar**:
1. Pare o Azure Functions Runtime (`Ctrl+C`)
2. Execute novamente: `mvn azure-functions:run`

### 2. Para Ambiente Azure (Production)

```bash
# Via Azure CLI
az functionapp config appsettings set \
  --name feedbackhub-func-55878 \
  --resource-group feedbackhub-rg \
  --settings \
    "ADMIN_EMAILS=seu-email@real.com" \
    "REPORT_EMAILS=seu-email@real.com"
```

**Ou pelo Portal Azure**:
1. Acesse o Function App no Azure Portal
2. Settings → Configuration
3. Application Settings
4. Edite `ADMIN_EMAILS` e `REPORT_EMAILS`
5. Clique em "Save"
6. Reinicie o Function App

---

## 📨 Formato dos E-mails Enviados

### E-mail de Notificação de Urgência

**Assunto**: `⚠️ URGENTE: Avaliação Crítica Recebida - Nota X`

**Conteúdo**:
```
┌─────────────────────────────────────────────────┐
│  ⚠️ ALERTA DE URGÊNCIA - AVALIAÇÃO CRÍTICA     │
└─────────────────────────────────────────────────┘

Descrição: [Descrição da avaliação]
Nota: [0-3] / 10
Urgência: CRÍTICA
Data de Envio: DD/MM/YYYY HH:MM:SS

┌─────────────────────────────────────────────────┐
│  Ação Requerida: Por favor, analise esta       │
│  avaliação e tome as medidas necessárias        │
└─────────────────────────────────────────────────┘
```

**Quando é enviado**:
- Imediatamente após receber avaliação com nota ≤ 3
- Processado pela função `notificarUrgencia` via Queue Trigger

### E-mail de Relatório Semanal

**Assunto**: `FeedbackHub - Relatório Semanal de Avaliações`

**Conteúdo**:
- Período do relatório (últimos 7 dias)
- Quantidade total de avaliações
- Média geral de notas
- Quantidade de avaliações por dia
- Quantidade de avaliações por nível de urgência:
  - ✅ Baixa (notas 7-10)
  - ⚠️ Média (notas 4-6)
  - 🚨 Crítica (notas 0-3)

**Quando é enviado**:
- Automaticamente: Toda segunda-feira às 09:00 UTC (06:00 Brasília)
- Manualmente: Via endpoint `GET /api/relatorio/manual`

---

## 🧪 Como Testar o Envio de E-mails

### Teste 1: Notificação de Urgência (Nota Baixa)

```bash
# 1. Configure seu e-mail real no local.settings.json
# 2. Execute as Azure Functions
mvn azure-functions:run

# 3. Em outro terminal, envie avaliação crítica
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Teste de notificação de urgência",
    "nota": 2
  }'

# 4. Verifique sua caixa de entrada em até 30 segundos
```

### Teste 2: Relatório Manual

```bash
# 1. Configure seu e-mail real no local.settings.json
# 2. Execute as Azure Functions
mvn azure-functions:run

# 3. Em outro terminal, solicite relatório manual
curl -X GET "http://localhost:7071/api/relatorio/manual"

# 4. Verifique sua caixa de entrada em até 30 segundos
```

---

## 🔍 Verificar se E-mails Foram Enviados

### 1. Pelos Logs da Aplicação

```bash
# Procure por estas mensagens nos logs:
[INFO] E-mail enviado com sucesso para: admin@feedbackhub.com
[INFO] Notificação de urgência enviada com sucesso para avaliação ID: 1
[INFO] Relatório semanal gerado e enviado com sucesso
```

### 2. Pelo Azure Communication Services Portal

1. Acesse o Azure Portal
2. Navegue até o recurso **Communication Services**
3. Vá em **Monitoring → Email Logs**
4. Verifique o status dos e-mails:
   - ✅ Delivered
   - ⏳ Queued
   - ❌ Failed

### 3. Pela Sua Caixa de Entrada

**Verifique também a pasta de SPAM/Lixo Eletrônico**

O e-mail remetente é: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`

---

## ❓ FAQ - Perguntas Frequentes

### Por que não estou recebendo os e-mails?

1. **E-mail configurado é fictício?**
   - Verifique se você alterou para seu e-mail real

2. **Função está rodando?**
   - Verifique os logs: `mvn azure-functions:run`

3. **E-mail foi para spam?**
   - Verifique a pasta de spam/lixo eletrônico

4. **Azure Communication Services configurado?**
   - Verifique a variável `AZURE_COMMUNICATION_CONNECTION_STRING`

5. **Firewall/Quota atingida?**
   - Verifique no Azure Portal se há erros

### Posso usar meu Gmail/Outlook pessoal?

**Sim!** Basta alterar no `local.settings.json`:

```json
{
  "Values": {
    "ADMIN_EMAILS": "seu-email@gmail.com",
    "REPORT_EMAILS": "seu-email@outlook.com"
  }
}
```

### Quanto custa enviar e-mails?

O Azure Communication Services tem uma camada gratuita:
- **Primeiros 100 e-mails/mês**: GRÁTIS
- Acima de 100: $0.00025 por e-mail

---

## 🎯 Exemplo Prático Completo

### Cenário: Quero receber e-mails no meu Gmail

```bash
# 1. Edite o arquivo local.settings.json
vim local.settings.json

# Altere:
"ADMIN_EMAILS": "meuemail@gmail.com",
"REPORT_EMAILS": "meuemail@gmail.com",

# 2. Salve e execute
mvn clean package -DskipTests
mvn azure-functions:run

# 3. Em outro terminal, teste com avaliação crítica
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Professor faltou aula sem avisar",
    "nota": 1
  }'

# 4. Aguarde ~30 segundos e verifique seu Gmail
# Assunto: ⚠️ URGENTE: Avaliação Crítica Recebida - Nota 1

# 5. Teste relatório manual
curl -X GET "http://localhost:7071/api/relatorio/manual"

# 6. Verifique seu Gmail novamente
# Assunto: FeedbackHub - Relatório Semanal de Avaliações
```

---

## 📞 Suporte

Se os e-mails ainda não estiverem chegando:
1. Verifique os logs em tempo real: `mvn azure-functions:run`
2. Consulte a documentação: `TROUBLESHOOTING.md`
3. Verifique o status do Azure Communication Services no Portal Azure

---

**Última atualização**: 18 de fevereiro de 2026

