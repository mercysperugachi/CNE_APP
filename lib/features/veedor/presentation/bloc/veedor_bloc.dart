import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/sync_service.dart';
import '../../domain/usecases/get_acta_mesa_usecase.dart';
import '../../domain/usecases/get_actas_by_mesa_usecase.dart';
import '../../domain/usecases/get_mesas_by_veedor_usecase.dart';
import '../../domain/usecases/get_pending_actas_usecase.dart';
import '../../domain/usecases/save_acta_offline_usecase.dart';
import '../../domain/usecases/submit_acta_usecase.dart';
import 'veedor_event.dart';
import 'veedor_state.dart';

class VeedorBloc extends Bloc<VeedorEvent, VeedorState> {
  final GetActaMesaUseCase getActaMesaUseCase;
  final GetActasByMesaUseCase getActasByMesaUseCase;
  final GetMesasByVeedorUseCase getMesasByVeedorUseCase;
  final SubmitActaUseCase submitActaUseCase;
  final SaveActaOfflineUseCase saveActaOfflineUseCase;
  final GetPendingActasUseCase getPendingActasUseCase;
  final SyncService syncService;

  VeedorBloc({
    required this.getActaMesaUseCase,
    required this.getActasByMesaUseCase,
    required this.getMesasByVeedorUseCase,
    required this.submitActaUseCase,
    required this.saveActaOfflineUseCase,
    required this.getPendingActasUseCase,
    required this.syncService,
  }) : super(VeedorInitial()) {
    on<CheckActaStatusEvent>(_onCheckActaStatus);
    on<LoadActasByMesaEvent>(_onLoadActasByMesa);
    on<LoadMesasByVeedorEvent>(_onLoadMesasByVeedor);
    on<SubmitActaEvent>(_onSubmitActa);
    on<SaveActaOfflineEvent>(_onSaveActaOffline);
    on<LoadPendingActasEvent>(_onLoadPendingActas);
    on<SyncPendingActasEvent>(_onSyncPendingActas);
  }

  Future<void> _onCheckActaStatus(CheckActaStatusEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await getActaMesaUseCase(event.mesaId, event.tipoActa);
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (acta) => emit(VeedorActaStatus(acta)),
    );
  }

  Future<void> _onLoadActasByMesa(LoadActasByMesaEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await getActasByMesaUseCase(event.mesaId);
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (actas) => emit(VeedorActasListLoaded(actas)),
    );
  }

  Future<void> _onLoadMesasByVeedor(LoadMesasByVeedorEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await getMesasByVeedorUseCase(event.veedorId);
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (mesas) => emit(VeedorMesasListLoaded(mesas)),
    );
  }

  Future<void> _onSubmitActa(SubmitActaEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await submitActaUseCase(
      mesaId: event.mesaId,
      recintoId: event.recintoId,
      tipoActa: event.tipoActa,
      novedades: event.novedades,
      imagePath: event.imagePath,
      votosCandidato1: event.votosCandidato1,
      votosCandidato2: event.votosCandidato2,
      votosCandidato3: event.votosCandidato3,
      votosCandidato4: event.votosCandidato4,
      votosCandidato5: event.votosCandidato5,
      votosBlancos: event.votosBlancos,
      votosNulos: event.votosNulos,
      totalSufragantes: event.totalSufragantes,
      latitud: event.latitud,
      longitud: event.longitud,
    );
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (acta) => emit(VeedorActaSubmittedSuccess(acta)),
    );
  }

  Future<void> _onSaveActaOffline(SaveActaOfflineEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await saveActaOfflineUseCase(event.acta);
    await result.fold(
      (failure) async => emit(VeedorError(failure.message)),
      (acta) async {
        emit(VeedorActaSavedOffline(acta));
        // Intentar sincronizar inmediatamente si hay conexión
        unawaited(syncService.syncNow());
      },
    );
  }

  Future<void> _onLoadPendingActas(LoadPendingActasEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final result = await getPendingActasUseCase();
    result.fold(
      (failure) => emit(VeedorError(failure.message)),
      (actas) => emit(VeedorPendingActasLoaded(actas)),
    );
  }

  Future<void> _onSyncPendingActas(SyncPendingActasEvent event, Emitter<VeedorState> emit) async {
    emit(VeedorLoading());
    final report = await syncService.syncNow();
    emit(VeedorSyncResult(
      synced: report.syncedCount,
      failed: report.failedCount,
      totalPending: report.totalPending,
      errors: report.errors,
    ));
  }
}

void unawaited(Future<dynamic> future) {
  future.catchError((Object e) {
    // Silenciar errores en sync background
  });
}
