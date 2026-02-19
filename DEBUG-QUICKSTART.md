# 🚀 Quick Start - Debug no IntelliJ

## ⚡ 3 Passos Rápidos

### 1️⃣ Abrir Configurações
No IntelliJ, no canto superior direito:
```
[Add Configuration ▼] → Você verá 3 novas configurações:
  ✅ Azure Functions - Run
  🐛 Azure Functions - Debug  
  🔌 Azure Functions - Remote Debug
```

### 2️⃣ Adicionar Breakpoint
Abra: `RecepcionarAvaliacaoFunction.java`
Clique na margem esquerda na linha 98 (onde tem `context.getLogger().info("Validação OK...")`)
Aparecerá um círculo vermelho ●

### 3️⃣ Iniciar Debug
Selecione **"Azure Functions - Debug"** e clique no botão 🐛

Ou no terminal:
```bash
# Terminal 1: Iniciar com debug
mvn azure-functions:run -DenableDebug

# Quando aparecer "Listening for transport..."
# No IntelliJ: Selecione "Azure Functions - Remote Debug" → 🐛
```

---

## 🧪 Testar

Quando as functions iniciarem:
```bash
curl -X POST "http://localhost:7071/api/avaliacao" \
  -H "Content-Type: application/json" \
  -d '{"descricao": "Debug test", "nota": 2}'
```

**O IntelliJ vai pausar no breakpoint!** 🎉

---

## 🎯 Locais Úteis para Breakpoints

### RecepcionarAvaliacaoFunction.java
- Linha ~55: Validação de campos
- Linha ~98: Antes de processar avaliação
- Linha ~105: Após processar, antes de retornar

### AvaliacaoService.java  
- Linha ~47: Início do processamento
- Linha ~51: Classificação de urgência
- Linha ~63: Antes de salvar no banco
- Linha ~70: Envio para fila (se crítica)

### NotificacaoUrgenciaFunction.java
- Linha ~51: Recebimento da mensagem da fila
- Linha ~75: Decodificação da mensagem
- Linha ~100: Antes de enviar e-mail

---

## 🔍 Comandos de Debug

Quando pausado no breakpoint:

| Tecla | Ação |
|-------|------|
| `F9` | Resume (continuar) |
| `F8` | Step Over (próxima linha) |
| `F7` | Step Into (entrar no método) |
| `Shift+F8` | Step Out (sair do método) |
| `Option+F8` | Evaluate Expression |
| `Cmd+F8` | Toggle Breakpoint |

---

## ✅ Checklist

- [ ] Configurações apareceram no IntelliJ?
- [ ] Adicionou breakpoint?
- [ ] Iniciou o debug? 🐛
- [ ] Enviou requisição curl?
- [ ] IntelliJ pausou no breakpoint?

**Se sim para tudo: Sucesso! 🎉**

---

## 🆘 Problemas?

### "Cannot connect to localhost:5005"
```bash
# Verifique se está rodando:
lsof -i :5005

# Se não estiver, inicie:
mvn azure-functions:run -DenableDebug
```

### "Breakpoint não para"
- Recompile: `mvn clean package`
- Verifique se o código está salvo
- Tente adicionar um System.out.println() para testar

### Configurações não aparecem
- Feche e reabra o IntelliJ
- Ou: `File` → `Invalidate Caches / Restart`

---

**📖 Guia completo:** Veja `DEBUG-INTELLIJ.md`

