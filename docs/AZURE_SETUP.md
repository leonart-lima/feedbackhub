# 📘 Guia Completo de Criação na Azure

Este documento descreve **todos os recursos** que você precisa criar na Azure para o FeedbackHub.

---

## 🎯 Resumo Executivo

### Recursos Necessários

| # | Recurso | Tipo | Custo Mensal Estimado | Obrigatório |
|---|---------|------|----------------------|-------------|
| 1 | Resource Group | Lógico | Gratuito | ✅ Sim |
| 2 | Azure SQL Database | Serverless | R$ 10-30* | ✅ Sim |
| 3 | Storage Account | Armazenamento | R$ 2-5 | ✅ Sim |
| 4 | Storage Queue | Fila | Incluído | ✅ Sim |
| 5 | Function App | Serverless | 1M exec/mês grátis | ✅ Sim |
| 6 | Application Insights | Monitoramento | 5GB/mês grátis | ✅ Sim |
| 7 | SendGrid (externo) | E-mail | 100/dia grátis | ✅ Sim |

**Total: R$ 12-35/mês** (pode ser menor com auto-pause do SQL Database)

---

## 🚀 Opções de Criação

### Opção 1: Script Automatizado (RECOMENDADO)

```bash
# 1. Dar permissão de execução
chmod +x azure-setup.sh

# 2. Executar script
./azure-setup.sh

# 3. Aguardar conclusão (5-10 minutos)
```

### Opção 2: Portal Azure (Manual)

Siga as instruções detalhadas na seção "Criação Manual" abaixo.

### Opção 3: Comandos Azure CLI (Individual)

Siga as instruções na seção "Comandos CLI Individuais" abaixo.

---

## 📋 Detalhamento dos Recursos

### 1️⃣ Resource Group

**O que é**: Container lógico que agrupa todos os recursos relacionados.

**Configurações**:
- **Nome**: `feedbackhub-rg`
- **Região**: `eastus` ou `brazilsouth`

**Por que precisa**: Organização e gerenciamento facilitado.

---

### 2️⃣ Azure SQL Database (Serverless)

**O que é**: Banco de dados relacional gratuito/barato com auto-pause.

**Configurações**:
- **SQL Server**: `feedbackhub-server-[timestamp]` (nome único globalmente)
- **Database**: `feedbackhub`
- **Tier**: General Purpose (Serverless)
- **Min vCores**: 0.5
- **Max vCores**: 1 ou 2
- **Auto-pause**: 60 minutos
- **Admin User**: `azureuser`
- **Admin Password**: `FeedbackHub@2026!` (altere!)

**Por que precisa**: 
- Armazenar avaliações (tabela `avaliacoes`)
- Suporta JPA/Hibernate do Spring Boot
- Auto-pause economiza custos quando não usado

**Tabelas criadas automaticamente**:
```sql
CREATE TABLE avaliacoes (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    descricao VARCHAR(1000) NOT NULL,
    nota INT NOT NULL CHECK (nota BETWEEN 0 AND 10),
    urgencia VARCHAR(20) NOT NULL,
    data_envio DATETIME2 NOT NULL,
    notificada BIT DEFAULT 0
);
```

---

### 3️⃣ Storage Account

**O que é**: Serviço de armazenamento de objetos da Azure.

**Configurações**:
- **Nome**: `feedbackhubst[timestamp]` (apenas minúsculas e números)
- **SKU**: Standard_LRS (Local Redundant Storage)
- **Tipo**: StorageV2
- **Região**: Mesma do Resource Group

**Por que precisa**:
- Obrigatório para Azure Functions (armazena runtime e estado)
- Hospedar a Queue de mensagens

---

### 4️⃣ Storage Queue

**O que é**: Fila de mensagens assíncrona.

**Configurações**:
- **Nome**: `feedback-urgencia-queue`
- **Storage Account**: `feedbackhubst[timestamp]`

**Por que precisa**:
- Processar avaliações críticas de forma assíncrona
- Desacoplar recepção de avaliação do envio de e-mail
- Garantir que notificações não sejam perdidas

**Fluxo**:
```
Avaliação nota ≤ 3 → Queue → NotificacaoUrgenciaFunction → SendGrid
```

