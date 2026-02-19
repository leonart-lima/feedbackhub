# 🐛 Guia de Debug no IntelliJ - Azure Functions

## 📋 Pré-requisitos

1. ✅ IntelliJ IDEA instalado (Community ou Ultimate)
2. ✅ Azure Functions Core Tools instalado
3. ✅ Java 21 configurado no IntelliJ
4. ✅ Maven configurado no IntelliJ

---

## 🎯 Método 1: Debug via Maven (Recomendado)

### Passo 1: Criar Run Configuration

1. **Abra IntelliJ IDEA**
2. **Menu:** `Run` → `Edit Configurations...`
3. **Clique em** `+` → `Maven`
4. **Configure:**
   - **Name:** `Azure Functions - Debug`
   - **Command line:** `clean package azure-functions:run`
   - **Working directory:** `$PROJECT_DIR$`
   - **Runner:**
     - ✅ Delegate IDE build/run actions to Maven
   - **Environment variables:** (adicionar se necessário)
     ```
     AZURE_STORAGE_CONNECTION_STRING=...
     AZURE_COMMUNICATION_CONNECTION_STRING=...
     ```

5. **Clique em** `Apply` e `OK`

### Passo 2: Configurar Debug

1. **Edite a mesma configuração**
2. **Em "Runner"**, adicione nos **VM Options:**
   ```
   -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005
   ```

3. **Ou use o método automático:**
   - Simplesmente clique no ícone de **Debug** (🐛) ao invés de Run
   - O IntelliJ configurará automaticamente

### Passo 3: Adicionar Breakpoints

1. **Abra o arquivo da função** (ex: `RecepcionarAvaliacaoFunction.java`)
2. **Clique na margem esquerda** da linha onde quer parar
3. **Aparecerá um círculo vermelho** ●

### Passo 4: Executar em Debug

1. **Clique no botão Debug** 🐛 (ou `Shift + F9`)
2. **Aguarde o Maven compilar e iniciar as Functions**
3. **Quando ver no console:**
   ```
   Azure Functions Core Tools
   Core Tools Version: 4.x
   Function Runtime Version: 4.x
   
   Functions:
     receberAvaliacao: [POST] http://localhost:7071/api/avaliacao
   ```

4. **Faça uma requisição:**
   ```bash
   curl -X POST "http://localhost:7071/api/avaliacao" \
     -H "Content-Type: application/json" \
     -d '{"descricao": "Teste debug", "nota": 2}'
   ```

5. **O IntelliJ pausará no breakpoint!** 🎉

---

## 🎯 Método 2: Debug Remoto (Alternativo)

### Passo 1: Iniciar Functions com Debug Port

No terminal:

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

# Compilar
mvn clean package -DskipTests

# Iniciar com debug habilitado
mvn azure-functions:run \
  -DenableDebug=true \
  -DdebugPort=5005
