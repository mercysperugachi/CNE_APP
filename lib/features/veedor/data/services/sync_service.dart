import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/acta_pendiente_entity.dart';
import '../../domain/repositories/veedor_repository.dart';
import '../datasources/acta_local_datasource.dart';
import 'dart:async';

class SyncReport {
  final int syncedCount;
  final int failedCount;
  final int totalPending;
  final List<String> errors;

  const SyncReport({
    required this.syncedCount,
    required this.failedCount,
    required this.totalPending,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
}

class SyncService {
  final ActaLocalDataSource _local;
  final VeedorRepository _remote;
  final ConnectivityService _connectivity;

  StreamController<SyncReport>? _controller;
  Timer? _periodicTimer;
  bool _isSyncing = false;

  SyncService(this._local, this._remote, this._connectivity);

  Stream<SyncReport> get syncStream {
    _controller ??= StreamController<SyncReport>.broadcast();
    return _controller!.stream;
  }

  void startAutoSync({Duration interval = const Duration(minutes: 2)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) => syncNow());
  }

  void stopAutoSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<SyncReport> syncNow() async {
    if (_isSyncing) {
      return const SyncReport(
        syncedCount: 0,
        failedCount: 0,
        totalPending: 0,
        errors: [],
      );
    }
    _isSyncing = true;
    try {
      final isOnline = await _connectivity.isOnline();
      if (!isOnline) {
        final pending = await _local.getAllPending();
        final report = SyncReport(
          syncedCount: 0,
          failedCount: pending.length,
          totalPending: pending.length,
          errors: const ['Sin conexión a internet'],
        );
        _controller?.add(report);
        return report;
      }

      final pending = await _local.getAllPending();
      final errors = <String>[];
      var synced = 0;
      var failed = 0;

      for (final acta in pending) {
        if (acta.estado == ActaSyncStatus.synced) continue;
        try {
          final updated = acta.copyWith(
            estado: ActaSyncStatus.syncing,
            updatedAt: DateTime.now(),
            clearLastError: true,
          );
          await _local.updateEstado(updated);

          final result = await _remote.submitActa(
            mesaId: acta.mesaId,
            recintoId: acta.recintoId,
            tipoActa: acta.tipoActa,
            novedades: acta.novedades,
            imagePath: acta.imageLocalPath ?? acta.imageRemoteUrl ?? '',
            votosCandidato1: acta.votosCandidato1,
            votosCandidato2: acta.votosCandidato2,
            votosCandidato3: acta.votosCandidato3,
            votosCandidato4: acta.votosCandidato4,
            votosCandidato5: acta.votosCandidato5,
            votosBlancos: acta.votosBlancos,
            votosNulos: acta.votosNulos,
            totalSufragantes: acta.totalSufragantes,
            latitud: acta.latitud,
            longitud: acta.longitud,
          );

          await result.fold(
            (failure) async {
              final errActa = updated.copyWith(
                estado: ActaSyncStatus.error,
                lastError: failure.message,
                attemptCount: acta.attemptCount + 1,
                updatedAt: DateTime.now(),
              );
              await _local.updateEstado(errActa);
              failed++;
              errors.add('Mesa ${acta.mesaId} - ${acta.tipoActa}: ${failure.message}');
            },
            (remote) async {
              final okActa = updated.copyWith(
                estado: ActaSyncStatus.synced,
                remoteId: remote.id,
                syncedAt: DateTime.now(),
                updatedAt: DateTime.now(),
                clearLastError: true,
              );
              await _local.updateEstado(okActa);
              synced++;
            },
          );
        } catch (e) {
          final errActa = acta.copyWith(
            estado: ActaSyncStatus.error,
            lastError: e.toString(),
            attemptCount: acta.attemptCount + 1,
            updatedAt: DateTime.now(),
          );
          await _local.updateEstado(errActa);
          failed++;
          errors.add('Mesa ${acta.mesaId} - ${acta.tipoActa}: $e');
        }
      }

      final report = SyncReport(
        syncedCount: synced,
        failedCount: failed,
        totalPending: pending.length,
        errors: errors,
      );
      _controller?.add(report);
      return report;
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _periodicTimer?.cancel();
    _controller?.close();
  }
}