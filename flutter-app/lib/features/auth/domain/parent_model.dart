import 'package:equatable/equatable.dart';

/// Parent/guardian account profile.
/// Company pattern: domain model with Equatable for BLoC state comparison.
class ParentModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;

  const ParentModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, name, phone, email];
}
