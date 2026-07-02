import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String rol;
  final String? recintoId;
  final String? telefono;
  final String? correo;
  final bool requiresPasswordChange;

  const UserEntity({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.rol,
    this.recintoId,
    this.telefono,
    this.correo,
    required this.requiresPasswordChange,
  });

  @override
  List<Object?> get props => [
        id,
        cedula,
        nombres,
        apellidos,
        rol,
        recintoId,
        telefono,
        correo,
        requiresPasswordChange,
      ];
}