import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/screens/pages.dart';
import 'package:provider/provider.dart';
import 'package:testable_form_field/testable_form_field.dart';
import '../connectivity_module.dart';
import '../data/http_sns_datasource.dart';
import '../data/sns_repository.dart';
import '../data/sqflite_sns_datasource.dart';

class Avaliar extends StatefulWidget {
  const Avaliar({super.key});

  @override
  State<Avaliar> createState() => _AvaliarState();
}

class _AvaliarState extends State<Avaliar> {
  int _numEstrelas = 0;
  Hospital? _hospitalSelecionado;
  final _dataHoraController = TextEditingController();
  final _notasController = TextEditingController();
  EvaluationReport? _avaliacao;
  bool _formInvalido = false;
  final dateFormatter = DateFormat("dd/MM/yyyy HH:mm");
  DateTime? _selectedDateTime;

  late final Future<List<Hospital>> hospitalsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _dataHoraController.text = dateFormatter.format(_selectedDateTime!);

    final httpDataSource = Provider.of<HttpSnsDataSource>(context, listen: false);
    final sqfliteDataSource = Provider.of<SqfliteSnsDataSource>(context, listen: false);
    final connectivityModule = Provider.of<ConnectivityModule>(context, listen: false);
    final snsRepository = SnsRepository(httpDataSource, sqfliteDataSource, connectivityModule);
    hospitalsFuture = snsRepository.getAllHospitals();
  }

  void _setAvaliacao(int valor) {
    setState(() {
      _numEstrelas = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Hospital>>(
      future: hospitalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5FAF8),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erro: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            body: Center(child: Text('Nenhum hospital encontrado.')),
          );
        }

        final hospitals = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(pages[3].title)),
          backgroundColor: const Color(0xFFF5FAF8),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 6),
                      _buildHospitalDropdown(hospitals),
                      SizedBox(height: 20),
                      _buildStarRating(),
                      SizedBox(height: 20),
                      _buildDateTimeField(),
                      SizedBox(height: 24),
                      _buildNotasField(),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                if (_formInvalido)
                  Text(
                    'Preencha a avaliação',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 16),
                _buildSubmitButton(Provider.of<SqfliteSnsDataSource>(context)),
                SizedBox(height: 72),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHospitalDropdown(List<Hospital> hospitals) {
    Hospital? selectedHospital;
    try {
      selectedHospital = hospitals.firstWhere((h) => h.id == _hospitalSelecionado?.id);
    } catch (e) {
      selectedHospital = null;
    }

    return TestableFormField<Hospital>(
      key: Key('evaluation-hospital-selection-field'),
      initialValue: selectedHospital,
      getValue: () => _hospitalSelecionado!,
      internalSetValue: (state, value) {
        state.didChange(value);
        setState(() {
          _hospitalSelecionado = value;
        });
      },
      builder: (state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return DropdownButtonFormField<Hospital>(
              decoration: InputDecoration(
                labelText: 'Nome do hospital',
                labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Selecione o hospital',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              isExpanded: true,
              value: selectedHospital,
              items: hospitals.map((hospital) {
                return DropdownMenuItem<Hospital>(
                  value: hospital,
                  child: Container(
                    width: constraints.maxWidth - 32,
                    child: Text(
                      hospital.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                state.didChange(value);
                setState(() {
                  _hospitalSelecionado = value;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStarRating() {
    return TestableFormField<int>(
      key: Key('evaluation-rating-field'),
      initialValue: _numEstrelas,
      getValue: () => _numEstrelas,
      internalSetValue: (state, value) {
        state.didChange(value);
        _setAvaliacao(value);
      },
      builder: (state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Avaliação',
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            errorText: state.errorText,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              int starIndex = index + 1;
              return IconButton(
                key: Key('star-$starIndex'),
                icon: Icon(
                  starIndex <= _numEstrelas ? Icons.star : Icons.star_border,
                  color: starIndex <= _numEstrelas ? Colors.orange : Colors.grey,
                  size: 42,
                ),
                onPressed: () {
                  state.didChange(starIndex);
                  _setAvaliacao(starIndex);
                },
                padding: EdgeInsets.zero,
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildDateTimeField() {
    return TestableFormField<DateTime>(
      key: Key('evaluation-datetime-field'),
      initialValue: _selectedDateTime ?? DateTime.now(),
      getValue: () => _selectedDateTime!,
      internalSetValue: (state, value) {
        state.didChange(value);
        setState(() {
          _selectedDateTime = value;
          _dataHoraController.text = dateFormatter.format(value);
        });
      },
      builder: (state) {
        return TextFormField(
          controller: _dataHoraController,
          decoration: InputDecoration(
            labelText: 'Data e hora',
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            hintText: '(31/12/2025 10:00)',
            errorText: state.errorText,
          ),
          onChanged: (value) {
            try {
              final parsed = dateFormatter.parse(value);
              state.didChange(parsed);
              setState(() {
                _selectedDateTime = parsed;
              });
            } catch (e) {
              state.didChange(null);
            }
          },
        );
      },
    );
  }

  Widget _buildNotasField() {
    return TestableFormField<String>(
      key: Key('evaluation-comment-field'),
      initialValue: _notasController.text,
      getValue: () => _notasController.text,
      internalSetValue: (state, value) {
        state.didChange(value);
        setState(() {
          _notasController.text = value;
        });
      },
      builder: (state) {
        return TextFormField(
          controller: _notasController,
          decoration: InputDecoration(
            labelText: 'Notas (opcional)',
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: 'Escreva um comentário...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 7,
          onChanged: (value) {
            state.didChange(value);
          },
        );
      },
    );
  }

  Widget _buildSubmitButton(SqfliteSnsDataSource sqfliteDataSource) {
    return Center(
      child: ElevatedButton.icon(
        key: Key('evaluation-form-submit-button'),
        onPressed: () async {
          final camposPreenchidos =
              _hospitalSelecionado != null && _numEstrelas != 0 && _selectedDateTime != null ;

          setState(() {
            _formInvalido = !camposPreenchidos;
          });

          if (!camposPreenchidos) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Existem campos obrigatórios que não foram preenchidos.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );
            return;
          }



          _avaliacao = EvaluationReport(
             nomeHospital: _hospitalSelecionado!.name,
            valor: _numEstrelas,
            dataHora: dateFormatter.format(_selectedDateTime!),
            nota: _notasController.text,
          );


          sqfliteDataSource.attachEvaluation(_hospitalSelecionado!.id, _avaliacao!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Avaliação enviada com sucesso!'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        },
        icon: Icon(Icons.send, size: 20, color: Colors.white),
        label: Text('Submeter', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00796B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
