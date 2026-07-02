import 'package:equatable/equatable.dart';

class ActaEntity extends Equatable {
  final String id;
  final String mesaId;
  final String recintoId;
  final String tipoActa;
  final String novedades;
  final String fotoUrl;
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

  const ActaEntity({
    required this.id,
    required this.mesaId,
    required this.recintoId,
    required this.tipoActa,
    required this.novedades,
    required this.fotoUrl,
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
        id,
        mesaId,
        recintoId,
        tipoActa,
        novedades,
        fotoUrl,
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