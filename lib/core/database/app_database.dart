import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  factory AppDatabase() => instance;
  AppDatabase._internal();

  static const String _dbName = 'veedor_offline.db';
  static const int _dbVersion = 1;

  static const String tableActasPendientes = 'actas_pendientes';
  static const String tableMesas = 'mesas_cache';
  static const String tableOrganizaciones = 'organizaciones_cache';

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _initDb();
  }

  Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = p.join(docsDir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableActasPendientes (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,
        mesa_id TEXT NOT NULL,
        recinto_id TEXT NOT NULL,
        tipo_acta TEXT NOT NULL,
        novedades TEXT,
        image_local_path TEXT,
        image_remote_url TEXT,
        votos_candidato_1 INTEGER NOT NULL DEFAULT 0,
        votos_candidato_2 INTEGER NOT NULL DEFAULT 0,
        votos_candidato_3 INTEGER NOT NULL DEFAULT 0,
        votos_candidato_4 INTEGER NOT NULL DEFAULT 0,
        votos_candidato_5 INTEGER NOT NULL DEFAULT 0,
        votos_blancos INTEGER NOT NULL DEFAULT 0,
        votos_nulos INTEGER NOT NULL DEFAULT 0,
        total_sufragantes INTEGER NOT NULL DEFAULT 0,
        latitud REAL NOT NULL DEFAULT 0.0,
        longitud REAL NOT NULL DEFAULT 0.0,
        estado TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT,
        last_error TEXT,
        attempt_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMesas (
        id TEXT PRIMARY KEY,
        numero_mesa TEXT NOT NULL,
        recinto_id TEXT NOT NULL,
        veedor_id TEXT,
        cached_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrganizaciones (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        siglas TEXT NOT NULL,
        candidato_nombres TEXT NOT NULL,
        candidato_apellidos TEXT NOT NULL,
        dignidad TEXT NOT NULL,
        numero_lista INTEGER NOT NULL,
        color_hex TEXT,
        logo_url TEXT,
        cached_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_actas_estado ON $tableActasPendientes(estado)
    ''');
    await db.execute('''
      CREATE INDEX idx_actas_mesa_tipo ON $tableActasPendientes(mesa_id, tipo_acta)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}