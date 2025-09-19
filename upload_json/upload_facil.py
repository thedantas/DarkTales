#!/usr/bin/env python3
"""
Script de conveniência para gerenciar histórias
Uso: python upload_facil.py [comando]
"""

import sys
import subprocess
import os

def mostrar_ajuda():
    """Mostra a ajuda do script"""
    print("📚 Script de Gerenciamento de Histórias")
    print("=" * 40)
    print()
    print("Comandos disponíveis:")
    print("  adicionar  - Adiciona uma nova história ao exemplo_historia.json")
    print("  upload     - Faz upload do exemplo_historia.json para o Firebase")
    print("  ver        - Mostra o conteúdo atual do exemplo_historia.json")
    print("  ajuda      - Mostra esta ajuda")
    print()
    print("Exemplos:")
    print("  python upload_facil.py adicionar")
    print("  python upload_facil.py upload")
    print("  python upload_facil.py ver")

def ver_historia():
    """Mostra o conteúdo atual do exemplo_historia.json"""
    exemplo_path = os.path.join(os.path.dirname(__file__), 'exemplo_historia.json')
    
    if not os.path.exists(exemplo_path):
        print("❌ Arquivo exemplo_historia.json não encontrado!")
        return
    
    try:
        import json
        with open(exemplo_path, 'r', encoding='utf-8') as f:
            historia = json.load(f)
        
        print("📖 História atual no exemplo_historia.json:")
        print("=" * 50)
        print(f"🆔 ID: {historia['id']}")
        print(f"📊 Nível: {historia['level']}")
        print(f"🖼️  Imagem: {historia['image']}")
        print()
        print("🇧🇷 Português:")
        print(f"  Título: {historia['pt-br']['title']}")
        print(f"  Pista: {historia['pt-br']['clue_text']}")
        print(f"  Resposta: {historia['pt-br']['answer_text']}")
        print()
        print("🇺🇸 Inglês:")
        print(f"  Title: {historia['en']['title']}")
        print(f"  Clue: {historia['en']['clue_text']}")
        print(f"  Answer: {historia['en']['answer_text']}")
        
    except Exception as e:
        print(f"❌ Erro ao ler arquivo: {str(e)}")

def executar_comando(comando):
    """Executa um comando específico"""
    if comando == "adicionar":
        print("📝 Iniciando adição de nova história...")
        subprocess.run([sys.executable, "adicionar_historia.py"])
    
    elif comando == "upload":
        print("🚀 Iniciando upload...")
        subprocess.run([sys.executable, "upload_exemplo.py"])
    
    elif comando == "ver":
        ver_historia()
    
    elif comando == "ajuda":
        mostrar_ajuda()
    
    else:
        print(f"❌ Comando desconhecido: {comando}")
        print("Use 'python upload_facil.py ajuda' para ver os comandos disponíveis")

def main():
    """Função principal"""
    if len(sys.argv) < 2:
        mostrar_ajuda()
        return
    
    comando = sys.argv[1].lower()
    executar_comando(comando)

if __name__ == "__main__":
    main()
