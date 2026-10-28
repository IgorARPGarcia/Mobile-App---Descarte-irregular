
import 'package:flutter/material.dart';

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Descarte Consciente',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descarte Consciente'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline,
                size: 90,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                'Cuide da sua cidade!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Registre pontos de descarte irregular '
                'e ajude a manter os espaços públicos limpos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Botão para abrir a tela de cadastro
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaCadastro(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Registrar ocorrência'),
                ),
              ),

              const SizedBox(height: 12),

              // Botão para abrir a tela de consulta
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaOcorrencias(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Visualizar ocorrências'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();

  String? _categoriaSelecionada;

  final List<String> _categorias = [
    'Descarte irregular de lixo',
    'Acúmulo de lixo em vias públicas',
    'Lixeira danificada ou transbordando',
  ];

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _registrarOcorrencia() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Formulário validado! '
            'O salvamento será implementado depois.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar ocorrência'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Qual problema você encontrou?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              const Text('Categoria'),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Selecione uma categoria',
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(
                      categoria,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _categoriaSelecionada = valor;
                  });
                },
                validator: (valor) {
                  if (valor == null) {
                    return 'Selecione uma categoria.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              const Text('Descrição'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _descricaoController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Descreva o problema encontrado...',
                  alignLabelWithHint: true,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe uma descrição.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _registrarOcorrencia,
                  icon: const Icon(Icons.check),
                  label: const Text('Registrar ocorrência'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaOcorrencias extends StatelessWidget {
  const TelaOcorrencias({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências'),
      ),
      body: const Center(
        child: Text(
          'Aqui serão exibidas as ocorrências registradas.',
        ),
      ),
    );
  }
}
