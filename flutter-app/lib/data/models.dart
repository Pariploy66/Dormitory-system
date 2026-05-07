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

class ParentProfile {
  final String id;
  final String name;
  final String phone;
  final String email;

  const ParentProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) => ParentProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
      );
}

enum AccessType { IN, OUT }

class AccessLog {
  final String id;
  final DateTime accessTime;
  final AccessType type;
  final String gateName;

  /// Authoritative status computed by the backend.
  /// "late"   → IN entry between 22:30 and 05:59 Thai time.
  /// "ontime" → all other IN entries and all OUT entries.
  final String status;

  const AccessLog({
    required this.id,
    required this.accessTime,
    required this.type,
    required this.gateName,
    required this.status,
  });

  /// True when the backend flagged this entry as a curfew violation.
  bool get isLate => status == 'late';

  factory AccessLog.fromJson(Map<String, dynamic> json) => AccessLog(
        id: json['id'] as String,
        accessTime: DateTime.parse(json['accessTime'] as String).toLocal(),
        type: json['type'] == 'IN' ? AccessType.IN : AccessType.OUT,
        gateName: json['gateName'] as String,
        // Older API versions may not return status — default to ontime.
        status: json['status'] as String? ?? 'ontime',
      );
}
