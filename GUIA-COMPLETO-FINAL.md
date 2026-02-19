# 🎯 GUIA COMPLETO - FeedbackHub

## 📧 RESPOSTA RÁPIDA: Para Onde os E-mails São Enviados?

### E-mails Configurados Atualmente

| Tipo | Variável | E-mail Configurado | Quando Recebe |
|------|----------|-------------------|---------------|
| 🚨 **Notificações Urgentes** | `ADMIN_EMAILS` | `admin@feedbackhub.com` | Avaliação com nota ≤ 3 |
| 📊 **Relatórios Semanais** | `REPORT_EMAILS` | `relatorios@feedbackhub.com` | Segunda-feira 9h UTC |
| 📤 **Remetente** | `AZURE_COMMUNICATION_FROM_EMAIL` | `DoNotReply@...azurecomm.net` | - |

### ⚠️ IMPORTANTE: Estes e-mails são FICTÍCIOS!

Para receber e-mails reais, edite:
```bash
vim local.settings.json
```

Altere:
```json
{
  "Values": {
    "ADMIN_EMAILS": "SEU-EMAIL@REAL.COM",
    "REPORT_EMAILS": "SEU-EMAIL@REAL.COM"
  }
}
```

**Documentação completa**: [`CONFIGURACAO-EMAILS.md`](CONFIGURACAO-EMAILS.md)

---

## 🚀 COMO EXECUTAR NO INTELLIJ

### Opção 1: Executar Normalmente (Sem Debug)

```bash
# No terminal do IntelliJ (⌘+1 ou Alt+F12)
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package -DskipTests
mvn azure-functions:run
```

### Opção 2: Debug Completo no IntelliJ

#### Configuração Rápida (1 minuto)

1. **Menu**: `Run` → `Edit Configurations...`
2. **Clique**: `+` → `Maven`
3. **Preencha**:
   - **Name**: `Azure Functions Debug`
   - **Working directory**: `/Users/leonartlima/IdeaProjects/feedbackhub`
   - **Command line**: `clean package -DskipTests azure-functions:run`
4. **Clique**: `Apply` → `OK`

#### Executar

1. **Coloque breakpoints** no código (clique na margem esquerda da linha)
2. **Execute em debug**: Ícone de inseto 🐛 ou `⌘+D`
3. **Teste**: Execute os CURLs em outro terminal

**Guia completo**: [`DEBUG-INTELLIJ-COMPLETO.md`](DEBUG-INTELLIJ-COMPLETO.md)

---

## 📋 REGRAS DE NEGÓCIO IMPLEMENTADAS

### ✅ O Sistema Faz:

1. **Recebe Avaliações** (`POST /api/avaliacao`)
   - Valida nota (0-10)
   - Valida descrição (não vazia)
   - Classifica urgência automaticamente
   - Salva no banco de dados Azure SQL

2. **Classifica Urgência Automaticamente**
   - **CRÍTICA**: Notas 0-3 → 🚨 Aciona notificação imediata
   - **MÉDIA**: Notas 4-6 → ⚠️ Apenas registra
   - **BAIXA**: Notas 7-10 → ✅ Apenas registra

3. **Notifica Urgências** (Automático via Queue)
   - Avaliação crítica (≤3) → Envia para fila Azure Storage Queue
   - Queue Trigger aciona função `notificarUrgencia`
   - Envia e-mail HTML formatado para `ADMIN_EMAILS`
   - Marca avaliação como "notificada" no banco

4. **Gera Relatórios Semanais**
   - **Automático**: Toda segunda-feira às 09:00 UTC (06:00 Brasília)
   - **Manual**: `GET /api/relatorio/manual`
   - Dados dos últimos 7 dias:
     - Total de avaliações
     - Média geral
     - Avaliações por dia
     - Avaliações por urgência
   - Envia e-mail para `REPORT_EMAILS`

### 📊 Dados Enviados por E-mail

