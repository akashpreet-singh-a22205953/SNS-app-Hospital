import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/connectivity_module.dart';

class SnsRepository  {
  SnsDataSource _httpSnsDataSource;
  SqfliteSnsDataSource _sqfliteSnsDataSource;
  ConnectivityModule _connectivityModule;


  SnsRepository( this._httpSnsDataSource,  this._sqfliteSnsDataSource,  this._connectivityModule);

  Future<SnsDataSource> _getDataSource() async {

      bool isConnected = await _connectivityModule.checkConnectivity();
    if (isConnected) {
      return _httpSnsDataSource;
    } else {
      return _sqfliteSnsDataSource;
    }
  }

  Future<void> syncHospitalsToLocal() async {
    bool isConnected = await _connectivityModule.checkConnectivity();
    if (!isConnected) {
      print('No internet');
      return;
    }

    try {

      final hospitalsFromApi = await _httpSnsDataSource.getAllHospitals();
/*
      if (_sqfliteSnsDataSource is SqfliteSnsDataSource) {
        await (_sqfliteSnsDataSource as SqfliteSnsDataSource).clearAllHospitals();
      }
*/
      for (final hospital in hospitalsFromApi) {
        await _sqfliteSnsDataSource.insertHospital(hospital);
      }

      print('Sync completed: ${hospitalsFromApi.length} hospitals synced to local database');
    } catch (e) {
      print('Error during sync: $e');
    }
  }


  Future<void> insertHospital(Hospital hospital) async {
    final dataSource = await _getDataSource();
    return dataSource.insertHospital(hospital);
  }


  Future<List<Hospital>> getAllHospitals() async {
    try {
      await _syncIfNeeded();

      final dataSource = await _getDataSource();
      final hospitals = await dataSource.getAllHospitals();

      // ✅ Attach reports and calculate rating manually
      for (var hospital in hospitals) {
        final reports = await _sqfliteSnsDataSource.getEvaluationsByHospitalId(hospital.id);
        hospital.setReports(reports); // this will also update hospital.rating
      }

      return hospitals;
    } catch (e) {
      print('Error getting hospitals: $e');

      try {
        final hospitals = await _sqfliteSnsDataSource.getAllHospitals();

        for (var hospital in hospitals) {
          final reports = await _sqfliteSnsDataSource.getEvaluationsByHospitalId(hospital.id);
          hospital.setReports(reports);
        }

        return hospitals;
      } catch (localError) {
        print('Error getting local hospitals: $localError');
        return [];
      }
    }
  }


  Future<void> _syncIfNeeded() async {
    try {
      bool isConnected = await _connectivityModule.checkConnectivity();

        final localHospitals = await _sqfliteSnsDataSource.getAllHospitals();
        if (localHospitals.isEmpty) {
          if (isConnected) {
          await syncHospitalsToLocal();
        }
      }
    } catch (e) {
      print('Error checking sync status: $e');
    }
  }


  Future<List<Hospital>> getHospitalsByName(String name) async {
    final dataSource = await _getDataSource();
    return dataSource.getHospitalsByName(name);
  }


  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    List<Hospital> hospitals = await getAllHospitals();

    for (var hospital in hospitals) {
      if (hospital.reports.isEmpty && hospital.id == hospitalId) {
        hospital.reports = await _sqfliteSnsDataSource.getEvaluationsByHospitalId(hospitalId);
      }
    }

    // hospital.reports = await _sqfliteSnsDataSource.getEvaluationsByHospitalId(hospitalId);


    return hospitals.firstWhere((hospital) => hospital.id == hospitalId);
  }


  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    final dataSource = await _getDataSource();
    return dataSource.attachEvaluation(hospitalId, report);
  }


  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) async {
    final dataSource = await _getDataSource();

    final waitingTimes = await dataSource.getHospitalWaitingTimes(hospitalId);

    for (var wt in waitingTimes) {
      await _sqfliteSnsDataSource.insertWaitingTime(hospitalId, wt);
    }

    return waitingTimes;
  }


  Future<void> insertWaitingTime(int hospitalId,waitingTime) async {

    await _sqfliteSnsDataSource.insertWaitingTime(hospitalId, waitingTime);


  }

}