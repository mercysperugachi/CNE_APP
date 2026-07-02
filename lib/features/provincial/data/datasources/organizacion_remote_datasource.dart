import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../models/organizacion_model.dart';

abstract class OrganizacionRemoteDataSource {
  Future<List<OrganizacionModel>> getOrganizacionesByDignidad(String dignidad);
  Future<List<OrganizacionModel>> getAllOrganizaciones();
}

class AppwriteOrganizacionDataSource implements OrganizacionRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteOrganizacionDataSource(this.appwriteConfig);

  @override
  Future<List<OrganizacionModel>> getOrganizacionesByDignidad(String dignidad) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.organizacionesCollectionId,
        queries: [
          Query.equal('dignidad', dignidad),
          Query.orderAsc('numeroLista'),
          Query.limit(100),
        ],
      );
      return response.documents
          .map((d) => OrganizacionModel.fromJson(d.data))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener organizaciones');
    }
  }

  @override
  Future<List<OrganizacionModel>> getAllOrganizaciones() async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.organizacionesCollectionId,
        queries: [
          Query.orderAsc('dignidad'),
          Query.orderAsc('numeroLista'),
          Query.limit(100),
        ],
      );
      return response.documents
          .map((d) => OrganizacionModel.fromJson(d.data))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener organizaciones');
    }
  }
}