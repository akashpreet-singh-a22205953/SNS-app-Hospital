import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/models/waiting_time.dart'; // Make sure to import your WaitingTime model

class Detalhes extends StatefulWidget {
  final int hospitalId;

  const Detalhes({Key? key, required this.hospitalId}) : super(key: key);

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  bool showWaitingTime = false;

  @override
  Widget build(BuildContext context) {
    final httpDataSource = Provider.of<HttpSnsDataSource>(context);
    final sqfliteDataSource = Provider.of<SqfliteSnsDataSource>(context);
    final connectivityModule = Provider.of<ConnectivityModule>(context);
    final snsRepository =
    SnsRepository(httpDataSource, sqfliteDataSource, connectivityModule);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Hospital')),
      backgroundColor: const Color(0xFFF5FAF8),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          snsRepository.getHospitalDetailById(widget.hospitalId),
          snsRepository.getHospitalWaitingTimes(widget.hospitalId),
        ]),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data![0] == null) {
            return const Center(child: Text('Hospital não encontrado'));
          } else {
            Hospital hospital = snapshot.data![0];
            List<WaitingTime> waitingTimes = snapshot.data![1] ?? [];
            return _buildHospitalDetailScreen(hospital, waitingTimes);
          }
        },
      ),
    );
  }

  Widget _buildHospitalDetailScreen(Hospital hospital, List<WaitingTime> waitingTimes) {
    final waitingTime = waitingTimes.isNotEmpty ? waitingTimes.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _decoratedInfoBox([
            _infoTile('🏥 Nome', hospital.name),
            _infoTile('📍 Endereço', hospital.address),
            _infoTile('🗺️ Distrito', hospital.district),
            _infoTile('📞 Telefone', hospital.phoneNumber.toString()),
            _infoTile('✉️ Email', hospital.email),
            _infoTile('🚨 Emergência', hospital.hasEmergency ? 'Sim' : 'Não'),
            _infoTile('📏 Distância de você', '559'),


            ElevatedButton(
              onPressed: () {
                setState(() {
                  showWaitingTime = !showWaitingTime;
                });
              },
              child: Text(showWaitingTime ? 'Ocultar Tempo de Espera' : 'Mostrar Tempo de Espera'),
            ),


            if (waitingTime != null && showWaitingTime) ...[
              const SizedBox(height: 16),
              const Text(
                '⏳ Tempo de Espera',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _infoTile('Última Atualização', waitingTime.lastUpdate.toString()),
              _infoTile('🟥 Vermelho', '${waitingTime.red.length} pessoas - ${(waitingTime.red.time/6000).round()} min'),
              _infoTile('🟧 Laranja', '${waitingTime.orange.length} pessoas - ${(waitingTime.orange.time/6000).round()} min'),
              _infoTile('🟨 Amarelo', '${waitingTime.yellow.length} pessoas - ${(waitingTime.yellow.time/6000).round()} min'),
              _infoTile('🟩 Verde', '${waitingTime.green.length} pessoas - ${(waitingTime.green.time/6000).round()} min'),
              _infoTile('🟦 Azul', '${waitingTime.blue.length} pessoas - ${(waitingTime.blue.time/6000).round()} min'),
            ],
          ]),
          const SizedBox(height: 32),
          const Text(
            '📝 Avaliações',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          hospital.reports.isEmpty
              ? const Text('Nenhuma avaliação disponível.')
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hospital.reports.length,
            itemBuilder: (context, index) =>
                _evaluationTile(hospital.reports[index]),
          )
        ],
      ),
    );
  }

  Widget _decoratedInfoBox(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _evaluationTile(EvaluationReport report) {
    int fullStars = report.valor.floor();
    bool hasHalfStar = (report.valor - fullStars) >= 0.5;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                if (index < fullStars) {
                  return Icon(Icons.star, color: Colors.orange, size: 24);
                } else if (index == fullStars && hasHalfStar) {
                  return Icon(Icons.star_half, color: Colors.grey, size: 24);
                } else {
                  return const Icon(Icons.star_border,
                      color: Colors.grey, size: 24);
                }
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  '${report.dataHora}',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (report.nota != null && report.nota!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${report.nota}',
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
