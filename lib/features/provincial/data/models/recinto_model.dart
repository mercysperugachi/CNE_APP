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
    // EL TRUCO ESTÁ AQUÍ: Convertimos el dato a entero sin importar cómo llegue
    int parsedMesas = 0;
    if (json['cantidadMesas'] != null) {
      if (json['cantidadMesas'] is int) {
        parsedMesas = json['cantidadMesas'];
      } else {
        parsedMesas = int.tryParse(json['cantidadMesas'].toString()) ?? 0;
      }
    }
    return RecintoModel(
      id: json['\$id'] ?? '',
      canton: json['canton'] ?? '',
      parroquia: json['parroquia'] ?? '',
      nombre: json['nombre'] ?? '',
      cantidadMesas: parsedMesas,
      coordinadorId: json['coordinadorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canton': canton,
      'parroquia': parroquia,
      'nombre': nombre,
      'cantidadMesas': cantidadMesas.toString(), 
      'coordinadorId': coordinadorId,
    };
  }
}