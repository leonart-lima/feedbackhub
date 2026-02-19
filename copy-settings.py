#!/usr/bin/env python3
"""
Script para copiar configurações entre Function Apps do Azure
"""
import subprocess
import json
import sys

def run_command(cmd):
    """Executa comando e retorna output"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=60
        )
        return result.stdout, result.returncode
    except subprocess.TimeoutExpired:
        print("❌ Comando timeout!")
        return None, 1

def main():
    print("🔄 Copiando configurações entre Function Apps...\n")

    # Exportar configurações do Function App antigo
    print("1️⃣ Exportando configurações de feedbackhub-func-55878...")
    cmd = """
    az functionapp config appsettings list \
      --name feedbackhub-func-55878 \
      --resource-group feedbackhub-rg \
      -o json
    """

    output, code = run_command(cmd)
    if code != 0 or not output:
        print("❌ Erro ao exportar configurações!")
        print("💡 Use o Azure Portal manualmente!")
        sys.exit(1)

    try:
        settings = json.loads(output)
    except:
        print("❌ Erro ao parsear JSON!")
        sys.exit(1)

    # Filtrar apenas configurações da aplicação
    app_settings = {}
    prefixes = ['DB_', 'AZURE_STORAGE_CONNECTION', 'AZURE_COMMUNICATION', 'ADMIN_', 'REPORT_']

    for setting in settings:
        name = setting.get('name', '')
        value = setting.get('value', '')

        if name == 'WEBSITE_TIME_ZONE' or any(name.startswith(p) for p in prefixes):
            app_settings[name] = value
            print(f"  ✓ {name}")

    if not app_settings:
        print("❌ Nenhuma configuração encontrada!")
        sys.exit(1)

    print(f"\n✅ {len(app_settings)} configurações encontradas!\n")

    # Salvar em arquivo
    with open('app-settings.json', 'w') as f:
        json.dump(app_settings, f, indent=2)

    print("📄 Configurações salvas em: app-settings.json\n")

    # Mostrar configurações
    print("📋 Configurações a serem copiadas:")
    print("-" * 60)
    for name, value in app_settings.items():
        # Mascarar valores sensíveis
        if 'PASSWORD' in name or 'KEY' in name or 'CONNECTION' in name:
            display_value = value[:20] + "..." if len(value) > 20 else value
        else:
            display_value = value
        print(f"{name}: {display_value}")
    print("-" * 60)

    # Perguntar se deve aplicar
    print("\n❓ Deseja aplicar essas configurações no feedbackhub-func?")
    print("   (Isso pode demorar 30-60 segundos)")
    response = input("   Digite 'sim' para continuar: ").lower()

    if response not in ['sim', 's', 'yes', 'y']:
        print("\n✋ Operação cancelada!")
        print("💡 Use o Azure Portal para aplicar manualmente.")
        print("   Arquivo: app-settings.json")
        sys.exit(0)

    # Aplicar configurações
    print("\n2️⃣ Aplicando configurações em feedbackhub-func...")

    settings_args = []
    for name, value in app_settings.items():
        # Escapar aspas
        escaped_value = value.replace('"', '\\"')
        settings_args.append(f'{name}="{escaped_value}"')

    settings_str = ' '.join(settings_args)

    cmd = f"""
    az functionapp config appsettings set \
      --name feedbackhub-func \
      --resource-group feedbackhub-rg \
      --settings {settings_str} \
      -o none
    """

    output, code = run_command(cmd)

    if code == 0:
        print("\n✅ Configurações aplicadas com sucesso!")
        print("\n🎉 Function App configurado!")
        print("\n📝 Próximos passos:")
        print("   1. Aguarde 1-2 minutos para o Function App reiniciar")
        print("   2. Teste a API com o comando:")
        print('   curl -X POST "https://feedbackhub-func.azurewebsites.net/api/receberAvaliacao?code=vOsFmAJjaQXb-Er_1529q_EP8T4fsaHE3OTDSuR2BfLjAzFusT33_Q==" \\')
        print('     -H "Content-Type: application/json" \\')
        print('     -d \'{"clienteId":1,"produtoId":101,"nota":5,"comentario":"Teste!","categoria":"PRODUTO"}\'')
    else:
        print("\n❌ Erro ao aplicar configurações!")
        print("💡 Use o Azure Portal:")
        print("   1. Acesse: https://portal.azure.com")
        print("   2. Navegue: feedbackhub-rg > feedbackhub-func > Configuration")
        print("   3. Adicione as configurações do arquivo app-settings.json")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n✋ Operação cancelada pelo usuário!")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Erro: {e}")
        sys.exit(1)

