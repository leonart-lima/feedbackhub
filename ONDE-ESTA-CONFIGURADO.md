# 📍 ONDE ESTÁ CONFIGURADO - Mapa Completo

## 🎯 Resumo Rápido

Os e-mails estão configurados em **2 lugares principais**:

| Arquivo | Localização | E-mail Configurado | Uso |
|---------|-------------|-------------------|-----|
| **`local.settings.json`** | Linha 17-18 | `leonart16@gmail.com` | ✅ **Ambiente Local** |
| **`application.yml`** | Linha 35-36 | Valores padrão (fallback) | Configuração base |

---

## 📂 ARQUIVO 1: `local.settings.json` (PRINCIPAL)

### Localização
```
/Users/leonartlima/IdeaProjects/feedbackhub/local.settings.json
```

### Linhas 17-18
```json
{
  "IsEncrypted": false,
  "Values": {
    // ... outras configs ...
    
    "ADMIN_EMAILS": "leonart16@gmail.com",      ← LINHA 17 ✅
    "REPORT_EMAILS": "leonart16@gmail.com",     ← LINHA 18 ✅
    
    "WEBSITE_TIME_ZONE": "E. South America Standard Time"
  }
}
```

### ✅ E-mail ATUAL Configurado

- **Notificações de Urgência**: `leonart16@gmail.com`
- **Relatórios Semanais**: `leonart16@gmail.com`

### 🎯 Este é o arquivo que você deve editar!

**Para mudar os e-mails**:
1. Abra: `local.settings.json`
2. Edite linhas 17 e 18
3. Salve
4. Reinicie: `mvn azure-functions:run`

---

## 📂 ARQUIVO 2: `application.yml` (Configuração Base)

### Localização
```
/Users/leonartlima/IdeaProjects/feedbackhub/src/main/resources/application.yml
```

### Linhas 35-36
```yaml
# Azure Communication Services
azure:
  communication:
    connection-string: ${AZURE_COMMUNICATION_CONNECTION_STRING}
    from-email: ${AZURE_COMMUNICATION_FROM_EMAIL:DoNotReply@...}

  storage:
    connection-string: ${AZURE_STORAGE_CONNECTION_STRING}
    queue:
      urgencia-name: ${AZURE_QUEUE_NAME:feedback-urgencia-queue}

  email:
    admin-recipients: ${ADMIN_EMAILS:admin@feedbackhub.com}     ← LINHA 35
    report-recipients: ${REPORT_EMAILS:relatorios@feedbackhub.com}  ← LINHA 36
```

### 📋 Como Funciona

```
admin-recipients: ${ADMIN_EMAILS:admin@feedbackhub.com}
                   │              │
                   │              └─── Valor padrão (fallback)
                   └────────────────── Lê da variável de ambiente
```

**Ordem de prioridade**:
1. Lê `ADMIN_EMAILS` do `local.settings.json` ✅
2. Se não existir, usa `admin@feedbackhub.com` (fallback)

### 🔍 Valores Padrão (Fallback)

Estes valores são usados **APENAS** se não houver variável de ambiente:
- `admin@feedbackhub.com` (fictício)
- `relatorios@feedbackhub.com` (fictício)

---

## 🔄 COMO OS VALORES SÃO CARREGADOS

### Fluxo de Configuração

```
┌────────────────────────────────────────┐
│  1. Azure Functions inicia            │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│  2. Lê local.settings.json             │
│     ADMIN_EMAILS = leonart16@gmail.com │
│     REPORT_EMAILS = leonart16@gmail.com│
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│  3. Define variáveis de ambiente       │
│     process.env.ADMIN_EMAILS           │
│     process.env.REPORT_EMAILS          │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│  4. Spring Boot inicia                 │
│     Lê application.yml                 │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│  5. Resolve ${ADMIN_EMAILS}            │
│     Encontra: leonart16@gmail.com      │
└────────────────┬───────────────────────┘
                 ↓
┌────────────────────────────────────────┐
│  6. Injeta no EmailService             │
│     @Value("${azure.email.admin-...}") │
└────────────────────────────────────────┘
```

