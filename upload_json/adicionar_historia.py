#!/usr/bin/env python3
"""
Script para adicionar uma nova história ao arquivo exemplo_historia.json
Uso: python adicionar_historia.py
"""

import json
import os

def adicionar_historia():
    """Adiciona uma nova história ao arquivo exemplo_historia.json"""
    
    print("📝 Adicionando nova história ao exemplo_historia.json")
    print("=" * 50)
    
    # Coleta dados da história
    print("\n📋 Digite os dados da nova história:")
    
    try:
        id_historia = int(input("ID da história (número): "))
        nivel = int(input("Nível (0=fácil, 1=normal, 2=difícil): "))
        imagem = input("Caminho da imagem (ex: images/021.png): ")
        
        print("\n🇧🇷 Dados em Português:")
        titulo_pt = input("Título: ")
        pista_pt = input("Texto da pista: ")
        resposta_pt = input("Texto da resposta: ")
        
        print("\n🇺🇸 Dados em Inglês:")
        titulo_en = input("Title: ")
        pista_en = input("Clue text: ")
        resposta_en = input("Answer text: ")
        
        # Cria a estrutura da história
        nova_historia = {
            "id": id_historia,
            "level": nivel,
            "image": imagem,
            "pt-br": {
                "title": titulo_pt,
                "clue_text": pista_pt,
                "answer_text": resposta_pt
            },
            "en": {
                "title": titulo_en,
                "clue_text": pista_en,
                "answer_text": resposta_en
            }
        }
        
        # Salva no arquivo exemplo_historia.json
        exemplo_path = os.path.join(os.path.dirname(__file__), 'exemplo_historia.json')
        
        with open(exemplo_path, 'w', encoding='utf-8') as f:
            json.dump(nova_historia, f, indent=2, ensure_ascii=False)
        
        print(f"\n✅ História salva em exemplo_historia.json!")
        print(f"📖 Título: {titulo_pt}")
        print(f"🆔 ID: {id_historia}")
        print(f"📊 Nível: {nivel}")
        
        print("\n🚀 Para fazer upload, execute:")
        print("python3 upload_exemplo.py")
        
    except ValueError:
        print("❌ Erro: ID e nível devem ser números inteiros")
    except KeyboardInterrupt:
        print("\n❌ Operação cancelada")
    except Exception as e:
        print(f"❌ Erro: {str(e)}")

if __name__ == "__main__":
    adicionar_historia()
