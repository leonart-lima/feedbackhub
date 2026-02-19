# 📧 QUANDO OS E-MAILS SÃO ENVIADOS - FeedbackHub

## 🎯 Resumo Executivo

Os e-mails são enviados em **2 situações**:

| Situação | Quando | Para Quem | Automático? |
|----------|--------|-----------|-------------|
| 🚨 **Notificação de Urgência** | Imediatamente após avaliação com nota ≤ 3 | `RM365903@fiap.com.br` | ✅ Sim |
| 📊 **Relatório Semanal** | Toda segunda-feira às 9h UTC (6h Brasília) | `RM365903@fiap.com.br` | ✅ Sim |

---

## 🚨 1. NOTIFICAÇÃO DE URGÊNCIA (Imediata)

### Quando É Enviado?

**Imediatamente** quando uma avaliação crítica é registrada!

### Gatilho (Trigger)

```
Avaliação com NOTA ≤ 3
    ↓
URGÊNCIA classificada como CRÍTICA
    ↓
Enviada para Azure Storage Queue
    ↓ (automático, ~5-30 segundos)
Queue Trigger aciona função notificarUrgencia
    ↓
E-MAIL ENVIADO para RM365903@fiap.com.br
```

### Fluxo Completo

1. **POST /api/avaliacao** com nota 0, 1, 2 ou 3
2. **Validação** → OK
3. **Classificação** → URGÊNCIA: CRÍTICA
4. **Salva no banco** → Azure SQL
5. **Envia para fila** → `feedback-urgencia-queue`
6. **Queue Trigger** → Função `notificarUrgencia` é acionada automaticamente
7. **E-mail enviado** → Via Azure Communication Services
8. **Marca como notificada** → Campo `notificacaoEnviada = true`

### Tempo de Entrega

- ⚡ **5 a 30 segundos** após receber a avaliação
- Depende do polling da fila (Azure verifica a cada ~10 segundos)

### Exemplo Prático

```bash
# 1. Você envia uma avaliação crítica
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Professor não compareceu à aula!",
    "nota": 2
  }'

# 2. Resposta imediata (< 1 segundo)
{
  "id": 1,
  "descricao": "Professor não compareceu à aula!",
  "nota": 2,
  "urgencia": "CRITICA",
  "dataEnvio": "2026-02-18T22:30:15",
  "notificacaoEnviada": false
}

# 3. Nos logs (5-30 segundos depois):
[INFO] 🚨 URGÊNCIA CRÍTICA detectada!
[INFO] Mensagem enviada para fila com sucesso
[INFO] Queue message received
[INFO] === Azure Function: Processando notificação de urgência ===
[INFO] E-mail enviado com sucesso para: RM365903@fiap.com.br
[INFO] Notificação de urgência enviada com sucesso para avaliação ID: 1

# 4. E-mail chega em 30-60 segundos na sua caixa (ou spam)
```

### Condições Exatas

| Nota | Urgência | Envia E-mail? |
|------|----------|---------------|
| 0 | CRÍTICA | ✅ SIM |
| 1 | CRÍTICA | ✅ SIM |
| 2 | CRÍTICA | ✅ SIM |
| 3 | CRÍTICA | ✅ SIM |
| 4 | MÉDIA | ❌ NÃO |
| 5 | MÉDIA | ❌ NÃO |
| 6 | MÉDIA | ❌ NÃO |
| 7 | BAIXA | ❌ NÃO |
| 8 | BAIXA | ❌ NÃO |
| 9 | BAIXA | ❌ NÃO |
| 10 | BAIXA | ❌ NÃO |

### Conteúdo do E-mail

**Para**: `RM365903@fiap.com.br`  
**De**: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`  
**Assunto**: `⚠️ URGENTE: Avaliação Crítica Recebida - Nota X`

**Conteúdo HTML**:
```
┌────────────────────────────────────────────┐
│ ⚠️ ALERTA DE URGÊNCIA - AVALIAÇÃO CRÍTICA  │
│ Uma avaliação com nota crítica foi         │
│ registrada no sistema e requer atenção     │
│ imediata.                                   │
└────────────────────────────────────────────┘

