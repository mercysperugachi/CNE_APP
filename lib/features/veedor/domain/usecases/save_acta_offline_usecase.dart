import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/acta_pendiente_entity.dart';
import '../repositories/veedor_repository.dart';

class SaveActaOfflineUseCase {
  final VeedorRepository repository;

  SaveActaOfflineUseCase(this.repository);

  Future<Either<Failure, ActaPendienteEntity>> call(ActaPendienteEntity acta) {
    if (acta.mesaId.isEmpty || acta.tipoActa.isEmpty) {
      return Future.value(
        const Left(ServerFailure('Datos de mesa/tipo de acta incompletos')),
      );
    }
    if (acta.sumaVotos != acta.totalSufragantes) {
      return Future.value(
        const Left(ServerFailure(
            'La suma de votos no coincide con el total de sufragantes')),
      );
    }
    if (acta.totalSufragantes < 0) {
      return Future.value(
        const Left(ServerFailure('El total de sufragantes no puede ser negativo')),
      );
    }
    return repository.saveActaOffline(acta);
  }
}