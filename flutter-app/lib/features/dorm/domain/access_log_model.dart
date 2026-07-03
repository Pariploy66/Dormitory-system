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

  /// Photo captured at the gate (Access Control returns รูปภาพ / รูปภาพสแกน).
  final String? imageUrl; // รูปภาพ — the profile/reference photo
  final String? scanImageUrl; // รูปภาพสแกน — the live face-scan snapshot

  const AccessLogModel({
    required this.id,
    required this.type,
    required this.accessTime,
    required this.gateName,
    required this.isLate,
    this.imageUrl,
    this.scanImageUrl,
  });

  bool get isEntry => type == 'IN';
  bool get isExit => type == 'OUT';

  /// Date + time in Thai Buddhist calendar with a 2-digit year, e.g. `3/7/69 14:38`.
  String get displayDateTime {
    final t = accessTime;
    final beYear2 = ((t.year + 543) % 100).toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.day}/${t.month}/$beYear2 $hh:$mm';
  }

  factory AccessLogModel.fromJson(Map<String, dynamic> json) =>
      AccessLogModel(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'IN',
        accessTime: DateTime.parse(json['accessTime'] as String).toLocal(),
        gateName: json['gateName'] as String? ?? '',
        // Backend sends 'status': 'late'|'ontime' — map to bool
        isLate: (json['status'] as String? ?? 'ontime') == 'late',
        imageUrl: (json['imageUrl'] ?? json['photoUrl']) as String?,
        scanImageUrl: (json['scanImageUrl'] ?? json['scanPhotoUrl']) as String?,
      );

  @override
  List<Object?> get props =>
      [id, type, accessTime, gateName, isLate, imageUrl, scanImageUrl];
}
