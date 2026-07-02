class AppConstants {
  // Appwrite Project & DB
  static const String backendUrl = 'https://backend-to-email.onrender.com'; // Backend de correos desplegado
  static const String projectId = '6a3d88c70024b0b40bab';
  static const String databaseId = '6a3d8e8a003536d98c4a';
  static const String apiKey = 'standard_ec07e3f1b072d14ed82a441240c90516cc71b5a442081247f12e226fce1bcc80dd3e59bd2d3ddf47df77b503dbdced452081be3833c1c7d10eaa8cbb81616a54d44d0e475df69e3ee6414bbbdffc3ea05b5c45d42a773007c925bc2c40c08fe8fb044d228c3be832b9dccf0e7245f827d92bfbbd9c1f81c5a758b4bce81bfd30';

  // Colecciones
  static const String usersCollectionId = 'users';
  static const String recintosCollectionId = 'recintos';
  static const String mesasCollectionId = 'mesas';
  static const String asignacionesCollectionId = 'asignaciones';
  static const String actasCollectionId = 'actas';
  static const String organizacionesCollectionId = 'organizaciones';
  static const String storageBucketId = '6a418301003dc80f8021';

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