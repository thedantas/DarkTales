import 'package:flutter/material.dart';
import 'package:darktales/core/services/firebase_test_service.dart';
import 'package:darktales/core/services/firebase_service_v2.dart';
import 'package:darktales/debug_firebase.dart';
import 'package:darktales/debug_language.dart';
import 'package:darktales/test_story_model.dart';
import 'package:darktales/test_firebase_data.dart';
import 'package:darktales/debug_parsing.dart';

/// Widget simples para testar a conexão com Firebase
/// Execute este widget para verificar se tudo está funcionando
class TestFirebaseWidget extends StatefulWidget {
  const TestFirebaseWidget({super.key});

  @override
  State<TestFirebaseWidget> createState() => _TestFirebaseWidgetState();
}

class _TestFirebaseWidgetState extends State<TestFirebaseWidget> {
  String _status = 'Pronto para testar';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testando conexão...';
    });

    try {
      await FirebaseTestService.testConnection();
      setState(() {
        _status = '✅ Conexão estabelecida com sucesso!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro na conexão: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleStories() async {
    setState(() {
      _isLoading = true;
      _status = 'Adicionando histórias de exemplo...';
    });

    try {
      await FirebaseTestService.addSampleStories();
      setState(() {
        _status = '✅ Histórias de exemplo adicionadas!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro ao adicionar histórias: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runDebugTests() async {
    setState(() {
      _isLoading = true;
      _status = 'Executando testes de debug...';
    });

    try {
      await FirebaseDebugger.runAllTests();
      setState(() {
        _status = '✅ Testes de debug concluídos! Verifique o console.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro nos testes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testV2Service() async {
    setState(() {
      _isLoading = true;
      _status = 'Testando FirebaseServiceV2...';
    });

    try {
      final firebaseService = FirebaseServiceV2();
      final stories = await firebaseService.getStories();

      setState(() {
        _status =
            '✅ V2: ${stories.length} histórias encontradas! Verifique o console.';
      });

      print('📊 FirebaseServiceV2 - Histórias encontradas: ${stories.length}');
      for (final story in stories) {
        print('   📖 História ${story.id}: ${story.difficulty}');
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erro no V2: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _debugLanguage() async {
    setState(() {
      _isLoading = true;
      _status = 'Debugando problema de idioma...';
    });

    try {
      await LanguageDebugger.debugLanguageIssue();
      setState(() {
        _status = '✅ Debug de idioma concluído! Verifique o console.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro no debug: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testStoryModel() async {
    setState(() {
      _isLoading = true;
      _status = 'Testando StoryModel...';
    });

    try {
      testStoryModel();
      setState(() {
        _status = '✅ Teste do StoryModel concluído! Verifique o console.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro no teste: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseData() async {
    setState(() {
      _isLoading = true;
      _status = 'Testando dados do Firebase...';
    });

    try {
      testFirebaseData();
      setState(() {
        _status =
            '✅ Teste de dados do Firebase concluído! Verifique o console.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro no teste: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _debugParsing() async {
    setState(() {
      _isLoading = true;
      _status = 'Debugando parsing...';
    });

    try {
      debugParsing();
      setState(() {
        _status = '✅ Debug de parsing concluído! Verifique o console.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro no debug: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Firebase'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConnection,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi),
              label: const Text('Testar Conexão'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addSampleStories,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: const Text('Adicionar Histórias de Exemplo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runDebugTests,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bug_report),
              label: const Text('Executar Testes de Debug'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testV2Service,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upgrade),
              label: const Text('Testar FirebaseService V2'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _debugLanguage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.language),
              label: const Text('Debug Problema de Idioma'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testStoryModel,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.model_training),
              label: const Text('Testar StoryModel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testFirebaseData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.data_object),
              label: const Text('Testar Dados do Firebase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _debugParsing,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bug_report),
              label: const Text('Debug Parsing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instruções:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                        '1. Clique em "Testar Conexão" para verificar se o Firebase está funcionando'),
                    SizedBox(height: 4),
                    Text(
                        '2. Clique em "Adicionar Histórias de Exemplo" para popular o banco com dados de teste'),
                    SizedBox(height: 4),
                    Text(
                        '3. Clique em "Executar Testes de Debug" para investigar problemas de dados'),
                    SizedBox(height: 4),
                    Text(
                        '4. Clique em "Testar FirebaseService V2" para testar a versão melhorada'),
                    SizedBox(height: 4),
                    Text('5. Verifique o console para logs detalhados'),
                    SizedBox(height: 4),
                    Text('6. Acesse o Firebase Console para ver os dados:'),
                    SizedBox(height: 4),
                    Text(
                      'https://console.firebase.google.com/project/dark-tales-e67d1/database',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
