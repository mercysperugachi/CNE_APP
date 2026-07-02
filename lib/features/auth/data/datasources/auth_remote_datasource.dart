import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String cedula, String password);
  Future<UserModel> getCurrentUser();
  Future<void> changePassword(String newPassword);
  Future<void> recoverPassword(String cedula);
  Future<void> logout();
}

class AppwriteAuthDataSource implements AuthRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteAuthDataSource(this.appwriteConfig);

  @override
  Future<UserModel> login(String cedula, String password) async {
    try {
      // 1. Buscar el correo real del usuario basado en la cédula
      final docs = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [Query.equal('cedula', cedula.trim())],
      );

      if (docs.documents.isEmpty) {
        throw Exception('No se encontró ninguna cuenta con esa cédula.');
      }

      final email = docs.documents.first.data['correo'] as String?;
      if (email == null || email.isEmpty) {
        throw Exception('El usuario no tiene un correo válido registrado.');
      }

      // 2. Iniciar sesión con el correo real
      await appwriteConfig.account.createEmailPasswordSession(
        email: email,
        password: password.trim(),
      );

      // 3. Verificar si el correo está confirmado
      final accountData = await appwriteConfig.account.get();
      if (!accountData.emailVerification) {
        // Borramos la sesión para no dejarlo logueado
        await appwriteConfig.account.deleteSession(sessionId: 'current');
        throw Exception('Debes confirmar tu correo antes de poder iniciar sesión. Revisa tu bandeja de entrada.');
      }

      return getCurrentUser();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error de autenticación');
    }
  }

@override
  Future<UserModel> getCurrentUser() async {
    try {
      // Obtenemos los datos base de autenticación
      final accountData = await appwriteConfig.account.get();
      
      // En lugar de buscar por ID de documento, buscamos por el correo de la sesión actual
      final docs = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [Query.equal('correo', accountData.email)],
      );

      if (docs.documents.isEmpty) {
        throw Exception('No se encontró el perfil de este usuario en la base de datos.');
      }

      return UserModel.fromJson(docs.documents.first.data);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener usuario actual');
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      // 1. Cambiar la clave en Appwrite Auth
      await appwriteConfig.account.updatePassword(
        password: newPassword,
        oldPassword: 'Ecuador2026',
      );
      
      // 2. Actualizar el flag en la base de datos
      final accountData = await appwriteConfig.account.get();
      await appwriteConfig.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: accountData.$id,
        data: {'requiresPasswordChange': false},
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cambiar la contraseña');
    }
  }

  @override
  Future<void> recoverPassword(String cedula) async {
    try {
      final docs = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [Query.equal('cedula', cedula.trim())],
      );

      if (docs.documents.isEmpty) {
        throw Exception('No se encontró ninguna cuenta con esa cédula.');
      }

      final email = docs.documents.first.data['correo'] as String?;
      if (email == null || email.isEmpty) {
        throw Exception('El usuario no tiene un correo válido registrado para recuperar la contraseña.');
      }

      // Call to the new mini-backend
      final response = await http.post(
        Uri.parse('${AppConstants.backendUrl}/api/auth/send-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 45), onTimeout: () {
        throw Exception('El servidor está tardando mucho en responder. Por favor, intenta de nuevo en un minuto.');
      });

      if (response.statusCode != 200) {
        throw Exception('Error del servidor de correos');
      }
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al enviar correo de recuperación');
    } catch (e) {
      throw Exception('Error al enviar correo de recuperación: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await appwriteConfig.account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cerrar sesión');
    }
  }
}