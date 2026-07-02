import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.cedula,
    required super.nombres,
    required super.apellidos,
    required super.rol,
    super.recintoId,
    super.telefono,
    super.correo,
    required super.requiresPasswordChange,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['\$id'] ?? '',
      cedula: json['cedula'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      rol: json['rol'] ?? 'veedor',
      recintoId: json['recintoId'],
      telefono: json['telefono'],
      correo: json['correo'],
      requiresPasswordChange: json['requiresPasswordChange'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'rol': rol,
      'recintoId': recintoId,
      'telefono': telefono,
      'correo': correo,
      'requiresPasswordChange': requiresPasswordChange,
    };
  }
}