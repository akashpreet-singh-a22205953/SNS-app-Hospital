import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/http_sns_datasource.dart';
import '../data/sqflite_sns_datasource.dart';
import '../connectivity_module.dart';
import '../data/sns_repository.dart';
import '../models/hospital.dart';
import 'detalhespage.dart';

class Lista extends StatefulWidget {
  Lista({super.key});

  @override
  State<Lista> createState() => _ListaState();
}

class _ListaState extends State<Lista> {




  @override
  Widget build(BuildContext context) {

    final httpDataSource = Provider.of<HttpSnsDataSource>(context);
    final sqfliteDataSource = Provider.of<SqfliteSnsDataSource>(context);
    final connectivityModule = Provider.of<ConnectivityModule>(context);
    final snsRepository = SnsRepository( httpDataSource,sqfliteDataSource, connectivityModule);


    return Scaffold(
      key: const Key('hospitals-list-page'),
      appBar: AppBar(title: const Text('Hospitais')),
      body: FutureBuilder<List<Hospital>>(
        future: snsRepository.getAllHospitals(),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Não foi possível obter os hospitais. error snapshot",
                textAlign: TextAlign.center,
              ),
            );
          }

          final hospitals = snapshot.data ?? [];

          if (hospitals.isEmpty) {
            return const Center
              (child: Text(
              'Não foi possível obter os hospitais. Verifique a conectividade e volte a tentar',textAlign: TextAlign.center,));
          }

          return ListView.separated(
            key: const Key('list-view'),
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              final hospital = hospitals[index];
              return ListTile(
                title: Text(hospital.name),

                subtitle: Column(
                  children: [
                    if(hospital.hasEmergency)
                    Row(
                      mainAxisAlignment:MainAxisAlignment.start,
                      children: const [

                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Tem Urgência',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          hospital.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(width: 6),
                        ...List.generate(5, (index) {
                          final rating = hospital.rating;
                          if (rating >= index + 1) {
                            return const Icon(Icons.star, color: Colors.amber, size: 16);
                          } else if (rating > index && rating < index + 1) {
                            return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                          } else {
                            return const Icon(Icons.star_border, color: Colors.amber, size: 16);
                          }
                        }),
                      ],
                ),
                  ],
                ),

                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Detalhes(hospitalId: hospital.id),
                  ),
                ),






              );
            },
            separatorBuilder: (_, __) =>
            const Divider(color: Colors.blueGrey, thickness: 2),
          );
        },
      ),
    );
  }
}