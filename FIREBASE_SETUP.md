# 🔥 Firebase Setup - Dark Tales

Este documento explica como o Firebase Realtime Database está configurado no projeto Dark Tales.

## 📋 Configuração Atual

### ✅ O que já está configurado:

1. **Firebase Core** - Inicializado no `main.dart`
2. **Firebase Realtime Database** - Configurado e funcionando
3. **Configurações de plataforma** - Android, iOS, macOS e Windows
4. **Modelos de dados** - `StoryModel` e `StoryContentModel`
5. **Serviço Firebase** - `FirebaseService` com operações CRUD completas

### 🗄️ Estrutura do Banco de Dados

```
dark-tales-e67d1-default-rtdb.firebaseio.com/
└── stories/
    ├── 1/
    │   ├── id: 1
    │   ├── difficulty: "easy"
    │   ├── category: "classic"
    │   ├── pt-br/
    │   │   ├── clue_text: "..."
    │   │   ├── answer_text: "..."
    │   │   └── image_clue: "..." (opcional)
    │   └── en/
    │       ├── clue_text: "..."
    │       ├── answer_text: "..."
    │       └── image_clue: "..." (opcional)
    ├── 2/
    └── ...
```

## 🚀 Como Usar

### 1. Importar o serviço

```dart
import 'package:darktales/core/services/firebase_service.dart';

final firebaseService = FirebaseService();
```

### 2. Operações Básicas

#### Buscar todas as histórias
```dart
final stories = await firebaseService.getStories();
```

#### Buscar história por ID
```dart
final story = await firebaseService.getStoryById(1);
```

#### Buscar por dificuldade
```dart
final easyStories = await firebaseService.getStoriesByDifficulty('easy');
```

#### Buscar por idioma
```dart
final ptStories = await firebaseService.getStoriesByLanguage('pt-br');
```

### 3. Operações CRUD

#### Criar nova história
```dart
final newStory = StoryModel(
  id: await firebaseService.getNextStoryId(),
  difficulty: 'easy',
  category: 'mystery',
  translations: {
    'pt-br': StoryContentModel(
      clueText: 'Sua dica aqui...',
      answerText: 'Sua resposta aqui...',
    ),
  },
);

final success = await firebaseService.addStory(newStory);
```

#### Atualizar história
```dart
final updatedStory = story.copyWith(difficulty: 'medium');
final success = await firebaseService.updateStory(updatedStory);
```

#### Deletar história
```dart
final success = await firebaseService.deleteStory(storyId);
```

### 4. Listeners em Tempo Real

#### Escutar mudanças em todas as histórias
```dart
firebaseService.listenToStories().listen((stories) {
  // Atualizar UI quando histórias mudarem
  print('Histórias atualizadas: ${stories.length}');
});
```

#### Escutar mudanças em uma história específica
```dart
firebaseService.listenToStory(storyId).listen((story) {
  if (story != null) {
    // História foi atualizada
  } else {
    // História foi removida
  }
});
```

## 🧪 Testes e Exemplos

### Executar exemplo completo
```dart
import 'package:darktales/core/services/firebase_example.dart';

// Executar exemplo completo
await FirebaseExample.runExample();
```

### Adicionar histórias de exemplo
```dart
import 'package:darktales/core/services/firebase_test_service.dart';

// Adicionar 5 histórias de exemplo
await FirebaseTestService.addSampleStories();

// Testar conexão
await FirebaseTestService.testConnection();

// Limpar todas as histórias (para testes)
await FirebaseTestService.clearAllStories();
```

## 🔧 Configuração do Firebase Console

### 1. Acessar o Console
- URL: https://console.firebase.google.com/
- Projeto: `dark-tales-e67d1`

### 2. Realtime Database
- URL: `https://dark-tales-e67d1-default-rtdb.firebaseio.com`
- Regras: Configuradas para permitir leitura/escrita (desenvolvimento)

### 3. Regras de Segurança (Produção)
Para produção, atualize as regras no Firebase Console:

```json
{
  "rules": {
    "stories": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$storyId": {
        ".validate": "newData.hasChildren(['id', 'difficulty', 'category'])"
      }
    }
  }
}
```

## 📱 URLs de Configuração

- **Android**: `google-services.json` ✅
- **iOS**: `GoogleService-Info.plist` ✅
- **macOS**: `GoogleService-Info.plist` ✅
- **Windows**: Configurado via `firebase_options.dart` ✅

## 🐛 Troubleshooting

### Erro de conexão
1. Verificar se o Firebase está inicializado no `main.dart`
2. Verificar se as configurações estão corretas
3. Verificar conectividade com internet

### Erro de permissão
1. Verificar regras do Realtime Database
2. Verificar se o projeto está ativo no Firebase Console

### Dados não aparecem
1. Verificar estrutura do JSON no Firebase Console
2. Verificar se os IDs são números (não strings)
3. Verificar se as traduções estão no formato correto

## 📊 Monitoramento

### Firebase Console
- Acesse: https://console.firebase.google.com/project/dark-tales-e67d1/database
- Monitore uso, erros e performance

### Logs do App
- Use `print()` para debug (já implementado no `FirebaseService`)
- Monitore erros de conexão e parsing

## 🔄 Próximos Passos

1. **Autenticação**: Implementar Firebase Auth para usuários
2. **Storage**: Adicionar Firebase Storage para imagens
3. **Analytics**: Implementar Firebase Analytics
4. **Crashlytics**: Adicionar crash reporting
5. **Performance**: Monitorar performance do app

## 📞 Suporte

Para dúvidas sobre a configuração do Firebase:
1. Verificar logs do console
2. Consultar documentação oficial do Firebase
3. Verificar exemplos no `firebase_example.dart`
