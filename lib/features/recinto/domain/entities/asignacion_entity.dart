import 'package:equatable/equatable.dart';

class AsignacionEntity extends Equatable {
  final String id;
  final String veedorId;
  final String mesaId;
  final String recintoId;
  final DateTime fechaAsignacion;
  final bool activa;
  final String? asignadoPor;

  const AsignacionEntity({
    required this.id,
    required this.veedorId,
    required this.mesaId,
    required this.recintoId,
    required this.fechaAsignacion,
    required this.activa,
    this.asignadoPor,
  });

  @override
  List<Object?> get props => [
        id,
        veedorId,
        mesaId,
        recintoId,
        fechaAsignacion,
        activa,
        asignadoPor,
      ];
}