```

### Passo 2: Criar Remote Debug Configuration

1. **Menu:** `Run` → `Edit Configurations...`
2. **Clique em** `+` → `Remote JVM Debug`
3. **Configure:**
   - **Name:** `Azure Functions Remote Debug`
   - **Debugger mode:** `Attach to remote JVM`
   - **Host:** `localhost`
   - **Port:** `5005`
   - **Use module classpath:** selecione `feedbackhub`

4. **Clique em** `Apply` e `OK`

### Passo 3: Conectar o Debugger

1. **Inicie as Functions no terminal** (passo 1 acima)
2. **No IntelliJ, clique em Debug** 🐛 na configuração `Azure Functions Remote Debug`
3. **Você verá:** `Connected to the target VM, address: 'localhost:5005'`
4. **Adicione breakpoints e teste!**

---

## 🎯 Método 3: Debug Direto (Mais Simples)

### Criar arquivo .run/AzureFunctions.run.xml

Vou criar automaticamente para você!

---

## 🔍 Dicas de Debug

### 1. **Ver Variáveis**
- Na janela de Debug, veja a aba **Variables**
- Mostra todas as variáveis no escopo atual

### 2. **Avaliar Expressões**
- Enquanto pausado, selecione uma expressão
- Pressione `Alt + F8` (ou `Option + F8` no Mac)
- Digite qualquer código Java para avaliar

### 3. **Step Over / Into / Out**
- **Step Over** (`F8`): Executar linha atual
- **Step Into** (`F7`): Entrar no método
- **Step Out** (`Shift + F8`): Sair do método atual

### 4. **Breakpoints Condicionais**
- Clique com botão direito no breakpoint ●
- Adicione condição: `nota <= 3`
- Só para quando a condição for verdadeira

### 5. **Logpoints (sem parar)**
- Clique com botão direito no breakpoint
- Selecione "Breakpoint Properties"
- Desmarque "Suspend"
- Marque "Log message to console"
- Digite: `"Avaliação recebida: " + avaliacaoDTO.getNota()`

### 6. **Watch Variables**
- Na janela Debug, aba "Watches"
- Clique em `+`
- Adicione: `avaliacaoDTO.getNota()`
- Será avaliado em cada pausa

---

## 📝 Exemplo de Debug Session

### Cenário: Debugar avaliação crítica

1. **Adicionar breakpoints:**
   - `RecepcionarAvaliacaoFunction.java`: linha `context.getLogger().info("Validação OK...")`
   - `AvaliacaoService.java`: linha `Urgencia urgencia = urgenciaClassificador.classificar(...)`
   - `UrgenciaClassificador.java`: linha `if (nota <= NOTA_MAXIMA_CRITICA)`

2. **Iniciar Debug** 🐛

3. **Enviar requisição:**
   ```bash
   curl -X POST "http://localhost:7071/api/avaliacao" \
     -H "Content-Type: application/json" \
     -d '{"descricao": "Aula péssima", "nota": 1}'
   ```

4. **Fluxo de execução:**
   - ⏸️ Para em `RecepcionarAvaliacaoFunction`
   - Ver `avaliacaoDTO.nota = 1`
   - Pressionar `F8` (Step Over) até chegar na chamada do service
   - Pressionar `F7` (Step Into) para entrar no service
   - ⏸️ Para em `AvaliacaoService.processarAvaliacao()`
   - Ver como classifica a urgência
   - Continue até ver mensagem sendo enviada para fila
   - Ver logs: "⚠️ AVALIAÇÃO CRÍTICA detectada"

---

## 🚨 Troubleshooting

### Problema 1: "Cannot connect to localhost:5005"

**Solução:**
- Verifique se as Functions estão rodando
- Veja no terminal se há mensagem: `Listening for transport dt_socket at address: 5005`
- Porta 5005 pode estar em uso: mude para 5006

### Problema 2: "Debugger não para nos breakpoints"

**Solução:**
- Verifique se compilou com debug info: veja `pom.xml`:
  ```xml
  <compilerArgs>
    <arg>-parameters</arg>
    <arg>-g</arg>  <!-- adicione esta linha -->
  </compilerArgs>
  ```
- Recompile: `mvn clean package`

### Problema 3: "Source code does not match bytecode"

**Solução:**
```bash
# Rebuild completo
mvn clean install -DskipTests
```

### Problema 4: Debug muito lento

**Solução:**
- Desabilite breakpoints não usados
- Use logpoints ao invés de breakpoints
- Aumente heap do Maven: `export MAVEN_OPTS="-Xmx1024m"`

---

## 🎨 Interface do IntelliJ Debug

```
┌─────────────────────────────────────────────────────────────┐
│ Debugger                                                   ▼│
├─────────────────────────────────────────────────────────────┤
│ Frames (call stack):                                        │
│  ├─ receberAvaliacao:47, RecepcionarAvaliacaoFunction      │
│  ├─ invoke, NativeMethod                                    │
│  └─ ...                                                     │
├─────────────────────────────────────────────────────────────┤
│ Variables:                                                  │
│  ├─ this = RecepcionarAvaliacaoFunction@123                │
│  ├─ request = HttpRequestMessage@456                       │
│  ├─ context = ExecutionContext@789                         │
│  ├─ avaliacaoDTO = AvaliacaoRequestDTO@abc                 │
│  │   ├─ descricao = "Teste debug"                          │
│  │   └─ nota = 2                                           │
│  └─ ...                                                     │
├─────────────────────────────────────────────────────────────┤
│ Watches:                                                    │
│  ├─ avaliacaoDTO.getNota() = 2                            │
│  └─ avaliacaoDTO.getDescricao().length() = 11             │
└─────────────────────────────────────────────────────────────┘

Toolbar: Resume (F9) | Step Over (F8) | Step Into (F7) | ...
```

---

## 📚 Atalhos Úteis (Mac)

| Ação | Atalho Mac | Atalho Windows/Linux |
|------|------------|---------------------|
| Debug | `⌃ D` | `Shift + F9` |
| Resume | `⌘ ⌥ R` | `F9` |
| Step Over | `F8` | `F8` |
| Step Into | `F7` | `F7` |
| Step Out | `⇧ F8` | `Shift + F8` |
| Evaluate | `⌥ F8` | `Alt + F8` |
| Toggle Breakpoint | `⌘ F8` | `Ctrl + F8` |
| View Breakpoints | `⌘ ⇧ F8` | `Ctrl + Shift + F8` |

---

## 🎯 Próximos Passos

1. **Execute o comando abaixo para criar a configuração automaticamente**
2. **Adicione breakpoints nas suas funções**
3. **Inicie o debug e teste!**

```bash
# No terminal, execute:
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package -DskipTests
mvn azure-functions:run -DenableDebug
```

**No IntelliJ:**
1. Vá em `Run` → `Edit Configurations...`
2. `+` → `Remote JVM Debug`
3. Host: `localhost`, Port: `5005`
4. Apply → Debug 🐛

---

**Pronto para debugar! 🎉**

Se tiver dúvidas sobre algum passo, me avise!

