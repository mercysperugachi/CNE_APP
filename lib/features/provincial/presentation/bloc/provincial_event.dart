import 'package:equatable/equatable.dart';

abstract class ProvincialEvent extends Equatable {
  const ProvincialEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecintosEvent extends ProvincialEvent {}

class CreateRecintoEvent extends ProvincialEvent {
  final String canton;
  final String parroquia;
  final String nombre;
  final int cantidadMesas;

  const CreateRecintoEvent({
    required this.canton,
    required this.parroquia,
    required this.nombre,
    required this.cantidadMesas,
  });

  @override
  List<Object?> get props => [canton, parroquia, nombre, cantidadMesas];
}

class CreateCoordinadorRecintoEvent extends ProvincialEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String recintoId;

  const CreateCoordinadorRecintoEvent({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.recintoId,
  });

  @override
  List<Object?> get props => [cedula, nombres, apellidos, telefono, correo, recintoId];
}

class LoadOrganizacionesEvent extends ProvincialEvent {
  final String dignidad;

  const LoadOrganizacionesEvent(this.dignidad);

  @override
  List<Object?> get props => [dignidad];
}

class LoadVotosConsolidadosEvent extends ProvincialEvent {
  final String dignidad;
  final String? recintoId;

  const LoadVotosConsolidadosEvent({required this.dignidad, this.recintoId});

  @override
  List<Object?> get props => [dignidad, recintoId];
}