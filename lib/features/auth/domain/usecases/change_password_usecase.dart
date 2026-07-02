import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String newPassword) {
    if (newPassword.length < 8) {
      return Future.value(const Left(AuthFailure('La contraseña debe tener al menos 8 caracteres')));
    }
    return repository.changePassword(newPassword);
  }
}