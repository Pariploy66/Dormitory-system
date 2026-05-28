import 'package:equatable/equatable.dart';

/// Student linked to a parent account.
/// Company pattern: domain model with Equatable.
class StudentModel extends Equatable {
  final String id;
  final String name;
  final String studentCode;
  final String dormitory;
  final String roomNumber;

  const StudentModel({
    required this.id,
    required this.name,
    required this.studentCode,
    required this.dormitory,
    required this.roomNumber,
  });

  String get locationLabel {
    if (dormitory.isEmpty && roomNumber.isEmpty) return '';
    if (dormitory.isNotEmpty && roomNumber.isNotEmpty) {
      return 'Dorm $dormitory room $roomNumber';
    }
    return dormitory.isNotEmpty ? dormitory : 'Room $roomNumber';
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        studentCode: json['studentCode'] as String? ?? '',
        dormitory: json['dormitory'] as String? ?? '',
        roomNumber: json['roomNumber'] as String? ?? '',
      );

  @override
  List<Object?> get props =>
      [id, name, studentCode, dormitory, roomNumber];
}
