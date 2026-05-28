import 'package:equatable/equatable.dart';

/// Single gate access record (entry or exit).
/// Company pattern: domain model with Equatable.
/// [type] is 'IN' or 'OUT' — use [isEntry] / [isExit] getters.
/// [isLate] is authoritative from backend (curfew logic lives server-side).
class AccessLogModel extends Equatable {
  final String id;
  final String type; // 'IN' | 'OUT'
  final DateTime accessTime;
  final String gateName;
  final bool isLate;

  const AccessLogModel({
    required this.id,
    required this.type,
    required this.accessTime,
    required this.gateName,
    required this.isLate,
  });

  bool get isEntry => type == 'IN';
  bool get isExit => type == 'OUT';

  factory AccessLogModel.fromJson(Map<String, dynamic> json) =>
      AccessLogModel(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'IN',
        accessTime: DateTime.parse(json['accessTime'] as String).toLocal(),
        gateName: json['gateName'] as String? ?? '',
        // Backend sends 'status': 'late'|'ontime' — map to bool
        isLate: (json['status'] as String? ?? 'ontime') == 'late',
      );

  @override
  List<Object?> get props => [id, type, accessTime, gateName, isLate];
}