---

### 5️⃣ Function App

**O que é**: Plataforma serverless para hospedar Azure Functions.

**Configurações**:
- **Nome**: `feedbackhub-func-[timestamp]`
- **Runtime**: Java 21
- **Functions Version**: 4.x
- **OS**: Linux
- **Plan**: Consumption (paga por execução)
- **Storage**: `feedbackhubst[timestamp]`

**Por que precisa**:
Hospedar as 3 funções serverless:

#### Função 1: `receberAvaliacao`
- **Trigger**: HTTP POST
- **Endpoint**: `/api/avaliacao`
- **Responsabilidade**: Receber e salvar avaliações

#### Função 2: `notificarUrgencia`
- **Trigger**: Queue (feedback-urgencia-queue)
- **Responsabilidade**: Enviar e-mails de urgência

#### Função 3: `gerarRelatorioSemanal`
- **Trigger**: Timer (CRON: segunda 9h)
- **Responsabilidade**: Gerar relatórios semanais

**Limite gratuito**: 1 milhão de execuções/mês

---

### 6️⃣ Application Insights

**O que é**: Serviço de monitoramento e diagnóstico.

**Configurações**:
- **Nome**: `feedbackhub-insights`
- **Tipo**: Web Application
- **Região**: Mesma do Resource Group

**Por que precisa**:
- Logs em tempo real de todas as funções
- Métricas de performance (tempo de resposta, taxa de erro)
- Rastreamento de dependências (SQL, Storage, SendGrid)
- Alertas personalizados
- Dashboards de monitoramento

**O que monitora**:
- ✅ Execuções de cada função
- ✅ Erros e exceções
- ✅ Tempo de resposta
- ✅ Queries SQL
- ✅ Chamadas HTTP externas
- ✅ Uso de memória/CPU

**Limite gratuito**: 5 GB de logs/mês

---

### 7️⃣ SendGrid (Serviço Externo)

**O que é**: Serviço de envio de e-mails transacionais.

**Configurações**:
- **Plano**: Free (100 e-mails/dia)
- **API Key**: Gerada no painel SendGrid
- **Sender**: E-mail verificado

**Por que precisa**:
- Azure não tem serviço nativo de e-mail transacional
- SendGrid é o recomendado pela Microsoft
- Enviar notificações de urgência
- Enviar relatórios semanais

**Setup**:
1. Criar conta: https://sendgrid.com/pricing/
2. Verificar e-mail remetente
3. Gerar API Key
4. Configurar no Function App

---

## 🔧 Variáveis de Ambiente (Function App)

Estas variáveis são configuradas automaticamente pelo script, mas é importante entender:

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `DB_URL` | Connection string do SQL | `jdbc:sqlserver://...` |
| `DB_USERNAME` | Usuário do SQL | `azureuser` |
| `DB_PASSWORD` | Senha do SQL | `FeedbackHub@2026!` |
| `AZURE_STORAGE_CONNECTION_STRING` | Connection do Storage | `DefaultEndpointsProtocol=https;...` |
| `SENDGRID_API_KEY` | API Key do SendGrid | `SG.xxxxx` |
| `SENDGRID_FROM_EMAIL` | E-mail remetente | `noreply@feedbackhub.com` |
| `ADMIN_EMAILS` | E-mails de admins | `admin@example.com,admin2@example.com` |
| `REPORT_EMAILS` | E-mails de relatórios | `reports@example.com` |

---

## 📝 Instruções de Uso

### Passo 1: Executar Script de Provisionamento

```bash
# 1. Login no Azure
az login

# 2. Executar script
chmod +x azure-setup.sh
./azure-setup.sh
```

**Aguarde**: 5-10 minutos para criação de todos os recursos.

**Resultado**: Arquivo `azure-credentials.txt` com todas as credenciais.

---

### Passo 2: Configurar SendGrid

