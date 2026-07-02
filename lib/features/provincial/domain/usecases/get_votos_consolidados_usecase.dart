import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/votos_consolidados_entity.dart';
import '../repositories/votos_consolidados_repository.dart';

class GetVotosConsolidadosUseCase {
  final VotosConsolidadosRepository repository;

  GetVotosConsolidadosUseCase(this.repository);

  Future<Either<Failure, List<VotosConsolidadosEntity>>> call({
    required String dignidad,
    String? recintoId,
  }) {
    if (dignidad.isEmpty) {
      return Future.value(
        const Left(ServerFailure('La dignidad no puede estar vacía')),
      );
    }
    return repository.getVotosConsolidadosByDignidad(
      dignidad: dignidad,
      recintoId: recintoId,
    );
  }
}