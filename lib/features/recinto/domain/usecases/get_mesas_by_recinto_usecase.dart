import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/mesa_entity.dart';
import '../repositories/coordinador_recinto_repository.dart';

class GetMesasByRecintoUseCase {
  final CoordinadorRecintoRepository repository;

  GetMesasByRecintoUseCase(this.repository);

  Future<Either<Failure, List<MesaEntity>>> call(String recintoId) {
    if (recintoId.isEmpty) {
      return Future.value(const Left(ServerFailure('ID de recinto no puede estar vacío')));
    }
    return repository.getMesasByRecinto(recintoId);
  }
}