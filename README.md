# Dark Tales

Um jogo de histórias sombrias (Black Stories) desenvolvido em Flutter com Firebase Realtime Database.

## 🎮 Sobre o Jogo

Dark Tales é um jogo de mistério onde os jogadores devem descobrir o que aconteceu em histórias enigmáticas. O jogo segue o conceito dos "Black Stories" onde:

- Uma pessoa é o narrador e lê a pista
- Os outros jogadores fazem perguntas
- O narrador só pode responder "Sim", "Não" ou "Não é relevante"
- O objetivo é descobrir a solução do mistério

## ✨ Funcionalidades

- **Splash Screen Animado**: Tela inicial com animações suaves
- **Tutorial Interativo**: Guia completo para novos jogadores
- **Sistema de Idiomas**: Suporte a múltiplos idiomas (PT-BR, EN, ES, FR, DE, IT, JA, RU)
- **Dificuldade por Cores**: Histórias organizadas por nível de dificuldade
- **Progresso do Jogador**: Acompanhe histórias concluídas
- **Interface Moderna**: Design dark theme com animações fluidas
- **Firebase Integration**: Dados sincronizados em tempo real

## 🏗️ Arquitetura

O projeto utiliza **Clean Architecture** com **GetX** para gerenciamento de estado:

```
lib/
├── core/                 # Configurações centrais
│   ├── constants/        # Constantes da aplicação
│   ├── theme/           # Tema e cores
│   ├── services/        # Serviços (Firebase, Storage)
│   └── utils/           # Utilitários
├── data/                # Camada de dados
│   ├── models/          # Modelos de dados
│   ├── repositories/    # Repositórios
│   └── datasources/     # Fontes de dados
├── domain/              # Camada de domínio
│   ├── entities/        # Entidades de negócio
│   ├── repositories/    # Interfaces de repositórios
│   └── usecases/        # Casos de uso
└── presentation/        # Camada de apresentação
    ├── controllers/     # Controllers GetX
    ├── pages/          # Telas da aplicação
    └── widgets/        # Widgets reutilizáveis
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (versão 3.6.0 ou superior)
- Dart SDK
- Java 17 (para Android)
- Xcode (para iOS)
- Firebase CLI

### Instalação

1. **Clone o repositório**
   ```bash
   git clone <repository-url>
   cd DarkTales
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**
   ```bash
   flutterfire configure --project=dark-tales-e67d1
   ```

4. **Execute o projeto**
   ```bash
   flutter run
   ```

### Estrutura do Firebase

O projeto utiliza Firebase Realtime Database com a seguinte estrutura:

```json
{
  "stories": [
    {
      "id": 1,
      "pt-br": {
        "clue_text": "Pista da história...",
        "image_clue": null,
        "answer_text": "Solução da história..."
      },
      "en": {
        "clue_text": "Story clue...",
        "image_clue": null,
        "answer_text": "Story solution..."
      },
      "difficulty": "easy|normal|hard",
      "category": "categoria"
    }
  ]
}
```

## 🎨 Design System

### Cores

- **Primária**: `#1A1A1A` (Preto)
- **Secundária**: `#2D2D2D` (Cinza escuro)
- **Accent**: `#FF6B35` (Laranja)
- **Fácil**: `#4CAF50` (Verde)
- **Normal**: `#FFC107` (Amarelo)
- **Difícil**: `#F44336` (Vermelho)

### Tipografia

- **Fonte**: Inter (Google Fonts)
- **Tamanhos**: Sistema de tipografia Material Design 3

## 📱 Telas

1. **Splash Screen**: Animação de entrada
2. **Tutorial**: 4 passos explicando como jogar
3. **Home**: Dashboard com estatísticas e categorias
4. **Lista de Histórias**: Grid com todas as histórias
5. **Jogo**: Tela da história com pista
6. **Solução**: Revelação da resposta

## 🔧 Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **GetX**: Gerenciamento de estado e navegação
- **Firebase**: Backend e banco de dados
- **Google Fonts**: Tipografia
- **Lottie**: Animações
- **Shared Preferences**: Armazenamento local

## 📋 TODO

- [ ] Implementar sistema completo de idiomas
- [ ] Adicionar mais animações Lottie
- [ ] Sistema de compartilhamento
- [ ] Modo offline
- [ ] Estatísticas avançadas
- [ ] Sistema de conquistas

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Contato

Desenvolvido com ❤️ para proporcionar horas de diversão e mistério!