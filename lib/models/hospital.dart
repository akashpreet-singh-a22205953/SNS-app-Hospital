import 'package:prjectcm/models/evaluation_report.dart';

class Hospital {
  final int id;
  final String name;
  //final String description;
  final double latitude;
  final double longitude;
  final String address;
  final int phoneNumber;
  final String email;
  final String district;
  double? distance = 0;

  //placeholders (distance and rating should be calculated dynamically)
  //final double distance;
  double rating;
  List<EvaluationReport> reports;
  final bool hasEmergency;

  Hospital({
    required this.id,
    required this.name,
    //required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.district,
    this.rating = 0.0,
    this.distance=0,
    List<EvaluationReport>? reports,
    required this.hasEmergency,
  }): this.reports = reports ?? [];

  List<EvaluationReport> getReports() {
    return reports;
  }

  void setReports(List<EvaluationReport> value) {
    reports.addAll(value);

    final soma = reports.fold(0, (acc, a) => acc + a.valor);
    rating = reports.isNotEmpty ? soma / reports.length : 0.0;
  }


  void insereAvaliacao(EvaluationReport avaliacao) {
    this.reports.add(avaliacao);
    final soma = reports.fold(0, (acc, a) => acc + a.valor);
    rating = soma / reports.length;
  }

  factory Hospital.fromMap(Map<String, dynamic> map) {
    // Handle data from API (with capital letters) or database (lowercase)
    return Hospital(
      id: _parseInt(map['Id'] ?? map['id']),
      name: _parseString(map['Name'] ?? map['name']),
      latitude: _parseDouble(map['Latitude'] ?? map['latitude']),
      longitude: _parseDouble(map['Longitude'] ?? map['longitude']),
      address: _parseString(map['Address'] ?? map['address']),
      phoneNumber: _parseInt(map['Phone'] ?? map['phoneNumber']),
      email: _parseString(map['Email'] ?? map['email']),
      district: _parseString(map['District'] ?? map['district']),
      hasEmergency: _parseBool(map['HasEmergency'] ?? map['hasEmergency']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'district': district,
      'hasEmergency': hasEmergency ? 1 : 0,
    };
  }
}