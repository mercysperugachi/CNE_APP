import 'package:equatable/equatable.dart';

abstract class RecintoEvent extends Equatable {
  const RecintoEvent();

  @override
  List<Object?> get props => [];
}

class LoadMesasEvent extends RecintoEvent {
  final String recintoId;

  const LoadMesasEvent(this.recintoId);

  @override
  List<Object?> get props => [recintoId];
}

class CreateMesaEvent extends RecintoEvent {
  final String numeroMesa;
  final String recintoId;

  const CreateMesaEvent({
    required this.numeroMesa,
    required this.recintoId,
  });

  @override
  List<Object?> get props => [numeroMesa, recintoId];
}

class CreateVeedorMesaEvent extends RecintoEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String mesaId;
  final String recintoId;

  const CreateVeedorMesaEvent({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.mesaId,
    required this.recintoId,
  });

  @override
  List<Object?> get props => [cedula, nombres, apellidos, telefono, correo, mesaId, recintoId];
}