import 'package:equatable/equatable.dart';

class MesaEntity extends Equatable {
  final String id;
  final String numeroMesa;
  final String recintoId;
  final String? veedorId; // ID del veedor asignado a la mesa

  const MesaEntity({
    required this.id,
    required this.numeroMesa,
    required this.recintoId,
    this.veedorId,
  });

  @override
  List<Object?> get props => [id, numeroMesa, recintoId, veedorId];
}