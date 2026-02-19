# 📧 Alternativas de E-mail - FeedbackHub

## 🎯 Opções Disponíveis

### Comparação Rápida

| Serviço | E-mails Grátis/Mês | Integração Azure | Recomendado |
|---------|-------------------|------------------|-------------|
| **Azure Communication Services** | 250 | ⭐⭐⭐⭐⭐ Nativo | ✅ **SIM** |
| SendGrid | 3.000 (100/dia) | ⭐⭐⭐⭐ Ótima | ✅ Alternativa |
| Mailgun | 5.000 (3 meses), depois 1.000 | ⭐⭐⭐ Boa | Alternativa |
| Mailjet | 6.000 (200/dia) | ⭐⭐⭐ Boa | Alternativa |
| Brevo | 9.000 (300/dia) | ⭐⭐⭐ Boa | Alternativa |
| Amazon SES | 62.000* | ⭐⭐ Precisa AWS | Não |

\* Apenas se hospedar no AWS

---

## 🏆 Opção 1: Azure Communication Services (RECOMENDADO)

### Vantagens

- ✅ **Serviço nativo da Microsoft Azure**
- ✅ **250 e-mails GRÁTIS/mês** permanentemente
- ✅ Integração perfeita com Azure Functions
- ✅ Mesma conta Azure (sem criar conta externa)
- ✅ Suporta e-mail, SMS, voz, vídeo
- ✅ Gerenciamento unificado no Portal Azure
- ✅ Sem necessidade de verificar domínio (usa domínio Azure)

### Custos

- **Free Tier**: 250 e-mails/mês GRÁTIS
- **Após free tier**: $0.25 por 1.000 e-mails (muito barato!)
- **Para o projeto**: Suficiente dentro do free tier

### Como Configurar

#### 1. Criar Communication Service

```bash
# Via Script (já incluído no azure-setup-acs.sh abaixo)
# OU manualmente:

az communication create \
  --name feedbackhub-comm \
  --resource-group feedbackhub-rg \
  --data-location "United States" \
  --location global
```

#### 2. Criar Email Communication Service

```bash
# Criar domínio de e-mail gerenciado pela Azure
az communication email domain create \
  --domain-name AzureManagedDomain \
  --email-service-name feedbackhub-email \
  --resource-group feedbackhub-rg
```

#### 3. Obter Connection String

```bash
az communication list-key \
  --name feedbackhub-comm \
  --resource-group feedbackhub-rg
```

#### 4. Atualizar Código Java

**Adicionar dependência no `pom.xml`:**

```xml
<!-- Azure Communication Email -->
<dependency>
    <groupId>com.azure</groupId>
    <artifactId>azure-communication-email</artifactId>
    <version>1.0.7</version>
</dependency>
```

**Atualizar `EmailService.java`:**

```java
import com.azure.communication.email.*;
import com.azure.communication.email.models.*;

@Service
public class EmailService {
    
    private final EmailClient emailClient;
    
    @Value("${azure.communication.connection-string}")
    private String connectionString;
    
    @Value("${azure.communication.from-email}")
    private String fromEmail;
    
    public EmailService() {
        this.emailClient = new EmailClientBuilder()
            .connectionString(connectionString)
            .buildClient();
    }
    
    public void enviarEmailUrgencia(Avaliacao avaliacao, String destinatario) {
        EmailMessage message = new EmailMessage()
            .setSenderAddress(fromEmail)
            .setToRecipients(destinatario)
            .setSubject("🚨 URGENTE: Avaliação Crítica - FeedbackHub")
            .setBodyPlainText("Descrição: " + avaliacao.getDescricao())
            .setBodyHtml(gerarHtmlUrgencia(avaliacao));
        
        emailClient.beginSend(message).waitForCompletion();
    }
    
    // ... resto do código
}
```

#### 5. Configurar Variáveis de Ambiente

```bash
az functionapp config appsettings set \
  --name feedbackhub-func-XXXXXX \
  --resource-group feedbackhub-rg \
  --settings \
    "AZURE_COMMUNICATION_CONNECTION_STRING=endpoint=https://feedbackhub-comm.communication.azure.com/;accesskey=xxxxx" \
    "AZURE_COMMUNICATION_FROM_EMAIL=DoNotReply@xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.azurecomm.net"
```

---

## 📧 Opção 2: SendGrid (Twilio)

### Vantagens

- ✅ **3.000 e-mails grátis/mês** (100/dia)
- ✅ API muito madura e estável
- ✅ Documentação excelente
- ✅ Recomendado pela Microsoft
- ✅ Templates avançados

### Desvantagens

- ❌ Requer conta externa (fora do Azure)
- ❌ Precisa verificar domínio/e-mail remetente
- ❌ Processo de aprovação pode demorar

### Como Configurar

**Já documentado em**: [QUICKSTART-AZURE.md](../QUICKSTART-AZURE.md)

---

## 📧 Opção 3: Mailgun (Twilio)

### Vantagens

- ✅ **5.000 e-mails grátis/mês** (primeiros 3 meses)
- ✅ Depois: 1.000 grátis/mês permanentemente
- ✅ API simples
- ✅ Validação de e-mail embutida

### Configuração

#### 1. Criar Conta

https://www.mailgun.com/pricing/

#### 2. Obter API Key

Dashboard > Settings > API Keys

#### 3. Adicionar Dependência

```xml
<dependency>
    <groupId>com.mailgun</groupId>
    <artifactId>mailgun-java</artifactId>
    <version>1.1.4</version>
</dependency>
```

