import '../../domain/entities/organizacion_entity.dart';

class OrganizacionModel extends OrganizacionEntity {
  const OrganizacionModel({
    required super.id,
    required super.nombre,
    required super.siglas,
    required super.candidatoNombres,
    required super.candidatoApellidos,
    required super.dignidad,
    required super.numeroLista,
    super.colorHex,
    super.logoUrl,
  });

  factory OrganizacionModel.fromJson(Map<String, dynamic> json) {
    return OrganizacionModel(
      id: json['\$id'] ?? '',
      nombre: json['nombre'] ?? '',
      siglas: json['siglas'] ?? '',
      candidatoNombres: json['candidatoNombres'] ?? '',
      candidatoApellidos: json['candidatoApellidos'] ?? '',
      dignidad: json['dignidad'] ?? 'Alcalde',
      numeroLista: json['numeroLista'] ?? 0,
      colorHex: json['colorHex'],
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'siglas': siglas,
      'candidatoNombres': candidatoNombres,
      'candidatoApellidos': candidatoApellidos,
      'dignidad': dignidad,
      'numeroLista': numeroLista,
      'colorHex': colorHex,
      'logoUrl': logoUrl,
    };
  }
}