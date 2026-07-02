import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/recinto_entity.dart';
import '../repositories/provincial_repository.dart';

class GetRecintosUseCase {
  final ProvincialRepository repository;

  GetRecintosUseCase(this.repository);

  Future<Either<Failure, List<RecintoEntity>>> call() {
    return repository.getRecintos();
  }
}