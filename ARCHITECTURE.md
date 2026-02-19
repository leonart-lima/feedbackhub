# 🏗️ Visão Geral da Arquitetura - FeedbackHub

## 📊 Diagrama de Componentes Azure

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              AZURE CLOUD                                      │
│                         Resource Group: feedbackhub-rg                        │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                ┌─────────────────────┼─────────────────────┐
                │                     │                     │
                ▼                     ▼                     ▼
        
┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
│   FUNCTION APP    │      │   SQL DATABASE    │      │  STORAGE ACCOUNT  │
│  (Serverless)     │◄────►│   (Serverless)    │      │                   │
│                   │      │                   │      │  ┌─────────────┐  │
│ ┌───────────────┐ │      │  feedbackhub      │      │  │   QUEUE     │  │
│ │ receberAvalia │ │      │                   │      │  │  feedback-  │  │
│ │     cao       │─┼─────►│  Tabela:          │      │  │  urgencia   │  │
│ │ (HTTP POST)   │ │      │  - avaliacoes     │      │  └──────┬──────┘  │
│ └───────┬───────┘ │      │                   │      └─────────┼─────────┘
│         │         │      └───────────────────┘                │
│         │ (nota≤3)│                                           │
│         └────────►├───────────────────────────────────────────┘
│                   │                  │
│ ┌───────────────┐ │                  │
│ │ notificar     │◄┼──────────────────┘
│ │  Urgencia     │ │                  
│ │ (Queue Trig.) │─┼────────────────────────┐
│ └───────────────┘ │                        │
│                   │                        ▼
│ ┌───────────────┐ │              ┌─────────────────┐
│ │ gerarRelato   │ │              │   SENDGRID      │
│ │  rioSemanal   │─┼─────────────►│  Email Service  │
│ │ (Timer: seg)  │ │              │                 │
│ └───────────────┘ │              │  100 emails/dia │
└───────────────────┘              └─────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│     APPLICATION INSIGHTS            │
│   Monitoramento e Logs              │
│                                     │
│  - Execuções                        │
│  - Performance                      │
│  - Erros                            │
│  - Dependências                     │
└─────────────────────────────────────┘
```

---

## 🔄 Fluxos de Dados

### Fluxo 1: Recepção de Avaliação (Positiva/Média)

```
┌──────────┐     POST      ┌──────────────────┐      Save      ┌──────────┐
│  Cliente ├──────────────►│ receberAvaliacao ├───────────────►│   SQL    │
│  (cURL)  │  /api/avalia  │   (Function)     │                │ Database │
└──────────┘     cao       └──────────────────┘                └──────────┘
                                    │
                                    │ Return
                                    ▼
                            ┌───────────────┐
                            │  JSON Response│
                            │  - id         │
                            │  - urgencia   │
                            │  - dataEnvio  │
                            └───────────────┘
```

### Fluxo 2: Avaliação Crítica (nota 0-3) - Com Notificação

```
┌──────────┐     POST      ┌──────────────────┐      Save      ┌──────────┐
│  Cliente ├──────────────►│ receberAvaliacao ├───────────────►│   SQL    │
│          │  nota ≤ 3     │   (Function)     │                │ Database │
└──────────┘               └────────┬─────────┘                └──────────┘
                                    │
                          Send to Queue
                                    │
                                    ▼
                          ┌─────────────────┐
                          │  Storage Queue  │
                          │ feedback-urgen  │
                          │     cia-queue   │
                          └────────┬────────┘
                                   │
                            Queue Trigger
                                   │
                                   ▼
                          ┌──────────────────┐     Email      ┌──────────┐
                          │ notificarUrgen   ├───────────────►│ SendGrid │
                          │  cia (Function)  │                └─────┬────┘
                          └──────────────────┘                      │
                                                                     ▼
                                                          ┌──────────────────┐
                                                          │ Administradores  │
                                                          │  (ADMIN_EMAILS)  │
                                                          └──────────────────┘
```

### Fluxo 3: Relatório Semanal (Segundas-feiras 9h)

```
                    ┌──────────────────┐
                    │  Azure Timer     │
                    │  (CRON: seg 9h)  │
                    └────────┬─────────┘
                             │
                       Timer Trigger
                             │
                             ▼
                    ┌──────────────────┐      Query      ┌──────────┐
                    │ gerarRelatorio   ├────────────────►│   SQL    │
                    │  Semanal (Func)  │   Last 7 days   │ Database │
                    └────────┬─────────┘                 └──────────┘
                             │
                      Calculate Stats
                             │
                             ▼
                    ┌──────────────────┐
                    │  HTML Report     │
                    │  - Total avaliaç.│
                    │  - Média geral   │
                    │  - Por urgência  │
                    │  - Por dia       │
                    └────────┬─────────┘
                             │
                       Send Email
                             │
                             ▼
                    ┌──────────────────┐     Email      ┌──────────┐
                    │    SendGrid      ├───────────────►│ Gerentes │
                    └──────────────────┘                │(REPORT_  │
                                                        │ EMAILS)  │
                                                        └──────────┘
