#!/bin/bash

echo "🚀 Instalando dependências para o script de upload..."

# Verifica se o Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado. Por favor, instale o Python 3 primeiro."
    exit 1
fi

# Instala as dependências
echo "📦 Instalando firebase-admin..."
pip3 install firebase-admin

echo "✅ Dependências instaladas com sucesso!"
echo ""
echo "📝 Próximos passos:"
echo "1. Configure o arquivo firebase_config.json com suas credenciais do Firebase"
echo "2. Execute: python3 upload_stories_v2.py --example"
echo "3. Edite o arquivo exemplo_historia.json com sua história"
echo "4. Execute: python3 upload_stories_v2.py exemplo_historia.json"
