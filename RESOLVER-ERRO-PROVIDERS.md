# 🔧 Resolver Erro de Registro de Providers Azure

## ❌ Erro Encontrado

```
MissingSubscriptionRegistration: The subscription is not registered to use namespace 'Microsoft.Sql'
```

## ✅ Solução Aplicada

Todos os providers necessários foram registrados:

```bash
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Insights
az provider register --namespace microsoft.operationalinsights
az provider register --namespace Microsoft.Communication
```

---

## ⏱️ Aguarde 1-2 Minutos

O registro dos providers leva alguns minutos para ser processado. Isso é **normal** na primeira vez que você usa esses serviços.

---

## 🔍 Verificar Status dos Providers

Execute este comando para verificar se todos estão registrados:

```bash
# Verificar um por um
az provider show --namespace Microsoft.Sql --query "registrationState" -o tsv
az provider show --namespace Microsoft.Storage --query "registrationState" -o tsv
az provider show --namespace Microsoft.Web --query "registrationState" -o tsv
az provider show --namespace Microsoft.Insights --query "registrationState" -o tsv
az provider show --namespace microsoft.operationalinsights --query "registrationState" -o tsv
az provider show --namespace Microsoft.Communication --query "registrationState" -o tsv
```

### Status Esperado:

- **`Registered`** = ✅ Pronto para usar
- **`Registering`** = ⏱️ Ainda processando (aguarde mais um pouco)

---

## 🚀 Após Todos Estarem "Registered"

Quando todos os providers mostrarem status **`Registered`**, execute novamente o script:

```bash
./azure-setup.sh
```

O script agora vai funcionar sem erros!

---

## 📋 Script de Verificação Rápida

Salve este script para verificar rapidamente:

```bash
#!/bin/bash

echo "Verificando providers Azure..."
echo ""

PROVIDERS=("Microsoft.Sql" "Microsoft.Storage" "Microsoft.Web" "Microsoft.Insights" "microsoft.operationalinsights" "Microsoft.Communication")

ALL_READY=true

for provider in "${PROVIDERS[@]}"; do
    STATUS=$(az provider show --namespace $provider --query "registrationState" -o tsv)
    
    if [ "$STATUS" == "Registered" ]; then
        echo "✅ $provider: $STATUS"
    else
        echo "⏱️  $provider: $STATUS (aguardando...)"
        ALL_READY=false
    fi
done

echo ""

if [ "$ALL_READY" = true ]; then
    echo "🎉 Todos os providers estão prontos!"
    echo "Execute: ./azure-setup.sh"
else
    echo "⏱️  Aguarde mais um pouco e execute este script novamente."
fi
```

Salve como `check-providers.sh` e execute:

```bash
chmod +x check-providers.sh
./check-providers.sh
```

---

## ⚠️ Se Demorar Muito (Mais de 5 minutos)

Você pode forçar o check do provider:

```bash
az provider register --namespace Microsoft.Sql --wait
```

Ou listar todos os providers para ver o status geral:

```bash
az provider list --query "[?starts_with(namespace, 'Microsoft.')].{Namespace:namespace, State:registrationState}" -o table
```

---

## 💡 Por Que Isso Aconteceu?

Na primeira vez que você usa determinados serviços Azure (SQL Database, Storage, etc), a assinatura precisa ser "registrada" para usar esses providers. Isso:

- ✅ É **normal** e esperado
- ✅ Só acontece **uma vez**
- ✅ É **automático** (você só precisa aguardar)
- ✅ **Não tem custo**

---

## 🎯 Próximos Passos

1. **Aguardar** 1-2 minutos
2. **Verificar** status com os comandos acima
3. **Executar** `./azure-setup.sh` novamente quando todos estiverem "Registered"

---

**O erro foi resolvido! Basta aguardar o registro ser concluído.** ✅

