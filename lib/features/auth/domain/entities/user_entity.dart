import 'package:equatable/equatable.dart';

import 'package:barwah_app/features/auth/domain/entities/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String roleBadgeCode;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleBadgeCode,
  });

  @override
  List<Object?> get props => [id, email, role];
}