#### E-mail de Urgência
```
Assunto: ⚠️ URGENTE: Avaliação Crítica Recebida - Nota X

Conteúdo:
- Descrição da avaliação
- Nota (0-3)
- Urgência: CRÍTICA
- Data de envio
- Ação requerida
```

#### E-mail de Relatório Semanal
```
Assunto: FeedbackHub - Relatório Semanal de Avaliações

Conteúdo:
- Período (últimos 7 dias)
- Total de avaliações
- Média geral
- Quantidade por dia
- Quantidade por urgência (Crítica/Média/Baixa)
```

---

## 🎯 TODOS OS CURLS - CÓPIA RÁPIDA

### 1. Avaliação Positiva (Nota 10)
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Excelente aula!", "nota": 10}'
```

### 2. Avaliação Média (Nota 5)
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Pode melhorar.", "nota": 5}'
```

### 3. Avaliação Crítica - ACIONA NOTIFICAÇÃO! (Nota 2)
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Professor faltou sem avisar!", "nota": 2}'
```

### 4. Validação de Erro (Nota Inválida)
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste validação", "nota": 15}'
```

### 5. Relatório Manual
```bash
curl -X GET "http://localhost:7071/api/relatorio/manual"
```

**Todos os CURLs**: [`CURLS-COMPLETOS.md`](CURLS-COMPLETOS.md)

---

## 🏗️ ARQUITETURA DA SOLUÇÃO

### Componentes Cloud

```
┌─────────────────────────────────────────────────────┐
│  AZURE FUNCTION APP (feedbackhub-func-55878)      │
│                                                     │
│  ┌─────────────────────────────────────────┐      │
│  │  Function 1: receberAvaliacao            │      │
│  │  Trigger: HTTP POST /api/avaliacao       │      │
│  │  - Valida entrada                        │      │
│  │  - Salva no Azure SQL                    │      │
│  │  - Classifica urgência                   │      │
│  │  - Se crítica → Envia para Queue         │      │
│  └─────────────────────────────────────────┘      │
│                        ↓                            │
│  ┌─────────────────────────────────────────┐      │
│  │  Azure Storage Queue                     │      │
│  │  feedback-urgencia-queue                 │      │
│  └─────────────────────────────────────────┘      │
│                        ↓                            │
│  ┌─────────────────────────────────────────┐      │
│  │  Function 2: notificarUrgencia           │      │
│  │  Trigger: Queue (automático)             │      │
│  │  - Lê mensagem da fila                   │      │
│  │  - Gera HTML do e-mail                   │      │
│  │  - Envia via Communication Services      │      │
│  │  - Marca como notificada                 │      │
│  └─────────────────────────────────────────┘      │
│                                                     │
│  ┌─────────────────────────────────────────┐      │
│  │  Function 3: gerarRelatorioSemanal       │      │
│  │  Trigger: Timer (Segunda 9h UTC)         │      │
│  │  - Consulta últimos 7 dias               │      │
│  │  - Calcula estatísticas                  │      │
│  │  - Gera HTML do relatório                │      │
│  │  - Envia via Communication Services      │      │
│  └─────────────────────────────────────────┘      │
│                                                     │
│  ┌─────────────────────────────────────────┐      │
│  │  Function 4: gerarRelatorioManual        │      │
│  │  Trigger: HTTP GET /api/relatorio/manual │      │
│  │  - Mesma lógica do automático            │      │
│  │  - Acionado sob demanda                  │      │
│  └─────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Azure SQL DB │ │ Storage      │ │ Comm Service │
│ feedbackhub  │ │ Account      │ │ (Email)      │
│              │ │ - Queue      │ │              │
│ - avaliacoes │ │ - Blobs      │ │ - Send Email │
└──────────────┘ └──────────────┘ └──────────────┘
```

### Padrões Implementados

