import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../models/mesa_model.dart';
import '../models/asignacion_model.dart';

abstract class RecintoRemoteDataSource {
  Future<List<MesaModel>> getMesasByRecinto(String recintoId);
  Future<MesaModel> createMesa({
    required String numeroMesa,
    required String recintoId,
  });
  Future<void> createVeedorMesa({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String mesaId,
    required String recintoId,
  });
  Future<List<AsignacionModel>> getAsignacionesByRecinto(String recintoId);
}

class AppwriteRecintoDataSource implements RecintoRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteRecintoDataSource(this.appwriteConfig);

  @override
  Future<List<MesaModel>> getMesasByRecinto(String recintoId) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.mesasCollectionId,
        queries: [
          Query.equal('recintoId', recintoId),
        ],
      );
      return response.documents.map((doc) => MesaModel.fromJson(doc.data)).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener mesas');
    }
  }

  @override
  Future<MesaModel> createMesa({
    required String numeroMesa,
    required String recintoId,
  }) async {
    try {
      final response = await appwriteConfig.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.mesasCollectionId,
        documentId: ID.unique(),
        data: {
          'numeroMesa': numeroMesa,
          'recintoId': recintoId,
        },
      );
      return MesaModel.fromJson(response.data);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear mesa');
    }
  }

  @override
  Future<void> createVeedorMesa({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String mesaId,
    required String recintoId,
  }) async {
    try {
      // 1. Buscar si ya existe un usuario con esta cédula
      String authId = '';
      bool esNuevo = true;
      try {
        final existing = await appwriteConfig.databases.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.usersCollectionId,
          queries: [Query.equal('cedula', cedula.trim())],
        );
        if (existing.documents.isNotEmpty) {
          authId = existing.documents.first.$id;
          esNuevo = false;
          await appwriteConfig.databases.updateDocument(
            databaseId: AppConstants.databaseId,
            collectionId: AppConstants.usersCollectionId,
            documentId: authId,
            data: {
              'telefono': telefono,
              'correo': correo,
              'rol': AppConstants.rolVeedor,
              'recintoId': recintoId,
            },
          );
        }
      } catch (_) {
        // Continuar con creación nueva
      }

      if (esNuevo) {
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
            authId = cedula;
          } else {
            throw AppwriteException(response.body, response.statusCode);
          }
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
              'rol': AppConstants.rolVeedor,
              'recintoId': recintoId,
              'requiresPasswordChange': true,
            },
          );
        } on AppwriteException catch (e) {
          if (e.code == 409 || (e.message ?? '').contains('already exists')) {
            authId = cedula;
          } else {
            rethrow;
          }
        } catch (e) {
          throw Exception('Error HTTP: $e');
        }
      }

      if (authId.isEmpty) {
        throw Exception('No se pudo obtener el ID del veedor');
      }

      // 2. Desactivar cualquier asignación previa del veedor para esta mesa
      final existingAsign = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.asignacionesCollectionId,
        queries: [
          Query.equal('veedorId', authId),
          Query.equal('mesaId', mesaId),
        ],
      );
      for (final doc in existingAsign.documents) {
        try {
          await appwriteConfig.databases.updateDocument(
            databaseId: AppConstants.databaseId,
            collectionId: AppConstants.asignacionesCollectionId,
            documentId: doc.$id,
            data: {'activa': false},
          );
        } catch (_) {}
      }

      // 3. Crear la nueva asignación (un veedor puede tener N mesas)
      await appwriteConfig.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.asignacionesCollectionId,
        documentId: ID.unique(),
        data: {
          'veedorId': authId,
          'mesaId': mesaId,
          'recintoId': recintoId,
          'fechaAsignacion': DateTime.now().toIso8601String(),
          'activa': true,
        },
      );

      // 4. Mantener compat: actualizar la Mesa con el último veedor (referencial)
      try {
        await appwriteConfig.databases.updateDocument(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.mesasCollectionId,
          documentId: mesaId,
          data: {
            'veedorId': authId,
          },
        );
      } catch (_) {
        // Si la mesa no permite update, no es crítico
      }
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear veedor');
    }
  }

  @override
  Future<List<AsignacionModel>> getAsignacionesByRecinto(String recintoId) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.asignacionesCollectionId,
        queries: [
          Query.equal('recintoId', recintoId),
          Query.equal('activa', true),
        ],
      );
      return response.documents
          .map((d) => AsignacionModel.fromJson(d.data))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener asignaciones');
    }
  }
}