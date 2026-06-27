import 'package:equatable/equatable.dart';

/// Parent/guardian account profile (ThaID-authenticated).
/// Company pattern: domain model with Equatable for BLoC state comparison.
class ParentModel extends Equatable {
  final String id;
  final String name;
  final String citizenId;

  const ParentModel({
    required this.id,
    required this.name,
    required this.citizenId,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        citizenId: json['citizenId'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, name, citizenId];
}
