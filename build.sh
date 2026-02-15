#!/bin/bash

# Script alternativo de build para FeedbackHub
# Use este script se tiver problemas com mvn compile

echo "🔨 FeedbackHub - Build Script"
echo "=============================="
echo ""

# Definir JAVA_HOME explicitamente (ajuste se necessário)
if [ -z "$JAVA_HOME" ]; then
    echo "⚠️  JAVA_HOME não está definido. Tentando detectar..."

    # Para macOS com Homebrew
    if [ -d "/opt/homebrew/opt/openjdk@21" ]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
    elif [ -d "/usr/local/opt/openjdk@21" ]; then
        export JAVA_HOME="/usr/local/opt/openjdk@21"
    # Para macOS com instalação padrão
    elif [ -d "/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home" ]; then
        export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"
    # Fallback para detectar automaticamente
    elif command -v /usr/libexec/java_home &> /dev/null; then
        export JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home)
    fi

    echo "✅ JAVA_HOME detectado: $JAVA_HOME"
fi

export PATH="$JAVA_HOME/bin:$PATH"

echo ""
echo "Versões:"
echo "--------"
java -version
echo ""
mvn -version
echo ""

echo "🧹 Limpando build anterior..."
mvn clean

echo ""
echo "📦 Compilando projeto..."
mvn compile \
    -Dmaven.compiler.source=21 \
    -Dmaven.compiler.target=21 \
    -Dmaven.compiler.release=21 \
    -Dproject.build.sourceEncoding=UTF-8 \
    -e

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Compilação bem-sucedida!"
    echo ""
    echo "Para fazer o build completo, execute:"
    echo "  mvn package"
    echo ""
    echo "Para fazer o deploy no Azure:"
    echo "  mvn azure-functions:deploy"
else
    echo ""
    echo "❌ Erro na compilação"
    echo ""
    echo "Soluções possíveis:"
    echo "1. Verifique se Java 21 está instalado: java -version"
    echo "2. Instale Java 21 se necessário:"
    echo "   - macOS: brew install openjdk@21"
    echo "   - Ubuntu: sudo apt install openjdk-21-jdk"
    echo "3. Configure JAVA_HOME manualmente"
    echo "4. Limpe o cache do Maven: rm -rf ~/.m2/repository"
    exit 1
fi

