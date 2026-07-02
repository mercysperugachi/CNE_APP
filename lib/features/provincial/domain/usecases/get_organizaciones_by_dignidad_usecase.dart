import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/organizacion_entity.dart';
import '../repositories/organizacion_repository.dart';

class GetOrganizacionesByDignidadUseCase {
  final OrganizacionRepository repository;

  GetOrganizacionesByDignidadUseCase(this.repository);

  Future<Either<Failure, List<OrganizacionEntity>>> call(String dignidad) {
    if (dignidad.isEmpty) {
      return Future.value(
        const Left(ServerFailure('La dignidad no puede estar vacía')),
      );
    }
    return repository.getOrganizacionesByDignidad(dignidad);
  }
}