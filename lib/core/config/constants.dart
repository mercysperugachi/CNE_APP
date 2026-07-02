class AppConstants {
  // Appwrite Project & DB
  static const String backendUrl = 'https://notificador-alertas-api.onrender.com'; // Backend de correos desplegado
  static const String projectId = '6a3dfba4001565b60d12';
  static const String databaseId = '6a46a0d0001346d3be26';
  static const String apiKey = 'standard_697582eb0cbbbc307bfa89253f43d282ed203c2e1589e1b0ff563418395487aeb056b567506234d5205d441ca21edf4f13b9c198ef46936fb205ec728c95a0baed4dc16d4ff8cf8ace97794518b4e3d9c34a1d97300e4bfeb6604aa4b5474ae847010926ba32560d81ce388fb630bdeb3b3788f6343d722c326c018b89f630bd';

  // Colecciones
  static const String usersCollectionId = 'users';
  static const String recintosCollectionId = 'recintos';
  static const String mesasCollectionId = 'mesas';
  static const String asignacionesCollectionId = 'asignaciones';
  static const String actasCollectionId = 'actas';
  static const String organizacionesCollectionId = 'organizaciones';
  static const String storageBucketId = '6a46a50b003a63c43539';

  // Roles
  static const String rolProvincial = 'provincial';
  static const String rolRecinto = 'recinto';
  static const String rolVeedor = 'veedor';

  // Dignidades
  static const String dignidadAlcalde = 'Alcalde';
  static const String dignidadPrefecto = 'Prefecto';

  // Sincronización offline
  static const Duration syncInterval = Duration(minutes: 2);
  static const int maxSyncAttempts = 5;
}