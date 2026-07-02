import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/recinto_entity.dart';
import '../repositories/provincial_repository.dart';

class CreateRecintoUseCase {
  final ProvincialRepository repository;

  CreateRecintoUseCase(this.repository);

  Future<Either<Failure, RecintoEntity>> call({
    required String canton,
    required String parroquia,
    required String nombre,
    required int cantidadMesas,
  }) {
    if (nombre.isEmpty || canton.isEmpty || parroquia.isEmpty || cantidadMesas <= 0) {
      return Future.value(const Left(ServerFailure('Todos los campos son obligatorios y mesas > 0')));
    }
    return repository.createRecinto(
      canton: canton,
      parroquia: parroquia,
      nombre: nombre,
      cantidadMesas: cantidadMesas,
    );
  }
}