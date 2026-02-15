# Documentação das Azure Functions

## Visão Geral

Este documento detalha as três Azure Functions implementadas no FeedbackHub, suas responsabilidades, triggers e fluxos de execução.

---

## 1. RecepcionarAvaliacaoFunction

### Descrição
Função HTTP que recebe avaliações de estudantes via API REST.

### Trigger
- **Tipo**: HTTP Trigger
- **Método**: POST
- **Rota**: `/api/avaliacao`
- **Authorization Level**: FUNCTION (requer Function Key)

### Request Body
```json
{
  "descricao": "string (obrigatório, max 1000 caracteres)",
  "nota": "integer (obrigatório, 0-10)"
}
```

### Response Body
```json
{
  "id": "long",
  "descricao": "string",
  "nota": "integer",
  "urgencia": "CRITICA | MEDIA | POSITIVA",
  "dataEnvio": "datetime (ISO-8601)",
  "mensagem": "string"
}
```

### Fluxo de Execução

```
1. Recebe requisição HTTP POST
   ↓
2. Valida campos obrigatórios
   ↓
3. Valida range da nota (0-10)
   ↓
4. Classifica urgência baseado na nota
   - 0-3: CRITICA
   - 4-6: MEDIA
   - 7-10: POSITIVA
   ↓
5. Persiste no Azure SQL Database
   ↓
6. Se CRITICA: Envia mensagem para Storage Queue
   ↓
7. Retorna resposta com dados salvos
```

### Códigos HTTP

| Código | Descrição |
|--------|-----------|
| 200 OK | Avaliação criada com sucesso |
| 400 Bad Request | Dados inválidos ou faltando |
| 500 Internal Server Error | Erro no processamento |

### Exemplo de Chamada

```bash
curl -X POST "https://feedbackhub-functions.azurewebsites.net/api/avaliacao?code=YOUR_FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula muito confusa, não entendi o conteúdo",
    "nota": 2
  }'
```

### Logs Importantes
- `Azure Function: Recebendo nova avaliação`
- `Avaliação processada com sucesso: ID=X`
- `Erro ao processar avaliação: [mensagem]`

---

## 2. NotificacaoUrgenciaFunction

### Descrição
Função que processa mensagens da fila e envia notificações por e-mail para avaliações críticas.

### Trigger
- **Tipo**: Queue Trigger
- **Queue Name**: `feedback-urgencia-queue`
- **Connection**: `AZURE_STORAGE_CONNECTION_STRING`
- **Polling Interval**: Configurado automaticamente pelo Azure

### Input (Mensagem da Fila)
```json
{
  "avaliacaoId": "long",
  "descricao": "string",
  "nota": "integer",
  "urgencia": "string",
  "dataEnvio": "string (ISO-8601)"
}
```

### Fluxo de Execução

```
1. Mensagem recebida da fila
   ↓
2. Desserializa JSON da mensagem
   ↓
3. Extrai dados da avaliação crítica
   ↓
4. Gera HTML formatado do e-mail
   ↓
5. Envia e-mail via SendGrid
   ↓
6. Marca avaliação como "notificada" no DB
   ↓
7. Mensagem removida da fila automaticamente
```

### E-mail Enviado

**Para**: Configurado em `ADMIN_EMAILS`  
**Assunto**: `⚠️ URGENTE: Avaliação Crítica Recebida - Nota X`  
**Formato**: HTML com estilização responsiva

**Conteúdo**:
- Banner de alerta vermelho
- Descrição da avaliação
- Nota destacada
- Nível de urgência
- Data e hora de envio
- Ação requerida

### Retry Policy
- **Max Delivery Count**: 5 tentativas
- **Visibility Timeout**: 30 segundos
- Se falhar após 5 tentativas, mensagem vai para poison queue

### Logs Importantes
- `Azure Function: Processando notificação de urgência`
- `Mensagem recebida: [JSON]`
- `Notificação de urgência enviada com sucesso para avaliação ID: X`
- `Erro ao processar notificação de urgência: [mensagem]`

---

## 3. RelatorioSemanalFunction

### Descrição
Função com timer trigger que gera e envia relatórios semanais automaticamente.

### Trigger
- **Tipo**: Timer Trigger
- **CRON Expression**: `0 0 9 * * MON`
- **Schedule**: Toda segunda-feira às 9:00 AM UTC (6:00 AM Brasília)
- **Timezone**: UTC (configurável)

### CRON Expression Explicada
```
0     0     9     *     *     MON
│     │     │     │     │     │
│     │     │     │     │     └─── Dia da semana (Monday)
│     │     │     │     └───────── Mês (qualquer)
│     │     │     └─────────────── Dia do mês (qualquer)
│     │     └───────────────────── Hora (9 AM)
│     └─────────────────────────── Minuto (0)
└───────────────────────────────── Segundo (0)
```

### Período Analisado
- **Início**: Segunda-feira anterior às 00:00:00
- **Fim**: Domingo anterior às 23:59:59
- **Total**: 7 dias completos

### Fluxo de Execução

```
1. Timer trigger ativa a função
   ↓
2. Calcula período da última semana
   ↓
3. Busca todas avaliações do período
   ↓
4. Calcula estatísticas:
   - Total de avaliações
   - Média das notas
   - Quantidade por dia
   - Quantidade por urgência
   ↓
5. Gera relatório HTML formatado
   ↓
6. Envia e-mail via SendGrid
   ↓
7. Log de sucesso/erro
```

### Dados do Relatório

