import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class RecoverPasswordUseCase {
  final AuthRepository repository;

  RecoverPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String cedula) async {
    return await repository.recoverPassword(cedula);
  }
}