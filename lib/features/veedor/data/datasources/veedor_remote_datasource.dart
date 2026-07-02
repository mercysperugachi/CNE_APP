import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../models/acta_model.dart';
import '../../../recinto/data/models/mesa_model.dart';

abstract class VeedorRemoteDataSource {
  Future<ActaModel?> getActaByMesa(String mesaId, String tipoActa);
  Future<List<ActaModel>> getActasByMesa(String mesaId);
  Future<List<MesaModel>> getMesasByVeedor(String veedorId);
  Future<ActaModel> submitActa({
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
}

class AppwriteVeedorDataSource implements VeedorRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteVeedorDataSource(this.appwriteConfig);

  @override
  Future<ActaModel?> getActaByMesa(String mesaId, String tipoActa) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.actasCollectionId,
        queries: [
          Query.equal('mesaId', mesaId),
          Query.equal('tipoActa', tipoActa),
        ],
      );
      if (response.documents.isEmpty) {
        return null; // No hay acta para esta mesa aún
      }
      return ActaModel.fromJson(response.documents.first.data);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener estado del acta');
    }
  }

  @override
  Future<List<ActaModel>> getActasByMesa(String mesaId) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.actasCollectionId,
        queries: [
          Query.equal('mesaId', mesaId),
          Query.orderAsc('tipoActa'),
          Query.limit(2),
        ],
      );
      return response.documents
          .map((d) => ActaModel.fromJson(d.data))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener las actas de la mesa');
    }
  }

  @override
  Future<List<MesaModel>> getMesasByVeedor(String veedorId) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.asignacionesCollectionId,
        queries: [
          Query.equal('veedorId', veedorId),
          Query.equal('activa', true),
        ],
      );
      
      List<MesaModel> mesas = [];
      for (var doc in response.documents) {
        final mesaId = doc.data['mesaId'];
        try {
          final mesaDoc = await appwriteConfig.databases.getDocument(
            databaseId: AppConstants.databaseId,
            collectionId: AppConstants.mesasCollectionId,
            documentId: mesaId,
          );
          mesas.add(MesaModel.fromJson(mesaDoc.data));
        } catch (e) {
          // Ignorar si la mesa no existe
        }
      }
      return mesas;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener mesas asignadas');
    }
  }

  @override
  Future<ActaModel> submitActa({
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
  }) async {
    try {
      // 1. Subir la imagen al Storage Bucket (solo si es un path local)
      String? fileId;
      String fotoUrl = imagePath;
      if (imagePath.isNotEmpty && !imagePath.startsWith('http') && AppConstants.storageBucketId.isNotEmpty) {
        final uploadedFile = await appwriteConfig.storage.createFile(
          bucketId: AppConstants.storageBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: imagePath),
        );
        fileId = uploadedFile.$id;
        fotoUrl = '${appwriteConfig.client.endPoint}/storage/buckets/${AppConstants.storageBucketId}/files/$fileId/view?project=${AppConstants.projectId}';
      }

      // Check if acta already exists to UPDATE instead of create
      final existingActa = await getActaByMesa(mesaId, tipoActa);

      if (existingActa != null) {
        // Update document
        final response = await appwriteConfig.databases.updateDocument(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.actasCollectionId,
          documentId: existingActa.id,
          data: {
            'novedades': novedades,
            'fotoUrl': fotoUrl,
            'votosCandidato1': votosCandidato1,
            'votosCandidato2': votosCandidato2,
            'votosCandidato3': votosCandidato3,
            'votosCandidato4': votosCandidato4,
            'votosCandidato5': votosCandidato5,
            'votosBlancos': votosBlancos,
            'votosNulos': votosNulos,
            'totalSufragantes': totalSufragantes,
            'latitud': latitud,
            'longitud': longitud,
          },
        );
        return ActaModel.fromJson(response.data);
      } else {
        // Create new document
        final response = await appwriteConfig.databases.createDocument(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.actasCollectionId,
          documentId: ID.unique(),
          data: {
            'mesaId': mesaId,
            'recintoId': recintoId,
            'tipoActa': tipoActa,
            'novedades': novedades,
            'fotoUrl': fotoUrl,
            'votosCandidato1': votosCandidato1,
            'votosCandidato2': votosCandidato2,
            'votosCandidato3': votosCandidato3,
            'votosCandidato4': votosCandidato4,
            'votosCandidato5': votosCandidato5,
            'votosBlancos': votosBlancos,
            'votosNulos': votosNulos,
            'totalSufragantes': totalSufragantes,
            'latitud': latitud,
            'longitud': longitud,
          },
        );
        return ActaModel.fromJson(response.data);
      }
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al subir el acta');
    }
  }
}