#### 4. Atualizar EmailService

```java
import com.mailgun.api.v3.MailgunMessagesApi;
import com.mailgun.client.MailgunClient;

@Service
public class EmailService {
    
    private final MailgunMessagesApi mailgunApi;
    
    @Value("${mailgun.api-key}")
    private String apiKey;
    
    @Value("${mailgun.domain}")
    private String domain;
    
    public EmailService() {
        this.mailgunApi = MailgunClient.config(apiKey)
            .createApi(MailgunMessagesApi.class);
    }
    
    public void enviarEmail(String to, String subject, String html) {
        Message message = Message.builder()
            .from("FeedbackHub <noreply@" + domain + ">")
            .to(to)
            .subject(subject)
            .html(html)
            .build();
            
        mailgunApi.sendMessage(domain, message);
    }
}
```

---

## 📧 Opção 4: Mailjet

### Vantagens

- ✅ **6.000 e-mails grátis/mês** (200/dia)
- ✅ Interface amigável
- ✅ API REST simples
- ✅ Estatísticas detalhadas

### Configuração

#### 1. Criar Conta

https://www.mailjet.com/pricing/

#### 2. Obter API Key

Account > API Keys

#### 3. Usar via REST API

```java
import org.springframework.web.client.RestTemplate;

@Service
public class EmailService {
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    @Value("${mailjet.api-key}")
    private String apiKey;
    
    @Value("${mailjet.secret-key}")
    private String secretKey;
    
    public void enviarEmail(String to, String subject, String html) {
        String url = "https://api.mailjet.com/v3.1/send";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setBasicAuth(apiKey, secretKey);
        headers.setContentType(MediaType.APPLICATION_JSON);
        
        String json = """
            {
                "Messages": [{
                    "From": {"Email": "noreply@feedbackhub.com"},
                    "To": [{"Email": "%s"}],
                    "Subject": "%s",
                    "HTMLPart": "%s"
                }]
            }
            """.formatted(to, subject, html);
        
        HttpEntity<String> request = new HttpEntity<>(json, headers);
        restTemplate.postForEntity(url, request, String.class);
    }
}
```

---

## 📧 Opção 5: Brevo (ex-Sendinblue)

### Vantagens

- ✅ **9.000 e-mails grátis/mês** (300/dia)
- ✅ Plano gratuito mais generoso
- ✅ Interface moderna
- ✅ Suporta SMS também

### Configuração

#### 1. Criar Conta

https://www.brevo.com/pricing/

#### 2. Obter API Key

Account > SMTP & API > API Keys

#### 3. Usar via REST API

```java
@Service
public class EmailService {
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    @Value("${brevo.api-key}")
    private String apiKey;
    
    public void enviarEmail(String to, String subject, String html) {
        String url = "https://api.brevo.com/v3/smtp/email";
        
        HttpHeaders headers = new HttpHeaders();
        headers.set("api-key", apiKey);
        headers.setContentType(MediaType.APPLICATION_JSON);
        
        String json = """
            {
                "sender": {"email": "noreply@feedbackhub.com"},
                "to": [{"email": "%s"}],
                "subject": "%s",
                "htmlContent": "%s"
            }
            """.formatted(to, subject, html);
        
        HttpEntity<String> request = new HttpEntity<>(json, headers);
        restTemplate.postForEntity(url, request, String.class);
    }
}
```

---

## 🎯 Recomendação Final

### Para o Tech Challenge (Produção):

**1ª Opção**: **Azure Communication Services** ⭐
- Nativo Azure
- 250 e-mails grátis/mês (suficiente)
- Sem conta externa
- Integração perfeita

**2ª Opção**: **SendGrid**
- Mais e-mails grátis (3.000/mês)
- Mais maduro
- Requer conta externa

**3ª Opção**: **Brevo**
- Maior free tier (9.000/mês)
- Interface moderna
- Bom para testes

### Para Demonstração (Vídeo):

Qualquer opção funciona! Escolha a mais fácil de configurar:
- **Mais rápido**: Azure Communication Services (mesma conta)
- **Mais e-mails**: Brevo ou Mailjet
- **Mais conhecido**: SendGrid

---

## 📜 Scripts Atualizados

Criei scripts alternativos para cada opção:

| Script | Serviço |
|--------|---------|
| `azure-setup.sh` | SendGrid (original) |
| `azure-setup-acs.sh` | Azure Communication Services ⭐ |
| `azure-setup-mailgun.sh` | Mailgun |
| `azure-setup-brevo.sh` | Brevo |

---

## 🔄 Migrar entre Serviços

Se já usou SendGrid e quer migrar:

1. Atualizar dependências no `pom.xml`
2. Atualizar `EmailService.java`
3. Atualizar variáveis de ambiente
4. Redesployar: `mvn azure-functions:deploy`

---

## 💡 Dicas

1. **Para o Tech Challenge**: Use Azure Communication Services (mais integrado)
2. **Para produção real**: SendGrid (mais robusto)
3. **Para economizar**: Brevo (mais e-mails grátis)
4. **Para aprender**: Teste todos! 😄

---

## 📞 Documentação Oficial

- **Azure Communication Services**: https://learn.microsoft.com/azure/communication-services/
- **SendGrid**: https://sendgrid.com/docs/
- **Mailgun**: https://documentation.mailgun.com/
- **Mailjet**: https://dev.mailjet.com/
- **Brevo**: https://developers.brevo.com/

---

**Escolha a opção que preferir e siga os guias correspondentes!** 🚀

