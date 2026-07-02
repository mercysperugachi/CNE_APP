import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/votos_consolidados_entity.dart';
import '../../domain/repositories/votos_consolidados_repository.dart';
import '../datasources/votos_consolidados_remote_datasource.dart';

class VotosConsolidadosRepositoryImpl implements VotosConsolidadosRepository {
  final VotosConsolidadosRemoteDataSource remoteDataSource;

  VotosConsolidadosRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<VotosConsolidadosEntity>>> getVotosConsolidadosByDignidad({
    required String dignidad,
    String? recintoId,
  }) async {
    try {
      final list = await remoteDataSource.getVotosConsolidadosByDignidad(
        dignidad: dignidad,
        recintoId: recintoId,
      );
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}