# 📚 Script de Upload de Histórias para Firebase

Este script permite fazer upload automático de histórias em formato JSON para o Firebase Realtime Database.

## 🚀 Configuração Inicial

### 1. Instalar Dependências

```bash
pip install firebase-admin
```

### 2. Configurar Credenciais do Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Vá para o projeto "dark-tales-e67d1"
3. Vá em "Configurações do projeto" > "Contas de serviço"
4. Clique em "Gerar nova chave privada"
5. Baixe o arquivo JSON e substitua o conteúdo do arquivo `firebase_config.json`

### 3. Estrutura do Arquivo JSON

Cada história deve seguir esta estrutura:

```json
{
  "id": 20,
  "level": 2,
  "image": "images/020.png",
  "pt-br": {
    "title": "Título da História",
    "clue_text": "Texto da pista",
    "answer_text": "Texto da resposta"
  },
  "en": {
    "title": "Story Title",
    "clue_text": "Clue text",
    "answer_text": "Answer text"
  }
}
```

**Campos obrigatórios:**
- `id`: ID único da história (número)
- `level`: Nível de dificuldade (0=fácil, 1=normal, 2=difícil)
- `image`: Caminho da imagem
- `pt-br`: Tradução em português brasileiro
- `en`: Tradução em inglês

**Campos opcionais:**
- Qualquer outro idioma (es, fr, de, it, ja, ru, zh-cn, zh-tw, ko, hi, ar, tr, pl, nl, he, sv, no, da, fi, cs, el, th, vi, id, ms, uk, ro)

## 📖 Como Usar

### Upload de um arquivo específico:
```bash
python upload_stories_v2.py historia_20.json
```

### Upload de todos os arquivos JSON da pasta:
```bash
python upload_stories_v2.py --all
```

### Criar arquivo de exemplo:
```bash
python upload_stories_v2.py --example
```

## 🔧 Funcionalidades

- ✅ **Validação automática**: Verifica se todos os campos obrigatórios estão presentes
- ✅ **Suporte a múltiplos idiomas**: Aceita qualquer idioma além de pt-br e en
- ✅ **Upload em lote**: Processa múltiplas histórias de uma vez
- ✅ **Logs detalhados**: Mostra o progresso e status de cada upload
- ✅ **Tratamento de erros**: Continua o processo mesmo se uma história falhar

## 📁 Estrutura de Arquivos

```
upload_json/
├── upload_stories_v2.py      # Script principal
├── firebase_config.json      # Configurações do Firebase
├── exemplo_historia.json     # Exemplo de história
└── README.md                 # Este arquivo
```

## 🎯 Exemplo de Uso

1. **Criar uma nova história:**
   ```bash
   python upload_stories_v2.py --example
   ```

2. **Editar o arquivo criado** com sua história

3. **Fazer upload:**
   ```bash
   python upload_stories_v2.py exemplo_historia.json
   ```

4. **Verificar no Firebase Console** se a história foi salva corretamente

## 🚨 Solução de Problemas

### Erro: "Arquivo firebase_config.json não encontrado"
- Certifique-se de que o arquivo `firebase_config.json` existe na pasta
- Verifique se as credenciais estão corretas

### Erro: "Campo obrigatório não encontrado"
- Verifique se todos os campos obrigatórios estão presentes no JSON
- Certifique-se de que pelo menos `pt-br` e `en` estão incluídos

### Erro: "Erro ao inicializar Firebase"
- Verifique se as credenciais do Firebase estão corretas
- Certifique-se de que o projeto está ativo no Firebase Console

## 📊 Estrutura no Firebase

As histórias são salvas no Firebase com a seguinte estrutura:

```
stories/
  └── {id}/
      ├── id: 20
      ├── level: 2
      ├── image: "images/020.png"
      ├── created_at: "2024-01-01T00:00:00.000Z"
      ├── updated_at: "2024-01-01T00:00:00.000Z"
      ├── pt-br/
      │   ├── title: "Título"
      │   ├── clue_text: "Pista"
      │   └── answer_text: "Resposta"
      └── en/
          ├── title: "Title"
          ├── clue_text: "Clue"
          └── answer_text: "Answer"
```
