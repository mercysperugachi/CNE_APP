import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_recintos_usecase.dart';
import '../../domain/usecases/create_recinto_usecase.dart';
import '../../domain/usecases/create_coordinador_recinto_usecase.dart';
import '../../domain/usecases/get_organizaciones_by_dignidad_usecase.dart';
import '../../domain/usecases/get_votos_consolidados_usecase.dart';
import 'provincial_event.dart';
import 'provincial_state.dart';

class ProvincialBloc extends Bloc<ProvincialEvent, ProvincialState> {
  final GetRecintosUseCase getRecintosUseCase;
  final CreateRecintoUseCase createRecintoUseCase;
  final CreateCoordinadorRecintoUseCase createCoordinadorRecintoUseCase;
  final GetOrganizacionesByDignidadUseCase getOrganizacionesUseCase;
  final GetVotosConsolidadosUseCase getVotosConsolidadosUseCase;

  ProvincialBloc({
    required this.getRecintosUseCase,
    required this.createRecintoUseCase,
    required this.createCoordinadorRecintoUseCase,
    required this.getOrganizacionesUseCase,
    required this.getVotosConsolidadosUseCase,
  }) : super(ProvincialInitial()) {
    on<LoadRecintosEvent>(_onLoadRecintos);
    on<CreateRecintoEvent>(_onCreateRecinto);
    on<CreateCoordinadorRecintoEvent>(_onCreateCoordinadorRecinto);
    on<LoadOrganizacionesEvent>(_onLoadOrganizaciones);
    on<LoadVotosConsolidadosEvent>(_onLoadVotosConsolidados);
  }

  Future<void> _onLoadRecintos(LoadRecintosEvent event, Emitter<ProvincialState> emit) async {
    emit(ProvincialLoading());
    final result = await getRecintosUseCase();
    result.fold(
      (failure) => emit(ProvincialError(failure.message)),
      (recintos) => emit(ProvincialRecintosLoaded(recintos)),
    );
  }

  Future<void> _onCreateRecinto(CreateRecintoEvent event, Emitter<ProvincialState> emit) async {
    emit(ProvincialLoading());
    final result = await createRecintoUseCase(
      canton: event.canton,
      parroquia: event.parroquia,
      nombre: event.nombre,
      cantidadMesas: event.cantidadMesas,
    );
    result.fold(
      (failure) => emit(ProvincialError(failure.message)),
      (_) {
        emit(const ProvincialActionSuccess('Recinto creado exitosamente'));
        add(LoadRecintosEvent());
      },
    );
  }

  Future<void> _onCreateCoordinadorRecinto(CreateCoordinadorRecintoEvent event, Emitter<ProvincialState> emit) async {
    emit(ProvincialLoading());
    final result = await createCoordinadorRecintoUseCase(
      cedula: event.cedula,
      nombres: event.nombres,
      apellidos: event.apellidos,
      telefono: event.telefono,
      correo: event.correo,
      recintoId: event.recintoId,
    );
    result.fold(
      (failure) => emit(ProvincialError(failure.message)),
      (_) {
        emit(const ProvincialActionSuccess('Coordinador creado y asignado al recinto'));
        add(LoadRecintosEvent());
      },
    );
  }

  Future<void> _onLoadOrganizaciones(LoadOrganizacionesEvent event, Emitter<ProvincialState> emit) async {
    emit(ProvincialLoading());
    final result = await getOrganizacionesUseCase(event.dignidad);
    result.fold(
      (failure) => emit(ProvincialError(failure.message)),
      (orgs) => emit(ProvincialOrganizacionesLoaded(orgs)),
    );
  }

  Future<void> _onLoadVotosConsolidados(LoadVotosConsolidadosEvent event, Emitter<ProvincialState> emit) async {
    emit(ProvincialLoading());
    final result = await getVotosConsolidadosUseCase(
      dignidad: event.dignidad,
      recintoId: event.recintoId,
    );
    result.fold(
      (failure) => emit(ProvincialError(failure.message)),
      (votos) => emit(ProvincialVotosConsolidadosLoaded(votos, event.dignidad, event.recintoId)),
    );
  }
}