import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/mesa_entity.dart';
import '../entities/asignacion_entity.dart';

abstract class CoordinadorRecintoRepository {
  Future<Either<Failure, List<MesaEntity>>> getMesasByRecinto(String recintoId);
  
  Future<Either<Failure, MesaEntity>> createMesa({
    required String numeroMesa,
    required String recintoId,
  });

  Future<Either<Failure, void>> createVeedorMesa({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String mesaId,
    required String recintoId,
  });

  Future<Either<Failure, List<AsignacionEntity>>> getAsignacionesByRecinto(String recintoId);
}