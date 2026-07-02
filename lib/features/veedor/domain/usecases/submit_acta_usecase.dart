import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/acta_entity.dart';
import '../repositories/veedor_repository.dart';

class SubmitActaUseCase {
  final VeedorRepository repository;

  SubmitActaUseCase(this.repository);

  Future<Either<Failure, ActaEntity>> call({
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
  }) {
    if (mesaId.isEmpty || imagePath.isEmpty || tipoActa.isEmpty) {
      return Future.value(const Left(ServerFailure('Faltan datos obligatorios o foto')));
    }
    if (votosCandidato1 < 0 || votosCandidato2 < 0 || votosCandidato3 < 0 ||
        votosCandidato4 < 0 || votosCandidato5 < 0 || votosBlancos < 0 || votosNulos < 0) {
      return Future.value(const Left(ServerFailure('Los votos no pueden ser negativos')));
    }

    final sumaTotal = votosCandidato1 + votosCandidato2 + votosCandidato3 +
                      votosCandidato4 + votosCandidato5 + votosBlancos + votosNulos;

    if (sumaTotal != totalSufragantes) {
      return Future.value(const Left(ServerFailure('La suma de los votos no coincide con el total de sufragantes.')));
    }

    return repository.submitActa(
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
  }
}