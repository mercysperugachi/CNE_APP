import 'package:equatable/equatable.dart';

enum ActaSyncStatus { pending, syncing, synced, error }

class ActaPendienteEntity extends Equatable {
  final int? localId;
  final String? remoteId;
  final String mesaId;
  final String recintoId;
  final String tipoActa;
  final String novedades;
  final String? imageLocalPath;
  final String? imageRemoteUrl;
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
  final ActaSyncStatus estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  final String? lastError;
  final int attemptCount;

  const ActaPendienteEntity({
    this.localId,
    this.remoteId,
    required this.mesaId,
    required this.recintoId,
    required this.tipoActa,
    this.novedades = '',
    this.imageLocalPath,
    this.imageRemoteUrl,
    this.votosCandidato1 = 0,
    this.votosCandidato2 = 0,
    this.votosCandidato3 = 0,
    this.votosCandidato4 = 0,
    this.votosCandidato5 = 0,
    this.votosBlancos = 0,
    this.votosNulos = 0,
    this.totalSufragantes = 0,
    this.latitud = 0.0,
    this.longitud = 0.0,
    this.estado = ActaSyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.lastError,
    this.attemptCount = 0,
  });

  ActaPendienteEntity copyWith({
    int? localId,
    String? remoteId,
    String? mesaId,
    String? recintoId,
    String? tipoActa,
    String? novedades,
    String? imageLocalPath,
    String? imageRemoteUrl,
    int? votosCandidato1,
    int? votosCandidato2,
    int? votosCandidato3,
    int? votosCandidato4,
    int? votosCandidato5,
    int? votosBlancos,
    int? votosNulos,
    int? totalSufragantes,
    double? latitud,
    double? longitud,
    ActaSyncStatus? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    String? lastError,
    int? attemptCount,
    bool clearLastError = false,
  }) {
    return ActaPendienteEntity(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      mesaId: mesaId ?? this.mesaId,
      recintoId: recintoId ?? this.recintoId,
      tipoActa: tipoActa ?? this.tipoActa,
      novedades: novedades ?? this.novedades,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      imageRemoteUrl: imageRemoteUrl ?? this.imageRemoteUrl,
      votosCandidato1: votosCandidato1 ?? this.votosCandidato1,
      votosCandidato2: votosCandidato2 ?? this.votosCandidato2,
      votosCandidato3: votosCandidato3 ?? this.votosCandidato3,
      votosCandidato4: votosCandidato4 ?? this.votosCandidato4,
      votosCandidato5: votosCandidato5 ?? this.votosCandidato5,
      votosBlancos: votosBlancos ?? this.votosBlancos,
      votosNulos: votosNulos ?? this.votosNulos,
      totalSufragantes: totalSufragantes ?? this.totalSufragantes,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  int get sumaVotos =>
      votosCandidato1 +
      votosCandidato2 +
      votosCandidato3 +
      votosCandidato4 +
      votosCandidato5 +
      votosBlancos +
      votosNulos;

  @override
  List<Object?> get props => [
        localId,
        remoteId,
        mesaId,
        recintoId,
        tipoActa,
        novedades,
        imageLocalPath,
        imageRemoteUrl,
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
        estado,
        createdAt,
        updatedAt,
        syncedAt,
        lastError,
        attemptCount,
      ];
}