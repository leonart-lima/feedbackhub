# 🔥 CURLs Completos - FeedbackHub

## 📋 Índice
1. [Receber Avaliação](#1-receber-avaliação)
2. [Relatório Manual](#2-relatório-manual)
3. [Notificação de Urgência (Automática)](#3-notificação-de-urgência-automática)
4. [Relatório Semanal (Automático)](#4-relatório-semanal-automático)
5. [Testes Completos](#5-testes-completos)

---

## 🚀 Antes de Começar

### 1. Certifique-se que as Functions estão rodando:
```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn azure-functions:run
```

### 2. Aguarde até ver esta mensagem:
```
[INFO] HTTP Trigger: receberAvaliacao.receberAvaliacao
[INFO] Timer Trigger: gerarRelatorioSemanal
[INFO] Queue Trigger: notificarUrgencia
```

### 3. Endpoints Disponíveis:
- **Local**: `http://localhost:7071`
- **Azure**: `https://feedbackhub-func-55878.azurewebsites.net`

---

## 1. Receber Avaliação

### 🎯 Endpoint
```
POST /api/avaliacao
```

### 📝 Descrição
Recebe uma avaliação de um estudante. Se a nota for ≤ 3, automaticamente envia para fila de notificação de urgência.

---

### ✅ Caso 1: Avaliação Positiva (Nota Alta)

```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Excelente aula! Professor muito didático e conteúdo bem explicado.",
    "nota": 10
  }'
```

**Resposta Esperada (200 OK)**:
```json
{
  "id": 1,
  "descricao": "Excelente aula! Professor muito didático e conteúdo bem explicado.",
  "nota": 10,
  "urgencia": "BAIXA",
  "dataEnvio": "2026-02-19T01:30:45",
  "notificacaoEnviada": false
}
```

**O que acontece**:
- ✅ Salva no banco de dados
- ✅ Classifica como urgência BAIXA
- ❌ NÃO envia notificação (nota boa)

---

### ⚠️ Caso 2: Avaliação Média

```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula boa, mas poderia ter mais exemplos práticos.",
    "nota": 6
  }'
```

**Resposta Esperada (200 OK)**:
```json
{
  "id": 2,
  "descricao": "Aula boa, mas poderia ter mais exemplos práticos.",
  "nota": 6,
  "urgencia": "MEDIA",
  "dataEnvio": "2026-02-19T01:31:12",
  "notificacaoEnviada": false
}
```

**O que acontece**:
- ✅ Salva no banco de dados
- ✅ Classifica como urgência MÉDIA
- ❌ NÃO envia notificação (nota aceitável)

---

### 🚨 Caso 3: Avaliação Crítica (Aciona Notificação!)

```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Professor faltou à aula sem avisar. Conteúdo não foi passado.",
    "nota": 2
  }'
```

**Resposta Esperada (200 OK)**:
```json
{
  "id": 3,
  "descricao": "Professor faltou à aula sem avisar. Conteúdo não foi passado.",
  "nota": 2,
  "urgencia": "CRITICA",
  "dataEnvio": "2026-02-19T01:32:05",
  "notificacaoEnviada": false
}
```

**O que acontece**:
- ✅ Salva no banco de dados
- ✅ Classifica como urgência CRÍTICA
- ✅ **Envia para fila de notificação**
- ✅ **Função `notificarUrgencia` é acionada automaticamente**
- ✅ **E-mail é enviado para `ADMIN_EMAILS`**

**Verificar logs**:
```
[INFO] 🚨 URGÊNCIA CRÍTICA detectada! Enviando para fila de notificação...
[INFO] Mensagem enviada para fila com sucesso
[INFO] === Azure Function: Processando notificação de urgência ===
[INFO] E-mail enviado com sucesso para: admin@feedbackhub.com
```

---

### 🔴 Caso 4: Avaliação Muito Crítica (Nota 0)

```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Equipamentos quebrados, aula cancelada, total despreparo.",
    "nota": 0
  }'
```

**Resposta Esperada (200 OK)**:
```json
{
  "id": 4,
  "descricao": "Equipamentos quebrados, aula cancelada, total despreparo.",
  "nota": 0,
  "urgencia": "CRITICA",
  "dataEnvio": "2026-02-19T01:33:22",
  "notificacaoEnviada": false
}
```

---

### 📊 Caso 5: Múltiplas Avaliações de Uma Vez

```bash
# Avaliação 1 - Excelente
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Aula fantástica! Melhor professor!", "nota": 10}'

# Avaliação 2 - Boa
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Muito bom, aprendi bastante.", "nota": 9}'

# Avaliação 3 - Média
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Ok, mas pode melhorar.", "nota": 5}'

# Avaliação 4 - Crítica (envia notificação)
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Muito ruim, não entendi nada.", "nota": 1}'

# Avaliação 5 - Boa
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Gostei da didática.", "nota": 8}'
```

---

### ❌ Caso 6: Validações - Nota Inválida

```bash
# Nota maior que 10
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Teste de validação",
    "nota": 15
  }'
```

**Resposta Esperada (400 Bad Request)**:
```json
{
  "error": "Nota deve estar entre 0 e 10"
}
```

---

```bash
# Nota negativa
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Teste de validação",
    "nota": -5
  }'
```

**Resposta Esperada (400 Bad Request)**:
```json
{
  "error": "Nota deve estar entre 0 e 10"
}
```

---

### ❌ Caso 7: Validações - Descrição Vazia

```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "",
    "nota": 8
  }'
```

**Resposta Esperada (400 Bad Request)**:
```json
{
  "error": "Descrição não pode estar vazia"
}
```

---

### ❌ Caso 8: Validações - Campos Faltando

```bash
# Faltando descrição
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "nota": 8
  }'
```

**Resposta Esperada (400 Bad Request)**:
```json
{
  "error": "Descrição é obrigatória"
}
```

---

```bash
# Faltando nota
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Teste sem nota"
  }'
```

**Resposta Esperada (400 Bad Request)**:
```json
{
  "error": "Nota é obrigatória"
}
```

---

## 2. Relatório Manual

### 🎯 Endpoint
```
GET /api/relatorio/manual
```

### 📝 Descrição
Gera um relatório dos últimos 7 dias e envia por e-mail para `REPORT_EMAILS`.

---

### ✅ Solicitar Relatório

```bash
curl -X GET "http://localhost:7071/api/relatorio/manual"
```

**Resposta Esperada (200 OK)**:
```json
{
  "status": "success",
  "message": "Relatório gerado e enviado com sucesso",
  "relatorio": {
    "titulo": "FeedbackHub - Relatório Semanal de Avaliações",
    "periodo": "12/02/2026 a 19/02/2026",
    "totalAvaliacoes": 15,
    "mediaGeral": 6.8,
    "avaliacoesPorDia": {
      "2026-02-19": 5,
      "2026-02-18": 4,
      "2026-02-17": 3,
      "2026-02-16": 2,
      "2026-02-15": 1
    },
    "avaliacoesPorUrgencia": {
      "CRITICA": 2,
      "MEDIA": 5,
      "BAIXA": 8
    }
  }
}
```

**O que acontece**:
- ✅ Consulta avaliações dos últimos 7 dias
- ✅ Calcula estatísticas
- ✅ Gera HTML formatado
- ✅ Envia e-mail para `REPORT_EMAILS`

**Verificar logs**:
```
[INFO] === Azure Function: Gerando relatório manual ===
[INFO] Gerando relatório dos últimos 7 dias...
[INFO] E-mail enviado com sucesso para: relatorios@feedbackhub.com
[INFO] Relatório semanal gerado e enviado com sucesso
```

---

### 📊 Com Parâmetros de Data (Opcional)

```bash
# Relatório dos últimos 14 dias
curl -X GET "http://localhost:7071/api/relatorio/manual?dias=14"
```

**Resposta**: Relatório com dados dos últimos 14 dias

---

```bash
# Relatório de apenas hoje
curl -X GET "http://localhost:7071/api/relatorio/manual?dias=1"
```

**Resposta**: Relatório com dados de hoje

---

## 3. Notificação de Urgência (Automática)

### 🎯 Trigger
```
Queue Trigger: feedback-urgencia-queue
```

### 📝 Descrição
**Função automática** acionada quando há mensagem na fila. **Não tem endpoint HTTP direto**.

### Como Testar

**Envie uma avaliação crítica (nota ≤ 3)**:
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Teste de notificação automática",
    "nota": 1
  }'
```

### O que acontece automaticamente:

1. **Avaliação recebida** → `receberAvaliacao`
2. **Classificada como CRÍTICA** → `UrgenciaClassificador`
3. **Enviada para fila** → `Azure Storage Queue`
4. **Queue Trigger acionado** → `notificarUrgencia`
5. **E-mail enviado** → `EmailService`
6. **Avaliação marcada como notificada** → Banco de dados

**Logs esperados**:
```
[INFO] 🚨 URGÊNCIA CRÍTICA detectada!
[INFO] Mensagem enviada para fila com sucesso
[INFO] Queue message received: {...}
[INFO] === Azure Function: Processando notificação de urgência ===
[INFO] ⚠️ AVALIAÇÃO CRÍTICA DETECTADA!
[INFO] E-mail enviado com sucesso para: admin@feedbackhub.com
[INFO] Notificação de urgência enviada com sucesso para avaliação ID: 1
```

---

## 4. Relatório Semanal (Automático)

### 🎯 Trigger
```
Timer Trigger: 0 0 9 * * MON (Toda segunda-feira às 9h UTC)
```

### 📝 Descrição
**Função automática** executada toda segunda-feira às 9h UTC (6h Brasília). **Não tem endpoint HTTP direto**.

### Como Funciona

**Automaticamente toda segunda às 9h**:
1. Timer aciona a função `gerarRelatorioSemanal`
2. Consulta avaliações dos últimos 7 dias
3. Gera estatísticas e HTML
4. Envia e-mail para `REPORT_EMAILS`

### Para Testar Agora (Sem Esperar Segunda)

**Use o endpoint manual**:
```bash
curl -X GET "http://localhost:7071/api/relatorio/manual"
```

### Logs Esperados (Segunda 9h):
```
[INFO] === Azure Function: Gerando relatório semanal automático ===
[INFO] Executando relatório agendado (Timer Trigger)
[INFO] Período do relatório: 12/02/2026 a 19/02/2026
[INFO] Total de avaliações encontradas: 45
[INFO] Média geral: 7.2
[INFO] E-mail enviado com sucesso para: relatorios@feedbackhub.com
[INFO] Relatório semanal executado com sucesso pelo timer
```

---

## 5. Testes Completos

### 🧪 Script de Teste Automatizado

Execute todos os testes de uma vez:

```bash
#!/bin/bash

echo "🚀 Iniciando testes do FeedbackHub..."

BASE_URL="http://localhost:7071"

echo ""
echo "✅ Teste 1: Avaliação Positiva (Nota 10)"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Excelente aula!", "nota": 10}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo "✅ Teste 2: Avaliação Positiva (Nota 8)"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Muito boa a didática.", "nota": 8}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo "⚠️ Teste 3: Avaliação Média (Nota 6)"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Ok, pode melhorar.", "nota": 6}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo "⚠️ Teste 4: Avaliação Média (Nota 5)"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Razoável.", "nota": 5}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo "🚨 Teste 5: Avaliação Crítica (Nota 3) - ACIONARÁ NOTIFICAÇÃO"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Aula muito fraca.", "nota": 3}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 3

echo "🚨 Teste 6: Avaliação Crítica (Nota 1) - ACIONARÁ NOTIFICAÇÃO"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Professor faltou sem avisar.", "nota": 1}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 3

echo "🚨 Teste 7: Avaliação Crítica (Nota 0) - ACIONARÁ NOTIFICAÇÃO"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Péssimo! Equipamentos quebrados.", "nota": 0}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 3

echo "❌ Teste 8: Validação - Nota Inválida (15)"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste validação", "nota": 15}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo "❌ Teste 9: Validação - Nota Negativa (-5)"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste validação", "nota": -5}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo "❌ Teste 10: Validação - Descrição Vazia"
curl -X POST "${BASE_URL}/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "", "nota": 8}' \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo "📊 Teste 11: Relatório Manual"
curl -X GET "${BASE_URL}/api/relatorio/manual" \
  -w "\nStatus: %{http_code}\n\n"
sleep 2

echo ""
echo "✅ Testes concluídos!"
echo ""
echo "📧 Verifique sua caixa de e-mail:"
echo "   - Devem ter chegado 3 notificações de urgência"
echo "   - Deve ter chegado 1 relatório semanal"
echo ""
echo "📋 Verifique os logs das Azure Functions para confirmar"
```

**Para executar**:
```bash
chmod +x test-all-curls.sh
./test-all-curls.sh
```

---

### 🎯 Teste Rápido de Validação

**5 comandos essenciais para testar tudo**:

```bash
# 1. Avaliação boa (não aciona notificação)
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Ótima aula!", "nota": 9}'

# 2. Avaliação crítica (aciona notificação por e-mail)
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Muito ruim!", "nota": 1}'

# 3. Validação de erro
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste", "nota": 20}'

# 4. Relatório manual
curl -X GET "http://localhost:7071/api/relatorio/manual"

# 5. Aguarde 30 segundos e verifique seu e-mail!
```

---

## 📊 Resumo de Endpoints

| Endpoint | Método | Função | Automático? |
|----------|--------|--------|-------------|
| `/api/avaliacao` | POST | Recebe avaliação | ❌ Manual |
| `/api/relatorio/manual` | GET | Gera relatório manual | ❌ Manual |
| `notificarUrgencia` | - | Envia notificação urgente | ✅ Queue Trigger |
| `gerarRelatorioSemanal` | - | Relatório semanal | ✅ Timer (Segunda 9h) |

---

## 📧 Verificar E-mails Enviados

### No seu e-mail pessoal (se configurou):
1. Verifique a caixa de entrada
2. **IMPORTANTE**: Verifique também a pasta SPAM/Lixo Eletrônico
3. Remetente: `DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net`

### Nos logs da aplicação:
```bash
# Procure por:
grep "E-mail enviado com sucesso" logs.txt
```

### No Azure Portal:
1. Acesse Communication Services
2. Monitoring → Email Logs
3. Verifique status de entrega

---

## 🎥 Para Demonstração em Vídeo

**Sequência recomendada**:

1. **Mostre o código rodando**:
   ```bash
   mvn azure-functions:run
   ```

2. **Envie avaliação positiva**:
   ```bash
   curl -X POST "http://localhost:7071/api/avaliacao" \
     -H "Content-Type: application/json" \
     -d '{"descricao": "Aula excelente!", "nota": 10}'
   ```
   Mostre o log: "Avaliação salva com urgência: BAIXA"

3. **Envie avaliação crítica**:
   ```bash
   curl -X POST "http://localhost:7071/api/avaliacao" \
     -H "Content-Type: application/json" \
     -d '{"descricao": "Muito ruim!", "nota": 1}'
   ```
   Mostre os logs:
   - "🚨 URGÊNCIA CRÍTICA detectada!"
   - "Mensagem enviada para fila"
   - "Processando notificação de urgência"
   - "E-mail enviado com sucesso"

4. **Solicite relatório**:
   ```bash
   curl -X GET "http://localhost:7071/api/relatorio/manual"
   ```
   Mostre o relatório JSON retornado

5. **Mostre seu e-mail**:
   - Abra o e-mail de notificação urgente
   - Abra o e-mail do relatório semanal

---

## 🔗 Referências

- **Configuração de E-mails**: `CONFIGURACAO-EMAILS.md`
- **Documentação das Functions**: `docs/FUNCTIONS.md`
- **Troubleshooting**: `TROUBLESHOOTING.md`
- **Script de Teste**: `test-functions.sh`

---

**Última atualização**: 18 de fevereiro de 2026
**Autor**: GitHub Copilot

