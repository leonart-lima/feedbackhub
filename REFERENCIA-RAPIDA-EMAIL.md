# ⚡ Referência Rápida - Configuração do E-mail

## 🎯 O Que Você Precisa Fazer

### 1. Execute o script (vai pausar automaticamente)
```bash
./azure-setup.sh
```

### 2. Quando pausar, siga estes 5 passos:

#### a) Abrir Portal Azure
```
https://portal.azure.com
```

#### b) Navegar
```
Resource Groups → feedbackhub-rg → feedbackhub-email
```

#### c) Provisionar Domínio
```
Menu lateral → "Provision Domains" ou "Try Email"
→ "Add domain"
→ "Add an Azure managed domain"
→ "Add"
```

#### d) Copiar E-mail Gerado
```
Formato: DoNotReply@xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.azurecomm.net
```

#### e) Conectar ao Communication Service
```
Na página do domínio → "Connect domain"
→ Selecionar: feedbackhub-comm-XXXXXX
→ "Connect"
```

### 3. Voltar ao terminal e pressionar ENTER

### 4. Aguardar o script completar (cria Function App e configura tudo)

---

## ⏰ Tempo: 3-5 minutos

---

## 📖 Guia Completo

Veja: **CONFIGURAR-EMAIL-DOMAIN.md** (com capturas de tela e troubleshooting)

---

## 🆘 Problemas?

### "Não encontro 'Provision Domains'"
→ Procure por: "Domains", "Try Email", ou "Email Domains"

### "Botão desabilitado"
→ Aguarde 1-2 minutos (ainda provisionando)

### "Erro ao conectar"
→ Recarregue a página e tente novamente

---

**Apenas 3-5 minutos de configuração manual e está pronto!** ✅

