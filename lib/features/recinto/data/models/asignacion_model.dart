import '../../domain/entities/asignacion_entity.dart';

class AsignacionModel extends AsignacionEntity {
  const AsignacionModel({
    required super.id,
    required super.veedorId,
    required super.mesaId,
    required super.recintoId,
    required super.fechaAsignacion,
    required super.activa,
    super.asignadoPor,
  });

  factory AsignacionModel.fromJson(Map<String, dynamic> json) {
    return AsignacionModel(
      id: json['\$id'] ?? '',
      veedorId: json['veedorId'] ?? '',
      mesaId: json['mesaId'] ?? '',
      recintoId: json['recintoId'] ?? '',
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : DateTime.now(),
      activa: json['activa'] ?? true,
      asignadoPor: json['asignadoPor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'veedorId': veedorId,
      'mesaId': mesaId,
      'recintoId': recintoId,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'activa': activa,
      'asignadoPor': asignadoPor,
    };
  }
}