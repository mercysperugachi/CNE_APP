// lib/core/utils/db_seeder.dart
import 'package:appwrite/appwrite.dart';
import '../config/constants.dart'; // Ajusta esta ruta según tu proyecto

class DatabaseSeeder {
  final Databases databases;

  DatabaseSeeder(Client client) : databases = Databases(client);

  Future<void> cargarDatosDePrueba() async {
    try {
      print("⏳ Iniciando carga de datos en Appwrite...");

      // 1. Cargar Centros de Votación (Recintos)
      final centro1 = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
        documentId: ID.unique(),
        data: {
          'canton': 'Quito',
          'parroquia': 'Iñaquito',
          'nombre': 'Colegio Nacional Central',
          'cantidadMesas': '5', // String si lo configuraste todo como String
        },
      );

      final centro2 = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
        documentId: ID.unique(),
        data: {
          'canton': 'Guayaquil',
          'parroquia': 'Tarqui',
          'nombre': 'Universidad Estatal',
          'cantidadMesas': '10',
        },
      );

      print("✅ Centros de votación creados.");

      // 2. Cargar Juntas Receptoras (Mesas) asociadas al Centro 1
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.mesasCollectionId,
        documentId: ID.unique(),
        data: {
          'numeroMesa': '1M',
          'recintoId': centro1.$id,
        },
      );

      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.mesasCollectionId,
        documentId: ID.unique(),
        data: {
          'numeroMesa': '2F',
          'recintoId': centro1.$id,
        },
      );

      print("✅ Juntas receptoras creados.");

      // 3. Cargar Listas Políticas (Candidatos)
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.organizacionesCollectionId,
        documentId: ID.unique(),
        data: {
          'nombre': 'Movimiento Renovación',
          'siglas': 'MR',
          'candidatoNombres': 'Carlos',
          'candidatoApellidos': 'Mendoza',
          'dignidad': AppConstants.dignidadAlcalde,
          'numeroLista': '1',
          'colorHex': 'FF0000', // Rojo
        },
      );

      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.organizacionesCollectionId,
        documentId: ID.unique(),
        data: {
          'nombre': 'Frente de Esperanza',
          'siglas': 'FE',
          'candidatoNombres': 'María',
          'candidatoApellidos': 'Gómez',
          'dignidad': AppConstants.dignidadAlcalde,
          'numeroLista': '5',
          'colorHex': '0000FF', // Azul
        },
      );

      print("✅ Listas políticas creadas.");
      print("🎉 ¡TODOS LOS DATOS FUERON CARGADOS EXITOSAMENTE!");

    } on AppwriteException catch (e) {
      print("❌ Error de Appwrite: ${e.message}");
    } catch (e) {
      print("❌ Error inesperado: $e");
    }
  }
}