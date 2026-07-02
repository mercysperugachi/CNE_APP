import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/acta_entity.dart';
import '../entities/acta_pendiente_entity.dart';
import '../../../recinto/domain/entities/mesa_entity.dart';

abstract class VeedorRepository {
  Future<Either<Failure, ActaEntity?>> getActaByMesa(String mesaId, String tipoActa);
  Future<Either<Failure, List<ActaEntity>>> getActasByMesa(String mesaId);
  Future<Either<Failure, List<MesaEntity>>> getMesasByVeedor(String veedorId);
  
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
  });

  /// Guarda un acta localmente para sincronización diferida
  Future<Either<Failure, ActaPendienteEntity>> saveActaOffline(ActaPendienteEntity acta);

  /// Obtiene el acta pendiente para una mesa/tipo
  Future<Either<Failure, ActaPendienteEntity?>> getActaOffline(String mesaId, String tipoActa);

  /// Devuelve todas las actas pendientes de sincronización
  Future<Either<Failure, List<ActaPendienteEntity>>> getAllPendingActas();
}