#!/usr/bin/env python3
"""
Script para fazer upload de histórias JSON para o Firebase Realtime Database
Uso: python upload_stories_v2.py [arquivo.json]
"""

import json
import sys
import os
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, db
import argparse

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
            print("   Copie suas credenciais do Firebase Console para o arquivo firebase_config.json")
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
    json_files = [f for f in os.listdir('.') if f.endswith('.json') and f != 'firebase_config.json']
    
    if not json_files:
        print("❌ Nenhum arquivo JSON encontrado na pasta")
        return
    
    print(f"📚 Encontrados {len(json_files)} arquivos JSON")
    
    for file_path in json_files:
        print(f"\n📁 Processando arquivo: {file_path}")
        upload_from_file(file_path)

def create_example_story():
    """Cria um arquivo de exemplo com a estrutura correta"""
    example_story = {
        "id": 20,
        "level": 2,
        "image": "images/020.png",
        "pt-br": {
            "title": "O Quarto Trancado",
            "clue_text": "Uma mansão antiga tinha um quarto que ninguém conseguia abrir, apesar de não haver fechadura.",
            "answer_text": "O quarto estava selado porque dentro dele jaziam os corpos da família original, assassinados; suas presenças impediam a porta de ser movida."
        },
        "en": {
            "title": "The Locked Room",
            "clue_text": "An old mansion had a room that no one could open, despite having no lock.",
            "answer_text": "The room was sealed because inside lay the bodies of the original family, murdered; their presence kept the door from moving."
        }
    }
    
    with open('exemplo_historia.json', 'w', encoding='utf-8') as f:
        json.dump(example_story, f, ensure_ascii=False, indent=2)
    
    print("📝 Arquivo de exemplo criado: exemplo_historia.json")

def main():
    parser = argparse.ArgumentParser(description='Upload de histórias para Firebase Realtime Database')
    parser.add_argument('file', nargs='?', help='Arquivo JSON específico para upload (opcional)')
    parser.add_argument('--all', action='store_true', help='Fazer upload de todos os arquivos JSON na pasta')
    parser.add_argument('--example', action='store_true', help='Criar arquivo de exemplo')
    
    args = parser.parse_args()
    
    print("🚀 Iniciando script de upload de histórias...")
    
    if args.example:
        create_example_story()
        return
    
    # Inicializa Firebase
    if not initialize_firebase():
        return
    
    if args.all:
        upload_all_json_files()
    elif args.file:
        upload_from_file(args.file)
    else:
        # Se não especificou arquivo, tenta fazer upload de todos
        upload_all_json_files()

if __name__ == "__main__":
    main()
