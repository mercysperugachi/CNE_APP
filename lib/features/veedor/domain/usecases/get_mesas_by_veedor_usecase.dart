import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../recinto/domain/entities/mesa_entity.dart';
import '../repositories/veedor_repository.dart';

class GetMesasByVeedorUseCase {
  final VeedorRepository repository;

  GetMesasByVeedorUseCase(this.repository);

  Future<Either<Failure, List<MesaEntity>>> call(String veedorId) {
    if (veedorId.isEmpty) {
      return Future.value(
        const Left(ServerFailure('ID de veedor no puede estar vacío')),
      );
    }
    return repository.getMesasByVeedor(veedorId);
  }
}