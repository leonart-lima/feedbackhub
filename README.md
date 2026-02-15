# FeedbackHub - Plataforma de Feedback Serverless

[![Deploy Azure Functions](https://github.com/yourusername/feedbackhub/actions/workflows/deploy.yml/badge.svg)](https://github.com/yourusername/feedbackhub/actions/workflows/deploy.yml)

## 📋 Descrição do Projeto

FeedbackHub é uma plataforma de feedback serverless desenvolvida para permitir que estudantes avaliem aulas e administradores acompanhem a satisfação dos alunos em tempo real. O sistema utiliza **Azure Functions** para automação de processos, **Azure SQL Database** para armazenamento de dados, e **SendGrid** para notificações por e-mail.

### Características Principais

- ✅ **Recepção de Feedbacks**: API REST para receber avaliações com descrição e nota (0-10)
- ✅ **Classificação Automática de Urgência**: Avaliações críticas (notas 0-3), médias (4-6) e positivas (7-10)
- ✅ **Notificações Automáticas**: E-mails enviados aos administradores para avaliações críticas
- ✅ **Relatórios Semanais**: Geração automática de relatórios com estatísticas e análises
- ✅ **Arquitetura MVC**: Código organizado seguindo o padrão Model-View-Controller
- ✅ **Serverless**: Três Azure Functions com responsabilidades únicas
- ✅ **Deploy Automatizado**: CI/CD com GitHub Actions

---

## 🏗️ Arquitetura da Solução

### Componentes Cloud (Azure)

```
┌─────────────────────────────────────────────────────────────────┐
│                         AZURE CLOUD                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐      ┌──────────────────┐                │
│  │  Azure Function  │      │  Azure Function  │                │
│  │  HTTP Trigger    │──────│  Queue Trigger   │                │
│  │ receberAvaliacao │      │ notificarUrgencia│                │
│  └────────┬─────────┘      └────────┬─────────┘                │
│           │                         │                           │
│           ▼                         ▼                           │
│  ┌─────────────────┐      ┌──────────────────┐                │
│  │  Azure SQL DB   │      │  Storage Queue   │                │
│  │   (Free Tier)   │      │  feedback-queue  │                │
│  └─────────────────┘      └──────────────────┘                │
│           │                         │                           │
│           │                         ▼                           │
│           │               ┌──────────────────┐                │
│           │               │    SendGrid      │                │
│           │               │  Email Service   │                │
│           │               └──────────────────┘                │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │  Azure Function  │                                          │
│  │  Timer Trigger   │                                          │
│  │ relatorioSemanal │                                          │
│  └──────────────────┘                                          │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                          │
│  │ App Insights     │                                          │
│  │ Monitoring       │                                          │
│  └──────────────────┘                                          │
└─────────────────────────────────────────────────────────────────┘
```

### Funções Serverless Implementadas

#### 1️⃣ **RecepcionarAvaliacaoFunction** (HTTP Trigger)
- **Responsabilidade**: Receber e processar avaliações via API REST
- **Endpoint**: `POST /api/avaliacao`
- **Input**: JSON com `descricao` e `nota`
- **Processo**:
  1. Valida dados de entrada
  2. Classifica urgência baseado na nota
  3. Persiste no Azure SQL Database
  4. Envia para fila se avaliação for crítica
- **Output**: Confirmação com dados da avaliação salva

#### 2️⃣ **NotificacaoUrgenciaFunction** (Queue Trigger)
- **Responsabilidade**: Processar avaliações críticas e enviar notificações
- **Trigger**: Azure Storage Queue (`feedback-urgencia-queue`)
- **Processo**:
  1. Lê mensagem da fila
  2. Gera e-mail formatado com dados da avaliação
  3. Envia notificação via SendGrid
  4. Marca avaliação como notificada
- **Output**: E-mail enviado aos administradores

#### 3️⃣ **RelatorioSemanalFunction** (Timer Trigger)
- **Responsabilidade**: Gerar e enviar relatórios semanais automaticamente
- **Schedule**: Toda segunda-feira às 9h (CRON: `0 0 9 * * MON`)
- **Processo**:
  1. Busca avaliações da última semana
  2. Calcula estatísticas (total, média, distribuição)
  3. Gera relatório HTML formatado
  4. Envia por e-mail
- **Output**: Relatório semanal enviado

### Arquitetura MVC

```
src/main/java/com/fiap/feedbackhub/
├── model/              # MODEL - Entidades JPA
│   └── Avaliacao.java
├── repository/         # DATA ACCESS - Spring Data JPA
│   └── AvaliacaoRepository.java
├── service/            # BUSINESS LOGIC
│   ├── AvaliacaoService.java
│   ├── RelatorioService.java
│   ├── EmailService.java
│   └── AzureQueueService.java
├── controller/         # CONTROLLER - REST API
│   └── AvaliacaoController.java
├── dto/                # VIEW - Data Transfer Objects
│   ├── AvaliacaoRequestDTO.java
│   ├── AvaliacaoResponseDTO.java
│   └── RelatorioSemanalDTO.java
├── functions/          # SERVERLESS FUNCTIONS
│   ├── RecepcionarAvaliacaoFunction.java
│   ├── NotificacaoUrgenciaFunction.java
│   └── RelatorioSemanalFunction.java
├── enums/
│   └── Urgencia.java
├── util/
│   └── UrgenciaClassificador.java
└── config/
    └── AppConfig.java
```

---

## 🚀 Instruções de Deploy

### Pré-requisitos

- **Java 21** ou superior
- **Maven 3.8+**
- **Azure CLI** instalado e configurado
- **Conta Azure** com créditos disponíveis
- **SendGrid Account** (100 emails/dia gratuitos)

### 1. Configurar Azure Resources

#### Criar Resource Group
```bash
az group create --name feedbackhub-rg --location eastus
```

#### Criar Azure SQL Database (Free Tier)
```bash
# Criar SQL Server
az sql server create \
  --name feedbackhub-server \
  --resource-group feedbackhub-rg \
  --location eastus \
  --admin-user azureuser \
  --admin-password "YourSecurePassword123!"

# Criar Database
az sql db create \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server \
  --name feedbackhub \
  --edition GeneralPurpose \
  --family Gen5 \
  --capacity 2 \
  --compute-model Serverless \
  --auto-pause-delay 60

# Configurar Firewall
az sql server firewall-rule create \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

#### Criar Storage Account
```bash
az storage account create \
  --name feedbackhubstorage \
  --resource-group feedbackhub-rg \
  --location eastus \
  --sku Standard_LRS

# Criar Queue
az storage queue create \
  --name feedback-urgencia-queue \
  --account-name feedbackhubstorage
```

#### Criar Function App
```bash
az functionapp create \
  --resource-group feedbackhub-rg \
  --consumption-plan-location eastus \
  --runtime java \
  --runtime-version 21 \
  --functions-version 4 \
  --name feedbackhub-functions-$(date +%s | tail -c 6) \
  --storage-account feedbackhubstorage \
  --os-type Linux
```

#### Criar Application Insights
```bash
az monitor app-insights component create \
  --app feedbackhub-insights \
  --location eastus \
  --resource-group feedbackhub-rg \
  --application-type web
```

### 2. Configurar Variáveis de Ambiente

```bash
# Obter connection strings
STORAGE_CONNECTION=$(az storage account show-connection-string \
  --name feedbackhubstorage \
  --resource-group feedbackhub-rg \
  --query connectionString -o tsv)

SQL_CONNECTION="jdbc:sqlserver://feedbackhub-server.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"

# Configurar App Settings
az functionapp config appsettings set \
  --name feedbackhub-functions \
  --resource-group feedbackhub-rg \
  --settings \
    "DB_URL=$SQL_CONNECTION" \
    "DB_USERNAME=azureuser" \
    "DB_PASSWORD=YourSecurePassword123!" \
    "AZURE_STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION" \
    "SENDGRID_API_KEY=your-sendgrid-api-key" \
    "SENDGRID_FROM_EMAIL=noreply@feedbackhub.com" \
    "ADMIN_EMAILS=admin@example.com" \
    "REPORT_EMAILS=reports@example.com"
```

### 3. Build e Deploy Local

```bash
# Build do projeto
mvn clean package

# Se tiver problemas de compilação, use o script alternativo
chmod +x build.sh
./build.sh

# Deploy para Azure
mvn azure-functions:deploy
```

#### Troubleshooting Build

**Erro: `java.lang.ExceptionInInitializerError: com.sun.tools.javac.code.TypeTag`**

Este erro indica incompatibilidade entre Java e Maven. Soluções:

1. **Verificar versão do Java**:
```bash
java -version  # Deve ser Java 21
```

2. **Instalar Java 21** (se necessário):
```bash
# macOS (Homebrew)
brew install openjdk@21

# Ubuntu/Debian
sudo apt install openjdk-21-jdk

# Windows (usar instalador do Adoptium/Temurin)
```

3. **Configurar JAVA_HOME**:
```bash
# macOS/Linux
export JAVA_HOME=$(/usr/libexec/java_home -v 21)  # macOS
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64  # Linux

# Adicione ao ~/.zshrc ou ~/.bashrc para permanência
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc
```

4. **Limpar cache do Maven**:
```bash
rm -rf ~/.m2/repository/org/apache/maven/plugins
mvn clean install -U
```

5. **Usar script de build alternativo**:
```bash
chmod +x build.sh
./build.sh
```

### 4. Deploy Automatizado via GitHub Actions

1. Obter **Publish Profile**:
```bash
az functionapp deployment list-publishing-profiles \
  --name feedbackhub-functions \
  --resource-group feedbackhub-rg \
  --xml
```

2. Configurar **GitHub Secrets**:
   - Vá em: `Settings > Secrets and variables > Actions`
   - Adicione os seguintes secrets:
     - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`
     - `DB_URL`
     - `DB_USERNAME`
     - `DB_PASSWORD`
     - `AZURE_STORAGE_CONNECTION_STRING`
     - `SENDGRID_API_KEY`
     - `ADMIN_EMAILS`
     - `REPORT_EMAILS`

3. Push para branch `main` ativa o deploy automaticamente

---

## 📊 Configuração do Monitoramento

### Application Insights

O monitoramento está configurado automaticamente via `host.json`:

- **Logs de execução** de todas as funções
- **Métricas de performance** (duração, taxa de sucesso)
- **Rastreamento de dependências** (SQL, Storage, SendGrid)
- **Alertas personalizados**

---

## 🔒 Configurações de Segurança

### 1. Autenticação das Functions
- **Function Keys**: Protegem endpoints HTTP
- **Authorization Level**: `FUNCTION` (requer chave de acesso)

### 2. Database Security
- **SSL/TLS**: Conexões criptografadas obrigatórias
- **Firewall**: Apenas IPs Azure permitidos
- **Credentials**: Armazenadas em variáveis de ambiente

---

## 📡 Endpoints da API

### POST /api/avaliacao
Cria uma nova avaliação

**Request:**
```json
{
  "descricao": "Aula excelente, muito didática!",
  "nota": 9
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "descricao": "Aula excelente, muito didática!",
  "nota": 9,
  "urgencia": "POSITIVA",
  "dataEnvio": "2024-02-15T10:30:00",
  "mensagem": "Avaliação registrada com sucesso!"
}
```

---

## 📚 Documentação Técnica

### Tecnologias Utilizadas

| Tecnologia | Versão | Propósito |
|------------|--------|-----------|
| Java | 21 | Linguagem de programação |
| Spring Boot | 3.2.2 | Framework MVC |
| Azure Functions | 4.x | Serverless computing |
| Azure SQL Database | Serverless | Banco de dados relacional |
| Azure Storage Queue | - | Fila de mensagens |
| SendGrid | 4.10.2 | Serviço de e-mail |

### Documentação Adicional

- 📖 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Guia completo de solução de problemas
- 📖 [docs/FUNCTIONS.md](docs/FUNCTIONS.md) - Documentação detalhada das Azure Functions

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
Plataforma de Feedback
