#!/usr/bin/env python3
"""
Script para fazer upload de histórias JSON para o Firebase Realtime Database
Uso: python upload_stories.py [arquivo.json]
"""

import json
import sys
import os
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, db
import argparse

# Configuração do Firebase
FIREBASE_CONFIG = {
    "type": "service_account",
    "project_id": "dark-tales-e67d1",
    "private_key_id": "your_private_key_id",
    "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-xxxxx@dark-tales-e67d1.iam.gserviceaccount.com",
    "client_id": "your_client_id",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs/firebase-adminsdk-xxxxx%40dark-tales-e67d1.iam.gserviceaccount.com"
}

def initialize_firebase():
    """Inicializa o Firebase Admin SDK"""
    try:
        # Verifica se já foi inicializado
        firebase_admin.get_app()
        print("✅ Firebase já inicializado")
    except ValueError:
        # Inicializa o Firebase
        cred = credentials.Certificate(FIREBASE_CONFIG)
        firebase_admin.initialize_app(cred, {
            'databaseURL': 'https://dark-tales-e67d1-default-rtdb.firebaseio.com/'
        })
        print("✅ Firebase inicializado com sucesso")

def validate_story_data(story_data):
    """Valida se os dados da história estão corretos"""
    required_fields = ['id', 'level', 'image']
    required_languages = ['pt-br', 'en']
    
    # Verifica campos obrigatórios
    for field in required_fields:
        if field not in story_data:
            raise ValueError(f"Campo obrigatório '{field}' não encontrado")
    
    # Verifica se pelo menos pt-br e en estão presentes
    for lang in required_languages:
        if lang not in story_data:
            raise ValueError(f"Idioma obrigatório '{lang}' não encontrado")
    
    # Verifica estrutura dos idiomas
    for lang, lang_data in story_data.items():
        if lang in ['id', 'level', 'image']:
            continue
            
        if not isinstance(lang_data, dict):
            raise ValueError(f"Dados do idioma '{lang}' devem ser um objeto")
        
        required_lang_fields = ['title', 'clue_text', 'answer_text']
        for field in required_lang_fields:
            if field not in lang_data:
                raise ValueError(f"Campo '{field}' obrigatório no idioma '{lang}'")
    
    return True

def upload_story(story_data):
    """Faz upload de uma história para o Firebase"""
    try:
        # Valida os dados
        validate_story_data(story_data)
        
        story_id = story_data['id']
        story_level = story_data['level']
        
        # Prepara os dados para upload
        upload_data = {
            'id': story_id,
            'level': story_level,
            'image': story_data['image'],
            'created_at': datetime.now().isoformat(),
            'updated_at': datetime.now().isoformat()
        }
        
        # Adiciona as traduções
        for lang, lang_data in story_data.items():
            if lang not in ['id', 'level', 'image']:
                upload_data[lang] = lang_data
        
        # Faz upload para o Firebase
        ref = db.reference(f'stories/{story_id}')
        ref.set(upload_data)
        
        print(f"✅ História {story_id} ('{story_data.get('pt-br', {}).get('title', 'Sem título')}') enviada com sucesso!")
        print(f"   - Nível: {story_level}")
        print(f"   - Imagem: {story_data['image']}")
        print(f"   - Idiomas: {', '.join([k for k in story_data.keys() if k not in ['id', 'level', 'image']])}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erro ao fazer upload da história {story_data.get('id', 'desconhecida')}: {str(e)}")
        return False

def upload_from_file(file_path):
    """Faz upload de histórias a partir de um arquivo JSON"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Se é uma lista de histórias
        if isinstance(data, list):
            print(f"📚 Encontradas {len(data)} histórias no arquivo")
            success_count = 0
            
            for i, story in enumerate(data, 1):
                print(f"\n📖 Processando história {i}/{len(data)}...")
                if upload_story(story):
                    success_count += 1
            
            print(f"\n🎉 Upload concluído! {success_count}/{len(data)} histórias enviadas com sucesso")
            
        # Se é uma única história
        elif isinstance(data, dict):
            print("📖 Processando história única...")
            if upload_story(data):
                print("\n🎉 História enviada com sucesso!")
            else:
                print("\n❌ Falha ao enviar história")
        else:
            raise ValueError("Formato de arquivo inválido. Deve ser um objeto ou array de histórias")
            
    except FileNotFoundError:
        print(f"❌ Arquivo não encontrado: {file_path}")
    except json.JSONDecodeError as e:
        print(f"❌ Erro ao decodificar JSON: {str(e)}")
    except Exception as e:
        print(f"❌ Erro inesperado: {str(e)}")

def upload_all_json_files():
    """Faz upload de todos os arquivos JSON na pasta"""
    json_files = [f for f in os.listdir('.') if f.endswith('.json')]
    
    if not json_files:
        print("❌ Nenhum arquivo JSON encontrado na pasta")
        return
    
    print(f"📚 Encontrados {len(json_files)} arquivos JSON")
    
    for file_path in json_files:
        print(f"\n📁 Processando arquivo: {file_path}")
        upload_from_file(file_path)

def main():
    parser = argparse.ArgumentParser(description='Upload de histórias para Firebase Realtime Database')
    parser.add_argument('file', nargs='?', help='Arquivo JSON específico para upload (opcional)')
    parser.add_argument('--all', action='store_true', help='Fazer upload de todos os arquivos JSON na pasta')
    
    args = parser.parse_args()
    
    print("🚀 Iniciando script de upload de histórias...")
    
    # Inicializa Firebase
    initialize_firebase()
    
    if args.all:
        upload_all_json_files()
    elif args.file:
        upload_from_file(args.file)
    else:
        # Se não especificou arquivo, tenta fazer upload de todos
        upload_all_json_files()

if __name__ == "__main__":
    main()
