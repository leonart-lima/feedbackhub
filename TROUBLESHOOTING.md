# Troubleshooting - FeedbackHub

## Problemas de Build

### Erro: `java.lang.ExceptionInInitializerError: com.sun.tools.javac.code.TypeTag :: UNKNOWN`

**Causa**: Incompatibilidade entre a versão do Java e o Maven Compiler Plugin.

**Soluções**:

#### 1. Verificar e Instalar Java 21

```bash
# Verificar versão atual
java -version

# Se não for Java 21, instalar:

# macOS (Homebrew)
brew install openjdk@21
brew link openjdk@21 --force

# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-21-jdk

# Fedora/RHEL
sudo dnf install java-21-openjdk-devel

# Windows
# Baixe e instale do: https://adoptium.net/temurin/releases/?version=21
```

#### 2. Configurar JAVA_HOME

**macOS/Linux:**
```bash
# Encontrar o caminho do Java 21
/usr/libexec/java_home -V  # macOS
update-alternatives --config java  # Linux

# Configurar JAVA_HOME (macOS)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Configurar JAVA_HOME (Linux)
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Adicionar ao PATH
export PATH="$JAVA_HOME/bin:$PATH"

# Tornar permanente (adicione ao ~/.zshrc ou ~/.bashrc)
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Windows:**
```cmd
# Configurar JAVA_HOME nas variáveis de ambiente do sistema
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-21.x.x.x-hotspot"
setx PATH "%JAVA_HOME%\bin;%PATH%"
```

#### 3. Limpar Cache do Maven

```bash
# Limpar cache de plugins
rm -rf ~/.m2/repository/org/apache/maven/plugins

# Ou limpar todo o repositório (cuidado: vai re-baixar tudo)
rm -rf ~/.m2/repository

# Forçar atualização de dependências
mvn clean install -U
```

#### 4. Usar Script de Build Alternativo

```bash
# Tornar executável
chmod +x build.sh

# Executar
./build.sh
```

O script detecta automaticamente o Java 21 e configura as variáveis necessárias.

#### 5. Atualizar Maven

```bash
# Verificar versão atual
mvn -version

# Instalar versão mais recente (3.9.x)

# macOS (Homebrew)
brew upgrade maven

# Ubuntu/Debian
sudo apt update
sudo apt install maven

# Ou baixar manualmente de: https://maven.apache.org/download.cgi
```

#### 6. Usar Maven Wrapper

O projeto já inclui configuração do Maven Wrapper. Use:

```bash
# Primeiro, baixe o wrapper (se não tiver)
mvn wrapper:wrapper

# Depois use ./mvnw em vez de mvn
./mvnw clean compile
./mvnw package
```

---

## Problemas de Dependências

### Erro: `Cannot resolve dependency`

**Solução**:
```bash
# Limpar e re-baixar dependências
mvn clean install -U

# Verificar settings.xml do Maven
cat ~/.m2/settings.xml

# Se tiver proxy corporativo, configure:
# ~/.m2/settings.xml
```

---

## Problemas com Lombok

### Erro: `cannot find symbol` em getters/setters

**Solução**:

1. **IntelliJ IDEA**:
   - Instale o plugin Lombok: `Preferences > Plugins > Lombok`
   - Enable Annotation Processing: `Preferences > Build > Compiler > Annotation Processors > Enable annotation processing`

2. **Eclipse**:
   - Baixe lombok.jar de https://projectlombok.org/download
   - Execute: `java -jar lombok.jar`
   - Selecione a instalação do Eclipse

3. **Via Maven**:
```bash
# Verificar se Lombok está configurado
mvn dependency:tree | grep lombok

# Rebuild forçando processamento de annotations
mvn clean compile -Dmaven.compiler.annotationProcessors.enabled=true
```

---

## Problemas com Azure Functions

### Erro: `Cannot find azure-functions-maven-plugin`

**Solução**:
```bash
# Atualizar versão do plugin no pom.xml
<azure.functions.maven.plugin.version>1.34.0</azure.functions.maven.plugin.version>

# Limpar e reinstalar
mvn clean install
```

### Erro ao fazer deploy

**Solução**:
```bash
# Verificar login no Azure
az login
az account show

# Verificar se resource group existe
az group show --name feedbackhub-rg

