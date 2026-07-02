import 'package:equatable/equatable.dart';

class VotosConsolidadosEntity extends Equatable {
  final String candidatoId;
  final String candidatoNombre;
  final String dignidad;
  final int totalVotos;
  final int cantidadMesas;
  final String? recintoId;
  final String? logoUrl;

  const VotosConsolidadosEntity({
    required this.candidatoId,
    required this.candidatoNombre,
    required this.dignidad,
    required this.totalVotos,
    required this.cantidadMesas,
    this.recintoId,
    this.logoUrl,
  });

  @override
  List<Object?> get props =>
      [candidatoId, candidatoNombre, dignidad, totalVotos, cantidadMesas, recintoId, logoUrl];
}