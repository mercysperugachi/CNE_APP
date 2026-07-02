import '../../domain/entities/acta_entity.dart';

class ActaModel extends ActaEntity {
  const ActaModel({
    required super.id,
    required super.mesaId,
    required super.recintoId,
    required super.tipoActa,
    required super.novedades,
    required super.fotoUrl,
    required super.votosCandidato1,
    required super.votosCandidato2,
    required super.votosCandidato3,
    required super.votosCandidato4,
    required super.votosCandidato5,
    required super.votosBlancos,
    required super.votosNulos,
    required super.totalSufragantes,
    required super.latitud,
    required super.longitud,
  });

  factory ActaModel.fromJson(Map<String, dynamic> json) {
    return ActaModel(
      id: json['\$id'] ?? '',
      mesaId: json['mesaId'] ?? '',
      recintoId: json['recintoId'] ?? '',
      tipoActa: json['tipoActa'] ?? 'Alcalde',
      novedades: json['novedades'] ?? '',
      fotoUrl: json['fotoUrl'] ?? '',
      votosCandidato1: json['votosCandidato1'] ?? 0,
      votosCandidato2: json['votosCandidato2'] ?? 0,
      votosCandidato3: json['votosCandidato3'] ?? 0,
      votosCandidato4: json['votosCandidato4'] ?? 0,
      votosCandidato5: json['votosCandidato5'] ?? 0,
      votosBlancos: json['votosBlancos'] ?? 0,
      votosNulos: json['votosNulos'] ?? 0,
      totalSufragantes: json['totalSufragantes'] ?? 0,
      latitud: (json['latitud'] ?? 0.0).toDouble(),
      longitud: (json['longitud'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mesaId': mesaId,
      'recintoId': recintoId,
      'tipoActa': tipoActa,
      'novedades': novedades,
      'fotoUrl': fotoUrl,
      'votosCandidato1': votosCandidato1,
      'votosCandidato2': votosCandidato2,
      'votosCandidato3': votosCandidato3,
      'votosCandidato4': votosCandidato4,
      'votosCandidato5': votosCandidato5,
      'votosBlancos': votosBlancos,
      'votosNulos': votosNulos,
      'totalSufragantes': totalSufragantes,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}