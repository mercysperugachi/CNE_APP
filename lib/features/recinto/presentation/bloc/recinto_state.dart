import 'package:equatable/equatable.dart';
import '../../domain/entities/mesa_entity.dart';

abstract class RecintoState extends Equatable {
  const RecintoState();

  @override
  List<Object?> get props => [];
}

class RecintoInitial extends RecintoState {}

class RecintoLoading extends RecintoState {}

class RecintoMesasLoaded extends RecintoState {
  final List<MesaEntity> mesas;

  const RecintoMesasLoaded(this.mesas);

  @override
  List<Object?> get props => [mesas];
}

class RecintoActionSuccess extends RecintoState {
  final String message;

  const RecintoActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RecintoError extends RecintoState {
  final String message;

  const RecintoError(this.message);

  @override
  List<Object?> get props => [message];
}