import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/entities/acta_pendiente_entity.dart';
import '../../domain/repositories/veedor_repository.dart';
import '../../../recinto/domain/entities/mesa_entity.dart';
import '../datasources/acta_local_datasource.dart';
import '../datasources/veedor_remote_datasource.dart';

class VeedorRepositoryImpl implements VeedorRepository {
  final VeedorRemoteDataSource remoteDataSource;
  final ActaLocalDataSource localDataSource;

  VeedorRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, ActaEntity?>> getActaByMesa(String mesaId, String tipoActa) async {
    ActaPendienteEntity? local;
    try {
      local = await localDataSource.getActa(mesaId, tipoActa);
      if (local != null && local.estado == ActaSyncStatus.synced) {
        return Right(ActaEntity(
          id: local.remoteId ?? '',
          mesaId: local.mesaId,
          recintoId: local.recintoId,
          tipoActa: local.tipoActa,
          novedades: local.novedades,
          fotoUrl: local.imageRemoteUrl ?? local.imageLocalPath ?? '',
          votosCandidato1: local.votosCandidato1,
          votosCandidato2: local.votosCandidato2,
          votosCandidato3: local.votosCandidato3,
          votosCandidato4: local.votosCandidato4,
          votosCandidato5: local.votosCandidato5,
          votosBlancos: local.votosBlancos,
          votosNulos: local.votosNulos,
          totalSufragantes: local.totalSufragantes,
          latitud: local.latitud,
          longitud: local.longitud,
        ));
      }
      final actaModel = await remoteDataSource.getActaByMesa(mesaId, tipoActa);
      return Right(actaModel);
    } catch (e) {
      // Si estamos offline o falla el servidor, devolvemos el draft local si existe, 
      // o null para permitir crear una nueva acta offline.
      if (local != null) {
        return Right(ActaEntity(
          id: local.remoteId ?? '',
          mesaId: local.mesaId,
          recintoId: local.recintoId,
          tipoActa: local.tipoActa,
          novedades: local.novedades,
          fotoUrl: local.imageRemoteUrl ?? local.imageLocalPath ?? '',
          votosCandidato1: local.votosCandidato1,
          votosCandidato2: local.votosCandidato2,
          votosCandidato3: local.votosCandidato3,
          votosCandidato4: local.votosCandidato4,
          votosCandidato5: local.votosCandidato5,
          votosBlancos: local.votosBlancos,
          votosNulos: local.votosNulos,
          totalSufragantes: local.totalSufragantes,
          latitud: local.latitud,
          longitud: local.longitud,
        ));
      }
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, List<ActaEntity>>> getActasByMesa(String mesaId) async {
    try {
      final models = await remoteDataSource.getActasByMesa(mesaId);
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MesaEntity>>> getMesasByVeedor(String veedorId) async {
    try {
      final models = await remoteDataSource.getMesasByVeedor(veedorId);
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ActaEntity>> submitActa({
    required String mesaId,
    required String recintoId,
    required String tipoActa,
    required String novedades,
    required String imagePath,
    required int votosCandidato1,
    required int votosCandidato2,
    required int votosCandidato3,
    required int votosCandidato4,
    required int votosCandidato5,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final actaModel = await remoteDataSource.submitActa(
        mesaId: mesaId,
        recintoId: recintoId,
        tipoActa: tipoActa,
        novedades: novedades,
        imagePath: imagePath,
        votosCandidato1: votosCandidato1,
        votosCandidato2: votosCandidato2,
        votosCandidato3: votosCandidato3,
        votosCandidato4: votosCandidato4,
        votosCandidato5: votosCandidato5,
        votosBlancos: votosBlancos,
        votosNulos: votosNulos,
        totalSufragantes: totalSufragantes,
        latitud: latitud,
        longitud: longitud,
      );
      return Right(actaModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ActaPendienteEntity>> saveActaOffline(ActaPendienteEntity acta) async {
    try {
      final id = await localDataSource.saveActa(acta);
      final saved = acta.copyWith(localId: id);
      return Right(saved);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ActaPendienteEntity?>> getActaOffline(String mesaId, String tipoActa) async {
    try {
      final local = await localDataSource.getActa(mesaId, tipoActa);
      return Right(local);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActaPendienteEntity>>> getAllPendingActas() async {
    try {
      final list = await localDataSource.getAllPending();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}