- ✅ **Serverless**: Todas as funções são Azure Functions
- ✅ **Responsabilidade Única**: Cada função tem uma responsabilidade
- ✅ **Event-Driven**: Queue Trigger para notificações
- ✅ **Scheduled Tasks**: Timer Trigger para relatórios
- ✅ **MVC Pattern**: Model, Service, Repository
- ✅ **Dependency Injection**: Spring Boot + Azure Functions

---

## 📦 ESTRUTURA DO PROJETO

```
feedbackhub/
├── src/main/java/com/fiap/feedbackhub/
│   ├── FeedbackhubApplication.java          # Spring Boot Application
│   ├── functions/                           # Azure Functions
│   │   ├── ReceberAvaliacaoFunction.java    # POST /api/avaliacao
│   │   ├── NotificacaoUrgenciaFunction.java # Queue Trigger
│   │   ├── RelatorioSemanalFunction.java    # Timer Trigger
│   │   └── RelatorioManualFunction.java     # GET /api/relatorio/manual
│   ├── model/                               # Entidades JPA
│   │   └── Avaliacao.java                   # Entity (avaliacoes table)
│   ├── repository/                          # Data Access Layer
│   │   └── AvaliacaoRepository.java         # JPA Repository
│   ├── service/                             # Business Logic
│   │   ├── AvaliacaoService.java            # CRUD de avaliações
│   │   ├── EmailService.java                # Envio de e-mails
│   │   ├── FilaService.java                 # Envio para queue
│   │   ├── RelatorioService.java            # Geração de relatórios
│   │   └── UrgenciaClassificador.java       # Classificação de urgência
│   └── dto/                                 # Data Transfer Objects
│       └── AvaliacaoRequest.java            # Request DTO
├── src/main/resources/
│   └── application.yml                      # Configurações Spring
├── pom.xml                                  # Maven dependencies
├── local.settings.json                      # Azure Functions local config
└── host.json                                # Azure Functions host config
```

---

## 🔒 CONFIGURAÇÕES DE SEGURANÇA

### Implementadas

✅ **Firewall Azure SQL**: IP `191.244.255.54` autorizado  
✅ **Connection Strings**: Stored em variáveis de ambiente  
✅ **SSL/TLS**: Conexão criptografada com Azure SQL  
✅ **API Keys**: Azure Communication Services protegido  
✅ **Managed Identity**: Recomendado para produção (não implementado ainda)

### Variáveis de Ambiente Sensíveis

```bash
DB_PASSWORD=FeedbackHub@2026!
AZURE_STORAGE_CONNECTION_STRING=...AccountKey=...
AZURE_COMMUNICATION_CONNECTION_STRING=...accesskey=...
```

**⚠️ NUNCA commite essas credenciais no Git!**

---

## 📊 MONITORAMENTO

### Application Insights (Configurado)

- Métricas de execução das funções
- Logs centralizados
- Alertas de erro
- Performance tracking

### Como Acessar

1. Azure Portal
2. Function App → `feedbackhub-func-55878`
3. Monitoring → Application Insights
4. Visualize:
   - Requests por segundo
   - Tempo de resposta
   - Erros 4xx/5xx
   - Logs em tempo real

---

## 🧪 TESTE COMPLETO EM 2 MINUTOS

```bash
# 1. Executar Azure Functions
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package -DskipTests && mvn azure-functions:run

# 2. Em outro terminal, executar testes
# Avaliação boa (não notifica)
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Ótima aula!", "nota": 9}'

# Avaliação crítica (NOTIFICA por e-mail!)
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Muito ruim!", "nota": 1}'

# Relatório manual
curl -X GET "http://localhost:7071/api/relatorio/manual"

# 3. Verificar logs
# Procure por:
# - "🚨 URGÊNCIA CRÍTICA detectada!"
# - "Mensagem enviada para fila com sucesso"
# - "E-mail enviado com sucesso para: ..."

# 4. Verificar e-mail (se configurou seu e-mail real)
# Verifique caixa de entrada E SPAM
```

---

