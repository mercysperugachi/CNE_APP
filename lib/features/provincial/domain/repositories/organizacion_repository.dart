import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/organizacion_entity.dart';

abstract class OrganizacionRepository {
  Future<Either<Failure, List<OrganizacionEntity>>> getOrganizacionesByDignidad(String dignidad);
  Future<Either<Failure, List<OrganizacionEntity>>> getAllOrganizaciones();
}