# 🐛 Guia de Debug no IntelliJ IDEA - FeedbackHub

## 🎯 Objetivo

Este guia ensina como executar e debugar as Azure Functions no IntelliJ IDEA, permitindo:
- ✅ Colocar breakpoints
- ✅ Inspecionar variáveis
- ✅ Executar passo a passo
- ✅ Ver logs em tempo real

---

## 🚀 Método 1: Debug via Maven (Recomendado)

### Passo 1: Configurar Run Configuration

1. **Abra o IntelliJ IDEA**
2. No menu superior: `Run` → `Edit Configurations...`
3. Clique em `+` (Add New Configuration)
4. Selecione `Maven`

### Passo 2: Preencher Configuração

**Name**: `Azure Functions Debug`

**Working directory**: 
```
/Users/leonartlima/IdeaProjects/feedbackhub
```

**Command line**:
```
clean package -DskipTests azure-functions:run
```

**Runner tab**:
- ✅ Delegate IDE build/run actions to Maven

### Passo 3: Configurar Debug

1. Na mesma tela de configuração
2. Vá em `Runner`
3. Em `VM Options`, adicione:
```
-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005
```

4. Clique em `Apply` e `OK`

### Passo 4: Executar em Debug

1. Coloque breakpoints no código:
   - Abra: `src/main/java/com/fiap/feedbackhub/functions/ReceberAvaliacaoFunction.java`
   - Clique na margem esquerda da linha desejada (linha 69, por exemplo)
   - Deve aparecer um círculo vermelho

2. No menu superior:
   - Clique no ícone de Debug (inseto) ao lado de "Azure Functions Debug"
   - Ou pressione `Ctrl+D` (Mac: `⌘+D`)

3. Aguarde até ver no console:
```
[INFO] HTTP Trigger: receberAvaliacao
[INFO] Functions ready to handle requests
```

### Passo 5: Testar com Breakpoint