## 📚 DOCUMENTAÇÃO COMPLETA

### Documentos Criados

| Arquivo | Descrição |
|---------|-----------|
| [`CONFIGURACAO-EMAILS.md`](CONFIGURACAO-EMAILS.md) | Como configurar e-mails, para onde vão, como testar |
| [`CURLS-COMPLETOS.md`](CURLS-COMPLETOS.md) | Todos os CURLs de teste com exemplos |
| [`DEBUG-INTELLIJ-COMPLETO.md`](DEBUG-INTELLIJ-COMPLETO.md) | Como debugar no IntelliJ IDEA |
| [`START-HERE.md`](START-HERE.md) | Início rápido TL;DR |
| `docs/FUNCTIONS.md` | Documentação técnica das functions |
| `TROUBLESHOOTING.md` | Solução de problemas |

### Documentos Existentes

| Arquivo | Descrição |
|---------|-----------|
| `README.md` | Documentação principal do projeto |
| `ARCHITECTURE.md` | Arquitetura detalhada |
| `QUICKSTART.md` | Guia de início rápido |
| `CURL-EXAMPLES.md` | Exemplos de curl (antigo) |

---

## 🎥 ROTEIRO PARA DEMONSTRAÇÃO EM VÍDEO

### 1. Introdução (2 min)
- Apresente o projeto FeedbackHub
- Explique o problema: necessidade de feedback rápido
- Mostre a arquitetura no slide/quadro

### 2. Mostrar Código (3 min)
- Abra IntelliJ
- Mostre estrutura do projeto
- Destaque as 4 funções:
  - `ReceberAvaliacaoFunction`
  - `NotificacaoUrgenciaFunction`
  - `RelatorioSemanalFunction`
  - `RelatorioManualFunction`

### 3. Configuração Azure (2 min)
- Mostre Azure Portal
- Mostre Function App criado
- Mostre Azure SQL Database
- Mostre Storage Account (Queue)
- Mostre Communication Services

### 4. Executar Localmente (5 min)
```bash
# No IntelliJ terminal
mvn azure-functions:run
```

Aguarde inicializar e mostre os logs:
```
[INFO] Azure Functions Java Runtime [4.x.x]
[INFO] HTTP Trigger: receberAvaliacao
[INFO] Timer Trigger: gerarRelatorioSemanal
[INFO] Queue Trigger: notificarUrgencia
```

### 5. Testar Endpoints (5 min)

**Teste 1: Avaliação Positiva**
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Excelente professor, aula muito didática!", "nota": 10}'
```

Mostre:
- Resposta JSON com `urgencia: "BAIXA"`
- Log: "Avaliação salva com urgência: BAIXA"

**Teste 2: Avaliação Crítica**
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Professor não compareceu à aula!", "nota": 1}'
```

Mostre:
- Resposta JSON com `urgencia: "CRITICA"`
- Logs importantes:
  ```
  🚨 URGÊNCIA CRÍTICA detectada!
  Mensagem enviada para fila com sucesso
  === Azure Function: Processando notificação de urgência ===
  E-mail enviado com sucesso para: admin@feedbackhub.com
  ```

**Teste 3: Relatório Manual**
```bash
curl -X GET "http://localhost:7071/api/relatorio/manual"
```

Mostre:
- JSON com estatísticas
- Log: "Relatório gerado e enviado com sucesso"

### 6. Mostrar E-mails Recebidos (2 min)
- Abra sua caixa de entrada
- Mostre e-mail de notificação urgente
- Mostre e-mail de relatório semanal

### 7. Mostrar Debug no IntelliJ (3 min)
- Coloque breakpoint em `ReceberAvaliacaoFunction.java:115`
- Execute em debug
- Execute curl
- Mostre parando no breakpoint
- Inspecione variáveis
- Continue e mostre resultado

### 8. Mostrar Azure Portal (3 min)
- Navegue até Function App
- Mostre logs em tempo real
- Mostre métricas de execução
- Mostre Application Insights

