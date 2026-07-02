import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../models/recinto_model.dart';

abstract class ProvincialRemoteDataSource {
  Future<List<RecintoModel>> getRecintos();
  Future<RecintoModel> createRecinto({
    required String canton,
    required String parroquia,
    required String nombre,
    required int cantidadMesas,
  });
  Future<void> createCoordinadorRecinto({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String recintoId,
  });
  Future<int> getActasCountByRecinto(String recintoId);
}

class AppwriteProvincialDataSource implements ProvincialRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteProvincialDataSource(this.appwriteConfig);

  @override
  Future<List<RecintoModel>> getRecintos() async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
      );
      return response.documents.map((doc) => RecintoModel.fromJson(doc.data)).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener recintos');
    }
  }

  @override
  Future<RecintoModel> createRecinto({
    required String canton,
    required String parroquia,
    required String nombre,
    required int cantidadMesas,
  }) async {
    try {
      final response = await appwriteConfig.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
        documentId: ID.unique(),
        data: {
          'canton': canton,
          'parroquia': parroquia,
          'nombre': nombre,
          'cantidadMesas': cantidadMesas,
        },
      );
      return RecintoModel.fromJson(response.data);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear recinto');
    }
  }

  @override
  Future<void> createCoordinadorRecinto({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String recintoId,
  }) async {
    try {
      // 1. Crear el Auth de Appwrite (usando API Server para evitar 401 Unauthorized)
      String authId = '';
      try {
        final response = await http.post(
          Uri.parse('${AppwriteConfig.endpoint}/users'),
          headers: {
            'Content-Type': 'application/json',
            'X-Appwrite-Project': AppConstants.projectId,
            'X-Appwrite-Key': AppConstants.apiKey,
          },
          body: jsonEncode({
            'userId': cedula,
            'email': correo,
            'password': 'Ecuador2026',
            'name': '$nombres $apellidos',
          }),
        );
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          authId = data['\$id'];

          // Enviar correo de verificación (a través del mini-backend) - Sin await para no bloquear la UI si Render está dormido
          http.post(
            Uri.parse('${AppConstants.backendUrl}/api/auth/send-verification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': correo, 'userId': authId}),
          ).timeout(const Duration(seconds: 30)).catchError((e) {
            print('Error al enviar correo de verificación: $e');
            return http.Response('', 500);
          });
        } else if (response.statusCode == 409) {
          // El usuario ya existe en Auth, usamos la cédula como ID
          authId = cedula;
        } else {
          throw Exception('Error del servidor Appwrite: ${response.body}');
        }
      } catch (e) {
        throw Exception('Error de conexión al crear usuario: $e');
      }

      // 2. Crear el documento en la colección Users
      await appwriteConfig.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: authId,
        data: {
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'correo': correo,
          'rol': AppConstants.rolRecinto,
          'recintoId': recintoId,
          'requiresPasswordChange': true,
        },
      );

      // 3. Actualizar el Recinto para asignarle este coordinador
      await appwriteConfig.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
        documentId: recintoId,
        data: {
          'coordinadorId': authId,
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear coordinador de recinto');
    }
  }

  @override
  Future<int> getActasCountByRecinto(String recintoId) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.actasCollectionId,
        queries: [
          Query.equal('recintoId', recintoId),
          Query.limit(1), // Solo queremos el total, no descargar todos los datos
        ],
      );
      return response.total;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener conteo de actas');
    }
  }
}