Detalhes da Avaliação:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Descrição: [texto da avaliação]
Nota: X / 10
Urgência: CRÍTICA
Data de Envio: DD/MM/YYYY HH:MM:SS

┌────────────────────────────────────────────┐
│ Ação Requerida:                            │
│ Por favor, analise esta avaliação e tome   │
│ as medidas necessárias para resolver o     │
│ problema reportado.                         │
└────────────────────────────────────────────┘
```

### Código Responsável

**Função**: `NotificacaoUrgenciaFunction.java`
```java
@FunctionName("notificarUrgencia")
public void notificarUrgencia(
    @QueueTrigger(
        name = "message",
        queueName = "feedback-urgencia-queue",
        connection = "AZURE_STORAGE_CONNECTION_STRING"
    ) String message,
    final ExecutionContext context) {
    
    // 1. Parse da mensagem
    Map<String, Object> dados = parseMensagem(message);
    
    // 2. Gera HTML do e-mail
    String htmlEmail = gerarHtmlNotificacao(...);
    
    // 3. Envia e-mail
    emailService.enviarNotificacaoUrgencia(assunto, htmlEmail);
    
    // 4. Marca como notificada
    avaliacaoService.marcarComoNotificada(avaliacaoId);
}
```

---

## 📊 2. RELATÓRIO SEMANAL (Agendado)

### Quando É Enviado?

**Automaticamente toda segunda-feira às 09:00 UTC** (06:00 horário de Brasília)

### Gatilho (Trigger)

```
Timer Trigger (CRON: 0 0 9 * * MON)
    ↓
Toda segunda-feira às 9h UTC
    ↓
Função gerarRelatorioSemanal executada
    ↓
Consulta últimos 7 dias no banco
    ↓
Gera estatísticas
    ↓
E-MAIL ENVIADO para RM365903@fiap.com.br
```

### Schedule (CRON Expression)

```
0     0     9     *     *     MON
│     │     │     │     │     │
│     │     │     │     │     └─── Segunda-feira
│     │     │     │     └───────── Qualquer mês
│     │     │     └─────────────── Qualquer dia
│     │     └───────────────────── 9 horas (UTC)
│     └─────────────────────────── 0 minutos
└───────────────────────────────── 0 segundos
```

**Resumo**: `0 0 9 * * MON` = Segunda-feira, 9h00 UTC (6h00 Brasília)

### Horários por Timezone

| Timezone | Horário do Envio |
|----------|------------------|
| UTC | Segunda-feira 09:00 |
| Brasília (BRT) | Segunda-feira 06:00 |
| São Paulo | Segunda-feira 06:00 |
| Rio de Janeiro | Segunda-feira 06:00 |

### Período Analisado

- **Início**: Segunda-feira anterior às 00:00:00
- **Fim**: Domingo às 23:59:59
- **Total**: Últimos 7 dias completos

**Exemplo**:
- E-mail enviado: Segunda, 24/02/2026 às 06:00
- Período analisado: 17/02/2026 00:00 até 23/02/2026 23:59

### Frequência

| Dia da Semana | E-mail Enviado? |
|---------------|-----------------|
| Segunda-feira 09:00 UTC | ✅ SIM |
| Terça-feira | ❌ NÃO |
| Quarta-feira | ❌ NÃO |
| Quinta-feira | ❌ NÃO |
| Sexta-feira | ❌ NÃO |
| Sábado | ❌ NÃO |
| Domingo | ❌ NÃO |

**Resumo**: 1 e-mail por semana, apenas segunda-feira

### Conteúdo do E-mail

**Para**: `RM365903@fiap.com.br`  
**De**: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`  
**Assunto**: `FeedbackHub - Relatório Semanal de Avaliações`