---

## 📝 ONDE É USADO NO CÓDIGO

### EmailService.java

```java
@Service
public class EmailService {
    
    // ↓ Lê de application.yml → ${ADMIN_EMAILS} → local.settings.json
    @Value("${azure.email.admin-recipients}")
    private String adminEmails;  // = "leonart16@gmail.com"
    
    // ↓ Lê de application.yml → ${REPORT_EMAILS} → local.settings.json
    @Value("${azure.email.report-recipients}")
    private String reportEmails; // = "leonart16@gmail.com"
    
    public void enviarNotificacaoUrgencia(String assunto, String conteudoHtml) {
        // Usa adminEmails aqui
        String[] destinatarios = adminEmails.split(",");
        for (String destinatario : destinatarios) {
            enviarEmail(destinatario.trim(), assunto, conteudoHtml);
        }
    }
    
    public void enviarRelatorioSemanal(String assunto, String conteudoHtml) {
        // Usa reportEmails aqui
        String[] destinatarios = reportEmails.split(",");
        for (String destinatario : destinatarios) {
            enviarEmail(destinatario.trim(), assunto, conteudoHtml);
        }
    }
}
```

---

## 🗂️ OUTROS ARQUIVOS (Secundários)

### config-vars.json
```
/Users/leonartlima/IdeaProjects/feedbackhub/config-vars.json
```
```json
{
  "ADMIN_EMAILS": "admin@feedbackhub.com",
  "REPORT_EMAILS": "reports@feedbackhub.com"
}
```
**Uso**: Template para configuração (não é usado em runtime)

### app-settings.json
```
/Users/leonartlima/IdeaProjects/feedbackhub/app-settings.json
```
```json
{
  "ADMIN_EMAILS": "admin@example.com",
  "REPORT_EMAILS": "reports@example.com"
}
```
**Uso**: Template para Azure Portal (não é usado localmente)

---

## 🎯 ARQUIVO CORRETO PARA EDITAR

### Para Ambiente LOCAL (Desenvolvimento)

**Edite**: `local.settings.json` (linhas 17-18)

```bash
# Abrir no editor
vim local.settings.json

# Ou no IntelliJ
# Navegue até: feedbackhub/local.settings.json
```

**Altere**:
```json
"ADMIN_EMAILS": "SEU-EMAIL@gmail.com",
"REPORT_EMAILS": "SEU-EMAIL@gmail.com",
```

### Para Ambiente AZURE (Produção)

**Via Azure Portal**:
1. Acesse: https://portal.azure.com
2. Function App → `feedbackhub-func-55878`
3. Settings → Configuration
4. Application Settings
5. Edite `ADMIN_EMAILS` e `REPORT_EMAILS`
6. Save e Restart

**Via Azure CLI**:
```bash
az functionapp config appsettings set \
  --name feedbackhub-func-55878 \
  --resource-group feedbackhub-rg \
  --settings \
    "ADMIN_EMAILS=seu-email@gmail.com" \
    "REPORT_EMAILS=seu-email@gmail.com"
```

---

## 🔍 VERIFICAR VALORES ATUAIS

### Via Código

Adicione log temporário no `EmailService.java`:
```java
@PostConstruct
public void init() {
    log.info("📧 E-mails configurados:");
    log.info("   Admin: " + adminEmails);
    log.info("   Report: " + reportEmails);
}
```

### Via Logs da Aplicação

Ao executar `mvn azure-functions:run`, procure por:
```
[INFO] 📧 E-mails configurados:
[INFO]    Admin: leonart16@gmail.com
[INFO]    Report: leonart16@gmail.com
```

### Via Variável de Ambiente (Terminal)

```bash
# No mesmo terminal onde as Functions estão rodando
echo $ADMIN_EMAILS
echo $REPORT_EMAILS
```

---

## 📊 MAPA VISUAL COMPLETO

