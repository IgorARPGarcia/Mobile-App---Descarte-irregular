import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

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
  Uint8List? _foto;
  double? _latitude;
  double? _longitude;
  bool _carregandoLocalizacao = false;

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

  
Future<void> _selecionarFoto() async {
  try {
    final imagem = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (imagem == null) return;

    final bytes = await imagem.readAsBytes();

    if (!mounted) return;

    setState(() {
      _foto = bytes;
    });
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Não foi possível selecionar a foto: $e'),
      ),
    );
  }
}

Future<void> _obterLocalizacao() async {
  setState(() {
    _carregandoLocalizacao = true;
  });

  try {
    final servicoAtivo =
        await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      throw Exception('Ative o serviço de localização.');
    }

    LocationPermission permissao =
        await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'A permissão foi negada permanentemente. '
        'Verifique as configurações do dispositivo.',
      );
    }

    final posicao = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _latitude = posicao.latitude;
      _longitude = posicao.longitude;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Localização obtida com sucesso!'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao obter localização: $e'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _carregandoLocalizacao = false;
      });
    }
  }
}


  
  void _registrarOcorrencia() {
    if (_formKey.currentState!.validate()) {
      final novaOcorrencia = Ocorrencia(
        categoria: _categoriaSelecionada!,
        descricao: _descricaoController.text.trim(),
        foto: _foto,
        latitude: _latitude,
        longitude: _longitude,
      );

      ocorrencias.add(novaOcorrencia);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorrência registrada com sucesso!'),
        ),
      );

      Navigator.pop(context);
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
              
              
              const Text(
                'Foto da ocorrência',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: _selecionarFoto,
                icon: const Icon(Icons.photo_library),
                label: const Text('Selecionar foto'),
              ),

              if (_foto != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _foto!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              const Text(
                'Localização',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed:
                    _carregandoLocalizacao ? null : _obterLocalizacao,
                icon: const Icon(Icons.my_location),
                label: Text(
                  _carregandoLocalizacao
                      ? 'Obtendo localização...'
                      : 'Obter minha localização',
                ),
              ),

              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${_latitude!.toStringAsFixed(6)}\n'
                  'Longitude: ${_longitude!.toStringAsFixed(6)}',
                ),
              ],

              const SizedBox(height: 28),

      
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
      body: ocorrencias.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma ocorrência registrada ainda.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ocorrencias.length,
              itemBuilder: (context, index) {
                final ocorrencia = ocorrencias[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      if (ocorrencia.foto != null)
                        Image.memory(
                          ocorrencia.foto!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),

                      ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 32,
                        ),
                        title: Text(
                          ocorrencia.categoria,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(top: 8),
                          child: Text(ocorrencia.descricao),
                        ),
                      ),

                      if (ocorrencia.latitude != null &&
                          ocorrencia.longitude != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 16,
                          ),
                          child: Text(
                            'Latitude: ${ocorrencia.latitude!.toStringAsFixed(6)}\n'
                            'Longitude: ${ocorrencia.longitude!.toStringAsFixed(6)}',
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}



class Ocorrencia {
  final String categoria;
  final String descricao;
  final Uint8List? foto;
  final double? latitude;
  final double? longitude;

  Ocorrencia({
    required this.categoria,
    required this.descricao,
    this.foto,
    this.latitude,
    this.longitude,
  });
}

final List<Ocorrencia> ocorrencias = [];
// Lista temporária compartilhada entre as telas.








