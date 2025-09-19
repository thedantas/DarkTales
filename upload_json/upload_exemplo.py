#!/usr/bin/env python3
"""
Script simplificado para fazer upload do arquivo exemplo_historia.json
Uso: python upload_exemplo.py
"""

import json
import os
import firebase_admin
from firebase_admin import credentials, db

def initialize_firebase():
    """Inicializa o Firebase Admin SDK"""
    try:
        # Verifica se já foi inicializado
        firebase_admin.get_app()
        print("✅ Firebase já inicializado")
    except ValueError:
        # Carrega configuração do arquivo
        config_path = os.path.join(os.path.dirname(__file__), 'firebase_config.json')
        
        if not os.path.exists(config_path):
            print("❌ Arquivo firebase_config.json não encontrado!")
            return False
        
        try:
            with open(config_path, 'r') as f:
                firebase_config = json.load(f)
            
            # Inicializa o Firebase
            cred = credentials.Certificate(firebase_config)
            firebase_admin.initialize_app(cred, {
                'databaseURL': 'https://dark-tales-e67d1-default-rtdb.firebaseio.com/'
            })
            print("✅ Firebase inicializado com sucesso")
            return True
            
        except Exception as e:
            print(f"❌ Erro ao inicializar Firebase: {str(e)}")
            return False

def upload_story(story_data):
    """Faz upload de uma história para o Firebase"""
    try:
        # Salva no Firebase (sem timestamps)
        ref = db.reference(f'stories/{story_data["id"]}')
        ref.set(story_data)
        
        print(f"✅ História {story_data['id']} ('{story_data['pt-br']['title']}') enviada com sucesso!")
        print(f"   - Nível: {story_data['level']}")
        print(f"   - Imagem: {story_data['image']}")
        print(f"   - Idiomas: {', '.join([lang for lang in story_data.keys() if lang not in ['id', 'level', 'image', 'created_at', 'updated_at']])}")
        return True
        
    except Exception as e:
        print(f"❌ Erro ao fazer upload da história: {str(e)}")
        return False

def main():
    """Função principal"""
    print("🚀 Iniciando upload do exemplo_historia.json...")
    
    # Inicializa Firebase
    if not initialize_firebase():
        print("❌ Falha ao inicializar Firebase")
        return
    
    # Carrega o arquivo exemplo_historia.json
    exemplo_path = os.path.join(os.path.dirname(__file__), 'exemplo_historia.json')
    
    if not os.path.exists(exemplo_path):
        print("❌ Arquivo exemplo_historia.json não encontrado!")
        print("   Execute: python upload_stories_v2.py --example")
        return
    
    try:
        with open(exemplo_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Verifica se é um array de histórias
        if 'stories' in data and isinstance(data['stories'], list):
            stories = data['stories']
            print(f"📚 Encontradas {len(stories)} histórias para upload")
            
            sucessos = 0
            for i, story_data in enumerate(stories, 1):
                print(f"\n📖 [{i}/{len(stories)}] Carregando: {story_data['pt-br']['title']}")
                
                if upload_story(story_data):
                    sucessos += 1
                else:
                    print(f"❌ Falha no upload da história {i}")
            
            print(f"\n🎉 Upload concluído! {sucessos}/{len(stories)} histórias enviadas com sucesso")
            
        else:
            # Formato antigo (história única)
            print(f"📖 Carregando história: {data['pt-br']['title']}")
            
            if upload_story(data):
                print("🎉 Upload concluído com sucesso!")
                print("🔍 Verifique no Firebase Console se a história foi salva")
            else:
                print("❌ Falha no upload")
            
    except Exception as e:
        print(f"❌ Erro ao processar arquivo: {str(e)}")

if __name__ == "__main__":
    main()
