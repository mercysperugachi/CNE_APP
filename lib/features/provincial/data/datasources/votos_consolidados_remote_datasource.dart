import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../../domain/entities/votos_consolidados_entity.dart';

abstract class VotosConsolidadosRemoteDataSource {
  Future<List<VotosConsolidadosEntity>> getVotosConsolidadosByDignidad({
    required String dignidad,
    String? recintoId,
  });
}

class AppwriteVotosConsolidadosDataSource implements VotosConsolidadosRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteVotosConsolidadosDataSource(this.appwriteConfig);

  @override
  Future<List<VotosConsolidadosEntity>> getVotosConsolidadosByDignidad({
    required String dignidad,
    String? recintoId,
  }) async {
    try {
      final queries = <String>[];

      if (recintoId != null && recintoId.isNotEmpty) {
        queries.add(Query.equal('recintoId', recintoId));
      }
      queries.add(Query.equal('tipoActa', dignidad));
      queries.add(Query.limit(500));

      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.actasCollectionId,
        queries: queries.map((q) => q).toList(),
      );

      // 1. Obtener los nombres reales de los candidatos
      Map<int, String> nombresReales = {};
      Map<int, String?> logosReales = {};
      try {
        final orgsResponse = await appwriteConfig.databases.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.organizacionesCollectionId,
          queries: [
            Query.equal('dignidad', dignidad),
            Query.orderAsc('numeroLista'),
          ],
        );
        int index = 1;
        for (final doc in orgsResponse.documents) {
          final nombre = doc.data['candidatoNombres'] ?? '';
          final apellido = doc.data['candidatoApellidos'] ?? '';
          nombresReales[index] = '$nombre $apellido'.trim();
          logosReales[index] = doc.data['logoUrl'];
          index++;
        }
      } catch (e) {
        // Ignorar si falla, usaremos 'Lista $i' como respaldo
      }

      final Map<String, VotosConsolidadosEntity> agregados = {};

      for (final doc in response.documents) {
        final data = doc.data;
        for (var i = 1; i <= 5; i++) {
          final key = 'votosCandidato$i';
          final candidatoId = 'c$i';
          final nombreReal = nombresReales[i] ?? 'Lista $i';
          final logoReal = logosReales[i];
          final votos = (data[key] as num?)?.toInt() ?? 0;
          final entity = agregados[candidatoId];
          if (entity == null) {
            agregados[candidatoId] = VotosConsolidadosEntity(
              candidatoId: candidatoId,
              candidatoNombre: nombreReal,
              dignidad: dignidad,
              totalVotos: votos,
              cantidadMesas: votos > 0 ? 1 : 0,
              recintoId: recintoId,
              logoUrl: logoReal,
            );
          } else {
            agregados[candidatoId] = VotosConsolidadosEntity(
              candidatoId: entity.candidatoId,
              candidatoNombre: entity.candidatoNombre,
              dignidad: entity.dignidad,
              totalVotos: entity.totalVotos + votos,
              cantidadMesas: entity.cantidadMesas + (votos > 0 ? 1 : 0),
              recintoId: entity.recintoId,
              logoUrl: logoReal,
            );
          }
        }
      }

      final list = agregados.values.toList();
      list.sort((a, b) => b.totalVotos.compareTo(a.totalVotos));
      return list;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener consolidado de votos');
    }
  }
}