Em outro terminal:
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste de debug", "nota": 5}'
```

**O IntelliJ vai parar no breakpoint!**

### Passo 6: Inspecionar Variáveis

Quando parar no breakpoint:
- **Variables**: Veja o valor de todas as variáveis locais
- **Watches**: Adicione expressões para monitorar
- **Debugger Console**: Execute código Java em tempo real
- **Call Stack**: Veja a pilha de chamadas

### Controles de Debug

| Ação | Atalho Mac | Atalho Windows/Linux |
|------|------------|----------------------|
| Step Over | `F8` | `F8` |
| Step Into | `F7` | `F7` |
| Step Out | `Shift+F8` | `Shift+F8` |
| Resume | `⌘+⌥+R` | `F9` |
| Stop | `⌘+F2` | `Ctrl+F2` |

---

## 🔥 Método 2: Debug Remoto (Advanced)

### Passo 1: Criar Remote JVM Debug Configuration

1. `Run` → `Edit Configurations...`
2. `+` → `Remote JVM Debug`
3. **Name**: `Azure Functions Remote Debug`
4. **Host**: `localhost`
5. **Port**: `5005`
6. **Command line arguments for remote JVM**:
```
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
```

### Passo 2: Iniciar Azure Functions com Debug

No terminal:
```bash
export MAVEN_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
mvn clean package -DskipTests
mvn azure-functions:run
```

### Passo 3: Conectar Debugger

1. Aguarde Functions inicializarem
2. No IntelliJ: Execute "Azure Functions Remote Debug"
3. Deve aparecer: `Connected to the target VM`

### Passo 4: Colocar Breakpoints e Testar

Igual ao Método 1!

---

## 🎨 Método 3: Debug Direto via Application (Alternativo)

### Passo 1: Criar Application Configuration

1. `Run` → `Edit Configurations...`
2. `+` → `Application`
3. **Name**: `FeedbackHub Application`
4. **Main class**: 
```
com.fiap.feedbackhub.FeedbackhubApplication
```
5. **Working directory**: 
```
/Users/leonartlima/IdeaProjects/feedbackhub
```
6. **Use classpath of module**: `feedbackhub`

### Passo 2: Configurar Environment Variables

Adicione as variáveis de ambiente:
```
DB_URL=jdbc:sqlserver://feedbackhub-server-55878.database.windows.net:1433;database=feedbackhub;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
DB_USERNAME=azureuser
DB_PASSWORD=FeedbackHub@2026!
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=feedbackhubst1455878;AccountKey=ST/ty25cuNJ3ON610VI6EgFl5+Q4BZEUzSWatrSHG2xvzes0ZGMfUnezYB8VNa+qzNJXNbfDvQ8C+AStaP/b1A==;BlobEndpoint=https://feedbackhubst1455878.blob.core.windows.net/;FileEndpoint=https://feedbackhubst1455878.file.core.windows.net/;QueueEndpoint=https://feedbackhubst1455878.queue.core.windows.net/;TableEndpoint=https://feedbackhubst1455878.table.core.windows.net/
AZURE_COMMUNICATION_CONNECTION_STRING=endpoint=https://feedbackhub-comm-55878.unitedstates.communication.azure.com/;accesskey=C7nAGjIV2yrUTzr3ptarTu7YBLkcmDbl4r3262ONS4dMgDdeEUuZJQQJ99CBACULyCp4YGpdAAAAAZCSqpwI
AZURE_COMMUNICATION_FROM_EMAIL=DoNotReply@d121e4d3-ff93-4bad-b352-c5082a883eed.azurecomm.net
ADMIN_EMAILS=seu-email@gmail.com
REPORT_EMAILS=seu-email@gmail.com
```

### Passo 3: Executar em Debug

Clique no ícone de Debug ao lado da configuração.

**⚠️ Limitação**: Este método inicia apenas o Spring Boot, não o Azure Functions Runtime.

---

## 🎯 Pontos Estratégicos para Breakpoints

### 1. ReceberAvaliacaoFunction.java

**Linha ~69**: Início do processamento
```java
public HttpResponseMessage receberAvaliacao(
```

**Linha ~95**: Validação de nota
```java
if (nota < 0 || nota > 10) {
```

**Linha ~115**: Classificação de urgência
```java
String urgencia = urgenciaClassificador.classificar(nota);
```

**Linha ~125**: Envio para fila (críticas)
```java
if ("CRITICA".equals(urgencia)) {
```

### 2. NotificacaoUrgenciaFunction.java

**Linha ~49**: Início do processamento da fila
```java
public void notificarUrgencia(
```

**Linha ~65**: Parse da mensagem
```java
Map<String, Object> dados = objectMapper.readValue(message, typeRef);
```

**Linha ~75**: Envio do e-mail
```java
emailService.enviarNotificacaoUrgencia(assunto, htmlEmail);
```

### 3. RelatorioSemanalFunction.java

**Linha ~40**: Timer trigger
```java
public void gerarRelatorioSemanal(
```

**Linha ~52**: Geração do relatório
```java
Map<String, Object> relatorio = relatorioService.gerarRelatorioSemanal();
```

### 4. UrgenciaClassificador.java

**Linha ~25**: Lógica de classificação
```java
public String classificar(Integer nota) {
```

### 5. EmailService.java

**Linha ~48**: Envio de notificação
```java
public void enviarNotificacaoUrgencia(String assunto, String conteudoHtml) {
```

**Linha ~72**: Envio real do e-mail
```java
Response response = sendGrid.api(request);
```

### 6. AvaliacaoService.java

**Linha ~35**: Salvar avaliação
```java
public Avaliacao salvar(Avaliacao avaliacao) {
```

---

## 🔍 Debug de Cenários Específicos

### Cenário 1: Debug de Avaliação Crítica

1. **Breakpoint em**: `ReceberAvaliacaoFunction.java:125`
```java
if ("CRITICA".equals(urgencia)) {
```

2. **Envie requisição**:
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste debug crítico", "nota": 2}'
```

3. **Inspecione**:
   - `nota` = 2
   - `urgencia` = "CRITICA"
   - `avaliacao` = objeto completo

4. **Continue (F9)** até:
   - `NotificacaoUrgenciaFunction.java:49` (processamento da fila)
   - `EmailService.java:48` (envio do e-mail)

### Cenário 2: Debug de Validação

1. **Breakpoint em**: `ReceberAvaliacaoFunction.java:95`
```java
if (nota < 0 || nota > 10) {
```

2. **Envie requisição inválida**:
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste validação", "nota": 15}'
```

3. **Verifique**: Deve entrar no `if` e retornar erro 400

### Cenário 3: Debug de Relatório

1. **Breakpoint em**: `RelatorioService.java:40`
```java
public Map<String, Object> gerarRelatorioSemanal() {
```

2. **Trigger manual**:
```bash
curl -X GET "http://localhost:7071/api/relatorio/manual"
```

3. **Inspecione**:
   - `avaliacoes` = Lista de avaliações
   - `totalAvaliacoes` = Contador
   - `mediaGeral` = Média calculada

---

## 🐞 Troubleshooting de Debug

### Problema 1: Breakpoints não param

**Solução**:
1. Verifique se compilou o código: `mvn clean package -DskipTests`
2. Verifique se está em modo Debug (não Run)
3. Certifique-se que o breakpoint está em linha executável (não em comentário)

### Problema 2: "Unable to connect to debugger"

**Solução**:
```bash
# Verifique se porta 5005 está livre
lsof -ti:5005 | xargs kill -9

# Execute novamente
mvn azure-functions:run
```

### Problema 3: Variáveis mostram "?"

**Solução**:
1. `File` → `Invalidate Caches / Restart`
2. Rebuild: `Build` → `Rebuild Project`
3. Execute novamente

### Problema 4: "Source code does not match"

**Solução**:
```bash
# Limpe e recompile
mvn clean install -DskipTests

# Execute novamente em debug
```

### Problema 5: Logs não aparecem

**Solução**:
1. Configure logging level em `application.yml`:
```yaml
logging:
  level:
    root: DEBUG
    com.fiap.feedbackhub: TRACE
```

2. Restart do debugger

---

## 📊 Atalhos Úteis do IntelliJ

| Ação | Mac | Windows/Linux |
|------|-----|---------------|
| Toggle Breakpoint | `⌘+F8` | `Ctrl+F8` |
| Evaluate Expression | `⌥+F8` | `Alt+F8` |
| View Breakpoints | `⌘+Shift+F8` | `Ctrl+Shift+F8` |
| Find in Files | `⌘+Shift+F` | `Ctrl+Shift+F` |
| Go to Class | `⌘+O` | `Ctrl+N` |
| Go to Symbol | `⌘+⌥+O` | `Ctrl+Alt+Shift+N` |
| Quick Documentation | `F1` | `Ctrl+Q` |
| Show Usages | `⌘+⌥+F7` | `Ctrl+Alt+F7` |

---

## 🎨 Configuração de Logging Detalhado

### application.yml

```yaml
logging:
  level:
    root: INFO
    com.fiap.feedbackhub: TRACE
    com.fiap.feedbackhub.functions: DEBUG
    com.fiap.feedbackhub.service: DEBUG
    com.microsoft.azure.functions: DEBUG
    com.azure: WARN
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

### Restart e veja logs detalhados:
```
[TRACE] Entrando no método receberAvaliacao
[DEBUG] Nota recebida: 5
[DEBUG] Descrição: Teste de debug
[DEBUG] Classificando urgência...
[DEBUG] Urgência classificada: MEDIA
[DEBUG] Salvando no banco de dados...
[DEBUG] Hibernate: insert into avaliacoes ...
[DEBUG] Avaliação salva com ID: 123
```

---

## 🎥 Para Demonstração em Vídeo

### Setup Recomendado

1. **Layout do IntelliJ**:
   - Editor com código aberto
   - Debug panel visível (bottom)
   - Variables panel aberto (lado direito)

2. **Breakpoint estratégico**:
   - `ReceberAvaliacaoFunction.java:115` (classificação)

3. **Terminal lateral**:
   - Pronto para executar curl

4. **Gravação**:
   - Mostre colocando breakpoint
   - Execute curl
   - Mostre parando no breakpoint
   - Inspecione variáveis
   - Step over algumas linhas
   - Continue e mostre resultado

---

## 📚 Recursos Adicionais

### Documentação IntelliJ IDEA
- [Debugging](https://www.jetbrains.com/help/idea/debugging-code.html)
- [Run/Debug Configurations](https://www.jetbrains.com/help/idea/run-debug-configuration.html)

### Azure Functions
- [Local Development](https://docs.microsoft.com/azure/azure-functions/functions-develop-local)
- [Java Developer Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-java)

---

## ✅ Checklist de Debug Funcionando

- [ ] IntelliJ IDEA instalado
- [ ] Java 21 configurado no projeto
- [ ] Maven configurado
- [ ] Breakpoint colocado em `ReceberAvaliacaoFunction.java`
- [ ] Run Configuration "Azure Functions Debug" criada
- [ ] Azure Functions rodando em debug (`mvn azure-functions:run`)
- [ ] Terminal aberto para executar curl
- [ ] Curl executado e breakpoint acionado
- [ ] Variáveis inspecionadas com sucesso
- [ ] Step over funcionando
- [ ] Resume funcionando
- [ ] Resposta HTTP recebida no terminal

---

**Pronto! Agora você pode debugar as Azure Functions como um profissional! 🚀**

**Última atualização**: 18 de fevereiro de 2026

