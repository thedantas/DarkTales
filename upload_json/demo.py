#!/usr/bin/env python3
"""
Script de demonstração do upload de histórias
"""

import json
import os
from upload_stories_v2 import initialize_firebase, upload_story

def create_demo_stories():
    """Cria algumas histórias de demonstração"""
    
    stories = [
        {
            "id": 100,
            "level": 0,
            "image": "images/100.png",
            "pt-br": {
                "title": "O Mistério do Elevador",
                "clue_text": "Um homem entra no elevador no térreo e sai no 10º andar, mas quando desce, está no 15º andar.",
                "answer_text": "O elevador estava indo para o subsolo, não para cima. O homem desceu para o -15º andar."
            },
            "en": {
                "title": "The Elevator Mystery",
                "clue_text": "A man enters the elevator on the ground floor and exits on the 10th floor, but when he goes down, he's on the 15th floor.",
                "answer_text": "The elevator was going to the basement, not up. The man went down to the -15th floor."
            }
        },
        {
            "id": 101,
            "level": 1,
            "image": "images/101.png",
            "pt-br": {
                "title": "A Carta Perdida",
                "clue_text": "Uma carta foi enviada, mas nunca chegou ao destinatário. O remetente morreu no mesmo dia.",
                "answer_text": "A carta era o próprio remetente. Ele se enviou por correio como uma forma de suicídio."
            },
            "en": {
                "title": "The Lost Letter",
                "clue_text": "A letter was sent, but never reached the recipient. The sender died the same day.",
                "answer_text": "The letter was the sender himself. He mailed himself as a form of suicide."
            }
        },
        {
            "id": 102,
            "level": 2,
            "image": "images/102.png",
            "pt-br": {
                "title": "O Espelho Quebrado",
                "clue_text": "Um espelho foi quebrado em 7 pedaços, mas quando reconstruído, mostra uma imagem diferente.",
                "answer_text": "O espelho não foi quebrado acidentalmente. Foi quebrado propositalmente para revelar um código escondido atrás dele."
            },
            "en": {
                "title": "The Broken Mirror",
                "clue_text": "A mirror was broken into 7 pieces, but when reconstructed, it shows a different image.",
                "answer_text": "The mirror wasn't broken accidentally. It was broken on purpose to reveal a hidden code behind it."
            }
        }
    ]
    
    return stories

def demo_upload():
    """Demonstra o upload de histórias"""
    
    print("🎭 Iniciando demonstração do upload de histórias...")
    
    # Inicializa Firebase
    if not initialize_firebase():
        print("❌ Falha ao inicializar Firebase")
        return False
    
    # Cria histórias de demonstração
    stories = create_demo_stories()
    
    print(f"📚 Criadas {len(stories)} histórias de demonstração")
    
    success_count = 0
    
    for i, story in enumerate(stories, 1):
        print(f"\n📖 Processando história {i}/{len(stories)}...")
        if upload_story(story):
            success_count += 1
    
    print(f"\n🎉 Demonstração concluída! {success_count}/{len(stories)} histórias enviadas com sucesso")
    
    if success_count > 0:
        print("🔍 Verifique no Firebase Console se as histórias foram criadas")
        print("   - História 100: O Mistério do Elevador")
        print("   - História 101: A Carta Perdida")
        print("   - História 102: O Espelho Quebrado")
    
    return success_count == len(stories)

if __name__ == "__main__":
    demo_upload()
