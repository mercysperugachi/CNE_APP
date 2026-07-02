import '../../domain/entities/mesa_entity.dart';

class MesaModel extends MesaEntity {
  const MesaModel({
    required super.id,
    required super.numeroMesa,
    required super.recintoId,
    super.veedorId,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) {
    return MesaModel(
      id: json['\$id'] ?? '',
      numeroMesa: json['numeroMesa'] ?? json['numeroJr'] ?? '',
      recintoId: json['recintoId'] ?? '',
      veedorId: json['veedorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroMesa': numeroMesa,
      'recintoId': recintoId,
      'veedorId': veedorId,
    };
  }
}