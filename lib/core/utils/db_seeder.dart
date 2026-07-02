// lib/core/utils/db_seeder.dart
import 'package:appwrite/appwrite.dart';
import '../config/constants.dart'; 

class DatabaseSeeder {
  final Databases databases;

  DatabaseSeeder(Client client) : databases = Databases(client);

  Future<void> cargarDatosDePrueba() async {
    try {
      print("⏳ Iniciando carga de datos REALES de Pedro Moncayo...");

      // 1. Cargar Centros de Votación Reales (Pedro Moncayo)
      final centro1 = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
        documentId: ID.unique(),
        data: {
          'canton': 'Pedro Moncayo',
          'parroquia': 'Tabacundo',
          'nombre': 'Unidad Educativa Tabacundo (Juan Montalvo y G. Suárez)',
          'cantidadMesas': '15', 
        },
      );

      final centro2 = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
        documentId: ID.unique(),
        data: {
          'canton': 'Pedro Moncayo',
          'parroquia': 'Tabacundo',
          'nombre': 'Unidad Educativa del Milenio Cochasqui',
          'cantidadMesas': '10',
        },
      );

      final centro3 = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.recintosCollectionId,
        documentId: ID.unique(),
        data: {
          'canton': 'Pedro Moncayo',
          'parroquia': 'Malchinguí',
          'nombre': 'Escuela de Educación Básica Malchinguí',
          'cantidadMesas': '7',
        },
      );

      print("✅ Recintos oficiales del CNE creados.");

      // 2. Cargar Juntas Receptoras (Mesas) asignadas a Tabacundo
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

      print("✅ Juntas receptoras reales creadas.");

      // 3. Cargar Listas Políticas (Candidatos simulados para el cantón)
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.organizacionesCollectionId,
        documentId: ID.unique(),
        data: {
          'nombre': 'Movimiento Alianza Pedro Moncayo',
          'siglas': 'APM',
          'candidatoNombres': 'Roberto',
          'candidatoApellidos': 'Andrade',
          'dignidad': 'Alcalde',
          'numeroLista': '12',
          'colorHex': '28A745', // Verde
        },
      );

      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.organizacionesCollectionId,
        documentId: ID.unique(),
        data: {
          'nombre': 'Frente Ciudadano Tabacundo',
          'siglas': 'FCT',
          'candidatoNombres': 'Lucía',
          'candidatoApellidos': 'Mendoza',
          'dignidad': 'Alcalde',
          'numeroLista': '6',
          'colorHex': '0056B3', // Azul
        },
      );

      print("✅ Listas políticas creadas.");
      print("🎉 ¡DATOS DE PEDRO MONCAYO CARGADOS EXITOSAMENTE!");

    } on AppwriteException catch (e) {
      print("❌ Error de Appwrite: ${e.message}");
    } catch (e) {
      print("❌ Error inesperado: $e");
    }
  }
}