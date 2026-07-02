import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String cedula, String password) {
    // Aquí podrían ir validaciones de negocio, ej. que la cédula tenga 10 dígitos
    if (cedula.isEmpty || password.isEmpty) {
      return Future.value(const Left(AuthFailure('Cédula y contraseña son requeridas')));
    }
    return repository.login(cedula, password);
  }
}