import 'package:equatable/equatable.dart';

/// Student linked to a parent account.
/// Company pattern: domain model with Equatable.
class StudentModel extends Equatable {
  final String id;
  final String name; // Thai name (ฝ่ายทะเบียน)
  final String nameEn; // English name ('' if none)
  final String studentCode;
  final String dormitory; // Thai building name e.g. "ลำดวน 3"
  final String dormitoryEn; // e.g. "Lamduan 3"
  final String roomNumber;
  final String relationship; // FATHER | MOTHER | GUARDIAN | OTHER (from registry)

  /// Official profile photo from the registrar (ฝ่ายทะเบียน); null if none.
  final String? photoUrl;

  const StudentModel({
    required this.id,
    required this.name,
    this.nameEn = '',
    required this.studentCode,
    required this.dormitory,
    this.dormitoryEn = '',
    required this.roomNumber,
    this.relationship = '',
    this.photoUrl,
  });

  /// Display name for the active locale — Thai stays Thai, English stays English.
  String displayName(bool isTh) =>
      isTh ? name : (nameEn.isNotEmpty ? nameEn : name);

  /// "หอลำดวน 3 ห้อง 3102" (TH) / "Lamduan 3 Room 3102" (EN).
  String locationLabel(bool isTh) {
    final dorm = isTh ? dormitory : (dormitoryEn.isNotEmpty ? dormitoryEn : dormitory);
    if (dorm.isEmpty && roomNumber.isEmpty) return '';
    if (dorm.isNotEmpty && roomNumber.isNotEmpty) {
      return isTh ? 'หอ$dorm ห้อง $roomNumber' : '$dorm Room $roomNumber';
    }
    return dorm.isNotEmpty ? dorm : (isTh ? 'ห้อง $roomNumber' : 'Room $roomNumber');
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        nameEn: json['nameEn'] as String? ?? '',
        studentCode: json['studentCode'] as String? ?? '',
        dormitory: json['dormitory'] as String? ?? '',
        dormitoryEn: json['dormitoryEn'] as String? ?? '',
        roomNumber: json['roomNumber'] as String? ?? '',
        relationship: json['relationship'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
      );

  @override
  List<Object?> get props => [
        id, name, nameEn, studentCode, dormitory, dormitoryEn,
        roomNumber, relationship, photoUrl,
      ];
}
