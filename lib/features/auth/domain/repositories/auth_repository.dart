import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Inicia sesión con cédula y contraseña
  Future<Either<Failure, UserEntity>> login(String cedula, String password);

  /// Verifica si hay una sesión activa y retorna el usuario actual
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Cambia la contraseña (usado en el primer inicio de sesión o manualmente)
  Future<Either<Failure, void>> changePassword(String newPassword);

  /// Recupera la contraseña por correo dado la cédula
  Future<Either<Failure, void>> recoverPassword(String cedula);

  /// Cierra sesión
  Future<Either<Failure, void>> logout();
}