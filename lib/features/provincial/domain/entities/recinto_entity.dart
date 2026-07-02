import 'package:equatable/equatable.dart';

class RecintoEntity extends Equatable {
  final String id;
  final String canton;
  final String parroquia;
  final String nombre;
  final int cantidadMesas;
  final String? coordinadorId; // ID del coordinador asignado

  const RecintoEntity({
    required this.id,
    required this.canton,
    required this.parroquia,
    required this.nombre,
    required this.cantidadMesas,
    this.coordinadorId,
  });

  @override
  List<Object?> get props => [id, canton, parroquia, nombre, cantidadMesas, coordinadorId];
}