import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/coordinador_recinto_repository.dart';

class CreateVeedorMesaUseCase {
  final CoordinadorRecintoRepository repository;

  CreateVeedorMesaUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String mesaId,
    required String recintoId,
  }) {
    if (cedula.isEmpty || nombres.isEmpty || apellidos.isEmpty || mesaId.isEmpty) {
      return Future.value(const Left(ServerFailure('Cédula, Nombres, Apellidos y Mesa son obligatorios')));
    }
    return repository.createVeedorMesa(
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      correo: correo,
      mesaId: mesaId,
      recintoId: recintoId,
    );
  }
}