```json
{
  "titulo": "Relatório Semanal de Feedbacks",
  "dataInicio": "datetime",
  "dataFim": "datetime",
  "totalAvaliacoes": "long",
  "mediaNotas": "double",
  "quantidadePorDia": {
    "2024-02-12": 15,
    "2024-02-13": 23,
    ...
  },
  "quantidadePorUrgencia": {
    "CRITICA": 5,
    "MEDIA": 12,
    "POSITIVA": 28
  },
  "avaliacoesCriticas": "long",
  "avaliacoesMedias": "long",
  "avaliacoesPositivas": "long"
}
```

### E-mail do Relatório

**Para**: Configurado em `REPORT_EMAILS`  
**Assunto**: `Relatório Semanal de Feedbacks`  
**Formato**: HTML com gráficos e tabelas

**Seções**:
1. Header com período
2. Resumo geral (total e média)
3. Distribuição por urgência
4. Tabela por dia
5. Footer automático

### Função Manual (Para Testes)

Existe também `gerarRelatorioManual` que pode ser executada sob demanda:
- **Schedule**: Desabilitado por padrão
- **Uso**: Testes e geração manual via Portal Azure

### Logs Importantes
- `Azure Function: Gerando relatório semanal`
- `Timer trigger: [info]`
- `Relatório semanal gerado e enviado com sucesso!`
- `Erro ao gerar relatório semanal: [mensagem]`

---

## Configurações Comuns

### Variáveis de Ambiente Necessárias

```bash
# Database
DB_URL=jdbc:sqlserver://...
DB_USERNAME=azureuser
DB_PASSWORD=***

# Azure Storage
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;...

# SendGrid
SENDGRID_API_KEY=SG.***
SENDGRID_FROM_EMAIL=noreply@feedbackhub.com

# Recipients
ADMIN_EMAILS=admin1@example.com,admin2@example.com
REPORT_EMAILS=reports@example.com
```

### Application Insights

Todas as funções estão integradas com Application Insights para:
- Rastreamento de execuções
- Métricas de performance
- Logs centralizados
- Alertas configuráveis

### Queries KQL Úteis

```kql
// Contar execuções por função (últimas 24h)
requests
| where timestamp > ago(24h)
| summarize count() by name
| order by count_ desc

// Taxa de erro por função
requests
| where timestamp > ago(24h)
| summarize 
    total = count(),
    failures = countif(success == false)
    by name
| extend errorRate = (failures * 100.0) / total

// Tempo médio de execução
requests
| where timestamp > ago(24h)
| summarize avgDuration = avg(duration) by name
| order by avgDuration desc

// Logs de erro
traces
| where severityLevel >= 3
| where timestamp > ago(24h)
| order by timestamp desc
| take 50
```

---

## Troubleshooting

### Função não está sendo executada

**Possíveis causas**:
1. Function App está parada
2. Trigger desabilitado
3. Credenciais inválidas
4. Fila vazia (para Queue Trigger)

**Solução**:
```bash
# Verificar status
az functionapp show --name feedbackhub-functions --resource-group feedbackhub-rg

# Reiniciar
az functionapp restart --name feedbackhub-functions --resource-group feedbackhub-rg

# Ver logs em tempo real
az functionapp log tail --name feedbackhub-functions --resource-group feedbackhub-rg
```

### Erro de conexão com banco de dados

**Sintomas**: `SQLServerException: Cannot open server`

**Verificar**:
1. Firewall do SQL Server permite IPs do Azure
2. Connection string está correta
3. Credenciais válidas

```bash
# Adicionar regra de firewall
az sql server firewall-rule create \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server \
  --name AllowAllAzure \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### E-mails não estão sendo enviados

**Verificar**:
1. SendGrid API Key válida
2. Sender verification configurado no SendGrid
3. E-mails de destino válidos
4. Quota do SendGrid não excedida

```bash
# Verificar configurações
az functionapp config appsettings list \
  --name feedbackhub-functions \
  --resource-group feedbackhub-rg \
  --query "[?name=='SENDGRID_API_KEY']"
```

### Mensagens ficam presas na fila

**Causas**:
1. Função com erro não tratado
2. Timeout de processamento
3. Dependências offline

**Solução**:
```bash
# Ver mensagens na fila
az storage message peek \
  --queue-name feedback-urgencia-queue \
  --account-name feedbackhubstorage \
  --num-messages 32

# Limpar fila (cuidado!)
az storage message clear \
  --queue-name feedback-urgencia-queue \
  --account-name feedbackhubstorage
```

---

## Performance e Custos

### Consumption Plan

| Métrica | Limite Free Tier | Custo Adicional |
|---------|------------------|-----------------|
| Execuções | 1 milhão/mês | $0.20 por milhão |
| Execution Time | 400.000 GB-s | $0.000016 por GB-s |
| Memória | 128 MB - 1.5 GB | Incluído |

### Otimizações Implementadas

1. **Cold Start**: Minimizado com Java 17 e dependências otimizadas
2. **Connection Pooling**: HikariCP configurado (max 5 connections)
3. **Batch Processing**: Queries otimizadas com índices
4. **Retry Logic**: Configurado automaticamente pelo Azure

### Estimativa de Custos Mensais

**Cenário**: 1000 avaliações/mês, 100 críticas, 4 relatórios

- RecepcionarAvaliacaoFunction: 1000 execuções × 2s = 2000s
- NotificacaoUrgenciaFunction: 100 execuções × 3s = 300s
- RelatorioSemanalFunction: 4 execuções × 5s = 20s

**Total**: ~2320s ≈ 0.64 GB-s (GRÁTIS dentro do Free Tier)

---

## Próximos Passos

1. ✅ Implementar testes unitários
2. ✅ Configurar Application Insights dashboards
3. ⬜ Adicionar autenticação OAuth
4. ⬜ Implementar cache com Redis
5. ⬜ Criar dashboard frontend

