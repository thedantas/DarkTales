#!/bin/bash

echo "🚀 Configurando script de upload de histórias..."

# Verifica se o Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado. Por favor, instale o Python 3 primeiro."
    exit 1
fi

# Instala dependências
echo "📦 Instalando dependências..."
pip3 install firebase-admin

# Cria arquivo de configuração se não existir
if [ ! -f "firebase_config.json" ]; then
    echo "📝 Criando arquivo de configuração..."
    cp firebase_config_example.json firebase_config.json
    echo "⚠️  IMPORTANTE: Configure o arquivo firebase_config.json com suas credenciais do Firebase"
fi

# Cria arquivo de exemplo se não existir
if [ ! -f "exemplo_historia.json" ]; then
    echo "📝 Criando arquivo de exemplo..."
    python3 upload_stories_v2.py --example
fi

echo ""
echo "✅ Configuração concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. Configure o arquivo firebase_config.json com suas credenciais do Firebase"
echo "2. Teste o upload: python3 test_upload.py"
echo "3. Faça upload de suas histórias: python3 upload_stories_v2.py --all"
echo ""
echo "📚 Para mais informações, consulte o README.md"
