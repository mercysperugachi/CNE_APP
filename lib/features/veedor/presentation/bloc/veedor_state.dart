import 'package:equatable/equatable.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/entities/acta_pendiente_entity.dart';
import '../../../recinto/domain/entities/mesa_entity.dart';

abstract class VeedorState extends Equatable {
  const VeedorState();

  @override
  List<Object?> get props => [];
}

class VeedorInitial extends VeedorState {}

class VeedorLoading extends VeedorState {}

class VeedorActaStatus extends VeedorState {
  final ActaEntity? acta; // Si es null, no ha reportado. Si tiene datos, ya reportó.

  const VeedorActaStatus(this.acta);

  @override
  List<Object?> get props => [acta];
}

class VeedorActaSubmittedSuccess extends VeedorState {
  final ActaEntity acta;

  const VeedorActaSubmittedSuccess(this.acta);

  @override
  List<Object?> get props => [acta];
}

class VeedorError extends VeedorState {
  final String message;

  const VeedorError(this.message);

  @override
  List<Object?> get props => [message];
}

class VeedorActasListLoaded extends VeedorState {
  final List<ActaEntity> actas;

  const VeedorActasListLoaded(this.actas);

  @override
  List<Object?> get props => [actas];
}

class VeedorMesasListLoaded extends VeedorState {
  final List<MesaEntity> mesas;

  const VeedorMesasListLoaded(this.mesas);

  @override
  List<Object?> get props => [mesas];
}

class VeedorActaSavedOffline extends VeedorState {
  final ActaPendienteEntity acta;

  const VeedorActaSavedOffline(this.acta);

  @override
  List<Object?> get props => [acta];
}

class VeedorPendingActasLoaded extends VeedorState {
  final List<ActaPendienteEntity> actas;

  const VeedorPendingActasLoaded(this.actas);

  @override
  List<Object?> get props => [actas];
}

class VeedorSyncResult extends VeedorState {
  final int synced;
  final int failed;
  final int totalPending;
  final List<String> errors;

  const VeedorSyncResult({
    required this.synced,
    required this.failed,
    required this.totalPending,
    required this.errors,
  });

  @override
  List<Object?> get props => [synced, failed, totalPending, errors];
}
