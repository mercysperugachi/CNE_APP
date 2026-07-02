import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/mesa_entity.dart';
import '../repositories/coordinador_recinto_repository.dart';

class CreateMesaUseCase {
  final CoordinadorRecintoRepository repository;

  CreateMesaUseCase(this.repository);

  Future<Either<Failure, MesaEntity>> call({
    required String numeroMesa,
    required String recintoId,
  }) {
    if (numeroMesa.isEmpty || recintoId.isEmpty) {
      return Future.value(const Left(ServerFailure('El número de mesa es obligatorio')));
    }
    return repository.createMesa(numeroMesa: numeroMesa, recintoId: recintoId);
  }
}