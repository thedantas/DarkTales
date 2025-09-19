#!/usr/bin/env python3
"""
Script de teste para verificar se o upload está funcionando
"""

import json
import os
from upload_stories_v2 import initialize_firebase, upload_story

def test_upload():
    """Testa o upload de uma história de exemplo"""
    
    # História de teste
    test_story = {
        "id": 999,
        "level": 1,
        "image": "images/test.png",
        "pt-br": {
            "title": "História de Teste",
            "clue_text": "Esta é uma história de teste para verificar se o upload está funcionando.",
            "answer_text": "A resposta é que o upload está funcionando corretamente!"
        },
        "en": {
            "title": "Test Story",
            "clue_text": "This is a test story to check if the upload is working.",
            "answer_text": "The answer is that the upload is working correctly!"
        }
    }
    
    print("🧪 Iniciando teste de upload...")
    
    # Inicializa Firebase
    if not initialize_firebase():
        print("❌ Falha ao inicializar Firebase")
        return False
    
    # Testa upload
    print("📤 Fazendo upload da história de teste...")
    success = upload_story(test_story)
    
    if success:
        print("✅ Teste de upload concluído com sucesso!")
        print("🔍 Verifique no Firebase Console se a história ID 999 foi criada")
        return True
    else:
        print("❌ Teste de upload falhou")
        return False

if __name__ == "__main__":
    test_upload()
