import '../../../../core/database/app_database.dart';
import '../../domain/entities/acta_pendiente_entity.dart';

abstract class ActaLocalDataSource {
  Future<int> saveActa(ActaPendienteEntity acta);
  Future<ActaPendienteEntity?> getActa(String mesaId, String tipoActa);
  Future<List<ActaPendienteEntity>> getAllPending();
  Future<ActaPendienteEntity?> getByLocalId(int localId);
  Future<void> updateEstado(ActaPendienteEntity acta);
  Future<void> deleteActa(int localId);
  Future<List<ActaPendienteEntity>> getActasByMesa(String mesaId);
}

class SqfliteActaLocalDataSource implements ActaLocalDataSource {
  final AppDatabase _db;

  SqfliteActaLocalDataSource(this._db);

  @override
  Future<int> saveActa(ActaPendienteEntity acta) async {
    final db = await _db.database;
    final data = _toRow(acta);
    if (acta.localId == null) {
      return db.insert(AppDatabase.tableActasPendientes, data);
    } else {
      await db.update(
        AppDatabase.tableActasPendientes,
        data,
        where: 'local_id = ?',
        whereArgs: [acta.localId],
      );
      return acta.localId!;
    }
  }

  @override
  Future<ActaPendienteEntity?> getActa(String mesaId, String tipoActa) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.tableActasPendientes,
      where: 'mesa_id = ? AND tipo_acta = ?',
      whereArgs: [mesaId, tipoActa],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<ActaPendienteEntity>> getAllPending() async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.tableActasPendientes,
      where: "estado IN ('pending', 'error')",
      orderBy: 'created_at ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<ActaPendienteEntity?> getByLocalId(int localId) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.tableActasPendientes,
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<void> updateEstado(ActaPendienteEntity acta) async {
    final db = await _db.database;
    await db.update(
      AppDatabase.tableActasPendientes,
      _toRow(acta),
      where: 'local_id = ?',
      whereArgs: [acta.localId],
    );
  }

  @override
  Future<void> deleteActa(int localId) async {
    final db = await _db.database;
    await db.delete(
      AppDatabase.tableActasPendientes,
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  @override
  Future<List<ActaPendienteEntity>> getActasByMesa(String mesaId) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.tableActasPendientes,
      where: 'mesa_id = ?',
      whereArgs: [mesaId],
      orderBy: 'updated_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Map<String, dynamic> _toRow(ActaPendienteEntity a) {
    return {
      if (a.localId != null) 'local_id': a.localId,
      'remote_id': a.remoteId,
      'mesa_id': a.mesaId,
      'recinto_id': a.recintoId,
      'tipo_acta': a.tipoActa,
      'novedades': a.novedades,
      'image_local_path': a.imageLocalPath,
      'image_remote_url': a.imageRemoteUrl,
      'votos_candidato_1': a.votosCandidato1,
      'votos_candidato_2': a.votosCandidato2,
      'votos_candidato_3': a.votosCandidato3,
      'votos_candidato_4': a.votosCandidato4,
      'votos_candidato_5': a.votosCandidato5,
      'votos_blancos': a.votosBlancos,
      'votos_nulos': a.votosNulos,
      'total_sufragantes': a.totalSufragantes,
      'latitud': a.latitud,
      'longitud': a.longitud,
      'estado': a.estado.name,
      'created_at': a.createdAt.toIso8601String(),
      'updated_at': a.updatedAt.toIso8601String(),
      'synced_at': a.syncedAt?.toIso8601String(),
      'last_error': a.lastError,
      'attempt_count': a.attemptCount,
    };
  }

  ActaPendienteEntity _fromRow(Map<String, dynamic> row) {
    return ActaPendienteEntity(
      localId: row['local_id'] as int?,
      remoteId: row['remote_id'] as String?,
      mesaId: row['mesa_id'] as String,
      recintoId: row['recinto_id'] as String,
      tipoActa: row['tipo_acta'] as String,
      novedades: (row['novedades'] as String?) ?? '',
      imageLocalPath: row['image_local_path'] as String?,
      imageRemoteUrl: row['image_remote_url'] as String?,
      votosCandidato1: (row['votos_candidato_1'] as int?) ?? 0,
      votosCandidato2: (row['votos_candidato_2'] as int?) ?? 0,
      votosCandidato3: (row['votos_candidato_3'] as int?) ?? 0,
      votosCandidato4: (row['votos_candidato_4'] as int?) ?? 0,
      votosCandidato5: (row['votos_candidato_5'] as int?) ?? 0,
      votosBlancos: (row['votos_blancos'] as int?) ?? 0,
      votosNulos: (row['votos_nulos'] as int?) ?? 0,
      totalSufragantes: (row['total_sufragantes'] as int?) ?? 0,
      latitud: (row['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (row['longitud'] as num?)?.toDouble() ?? 0.0,
      estado: ActaSyncStatus.values.firstWhere(
        (e) => e.name == (row['estado'] as String? ?? 'pending'),
        orElse: () => ActaSyncStatus.pending,
      ),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      syncedAt: row['synced_at'] != null
          ? DateTime.parse(row['synced_at'] as String)
          : null,
      lastError: row['last_error'] as String?,
      attemptCount: (row['attempt_count'] as int?) ?? 0,
    );
  }
}