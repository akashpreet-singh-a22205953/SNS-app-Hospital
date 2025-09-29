class WaitingTime {
  final TriageLevel red;
  final TriageLevel orange;
  final TriageLevel yellow;
  final TriageLevel green;
  final TriageLevel blue;
  final DateTime lastUpdate;

  WaitingTime({
    required this.red,
    required this.orange,
    required this.yellow,
    required this.green,
    required this.blue,
    required this.lastUpdate,
  });

  factory WaitingTime.fromJson(Map<String, dynamic> json) {
    return WaitingTime(
      red: TriageLevel.fromJson(json['Red'] ?? {}),
      orange: TriageLevel.fromJson(json['Orange'] ?? {}),
      yellow: TriageLevel.fromJson(json['Yellow'] ?? {}),
      green: TriageLevel.fromJson(json['Green'] ?? {}),
      blue: TriageLevel.fromJson(json['Blue'] ?? {}),
      lastUpdate: DateTime.parse(json['LastUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }



  Map<String, dynamic> toMap({required int hospitalId}) {
    return {
      'hospital_id': hospitalId,
      'last_update': lastUpdate.toIso8601String(),
      'red_length': red.length,
      'red_time': red.time,
      'orange_length': orange.length,
      'orange_time': orange.time,
      'yellow_length': yellow.length,
      'yellow_time': yellow.time,
      'green_length': green.length,
      'green_time': green.time,
      'blue_length': blue.length,
      'blue_time': blue.time,
    };
  }
}

class TriageLevel {
  final int length;
  final int time;

  TriageLevel({required this.length, required this.time});

  factory TriageLevel.fromJson(Map<String, dynamic> json) {
    return TriageLevel(
      length: json['Length'] ?? 0,
      time: json['Time'] ?? 0,
    );
  }
}
