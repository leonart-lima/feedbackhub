# Guia Rápido de Compilação - FeedbackHub (Java 21)

## ✅ Projeto Configurado para Java 21

O projeto foi atualizado para usar **Java 21** (a versão que você tem instalada no seu MacBook).

---

## 🚀 Como Compilar

### Opção 1: Maven Direto

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

# Limpar build anterior
mvn clean

# Compilar
mvn compile

# Build completo (compilar + testes + package)
mvn clean package
```

### Opção 2: Script de Build

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

# Tornar executável (primeira vez)
chmod +x build.sh

# Executar
./build.sh
```

O script detecta automaticamente o Java 21 no seu Mac.

---

## 🔍 Verificar Configuração

```bash
# Verificar Java (deve mostrar versão 21.x.x)
java -version

# Verificar JAVA_HOME
echo $JAVA_HOME

# Se JAVA_HOME não estiver configurado
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="$JAVA_HOME/bin:$PATH"

# Para tornar permanente, adicione ao ~/.zshrc
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 📦 O Que Foi Alterado

Todas as referências de Java 17 foram atualizadas para Java 21:

✅ `pom.xml` - Propriedades Java: 17 → 21  
✅ `pom.xml` - maven-compiler-plugin: 17 → 21  
✅ `pom.xml` - Azure Functions runtime: 17 → 21  
✅ `.mvn/jvm.config` - Parâmetros JVM: 17 → 21  
✅ `build.sh` - Script de build: 17 → 21  
✅ `README.md` - Documentação: 17 → 21  
✅ `TROUBLESHOOTING.md` - Guia de solução: 17 → 21  

---

## 🎯 Estrutura do Projeto

```
feedbackhub/
├── pom.xml                          # Maven (Java 21)
├── build.sh                         # Script de build
├── src/
│   └── main/
│       ├── java/
│       │   └── com/fiap/feedbackhub/
│       │       ├── FeedbackHubApplication.java
│       │       ├── model/
│       │       │   └── Avaliacao.java
│       │       ├── repository/
│       │       │   └── AvaliacaoRepository.java
│       │       ├── service/
│       │       │   ├── AvaliacaoService.java
│       │       │   ├── RelatorioService.java
│       │       │   ├── EmailService.java
│       │       │   └── AzureQueueService.java
│       │       ├── controller/
│       │       │   └── AvaliacaoController.java
│       │       ├── dto/
│       │       │   ├── AvaliacaoRequestDTO.java
│       │       │   ├── AvaliacaoResponseDTO.java
│       │       │   └── RelatorioSemanalDTO.java
│       │       ├── functions/
│       │       │   ├── RecepcionarAvaliacaoFunction.java
│       │       │   ├── NotificacaoUrgenciaFunction.java
│       │       │   └── RelatorioSemanalFunction.java
│       │       ├── enums/
│       │       │   └── Urgencia.java
│       │       ├── util/
│       │       │   └── UrgenciaClassificador.java
│       │       └── config/
│       │           └── AppConfig.java
│       └── resources/
│           └── application.yml
├── .mvn/
│   ├── jvm.config
│   └── wrapper/
│       └── maven-wrapper.properties
├── host.json
├── local.settings.json
├── README.md
├── TROUBLESHOOTING.md
└── docs/
    └── FUNCTIONS.md
```

---

## 🛠️ Comandos Úteis

### Build e Deploy

```bash
# Build local
mvn clean package

# Executar Azure Functions localmente
mvn azure-functions:run

# Deploy no Azure (após configurar credenciais)
mvn azure-functions:deploy
```

### Testes

```bash
# Executar testes
mvn test

# Pular testes no build
mvn clean package -DskipTests
```

### Diagnóstico

```bash
# Informações detalhadas do build
mvn clean compile -X -e

# Verificar dependências
mvn dependency:tree

# Verificar plugins
mvn help:effective-pom
```

---

## 🐛 Solução de Problemas

### Se ainda tiver erro de compilação:

1. **Limpar cache do Maven**:
```bash
rm -rf ~/.m2/repository/org/apache/maven/plugins
mvn clean install -U
```

2. **Verificar JAVA_HOME**:
```bash
echo $JAVA_HOME
# Deve apontar para Java 21

# Se não estiver configurado:
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
```

3. **Usar o script de build**:
```bash
chmod +x build.sh
./build.sh
```

4. **Reinstalar dependências**:
```bash
mvn clean install -U
```

### Se precisar voltar para Java 17:

Instale Java 17:
```bash
brew install openjdk@17
```

E execute o script novamente - ele detectará automaticamente.

---

## 📚 Documentação

- **README.md** - Documentação completa do projeto
- **TROUBLESHOOTING.md** - Guia completo de solução de problemas
- **docs/FUNCTIONS.md** - Documentação das Azure Functions

---

## ✅ Próximos Passos

1. **Compile o projeto**:
```bash
mvn clean compile
```

2. **Se compilar com sucesso, faça o package**:
```bash
mvn clean package
```

3. **Configure o Azure** (veja README.md seção "Instruções de Deploy")

4. **Configure o SendGrid** (obtenha API Key gratuita)

5. **Faça o deploy**:
```bash
mvn azure-functions:deploy
```

---

**Data de atualização:** 15 de Fevereiro de 2026  
**Versão Java:** 21  
**Status:** ✅ Configurado e pronto para compilar

