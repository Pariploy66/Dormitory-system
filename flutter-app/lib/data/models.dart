class Student {
  final String id;
  final String name;
  final String studentCode;
  final String? dormitory;
  final String? roomNumber;

  const Student({
    required this.id,
    required this.name,
    required this.studentCode,
    this.dormitory,
    this.roomNumber,
  });

  String get locationLabel {
    if (dormitory == null && roomNumber == null) return '';
    if (dormitory != null && roomNumber != null) return 'Dorm $dormitory room $roomNumber';
    return dormitory ?? 'Room $roomNumber';
  }

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        name: json['name'] as String,
        studentCode: json['studentCode'] as String,
        dormitory: json['dormitory'] as String?,
        roomNumber: json['roomNumber'] as String?,
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

  /// Authoritative curfew status computed by the backend.
  /// "late"   → IN entry at 22:30–05:59 Thai time.
  /// "ontime" → everything else (all OUT entries are always "ontime").
  final String status;

  const AccessLog({
    required this.id,
    required this.accessTime,
    required this.type,
    required this.gateName,
    required this.status,
  });

  /// Convenience getter — true when the backend flagged this as a curfew violation.
  bool get isLate => status == 'late';

  factory AccessLog.fromJson(Map<String, dynamic> json) => AccessLog(
        id: json['id'] as String,
        accessTime: DateTime.parse(json['accessTime'] as String).toLocal(),
        type: json['type'] == 'IN' ? AccessType.IN : AccessType.OUT,
        gateName: json['gateName'] as String,
        // Older API versions won't send status — default to ontime.
        status: json['status'] as String? ?? 'ontime',
      );
}