```
┌──────────────────────────────────────────────────────────────┐
│  CONFIGURAÇÃO DE E-MAILS - FEEDBACKHUB                        │
└──────────────────────────────────────────────────────────────┘

📂 local.settings.json (PRINCIPAL - EDITE AQUI!)
   ├── Linha 17: "ADMIN_EMAILS": "leonart16@gmail.com"
   └── Linha 18: "REPORT_EMAILS": "leonart16@gmail.com"
        │
        ↓ (carregado como variável de ambiente)
        │
        ↓
📂 application.yml (Configuração Base)
   ├── Linha 35: admin-recipients: ${ADMIN_EMAILS:admin@feedbackhub.com}
   └── Linha 36: report-recipients: ${REPORT_EMAILS:relatorios@feedbackhub.com}
        │
        │ (resolve variável)
        ↓
        │
        ↓ (@Value injection)
        │
📄 EmailService.java (Uso no Código)
   ├── @Value("${azure.email.admin-recipients}")
   │   private String adminEmails;  ← "leonart16@gmail.com"
   │
   └── @Value("${azure.email.report-recipients}")
       private String reportEmails; ← "leonart16@gmail.com"
        │
        ↓ (usado ao enviar)
        │
📧 E-MAILS ENVIADOS PARA:
   ├── Notificações: leonart16@gmail.com
   └── Relatórios: leonart16@gmail.com
```

---

## ✏️ COMO EDITAR - PASSO A PASSO

### Opção 1: IntelliJ IDEA

1. **Abra o projeto** no IntelliJ
2. **Navegue**: `feedbackhub` → `local.settings.json`
3. **Localize** linhas 17-18
4. **Edite**:
   ```json
   "ADMIN_EMAILS": "novo-email@gmail.com",
   "REPORT_EMAILS": "novo-email@gmail.com",
   ```
5. **Salve**: `⌘+S` (Mac) ou `Ctrl+S` (Windows)
6. **Reinicie** Azure Functions

### Opção 2: Terminal / vim

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

# Editar com vim
vim local.settings.json

# Ou com nano
nano local.settings.json

# Ou com VS Code
code local.settings.json
```

### Opção 3: Linha de Comando (sed)

```bash
cd /Users/leonartlima/IdeaProjects/feedbackhub

# Substituir ambos os e-mails de uma vez
sed -i '' 's/leonart16@gmail.com/novo-email@gmail.com/g' local.settings.json

# Verificar
grep "ADMIN_EMAILS\|REPORT_EMAILS" local.settings.json
```

---

## 🧪 TESTAR APÓS ALTERAR

```bash
# 1. Parar Azure Functions (se estiver rodando)
# Pressione Ctrl+C no terminal

# 2. Recompilar (opcional, mas recomendado)
mvn clean package -DskipTests

# 3. Reiniciar Azure Functions
mvn azure-functions:run

# 4. Aguardar logs mostrarem as variáveis carregadas
# Procure por linhas indicando os e-mails configurados

# 5. Testar envio
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Teste após alterar e-mail", "nota": 1}'

# 6. Verificar novo e-mail (inclusive SPAM!)
```

---

## 📋 CHECKLIST

- [x] **Arquivo identificado**: `local.settings.json`
- [x] **Linhas localizadas**: 17-18
- [x] **Valor atual**: `leonart16@gmail.com`
- [ ] **Editar para seu e-mail** (se necessário)
- [ ] **Salvar arquivo**
- [ ] **Reiniciar Azure Functions**
- [ ] **Testar envio**
- [ ] **Verificar e-mail recebido**

---

## 🎯 RESUMO FINAL

### ONDE ESTÁ CONFIGURADO?

**Arquivo**: `/Users/leonartlima/IdeaProjects/feedbackhub/local.settings.json`  
**Linhas**: 17-18  
**Valores atuais**:
- `ADMIN_EMAILS`: `leonart16@gmail.com` ✅
- `REPORT_EMAILS`: `leonart16@gmail.com` ✅

### PARA MUDAR OS E-MAILS:

1. Edite: `local.settings.json` (linhas 17-18)
2. Salve o arquivo
3. Reinicie: `mvn azure-functions:run`
4. Teste e verifique seu novo e-mail!

---

**Última atualização**: 18 de fevereiro de 2026  
**E-mail configurado**: `leonart16@gmail.com` 📧

