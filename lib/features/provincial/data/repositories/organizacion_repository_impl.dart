import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/organizacion_entity.dart';
import '../../domain/repositories/organizacion_repository.dart';
import '../datasources/organizacion_remote_datasource.dart';

class OrganizacionRepositoryImpl implements OrganizacionRepository {
  final OrganizacionRemoteDataSource remoteDataSource;

  OrganizacionRepositoryImpl(this.remoteDataSource);

  Future<File> _getCacheFile(String dignidad) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/orgs_$dignidad.json');
  }

  @override
  Future<Either<Failure, List<OrganizacionEntity>>> getOrganizacionesByDignidad(String dignidad) async {
    try {
      final list = await remoteDataSource.getOrganizacionesByDignidad(dignidad);
      // Guardar en caché local para el modo offline
      try {
        final file = await _getCacheFile(dignidad);
        final jsonList = list.map((e) => {
          'id': e.id,
          'nombre': e.nombre,
          'siglas': e.siglas,
          'candidatoNombres': e.candidatoNombres,
          'candidatoApellidos': e.candidatoApellidos,
          'dignidad': e.dignidad,
          'numeroLista': e.numeroLista,
        }).toList();
        await file.writeAsString(jsonEncode(jsonList));
      } catch (_) {}
      return Right(list);
    } catch (e) {
      // Intentar cargar desde el caché local si falla el servidor o no hay internet
      try {
        final file = await _getCacheFile(dignidad);
        if (await file.exists()) {
          final content = await file.readAsString();
          final List<dynamic> jsonList = jsonDecode(content);
          final list = jsonList.map((e) => OrganizacionEntity(
            id: e['id'],
            nombre: e['nombre'],
            siglas: e['siglas'],
            candidatoNombres: e['candidatoNombres'],
            candidatoApellidos: e['candidatoApellidos'],
            dignidad: e['dignidad'],
            numeroLista: e['numeroLista'],
          )).toList();
          return Right(list);
        }
      } catch (_) {}
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrganizacionEntity>>> getAllOrganizaciones() async {
    try {
      final list = await remoteDataSource.getAllOrganizaciones();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}