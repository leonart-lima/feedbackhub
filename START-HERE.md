# 🚀 Início Rápido - FeedbackHub

## ⚡ TL;DR - Para começar AGORA

```bash
# 1. Configure o firewall (já foi feito!)
# Aguarde 5 minutos para propagação da regra

# 2. Compile e inicie as Azure Functions
cd /Users/leonartlima/IdeaProjects/feedbackhub
mvn clean package -DskipTests
mvn azure-functions:run

# 3. Em outro terminal, teste
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Primeira avaliação de teste", "nota": 8}'
```

---

## 📋 O que foi corrigido?

✅ **ClassNotFoundException** - Agora as classes são encontradas  
✅ **Firewall Azure SQL** - IP `191.244.255.54` autorizado  
✅ **Lógica de Negócio** - Integração completa Spring + Azure  
✅ **Documentação** - Exemplos cURL, scripts de teste, troubleshooting  

---

## 🎯 Funções Disponíveis

### 1. Receber Avaliação
```bash
POST http://localhost:7071/api/avaliacao
{
  "descricao": "Descrição da avaliação",
  "nota": 0-10
}
```

**O que faz:**
- Salva no banco de dados
- Classifica urgência
- Se crítica (≤3), envia para fila de notificação

### 2. Notificação de Urgência
**Automática** - Acionada por fila  
- Lê avaliações críticas da fila
- Envia e-mail para administradores

### 3. Relatório Semanal
**Automática** - Timer (segunda 9h UTC)  
**Manual:**
```bash
GET http://localhost:7071/api/relatorio/manual
```

---

## 🧪 Testar Tudo de Uma Vez

```bash
./test-functions.sh
```

Executa 15 testes automatizados!

---

## 📚 Documentação Completa

### 🎯 Documentos Principais

- **[GUIA-COMPLETO-FINAL.md](GUIA-COMPLETO-FINAL.md)** - 📖 **COMECE AQUI!** Guia completo com tudo
- **[CONFIGURACAO-EMAILS.md](CONFIGURACAO-EMAILS.md)** - 📧 Para onde vão os e-mails e como configurar
- **[CURLS-COMPLETOS.md](CURLS-COMPLETOS.md)** - 🔥 Todos os CURLs de teste
- **[DEBUG-INTELLIJ-COMPLETO.md](DEBUG-INTELLIJ-COMPLETO.md)** - 🐛 Como debugar no IntelliJ

### 📋 Outros Documentos

- **CURL-EXAMPLES.md** - Exemplos de chamadas (antigo)
- **TROUBLESHOOTING-FIREWALL.md** - Solução de problemas de firewall
- **RESUMO-CORRECOES.md** - Detalhes de todas as correções
- **docs/FUNCTIONS.md** - Documentação técnica das functions

---

## ⏰ Timeline

```
[✅ Feito] Correção do pom.xml
[✅ Feito] Restauração da lógica de negócio
[✅ Feito] Configuração do firewall Azure SQL
[⏳ Aguardando] Propagação da regra (até 5 min)
[📍 Você está aqui] Pronto para testar!
```

---

## 🆘 Problemas?

### Firewall ainda bloqueando?
```bash
# Aguarde mais um pouco ou execute novamente
./fix-azure-sql-firewall.sh
```

### Erro ao compilar?
```bash
mvn clean install -U -DskipTests
```

### Functions não iniciam?
```bash
# Verificar Java 21
java -version

# Verificar porta 7071 livre
lsof -ti:7071 | xargs kill -9
```

---

## 📞 Contato

Documentação completa nos arquivos:
- `CURL-EXAMPLES.md`
- `TROUBLESHOOTING-FIREWALL.md`
- `RESUMO-CORRECOES.md`

---

**Bons testes! 🎉**

