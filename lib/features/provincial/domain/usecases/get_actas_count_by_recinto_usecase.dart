import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/provincial_repository.dart';

class GetActasCountByRecintoUseCase {
  final ProvincialRepository repository;

  GetActasCountByRecintoUseCase(this.repository);

  Future<Either<Failure, int>> call(String recintoId) {
    if (recintoId.isEmpty) {
      return Future.value(const Left(ServerFailure('El id del recinto no puede estar vacío')));
    }
    return repository.getActasCountByRecinto(recintoId);
  }
}