import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/recinto_entity.dart';

abstract class ProvincialRepository {
  Future<Either<Failure, List<RecintoEntity>>> getRecintos();
  
  Future<Either<Failure, RecintoEntity>> createRecinto({
    required String canton,
    required String parroquia,
    required String nombre,
    required int cantidadMesas,
  });

  Future<Either<Failure, void>> createCoordinadorRecinto({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String recintoId,
  });

  Future<Either<Failure, int>> getActasCountByRecinto(String recintoId);
}