```

---

## 🗂️ Estrutura MVC

```
src/main/java/com/fiap/feedbackhub/
│
├── 📋 MODEL (Entidades de Domínio)
│   └── model/
│       └── Avaliacao.java                    [Entidade JPA]
│
├── 🎯 CONTROLLER (Interface REST)
│   └── controller/
│       └── AvaliacaoController.java          [REST endpoints]
│
├── 🔧 SERVICE (Lógica de Negócio)
│   └── service/
│       ├── AvaliacaoService.java             [CRUD avaliações]
│       ├── RelatorioService.java             [Gerar relatórios]
│       ├── EmailService.java                 [Enviar e-mails]
│       └── AzureQueueService.java            [Gerenciar fila]
│
├── 💾 REPOSITORY (Acesso a Dados)
│   └── repository/
│       └── AvaliacaoRepository.java          [Spring Data JPA]
│
├── 📊 DTO (Data Transfer Objects)
│   └── dto/
│       ├── AvaliacaoRequestDTO.java          [Request payload]
│       ├── AvaliacaoResponseDTO.java         [Response payload]
│       └── RelatorioSemanalDTO.java          [Relatório data]
│
├── ⚡ FUNCTIONS (Azure Serverless)
│   └── functions/
│       ├── RecepcionarAvaliacaoFunction.java [HTTP Trigger]
│       ├── NotificacaoUrgenciaFunction.java  [Queue Trigger]
│       └── RelatorioSemanalFunction.java     [Timer Trigger]
│
├── 🔤 ENUMS
│   └── enums/
│       └── Urgencia.java                     [CRITICA, MEDIA, POSITIVA]
│
├── 🛠️ UTILS
│   └── util/
│       └── UrgenciaClassificador.java        [Classificar por nota]
│
└── ⚙️ CONFIG
    └── config/
        └── AppConfig.java                    [Spring Configuration]
```

---

## 📦 Recursos Azure Criados

| # | Recurso | Nome | Função |
|---|---------|------|--------|
| 1 | Resource Group | `feedbackhub-rg` | Agrupar recursos |
| 2 | SQL Server | `feedbackhub-server-XXXXXX` | Hospedar database |
| 3 | SQL Database | `feedbackhub` | Armazenar avaliações |
| 4 | Storage Account | `feedbackhubstXXXXXXXX` | Armazenamento geral |
| 5 | Storage Queue | `feedback-urgencia-queue` | Fila de mensagens |
| 6 | Function App | `feedbackhub-func-XXXXXX` | Hospedar functions |
| 7 | App Insights | `feedbackhub-insights` | Monitoramento |

---

## 🔒 Camadas de Segurança

```
┌─────────────────────────────────────────────────────────────┐
│                    SEGURANÇA IMPLEMENTADA                    │
└─────────────────────────────────────────────────────────────┘

1️⃣  AUTENTICAÇÃO
    ├─ Function Keys (API protegida)
    └─ Authorization Level: FUNCTION

2️⃣  REDE
    ├─ HTTPS obrigatório
    ├─ SQL Firewall (apenas Azure Services)
    └─ SQL Firewall (IP específico permitido)

3️⃣  DADOS
    ├─ SQL: SSL/TLS criptografado
    ├─ Storage: HTTPS obrigatório
    └─ Variáveis de ambiente protegidas

4️⃣  CREDENCIAIS
    ├─ App Settings (não no código)
    ├─ Connection Strings protegidas
    └─ .gitignore configurado

5️⃣  ACESSO
    ├─ RBAC (Role-Based Access Control)
    ├─ Managed Identity (futuro)
    └─ Key Vault (futuro - opcional)
```

---

## 📈 Monitoramento e Observabilidade

```
┌────────────────────────────────────────────────────────────────┐
│              APPLICATION INSIGHTS DASHBOARD                     │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📊 MÉTRICAS                                                    │
│  ├─ Execuções/segundo                                          │
│  ├─ Taxa de sucesso (%)                                        │
│  ├─ Tempo médio de resposta (ms)                              │
│  └─ Erros/exceções                                             │
│                                                                 │
│  📝 LOGS                                                        │
│  ├─ receberAvaliacao: "Avaliação X recebida"                  │
│  ├─ notificarUrgencia: "E-mail enviado para Y"                │
│  └─ gerarRelatorioSemanal: "Relatório gerado: Z avaliações"   │
│                                                                 │
│  🔗 DEPENDÊNCIAS                                                │
│  ├─ SQL Database (tempo de query)                             │
│  ├─ Storage Queue (tempo de enqueue)                          │
│  └─ SendGrid API (tempo de envio)                             │
│                                                                 │
│  🎯 ALERTAS CUSTOMIZADOS                                        │
│  ├─ Taxa de erro > 5%                                          │
│  ├─ Tempo de resposta > 3s                                     │
│  └─ SQL Database offline                                       │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

