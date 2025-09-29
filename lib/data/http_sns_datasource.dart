import 'dart:convert';

import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';

import '../http/http_client.dart';

class HttpSnsDataSource extends SnsDataSource {
  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) {
    // TODO: implement attachEvaluation
    throw UnimplementedError();
  }
  @override
  Future<List<Hospital>> getAllHospitals() async {
    final response = await HttpCliente().get(
      url: 'https://servicos.min-saude.pt/pds/api/tems/institution',
    );
    if (response.statusCode == 200) {
      final responseJSON = jsonDecode(response.body);
      List hospitalsJSON = responseJSON['Result'];
      List<Hospital> hospitalsLIST = hospitalsJSON
          .map((hospitalJSON) => Hospital.fromMap(hospitalJSON))
          .toList();


      return hospitalsLIST;
    } else {
      throw Exception('status code: ${response.statusCode}');
    }
  }


  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {


    List<Hospital>? cachedHospitals = await getAllHospitals();
    final hospital = cachedHospitals.firstWhere(
          (h) => h.id == hospitalId,
      orElse: () => throw Exception('Hospital com ID $hospitalId não encontrado'),
    );

    return hospital;
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) async {
    final response = await HttpCliente().get(
      url: 'https://servicos.min-saude.pt/pds/api/tems/standbyTime/$hospitalId',
    );

    if (response.statusCode == 200) {
      final responseJSON = jsonDecode(response.body);

      if (responseJSON['Result'] != null) {
        List waitingTimeJSON = responseJSON['Result'];
        List<WaitingTime> waitingList = waitingTimeJSON.map((item) {
          final waiting = WaitingTime.fromJson(item);
          print(waiting);
          print('WaitingTime: ${waiting.toMap(hospitalId: hospitalId)}');
          return waiting;
        }).toList();
        return waitingList;
      }
      else {
        throw Exception('API retornou sucesso mas sem dados (Result nulo)');
      }
    } else if(response.statusCode == 404) {
      return [];
    }else{
      throw Exception('Error: ${response.statusCode}');
    }
  }


  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    final hospitals = await getAllHospitals();
    final lowerName = name.toLowerCase();

    return hospitals.where((h) => h.name.toLowerCase().contains(lowerName)).toList();
  }


  @override
  Future<void> insertHospital(Hospital hospital) {
    // TODO: implement insertHospital
    throw UnimplementedError();
  }

  @override
  Future<void> insertWaitingTime(int hospitalId, waitingTime) {
    // TODO: implement insertWaitingTime
    throw UnimplementedError();
  }
}