```bash
# 1. Criar conta no SendGrid
# Acesse: https://sendgrid.com/pricing/
# Escolha plano Free (100 emails/dia)

# 2. Verificar e-mail remetente
# No painel SendGrid: Settings > Sender Authentication

# 3. Gerar API Key
# No painel SendGrid: Settings > API Keys > Create API Key
# Permissões: Full Access (para testes) ou Mail Send (produção)

# 4. Executar script de configuração
chmod +x azure-configure-sendgrid.sh
./azure-configure-sendgrid.sh
```

---

### Passo 3: Deploy da Aplicação

```bash
# 1. Build do projeto
mvn clean package

# 2. Deploy para Azure
mvn azure-functions:deploy

# 3. Aguardar conclusão (3-5 minutos)
```

---

### Passo 4: Testar a API

```bash
# 1. Obter Function Key
az functionapp keys list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# 2. Testar endpoint
curl -X POST "https://feedbackhub-func-XXXXXX.azurewebsites.net/api/avaliacao?code=FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula excelente, muito didática!",
    "nota": 9
  }'

# 3. Testar avaliação crítica (deve enviar e-mail)
curl -X POST "https://feedbackhub-func-XXXXXX.azurewebsites.net/api/avaliacao?code=FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Não entendi nada da aula",
    "nota": 2
  }'
```

---

## 🔍 Monitoramento

### Ver Logs das Funções

```bash
# Via Azure CLI
az functionapp log tail \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg

# Via Portal
# https://portal.azure.com > Function App > Monitor > Logs
```

### Ver Application Insights

```bash
# Abrir no Portal
az monitor app-insights component show \
  --app feedbackhub-insights \
  --resource-group feedbackhub-rg \
  --query "appId" -o tsv

# Acesse: https://portal.azure.com > Application Insights > feedbackhub-insights
```

---

## 💰 Estimativa de Custos

### Breakdown Mensal (Uso Moderado)

| Recurso | Uso Estimado | Custo/Mês |
|---------|--------------|-----------|
| SQL Database Serverless | 10h ativas, 14h pausado/dia | R$ 10-20 |
| Storage Account | 1 GB dados + transações | R$ 2-3 |
| Function App | 50k execuções | Grátis |
| Application Insights | 2 GB logs | Grátis |
| SendGrid | 50 e-mails/dia | Grátis |
| **TOTAL** | | **R$ 12-23** |

### Dicas para Reduzir Custos

1. **SQL Database**: Configurar auto-pause para 60 min
2. **Storage**: Usar lifecycle policies para deletar dados antigos
3. **Functions**: Otimizar código para execução rápida
4. **Logs**: Configurar retenção de 30 dias

---

## 🔒 Segurança

### Configurações Aplicadas

✅ **SQL Database**:
- SSL/TLS obrigatório
- Firewall restrito (apenas Azure Services)
- Credenciais em variáveis de ambiente

✅ **Function App**:
- Authorization Level: FUNCTION (requer chave)
- HTTPS obrigatório
- Managed Identity (futuro)

✅ **Storage**:
- Acesso via connection string segura
- Queue não exposta publicamente

✅ **Application Insights**:
- Dados não contêm informações sensíveis
- Retenção limitada

---

## 🧹 Limpeza (Deletar Recursos)

```bash
# CUIDADO: Deleta TODOS os recursos!
az group delete --name feedbackhub-rg --yes --no-wait
```

---

## 📞 Suporte

- **Azure Docs**: https://docs.microsoft.com/azure
- **SendGrid Docs**: https://docs.sendgrid.com
- **Spring Boot**: https://spring.io/projects/spring-boot
- **Azure Functions Java**: https://docs.microsoft.com/azure/azure-functions/functions-reference-java

---

## ✅ Checklist de Verificação

Antes do deploy final, verifique:

- [ ] Resource Group criado
- [ ] SQL Database online e acessível
- [ ] Storage Account com Queue criada
- [ ] Function App criado
- [ ] Application Insights configurado
- [ ] SendGrid configurado e testado
- [ ] Variáveis de ambiente configuradas
- [ ] Build do Maven funcionando (`mvn clean package`)
- [ ] Deploy testado (`mvn azure-functions:deploy`)
- [ ] API testada (POST /api/avaliacao)
- [ ] E-mails de urgência recebidos
- [ ] Logs visíveis no Application Insights

---

**Última atualização**: 15/02/2026

