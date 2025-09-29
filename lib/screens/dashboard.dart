import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/screens/pages.dart';

import '../connectivity_module.dart';
import '../data/http_sns_datasource.dart';
import '../data/sns_repository.dart';
import '../data/sqflite_sns_datasource.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<String> _senhas = [];
  Hospital? _selectedHospital;

  late Future<List<Hospital>> _futureHospitals;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/img1.png',
      'text':
          'Apagão: Hospital de Viseu ligado a geradores e autoridades pedem tranquilidade',
    },
    {
      'image': 'assets/img2.png',
      'text':
          'Enfermeiros da ULS Algarve iniciam esta sexta-feira greve que também abrange dias 8 e 9',
    },
    {
      'image': 'assets/img3.png',
      'text':
          'Equipamentos de última geração chegam ao hospital Vila Franca de Xira',
    },
  ];

  String _generateSenha() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random();
    final letter = letters[rand.nextInt(letters.length)];
    final number = rand.nextInt(90) + 10;
    return '$letter$number';
  }

  @override
  void initState() {
    super.initState();
    final httpDataSource =
        Provider.of<HttpSnsDataSource>(context, listen: false);
    final sqfliteDataSource =
        Provider.of<SqfliteSnsDataSource>(context, listen: false);
    final connectivityModule =
        Provider.of<ConnectivityModule>(context, listen: false);
    final snsRepository =
        SnsRepository(httpDataSource, sqfliteDataSource, connectivityModule);

    _futureHospitals = snsRepository.getAllHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pages[0].title)),
      backgroundColor: const Color(0xFFF6FFFA),
      body: Column(
        children: [
          // Slider de notícias (fora do FutureBuilder)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(_slides[index]['image']!,
                            fit: BoxFit.cover),
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _slides[index]['text']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: _currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // FutureBuilder com hospitais (separado do slider)
          Expanded(
            child: FutureBuilder<List<Hospital>>(
              future: _futureHospitals,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Não foi possível obter os hospitais. Verifique a conectividade e volte a tentar.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final hospitals = snapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Text(
                              '🩺 Cuidar da saúde é um ato de amor!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      // Lista de hospitais
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: hospitals.length,
                          itemBuilder: (context, index) {
                            final hospital = hospitals[index];
                            final isSelected = _selectedHospital == hospital;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedHospital = hospital;
                                });
                              },
                              child: Card(
                                margin: const EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: isSelected
                                    ? Colors.teal[200]
                                    : Colors.white,
                                child: Container(
                                  width: 220,
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(hospital.name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(hospital.address,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('📍 ${hospital.district}',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Botão gerar senha
                      ElevatedButton.icon(
                        key: Key('generate-password-button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedHospital == null
                              ? Colors.grey[800]
                              : Colors.cyan[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _selectedHospital == null
                            ? null
                            : () {
                                setState(() {
                                  _senhas.add(
                                      '${_selectedHospital!.name}: ${_generateSenha()}');
                                });
                              },
                        icon: const Icon(Icons.list),
                        label: const Text('Gerar Senha'),
                      ),

                      // Lista de senhas
                      if (_senhas.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.teal, width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _senhas
                                    .map((senha) => Text(
                                          '🔹 Senha: $senha',
                                          key: Key('generated-password-text'),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
