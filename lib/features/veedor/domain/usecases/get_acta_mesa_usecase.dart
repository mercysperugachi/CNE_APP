import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/acta_entity.dart';
import '../repositories/veedor_repository.dart';

class GetActaMesaUseCase {
  final VeedorRepository repository;

  GetActaMesaUseCase(this.repository);

  Future<Either<Failure, ActaEntity?>> call(String mesaId, String tipoActa) {
    if (mesaId.isEmpty || tipoActa.isEmpty) {
      return Future.value(const Left(ServerFailure('ID de mesa o tipo de acta no puede estar vacío')));
    }
    return repository.getActaByMesa(mesaId, tipoActa);
  }
}