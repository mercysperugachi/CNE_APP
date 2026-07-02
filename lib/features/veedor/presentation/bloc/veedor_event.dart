import 'package:equatable/equatable.dart';
import '../../domain/entities/acta_pendiente_entity.dart';

abstract class VeedorEvent extends Equatable {
  const VeedorEvent();

  @override
  List<Object?> get props => [];
}

class LoadActasByMesaEvent extends VeedorEvent {
  final String mesaId;

  const LoadActasByMesaEvent(this.mesaId);

  @override
  List<Object?> get props => [mesaId];
}

class LoadMesasByVeedorEvent extends VeedorEvent {
  final String veedorId;

  const LoadMesasByVeedorEvent(this.veedorId);

  @override
  List<Object?> get props => [veedorId];
}

class CheckActaStatusEvent extends VeedorEvent {
  final String mesaId;
  final String tipoActa;

  const CheckActaStatusEvent(this.mesaId, this.tipoActa);

  @override
  List<Object?> get props => [mesaId, tipoActa];
}

class SubmitActaEvent extends VeedorEvent {
  final String mesaId;
  final String recintoId;
  final String tipoActa;
  final String novedades;
  final String imagePath;
  final int votosCandidato1;
  final int votosCandidato2;
  final int votosCandidato3;
  final int votosCandidato4;
  final int votosCandidato5;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final double latitud;
  final double longitud;

  const SubmitActaEvent({
    required this.mesaId,
    required this.recintoId,
    required this.tipoActa,
    required this.novedades,
    required this.imagePath,
    required this.votosCandidato1,
    required this.votosCandidato2,
    required this.votosCandidato3,
    required this.votosCandidato4,
    required this.votosCandidato5,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    required this.latitud,
    required this.longitud,
  });

  @override
  List<Object?> get props => [
        mesaId,
        recintoId,
        tipoActa,
        novedades,
        imagePath,
        votosCandidato1,
        votosCandidato2,
        votosCandidato3,
        votosCandidato4,
        votosCandidato5,
        votosBlancos,
        votosNulos,
        totalSufragantes,
        latitud,
        longitud,
      ];
}

class SaveActaOfflineEvent extends VeedorEvent {
  final ActaPendienteEntity acta;

  const SaveActaOfflineEvent(this.acta);

  @override
  List<Object?> get props => [acta];
}

class SyncPendingActasEvent extends VeedorEvent {}

class LoadPendingActasEvent extends VeedorEvent {}
