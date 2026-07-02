import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/votos_consolidados_entity.dart';

abstract class VotosConsolidadosRepository {
  Future<Either<Failure, List<VotosConsolidadosEntity>>> getVotosConsolidadosByDignidad({
    required String dignidad,
    String? recintoId,
  });
}