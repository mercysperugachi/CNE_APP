import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/asignacion_entity.dart';
import '../repositories/coordinador_recinto_repository.dart';

class GetAsignacionesByRecintoUseCase {
  final CoordinadorRecintoRepository repository;

  GetAsignacionesByRecintoUseCase(this.repository);

  Future<Either<Failure, List<AsignacionEntity>>> call(String recintoId) {
    if (recintoId.isEmpty) {
      return Future.value(
        const Left(ServerFailure('ID de recinto no puede estar vacío')),
      );
    }
    return repository.getAsignacionesByRecinto(recintoId);
  }
}