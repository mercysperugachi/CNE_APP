import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/provincial_repository.dart';

class CreateCoordinadorRecintoUseCase {
  final ProvincialRepository repository;

  CreateCoordinadorRecintoUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String recintoId,
  }) {
    if (cedula.isEmpty || nombres.isEmpty || apellidos.isEmpty || recintoId.isEmpty) {
      return Future.value(const Left(ServerFailure('Cédula, Nombres, Apellidos y Recinto son obligatorios')));
    }
    return repository.createCoordinadorRecinto(
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      correo: correo,
      recintoId: recintoId,
    );
  }
}