# Fazer deploy com logs detalhados
mvn azure-functions:deploy -X
```

---

## Problemas com Banco de Dados

### Erro: `Cannot open server`

**Causas e Soluções**:

1. **Firewall do Azure SQL**:
```bash
# Adicionar seu IP ao firewall
MY_IP=$(curl -s ifconfig.me)
az sql server firewall-rule create \
  --resource-group feedbackhub-rg \
  --server feedbackhub-server \
  --name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP
```

2. **Connection String incorreta**:
```bash
# Verificar variável de ambiente
echo $DB_URL

# Formato correto:
# jdbc:sqlserver://SERVER.database.windows.net:1433;database=DB;encrypt=true;...
```

3. **Credenciais inválidas**:
```bash
# Resetar senha do SQL Server
az sql server update \
  --resource-group feedbackhub-rg \
  --name feedbackhub-server \
  --admin-password "NewPassword123!"
```

---

## Problemas com SendGrid

### E-mails não estão sendo enviados

**Verificações**:

1. **API Key válida**:
```bash
# Testar API Key com curl
curl -X POST https://api.sendgrid.com/v3/mail/send \
  -H "Authorization: Bearer YOUR_SENDGRID_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"personalizations":[{"to":[{"email":"test@example.com"}]}],"from":{"email":"sender@example.com"},"subject":"Test","content":[{"type":"text/plain","value":"Test"}]}'
```

2. **Sender Verification**:
   - Acesse https://app.sendgrid.com/settings/sender_auth
   - Verifique o domínio ou e-mail de envio

3. **Quota não excedida**:
   - Free tier: 100 emails/dia
   - Verifique em: https://app.sendgrid.com/

---

## Problemas de IDE

### IntelliJ IDEA

**Reimportar projeto Maven**:
1. Right-click no `pom.xml`
2. Maven > Reload Project

**Invalidar caches**:
1. File > Invalidate Caches / Restart
2. Invalidate and Restart

**Configurar SDK**:
1. File > Project Structure > Project
2. SDK: 21 (java version "21.x.x")
3. Language Level: 21

### VS Code

**Instalar extensões**:
- Extension Pack for Java
- Spring Boot Extension Pack
- Azure Functions

**Configurar Java**:
```json
// settings.json
{
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-21",
      "path": "/path/to/jdk-21",
      "default": true
    }
  ]
}
```

---

## Comandos Úteis

### Diagnóstico Completo

```bash
# Informações do sistema
echo "=== Java Version ==="
java -version
echo ""
echo "=== Maven Version ==="
mvn -version
echo ""
echo "=== JAVA_HOME ==="
echo $JAVA_HOME
echo ""
echo "=== Azure CLI ==="
az --version
echo ""

# Verificar estrutura do projeto
echo "=== Project Structure ==="
tree -L 3 src/

# Listar dependências
echo "=== Dependencies ==="
mvn dependency:tree
```

### Build Completo Passo a Passo

```bash
# 1. Limpar completamente
mvn clean
rm -rf target/

# 2. Validar pom.xml
mvn validate

# 3. Compilar
mvn compile

# 4. Executar testes
mvn test

# 5. Package
mvn package

# 6. Verificar artefato gerado
ls -lh target/*.jar
```

### Testes Locais

```bash
# Rodar Azure Functions localmente
mvn azure-functions:run

# Em outro terminal, testar
curl -X POST http://localhost:7071/api/avaliacao \
  -H "Content-Type: application/json" \
  -d '{"descricao":"Teste local","nota":8}'
```

---

## Logs e Debug

### Habilitar Logs Detalhados

```bash
# Maven com debug
mvn clean package -X

# Maven com stack traces
mvn clean package -e

# Ambos
mvn clean package -X -e
```

### Application Logs (Azure)

```bash
# Stream de logs em tempo real
az webapp log tail \
  --name feedbackhub-functions \
  --resource-group feedbackhub-rg

# Download de logs
az webapp log download \
  --name feedbackhub-functions \
  --resource-group feedbackhub-rg \
  --log-file logs.zip
```

---

## Recursos de Ajuda

- **Maven**: https://maven.apache.org/troubleshooting.html
- **Azure Functions Java**: https://docs.microsoft.com/azure/azure-functions/functions-reference-java
- **Spring Boot**: https://spring.io/guides
- **Lombok**: https://projectlombok.org/
- **SendGrid**: https://docs.sendgrid.com/

---

## Contato

Se o problema persistir após tentar todas as soluções acima, abra uma Issue no GitHub com:
- Output completo do erro
- Resultado de `java -version` e `mvn -version`
- Sistema operacional
- Logs completos (`mvn clean compile -X -e > build.log 2>&1`)