---

## 💰 Estimativa de Custos Mensal

| Recurso | Configuração | Uso Estimado | Custo/Mês |
|---------|-------------|--------------|-----------|
| **SQL Database** | Serverless Gen5<br>0.5-2 vCores<br>Auto-pause 60min | 10h ativas/dia<br>14h pausado/dia | R$ 10-20 |
| **Storage Account** | Standard LRS<br>1 GB dados | 10k transações/mês | R$ 2-3 |
| **Storage Queue** | Standard | 5k mensagens/mês | Incluído |
| **Function App** | Consumption Plan | 50k execuções/mês<br>256 MB memory | Grátis* |
| **App Insights** | Standard | 2 GB logs/mês | Grátis* |
| **SendGrid** | Free Plan | 50 emails/dia | Grátis* |
| **TOTAL** | | | **R$ 12-23** |

\* Dentro do tier gratuito

### 💡 Dicas para Economizar

1. **SQL Database**: Configurar auto-pause para 60 minutos (já configurado)
2. **Functions**: Otimizar código para execução rápida (<1s)
3. **Storage**: Limpar queue regularmente
4. **Logs**: Configurar retenção de 30 dias no App Insights
5. **Pausar quando não usar**: Parar Function App fora do horário de testes

---

## 🎯 Responsabilidades das Functions

### 1️⃣ receberAvaliacao (HTTP Trigger)
**Single Responsibility**: Receber e validar avaliações

```
✅ FAZ:
  - Valida request (campos obrigatórios, range de nota)
  - Classifica urgência
  - Persiste no banco
  - Envia para queue se crítico
  - Retorna confirmação

❌ NÃO FAZ:
  - Enviar e-mails (delegado para notificarUrgencia)
  - Gerar relatórios (delegado para gerarRelatorioSemanal)
```

### 2️⃣ notificarUrgencia (Queue Trigger)
**Single Responsibility**: Processar notificações urgentes

```
✅ FAZ:
  - Lê mensagem da queue
  - Gera e-mail formatado
  - Envia via SendGrid
  - Marca como notificada

❌ NÃO FAZ:
  - Receber avaliações (delegado para receberAvaliacao)
  - Validar dados (já validado)
  - Gerar relatórios (delegado para gerarRelatorioSemanal)
```

### 3️⃣ gerarRelatorioSemanal (Timer Trigger)
**Single Responsibility**: Gerar e enviar relatórios periódicos

```
✅ FAZ:
  - Busca avaliações da semana
  - Calcula estatísticas
  - Gera relatório HTML
  - Envia por e-mail

❌ NÃO FAZ:
  - Receber avaliações (delegado para receberAvaliacao)
  - Notificar urgências (delegado para notificarUrgencia)
  - Validar dados individuais
```

---

## 🚀 Workflow de Deploy

```
┌────────────────┐
│  Desenvolvedor │
└───────┬────────┘
        │
        │ git push
        ▼
┌────────────────┐
│     GitHub     │
└───────┬────────┘
        │
        │ Trigger (opcional)
        ▼
┌────────────────────┐
│  GitHub Actions    │
│  (CI/CD Pipeline)  │
└────────┬───────────┘
         │
         │ mvn package
         ▼
┌────────────────────┐
│   Build JAR        │
│  feedbackhub.jar   │
└────────┬───────────┘
         │
         │ mvn azure-functions:deploy
         ▼
┌────────────────────┐
│   Azure Portal     │
│  Function App      │
└────────┬───────────┘
         │
         │ Health Check
         ▼
┌────────────────────┐
│  Functions Online  │
│  ✅ Ready to use   │
└────────────────────┘
```

---

## 📞 Links Úteis

- **Portal Azure**: https://portal.azure.com
- **SendGrid**: https://app.sendgrid.com
- **Application Insights**: https://portal.azure.com > App Insights
- **Documentação Azure Functions**: https://docs.microsoft.com/azure/azure-functions/
- **Spring Boot Docs**: https://spring.io/projects/spring-boot

---

**Criado para o Tech Challenge FIAP - Fase 4**

