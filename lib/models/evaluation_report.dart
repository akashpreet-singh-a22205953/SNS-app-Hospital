class EvaluationReport {
  String? nomeHospital;
  int valor;
  String? dataHora;
  String? nota;

  EvaluationReport({
      required this.nomeHospital,
      required this.valor,
      required this.dataHora,
      this.nota,
});

  factory EvaluationReport.fromDB(Map<String, dynamic> db) {
    return EvaluationReport(
      nomeHospital: db['nomeHospital'],
      valor: db['valor'],
      dataHora: db['dataHora'],
      nota: db['nota'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'nomeHospital': nomeHospital,
      'valor': valor,
      'dataHora': dataHora,
      'nota': nota,
    };
  }
}
