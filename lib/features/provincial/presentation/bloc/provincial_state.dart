import 'package:equatable/equatable.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/organizacion_entity.dart';
import '../../domain/entities/votos_consolidados_entity.dart';

abstract class ProvincialState extends Equatable {
  const ProvincialState();

  @override
  List<Object?> get props => [];
}

class ProvincialInitial extends ProvincialState {}

class ProvincialLoading extends ProvincialState {}

class ProvincialRecintosLoaded extends ProvincialState {
  final List<RecintoEntity> recintos;

  const ProvincialRecintosLoaded(this.recintos);

  @override
  List<Object?> get props => [recintos];
}

class ProvincialActionSuccess extends ProvincialState {
  final String message;

  const ProvincialActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProvincialError extends ProvincialState {
  final String message;

  const ProvincialError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProvincialOrganizacionesLoaded extends ProvincialState {
  final List<OrganizacionEntity> organizaciones;

  const ProvincialOrganizacionesLoaded(this.organizaciones);

  @override
  List<Object?> get props => [organizaciones];
}

class ProvincialVotosConsolidadosLoaded extends ProvincialState {
  final List<VotosConsolidadosEntity> votos;
  final String dignidad;
  final String? recintoId;

  const ProvincialVotosConsolidadosLoaded(this.votos, this.dignidad, this.recintoId);

  @override
  List<Object?> get props => [votos, dignidad, recintoId];
}