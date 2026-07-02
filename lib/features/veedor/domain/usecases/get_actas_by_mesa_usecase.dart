import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/acta_entity.dart';
import '../repositories/veedor_repository.dart';

class GetActasByMesaUseCase {
  final VeedorRepository repository;

  GetActasByMesaUseCase(this.repository);

  Future<Either<Failure, List<ActaEntity>>> call(String mesaId) {
    if (mesaId.isEmpty) {
      return Future.value(
        const Left(ServerFailure('ID de mesa no puede estar vacío')),
      );
    }
    return repository.getActasByMesa(mesaId);
  }
}