**Conteúdo HTML**:
```
┌────────────────────────────────────────────┐
│ FeedbackHub - Relatório Semanal            │
│ Período: DD/MM/YYYY a DD/MM/YYYY           │
└────────────────────────────────────────────┘

📊 Resumo Geral
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total de Avaliações: 45
Média Geral: 7.2 / 10

📅 Avaliações por Dia
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
19/02/2026: 10 avaliações
18/02/2026: 8 avaliações
17/02/2026: 12 avaliações
16/02/2026: 7 avaliações
15/02/2026: 5 avaliações
14/02/2026: 2 avaliações
13/02/2026: 1 avaliação

⚠️ Distribuição por Urgência
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Baixa (7-10):    30 avaliações (66.7%)
⚠️ Média (4-6):     12 avaliações (26.7%)
🚨 Crítica (0-3):   3 avaliações (6.7%)
```

### Código Responsável

**Função**: `RelatorioSemanalFunction.java`
```java
@FunctionName("gerarRelatorioSemanal")
public void gerarRelatorioSemanal(
    @TimerTrigger(
        name = "timerInfo",
        schedule = "0 0 9 * * MON"  // Segunda 9h UTC
    ) String timerInfo,
    final ExecutionContext context) {
    
    // Gerar e enviar relatório
    relatorioService.enviarRelatorioSemanal();
}
```

### Como Testar Agora (Sem Esperar Segunda)

Você pode gerar um relatório manual a qualquer momento:

```bash
curl -X GET "http://localhost:7071/api/relatorio/manual"
```

Ou via Azure Portal:
1. Acesse o Function App
2. Functions → `gerarRelatorioSemanal`
3. Clique em "Test/Run"
4. Clique em "Run"

---

## ⏱️ TIMELINE COMPLETA - EXEMPLO REAL

### Cenário: Você envia 3 avaliações

```
18/02/2026 22:30:00 - POST avaliação nota 10 (boa)
    ↓
    22:30:01 - ✅ Salva no banco
    22:30:01 - ✅ Classifica: BAIXA
    22:30:01 - ❌ NÃO envia e-mail
    
18/02/2026 22:31:00 - POST avaliação nota 5 (média)
    ↓
    22:31:01 - ✅ Salva no banco
    22:31:01 - ✅ Classifica: MÉDIA
    22:31:01 - ❌ NÃO envia e-mail
    
18/02/2026 22:32:00 - POST avaliação nota 1 (crítica)
    ↓
    22:32:01 - ✅ Salva no banco
    22:32:01 - ✅ Classifica: CRÍTICA
    22:32:01 - ✅ Envia para fila
    22:32:05 - ⚡ Queue trigger acionado
    22:32:06 - 📧 E-MAIL ENVIADO (notificação urgência)
    22:32:07 - ✅ Marca como notificada
    22:32:30 - 📬 E-mail chega na caixa de entrada
    
19/02/2026 06:00:00 - Segunda-feira
    ❌ NÃO envia relatório (não é 9h UTC)
    
19/02/2026 09:00:00 - Segunda-feira (6h Brasília)
    ⏰ Timer trigger acionado
    📊 Consulta últimos 7 dias
    📧 E-MAIL ENVIADO (relatório semanal)
    📬 E-mail chega em 1-2 minutos
```

---

## 📧 PARA QUEM OS E-MAILS SÃO ENVIADOS?

### Configuração Atual

Vejo no seu `local.settings.json`:

```json
"ADMIN_EMAILS": "RM365903@fiap.com.br",
"REPORT_EMAILS": "RM365903@fiap.com.br",
```

✅ **Perfeito!** Ambos os e-mails vão para: `RM365903@fiap.com.br`

### Múltiplos Destinatários (Opcional)

Se quiser enviar para mais pessoas, separe por vírgula:

```json
"ADMIN_EMAILS": "RM365903@fiap.com.br,professor@fiap.com.br,admin@empresa.com",
"REPORT_EMAILS": "RM365903@fiap.com.br,gerente@fiap.com.br",
```

---

## ✅ CHECKLIST DE VERIFICAÇÃO

### Para Notificações de Urgência Funcionarem

