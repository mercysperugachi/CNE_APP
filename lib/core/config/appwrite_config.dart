import 'package:appwrite/appwrite.dart';

class AppwriteConfig {
  static const String projectId = '6a3dfba4001565b60d12';
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';

  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  AppwriteConfig() {
    client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}