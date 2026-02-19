# ⚡ INSTRUÇÕES RÁPIDAS - Providers Azure

## ✅ O que aconteceu:

Durante a execução do `azure-setup.sh`, o script encontrou 2 erros de providers não registrados:

1. ❌ **Microsoft.Sql** - Descoberto no passo 3/8
2. ❌ **microsoft.operationalinsights** - Descoberto no passo 5/8

**Causa**: Na primeira vez que usa certos serviços Azure, é necessário "registrar" os providers.

## ✅ O que foi feito:

Todos os **6 providers** necessários foram registrados:

1. ✅ Microsoft.Sql
2. ✅ Microsoft.Storage
3. ✅ Microsoft.Web
4. ✅ Microsoft.Insights
5. ✅ microsoft.operationalinsights
6. ✅ Microsoft.Communication

---

## 🎯 O QUE VOCÊ DEVE FAZER AGORA:

### Opção 1: Aguardar e Verificar (Simples)

```bash
# Aguarde 2 minutos (os providers estão sendo registrados)

# Depois verifique:
bash check-status.sh

# Quando TODOS mostrarem "Registered", execute:
./azure-setup.sh
```

### Opção 2: Garantir Tudo Registrado (Seguro)

```bash
# Registrar todos novamente (garantir)
bash register-all-providers.sh

# Aguardar 2-3 minutos

# Verificar:
bash check-status.sh

# Quando TODOS mostrarem "Registered", execute:
./azure-setup.sh
```

---

## 📊 Interpretando o check-status.sh:

```
✅ Microsoft.Sql: Registered              ← Pronto! ✅
⏱️  microsoft.operationalinsights: Registering  ← Aguarde mais um pouco ⏱️
```

**Quando TODOS mostrarem "Registered"** = Pronto para executar `./azure-setup.sh`

---

## 💡 Dica:

Após executar `bash check-status.sh`, se algum ainda estiver "Registering":
- Aguarde mais 1 minuto
- Execute `bash check-status.sh` novamente
- Repita até todos estarem "Registered"

---

## ⏰ Tempo Estimado:

- **Primeiros 5 providers**: Provavelmente já prontos (registrados há ~5 min)
- **operationalinsights**: Mais 1-2 minutos

**TOTAL**: ~2 minutos até poder continuar

---

## 🚀 Depois que Tudo Estiver Pronto:

```bash
# 1. Executar o script de provisionamento
./azure-setup.sh

# 2. O script vai criar TODOS os recursos (5-10 min)

# 3. Deploy da aplicação
mvn clean package azure-functions:deploy
```

---

**Execute agora: `bash check-status.sh`** 🚀