### 9. Conclusão (1 min)
- Recapitule o que foi demonstrado
- Destaque os requisitos atendidos:
  - ✅ Serverless implementado
  - ✅ Cloud computing (Azure)
  - ✅ Múltiplas functions com responsabilidade única
  - ✅ Notificações automáticas
  - ✅ Relatórios semanais
  - ✅ Monitoramento
  - ✅ Segurança

---

## ✅ CHECKLIST FINAL

### Antes de Gravar Vídeo

- [ ] Azure Functions rodando localmente
- [ ] E-mail configurado com seu e-mail real
- [ ] Banco de dados com algumas avaliações
- [ ] Azure Portal aberto em aba separada
- [ ] Caixa de e-mail aberta
- [ ] IntelliJ configurado para debug
- [ ] Terminal com comandos curl prontos
- [ ] Documentação aberta para referência

### Durante Gravação

- [ ] Áudio claro
- [ ] Zoom adequado no código
- [ ] Pausas entre comandos para mostrar resultados
- [ ] Explicar o que está acontecendo
- [ ] Mostrar logs relevantes
- [ ] Mostrar e-mails recebidos

---

## 🆘 PRECISA DE AJUDA?

### Problemas Comuns

| Problema | Solução Rápida |
|----------|----------------|
| Firewall Azure SQL | `./fix-azure-sql-firewall.sh` |
| Functions não iniciam | `mvn clean install -U -DskipTests` |
| Porta 7071 ocupada | `lsof -ti:7071 \| xargs kill -9` |
| E-mails não chegam | Verifique `ADMIN_EMAILS` e pasta SPAM |
| Breakpoint não para | Recompile: `mvn clean package` |

### Arquivos de Troubleshooting

- `TROUBLESHOOTING.md` - Solução geral de problemas
- `TROUBLESHOOTING-FIREWALL.md` - Específico de firewall
- `DEBUG-INTELLIJ-COMPLETO.md` - Debug no IntelliJ

---

## 🎓 REQUISITOS DO TECH CHALLENGE - ATENDIDOS

### ✅ Requisitos Obrigatórios

- [x] **Serverless implementado** - 4 Azure Functions
- [x] **Cloud computing** - Azure (Function App, SQL, Storage, Communication)
- [x] **Mínimo 2 functions** - Temos 4 functions
- [x] **Responsabilidade Única** - Cada function tem uma responsabilidade
- [x] **Notificações automáticas** - Queue Trigger para urgências
- [x] **Relatório semanal** - Timer Trigger toda segunda 9h
- [x] **Banco de dados configurado** - Azure SQL Database
- [x] **Deploy automatizado** - Scripts de deploy
- [x] **Monitoramento** - Application Insights
- [x] **Segurança e governança** - Firewall, variáveis de ambiente

### ✅ Artefatos de Entrega

- [x] **Repositório aberto** - Código-fonte completo
- [x] **Vídeo de demonstração** - Roteiro pronto acima
- [x] **Documentação completa**:
  - [x] Arquitetura da solução
  - [x] Instruções de deploy
  - [x] Configuração de monitoramento
  - [x] Documentação das funções
  - [x] Qualidade do código
  - [x] Explicação do modelo cloud

---

## 📞 CONTATOS E LINKS

### Repositório
```
https://github.com/SEU-USUARIO/feedbackhub
```

### Azure Resources
- **Function App**: `feedbackhub-func-55878`
- **SQL Server**: `feedbackhub-server-55878`
- **Database**: `feedbackhub`
- **Storage Account**: `feedbackhubst1455878`
- **Communication Services**: `feedbackhub-comm-55878`
- **Resource Group**: `feedbackhub-rg`

---

**🎉 Tudo pronto! Boa sorte com o Tech Challenge!**

**Data**: 18 de fevereiro de 2026  
**Última atualização**: 2026-02-19T01:45:00

