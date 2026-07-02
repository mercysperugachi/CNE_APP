import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/mesa_entity.dart';
import '../../domain/entities/asignacion_entity.dart';
import '../../domain/repositories/coordinador_recinto_repository.dart';
import '../datasources/recinto_remote_datasource.dart';

class CoordinadorRecintoRepositoryImpl implements CoordinadorRecintoRepository {
  final RecintoRemoteDataSource remoteDataSource;

  CoordinadorRecintoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MesaEntity>>> getMesasByRecinto(String recintoId) async {
    try {
      final mesas = await remoteDataSource.getMesasByRecinto(recintoId);
      return Right(mesas);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MesaEntity>> createMesa({
    required String numeroMesa,
    required String recintoId,
  }) async {
    try {
      final mesa = await remoteDataSource.createMesa(
        numeroMesa: numeroMesa,
        recintoId: recintoId,
      );
      return Right(mesa);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createVeedorMesa({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String mesaId,
    required String recintoId,
  }) async {
    try {
      await remoteDataSource.createVeedorMesa(
        cedula: cedula,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        correo: correo,
        mesaId: mesaId,
        recintoId: recintoId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AsignacionEntity>>> getAsignacionesByRecinto(String recintoId) async {
    try {
      final list = await remoteDataSource.getAsignacionesByRecinto(recintoId);
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}