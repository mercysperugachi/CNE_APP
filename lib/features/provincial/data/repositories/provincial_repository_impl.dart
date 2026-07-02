import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/repositories/provincial_repository.dart';
import '../datasources/provincial_remote_datasource.dart';

class ProvincialRepositoryImpl implements ProvincialRepository {
  final ProvincialRemoteDataSource remoteDataSource;

  ProvincialRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<RecintoEntity>>> getRecintos() async {
    try {
      final recintos = await remoteDataSource.getRecintos();
      return Right(recintos);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecintoEntity>> createRecinto({
    required String canton,
    required String parroquia,
    required String nombre,
    required int cantidadMesas,
  }) async {
    try {
      final recinto = await remoteDataSource.createRecinto(
        canton: canton,
        parroquia: parroquia,
        nombre: nombre,
        cantidadMesas: cantidadMesas,
      );
      return Right(recinto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCoordinadorRecinto({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String recintoId,
  }) async {
    try {
      await remoteDataSource.createCoordinadorRecinto(
        cedula: cedula,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        correo: correo,
        recintoId: recintoId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getActasCountByRecinto(String recintoId) async {
    try {
      final count = await remoteDataSource.getActasCountByRecinto(recintoId);
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}