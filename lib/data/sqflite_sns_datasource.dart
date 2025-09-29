import 'dart:io';
import 'package:path/path.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:sqflite/sqflite.dart';
import '../models/waiting_time.dart';

class SqfliteSnsDataSource extends SnsDataSource {
  Database? _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'sns.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE hospital(
          id INTEGER PRIMARY KEY,
          name TEXT,
          latitude REAL,
          longitude REAL,
          address TEXT,
          phoneNumber INTEGER,
          email TEXT,
          district TEXT,
          hasEmergency INTEGER
        )
      ''');

        await db.execute('''
        CREATE TABLE evaluations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hospitalId INTEGER,
          nomeHospital TEXT,
          valor INTEGER,
          dataHora TEXT,
          nota TEXT,
          FOREIGN KEY (hospitalId) REFERENCES hospital(id)
        )
      ''');

        await db.execute('''
        CREATE TABLE waiting_times(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hospital_id INTEGER,
  last_update TEXT,
  red_length INTEGER,
  red_time INTEGER,
  orange_length INTEGER,
  orange_time INTEGER,
  yellow_length INTEGER,
  yellow_time INTEGER,
  green_length INTEGER,
  green_time INTEGER,
  blue_length INTEGER,
  blue_time INTEGER,
  FOREIGN KEY (hospital_id) REFERENCES hospital(id)
)
      ''');
      },
    );
  }


  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    if (_database != null) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'sns.db');
      await close();
      await File(path).delete();
    }
  }

  @override
  Future<void> insertHospital(Hospital hospital) async {
    if (_database != null) {
      await _database!.insert(
        'hospital',
        hospital.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    if (_database == null) {
      return [];
    }

    final List<Map<String, dynamic>> maps = await _database!.rawQuery('SELECT * FROM hospital');
    return maps.map((map) => Hospital.fromMap(map)).toList();
  }


  Future<void> clearAllHospitals() async {
    if (_database != null) {
      await _database!.delete('hospital');
    }
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    if (_database == null) throw Exception('Database not initialized');

    final maps = await _database!.query(
      'hospital',
      where: 'id = ?',
      whereArgs: [hospitalId],
    );

    if (maps.isNotEmpty) {
      final hospital = Hospital.fromMap(maps.first);

      // final reports = await getEvaluationsByHospitalId(hospitalId);
      // hospital.reports.addAll(reports);

      hospital.rating = hospital.reports.isNotEmpty
          ? hospital.reports.map((r) => r.valor).reduce((a, b) => a + b) / hospital.reports.length
          : 0.0;

      return hospital;
    } else {
      throw Exception('Hospital with ID $hospitalId not found');
    }
  }


  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    if (_database == null) return [];
    final maps = await _database!.query(
      'hospital',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${name.toLowerCase()}%'],
    );
    return maps.map((map) => Hospital.fromMap(map)).toList();
  }


  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    if (_database != null) {
      await _database!.insert(
        'evaluations',
        {
          'hospitalId': hospitalId,
          'nomeHospital': report.nomeHospital,
          'valor': report.valor,
          'dataHora': report.dataHora,
          'nota': report.nota,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Attempting to insert evaluation for hospitalId: $hospitalId');
      print('Evaluation data:');
      print('  nomeHospital: ${report.nomeHospital}');
      print('  valor: ${report.valor}');
      print('  dataHora: ${report.dataHora}');
      print('  nota: ${report.nota}');
    }
  }

  // @override
  // Future<void> attachEvaluation(int hospitalId, EvaluationReport report) {
  //   if (_database == null) {
  //     return Future.value();
  //   }
  //
  //   return _database!.insert('evaluation', report.toDB());
  // }



  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) async {
    if (_database == null) return [];

    final maps = await _database!.query(
      'waiting_times',
      where: 'hospital_id = ?',
      whereArgs: [hospitalId],
      orderBy: 'last_update DESC',
    );

    return maps.map((map) {
      return WaitingTime(
        lastUpdate: DateTime.parse(map['last_update'] as String),
        red: TriageLevel(length: map['red_length'] as int, time: map['red_time'] as int),
        orange: TriageLevel(length: map['orange_length'] as int, time: map['orange_time'] as int),
        yellow: TriageLevel(length: map['yellow_length'] as int, time: map['yellow_time'] as int),
        green: TriageLevel(length: map['green_length'] as int, time: map['green_time'] as int),
        blue: TriageLevel(length: map['blue_length'] as int, time: map['blue_time'] as int),

      );
    }).toList();
  }


  Future<int> getHospitalCount() async {
    if (_database == null) return 0;
    final result = await _database!.rawQuery('SELECT COUNT(*) as count FROM hospital');
    return result.first['count'] as int;
  }

  Future<List<EvaluationReport>> getEvaluationsByHospitalId(int hospitalId) async {
    if (_database == null) return [];
    final maps = await _database!.query(
      'evaluations',
      where: 'hospitalId = ?',
      whereArgs: [hospitalId],
      orderBy: 'dataHora DESC',
    );
    return maps.map((map) => EvaluationReport.fromDB(map)).toList();
  }
  @override
  Future<void> insertWaitingTime(int hospitalId, waitingTime) async {
    if (_database != null) {
      await _database!.insert(
        'waiting_times',
        waitingTime.toMap(hospitalId: hospitalId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted waiting time for hospitalId: $hospitalId');
    }
  }


}
