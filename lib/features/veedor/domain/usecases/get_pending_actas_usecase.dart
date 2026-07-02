import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/acta_pendiente_entity.dart';
import '../repositories/veedor_repository.dart';

class GetPendingActasUseCase {
  final VeedorRepository repository;

  GetPendingActasUseCase(this.repository);

  Future<Either<Failure, List<ActaPendienteEntity>>> call() {
    return repository.getAllPendingActas();
  }
}