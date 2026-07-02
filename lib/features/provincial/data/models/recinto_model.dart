import '../../domain/entities/recinto_entity.dart';

class RecintoModel extends RecintoEntity {
  const RecintoModel({
    required super.id,
    required super.canton,
    required super.parroquia,
    required super.nombre,
    required super.cantidadMesas,
    super.coordinadorId,
  });

  factory RecintoModel.fromJson(Map<String, dynamic> json) {
    return RecintoModel(
      id: json['\$id'] ?? '',
      canton: json['canton'] ?? '',
      parroquia: json['parroquia'] ?? '',
      nombre: json['nombre'] ?? '',
      cantidadMesas: json['cantidadMesas'] ?? 0,
      coordinadorId: json['coordinadorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canton': canton,
      'parroquia': parroquia,
      'nombre': nombre,
      'cantidadMesas': cantidadMesas,
      'coordinadorId': coordinadorId,
    };
  }
}