class Student {
  final String id;
  final String name;
  final String studentCode;

  const Student({
    required this.id,
    required this.name,
    required this.studentCode,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        name: json['name'] as String,
        studentCode: json['studentCode'] as String,
      );
}

enum AccessType { IN, OUT }

class AccessLog {
  final String id;
  final DateTime accessTime;
  final AccessType type;
  final String gateName;

  const AccessLog({
    required this.id,
    required this.accessTime,
    required this.type,
    required this.gateName,
  });

  factory AccessLog.fromJson(Map<String, dynamic> json) => AccessLog(
        id: json['id'] as String,
        accessTime: DateTime.parse(json['accessTime'] as String).toLocal(),
        type: json['type'] == 'IN' ? AccessType.IN : AccessType.OUT,
        gateName: json['gateName'] as String,
      );
}