- [x] `ADMIN_EMAILS` configurado: `RM365903@fiap.com.br`
- [x] Azure Communication Services configurado
- [x] Azure Storage Queue criada: `feedback-urgencia-queue`
- [x] Função `notificarUrgencia` deployada
- [x] Azure Functions rodando
- [ ] Enviar avaliação com nota ≤ 3
- [ ] Aguardar 30-60 segundos
- [ ] Verificar e-mail (inclusive SPAM)

### Para Relatório Semanal Funcionar

- [x] `REPORT_EMAILS` configurado: `RM365903@fiap.com.br`
- [x] Azure Communication Services configurado
- [x] Função `gerarRelatorioSemanal` deployada
- [x] Timer trigger configurado: `0 0 9 * * MON`
- [ ] Aguardar segunda-feira 09:00 UTC (06:00 Brasília)
- [ ] OU executar manualmente: `GET /api/relatorio/manual`
- [ ] Verificar e-mail

---

## 🔍 COMO CONFIRMAR QUE FUNCIONOU

### 1. Pelos Logs da Aplicação

**Notificação de Urgência**:
```
[INFO] 🚨 URGÊNCIA CRÍTICA detectada!
[INFO] Mensagem enviada para fila com sucesso
[INFO] === Azure Function: Processando notificação de urgência ===
[INFO] E-mail enviado com sucesso para: RM365903@fiap.com.br
[INFO] Notificação de urgência enviada com sucesso para avaliação ID: X
```

**Relatório Semanal**:
```
[INFO] === Azure Function: Gerando relatório semanal ===
[INFO] Timer trigger: [info do timer]
[INFO] Gerando relatório dos últimos 7 dias...
[INFO] E-mail enviado com sucesso para: RM365903@fiap.com.br
[INFO] Relatório semanal gerado e enviado com sucesso!
```

### 2. No Azure Portal

1. Acesse: https://portal.azure.com
2. `Communication Services` → `feedbackhub-comm-55878`
3. `Monitoring` → `Email Logs`
4. Verifique:
   - **To**: `RM365903@fiap.com.br`
   - **Status**: `Delivered` ✅
   - **Timestamp**: Data/hora do envio

### 3. Na Sua Caixa de E-mail

**⚠️ IMPORTANTE**: Verifique também a pasta **SPAM/Lixo Eletrônico**!

O remetente será: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`

---

## 🎯 RESUMO VISUAL

```
┌──────────────────────────────────────────────────────────┐
│  QUANDO OS E-MAILS SÃO ENVIADOS?                          │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  🚨 NOTIFICAÇÃO DE URGÊNCIA                                │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Quando: IMEDIATAMENTE após avaliação com nota ≤ 3       │
│  Tempo: 5-30 segundos                                     │
│  Para: RM365903@fiap.com.br                               │
│  Assunto: ⚠️ URGENTE: Avaliação Crítica Recebida         │
│                                                            │
│  📊 RELATÓRIO SEMANAL                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Quando: Toda segunda-feira às 09:00 UTC (06:00 BRT)     │
│  Frequência: 1x por semana                                │
│  Para: RM365903@fiap.com.br                               │
│  Assunto: FeedbackHub - Relatório Semanal                 │
│                                                            │
└──────────────────────────────────────────────────────────┘
```

---

## 🧪 TESTE AGORA

### Teste 1: Notificação de Urgência

```bash
# 1. Execute as Azure Functions
mvn azure-functions:run

# 2. Em outro terminal, envie avaliação crítica
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste de notificação urgente", "nota": 1}'

# 3. Aguarde 30-60 segundos

# 4. Verifique RM365903@fiap.com.br (e pasta SPAM!)
```

### Teste 2: Relatório Manual

```bash
# Gera relatório imediatamente (não precisa esperar segunda)
curl -X GET "http://localhost:7071/api/relatorio/manual"

# Aguarde 1-2 minutos e verifique RM365903@fiap.com.br
```

---

**✅ Pronto! Agora você sabe exatamente quando e para quem os e-mails são enviados!**

**Destinatário configurado**: `RM365903@fiap.com.br` ✉️

**Data**: 18 de fevereiro de 2026

