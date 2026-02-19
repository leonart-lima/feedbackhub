# 🚀 Guia Rápido de Deploy - FeedbackHub

## 📑 Índice

- [TL;DR - Comandos Rápidos](#-tldr-too-long-didnt-read)
- [Passo a Passo Detalhado](#-passo-a-passo-detalhado)
  - [1. Pré-requisitos](#1️⃣-pré-requisitos)
  - [2. Login no Azure](#2️⃣-login-no-azure)
  - [3. Criar Recursos na Azure](#3️⃣-criar-recursos-na-azure)
  - [4. Build e Deploy](#4️⃣-build-e-deploy)
  - [5. Obter Credenciais](#5️⃣-obter-url-e-function-key)
  - [6. Testar a API](#6️⃣-testar-a-api)
  - [7. Monitorar](#7️⃣-monitorar)
- [Vídeo de Demonstração](#-para-o-vídeo-de-demonstração)
- [Troubleshooting](#-troubleshooting)

---

## ⚡ TL;DR (Too Long; Didn't Read)

```bash
# 1. Login no Azure
az login

# 2. Criar todos os recursos na Azure (5-10 min)
./azure-setup.sh

# 3. Deploy da aplicação
mvn clean package azure-functions:deploy

# 4. Testar
curl -X POST "https://SEU-FUNCTION-APP.azurewebsites.net/api/avaliacao?code=FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste", "nota": 8}'
```

**Serviço de E-mail**: Azure Communication Services (nativo Azure, 250 e-mails grátis/mês)

---

## 📋 Passo a Passo Detalhado

### 1️⃣ Pré-requisitos

```bash
# Verificar Java 21
java -version
# Deve mostrar: openjdk version "21"

# Verificar Maven
mvn -version

# Verificar Azure CLI
az --version
```

**Não tem Azure CLI?**
```bash
# macOS
brew install azure-cli

# Verificar instalação
az --version
```

---

### 2️⃣ Login no Azure

```bash
az login
```

Isso abrirá o navegador para você fazer login com sua conta Microsoft/Azure.

---

### 3️⃣ Criar Recursos na Azure

```bash
./azure-setup.sh
```

**O que este script faz:**
- ✅ Cria Resource Group
- ✅ Cria Azure SQL Database (Serverless)
- ✅ Cria Storage Account + Queue
- ✅ Cria Function App
- ✅ Cria Application Insights
- ✅ **Cria Azure Communication Services** (e-mail nativo)
- ✅ Configura Firewall e Variáveis de Ambiente

**Tempo**: 5-10 minutos

**Resultado**: Arquivo `azure-credentials.txt` com todas as credenciais

**Serviço de E-mail**:
- ✅ Azure Communication Services (nativo Microsoft)
- ✅ 250 e-mails GRÁTIS/mês (permanente)
- ✅ Sem necessidade de conta externa
- ✅ Domínio de e-mail gerenciado pela Azure
- ✅ Integração perfeita com Functions


---

### 4️⃣ Build e Deploy

```bash
# Build do projeto
mvn clean package

# Deploy para Azure
mvn azure-functions:deploy
```

**Tempo**: 3-5 minutos

**Resultado**: Functions publicadas e rodando na Azure

---

### 5️⃣ Obter URL e Function Key

```bash
# Obter nome do Function App
cat azure-credentials.txt | grep "Function App:"

# Listar Function Keys
az functionapp keys list \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg
```

Copie o valor de `default` (Function Key).

---

### 6️⃣ Testar a API

#### Teste 1: Avaliação Positiva

```bash
curl -X POST "https://feedbackhub-func-XXXXXX.azurewebsites.net/api/avaliacao?code=FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Aula excelente, muito didática!",
    "nota": 9
  }'
```

**Resultado esperado**:
```json
{
  "id": 1,
  "descricao": "Aula excelente, muito didática!",
  "nota": 9,
  "urgencia": "POSITIVA",
  "dataEnvio": "2026-02-15T...",
  "mensagem": "Avaliação registrada com sucesso!"
}
```

#### Teste 2: Avaliação Crítica (envia e-mail!)

```bash
curl -X POST "https://feedbackhub-func-XXXXXX.azurewebsites.net/api/avaliacao?code=FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Não entendi nada da aula, muito confusa",
    "nota": 2
  }'
```

**Resultado esperado**:
- API retorna confirmação
- **E-mail enviado** para os administradores!
- Verificar caixa de entrada

#### Teste 3: Relatório Manual

Para testar o relatório sem esperar segunda-feira:

```bash
# Invocar function manualmente
az functionapp function invoke \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --function-name gerarRelatorioSemanal
```

**Resultado**: E-mail de relatório semanal enviado.

---

### 7️⃣ Monitorar

#### Ver Logs em Tempo Real

```bash
az functionapp log tail \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg
```

#### Ver no Portal Azure

1. Acesse: https://portal.azure.com
2. Resource Groups > `feedbackhub-rg`
3. Function App > `feedbackhub-func-XXXXXX`
4. **Functions** > Ver lista de funções
5. **Monitor** > Ver execuções
6. **Log stream** > Logs em tempo real

#### Application Insights

1. Portal Azure > Application Insights > `feedbackhub-insights`
2. **Live Metrics** > Métricas em tempo real
3. **Failures** > Erros
4. **Performance** > Tempo de resposta

---

## 🎥 Para o Vídeo de Demonstração

### 1. Mostrar Portal Azure

- Resource Group com todos os recursos
- SQL Database (mostrar que está serverless)
- Storage Queue
- Function App (3 funções deployadas)
- **Azure Communication Services** (serviço de e-mail)
- Application Insights (métricas)

### 2. Demonstrar API

```bash
# Avalição positiva
curl -X POST "..." -d '{"descricao": "Ótima aula!", "nota": 10}'

# Avaliação média
curl -X POST "..." -d '{"descricao": "Razoável", "nota": 5}'

# Avaliação crítica (mostra e-mail chegando)
curl -X POST "..." -d '{"descricao": "Péssima aula", "nota": 1}'
```

### 3. Mostrar E-mails

- E-mail de urgência recebido
- Formato HTML bonito
- Informações completas

### 4. Mostrar Relatório Semanal

- Invocar manualmente
- Mostrar e-mail de relatório
- Estatísticas e gráficos

### 5. Mostrar Monitoramento

- Application Insights com execuções
- Logs das funções
- Métricas de performance

### 6. Mostrar Código

- Arquitetura MVC
- Separação de responsabilidades
- Functions com responsabilidade única

### 7. Mostrar Configurações de Segurança

- Firewall do SQL
- Function Keys
- Variáveis de ambiente (sem mostrar valores!)
- SSL/TLS

---

## 📊 Dados de Teste

Use estes dados para popular o banco durante a demonstração:

```bash
# 10 avaliações variadas
for i in {1..3}; do
  curl -X POST "URL?code=KEY" -H "Content-Type: application/json" \
    -d "{\"descricao\": \"Aula excelente $i\", \"nota\": $((8 + RANDOM % 3))}"
done

for i in {1..4}; do
  curl -X POST "URL?code=KEY" -H "Content-Type: application/json" \
    -d "{\"descricao\": \"Aula razoável $i\", \"nota\": $((4 + RANDOM % 3))}"
done

for i in {1..3}; do
  curl -X POST "URL?code=KEY" -H "Content-Type: application/json" \
    -d "{\"descricao\": \"Aula ruim $i\", \"nota\": $((0 + RANDOM % 4))}"
done
```

---


## ❓ Troubleshooting

### Erro: "MissingSubscriptionRegistration" ou "Microsoft.Sql not registered"

**Problema**: Sua assinatura Azure não está registrada para usar determinados serviços.

**Solução**:

```bash
# Registrar todos os providers necessários
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Insights
az provider register --namespace microsoft.operationalinsights
az provider register --namespace Microsoft.Communication

# Aguardar 1-2 minutos e verificar status
bash check-status.sh
```

Quando todos mostrarem status **"Registered"**, execute o script novamente:
```bash
./azure-setup.sh
```

**Nota**: Este erro é normal na **primeira vez** que você usa esses serviços.

---

### Erro: "az: command not found"

```bash
brew install azure-cli
```

### Erro: "No subscription found"

```bash
az login
az account set --subscription "NOME_DA_ASSINATURA"
```

### Erro de compilação Maven

```bash
# Verificar Java 21
java -version

# Se não for Java 21
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Limpar e recompilar
mvn clean install -U
```

### Function não executa

```bash
# Ver logs
az functionapp log tail --name feedbackhub-func-XXXXXX --resource-group feedbackhub-rg

# Verificar configurações
az functionapp config appsettings list --name feedbackhub-func-XXXXXX --resource-group feedbackhub-rg
```

### E-mail não chega

1. Verificar Connection String do Azure Communication Services está correta
2. Verificar e-mail de destino está correto
3. Verificar spam/lixo eletrônico
4. Ver logs do Application Insights
5. Verificar que está dentro do limite de 250 e-mails/mês
6. Verificar no Portal Azure se o Communication Service está ativo

---


## 🧹 Limpeza (Deletar Tudo)

```bash
# CUIDADO: Deleta TODOS os recursos!
az group delete --name feedbackhub-rg --yes
```

---

## 📞 Links Úteis

- **Portal Azure**: https://portal.azure.com
- **Azure Communication Services**: https://learn.microsoft.com/azure/communication-services/
- **Azure Functions Docs**: https://docs.microsoft.com/azure/azure-functions/
- **Spring Boot**: https://spring.io/projects/spring-boot

---

**Boa sorte no Tech Challenge! 🚀**

