import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_mesas_by_recinto_usecase.dart';
import '../../domain/usecases/create_mesa_usecase.dart';
import '../../domain/usecases/create_veedor_mesa_usecase.dart';
import 'recinto_event.dart';
import 'recinto_state.dart';

class RecintoBloc extends Bloc<RecintoEvent, RecintoState> {
  final GetMesasByRecintoUseCase getMesasUseCase;
  final CreateMesaUseCase createMesaUseCase;
  final CreateVeedorMesaUseCase createVeedorMesaUseCase;

  RecintoBloc({
    required this.getMesasUseCase,
    required this.createMesaUseCase,
    required this.createVeedorMesaUseCase,
  }) : super(RecintoInitial()) {
    on<LoadMesasEvent>(_onLoadMesas);
    on<CreateMesaEvent>(_onCreateMesa);
    on<CreateVeedorMesaEvent>(_onCreateVeedorMesa);
  }

  Future<void> _onLoadMesas(LoadMesasEvent event, Emitter<RecintoState> emit) async {
    emit(RecintoLoading());
    final result = await getMesasUseCase(event.recintoId);
    result.fold(
      (failure) => emit(RecintoError(failure.message)),
      (mesas) => emit(RecintoMesasLoaded(mesas)),
    );
  }

  Future<void> _onCreateMesa(CreateMesaEvent event, Emitter<RecintoState> emit) async {
    emit(RecintoLoading());
    final result = await createMesaUseCase(
      numeroMesa: event.numeroMesa,
      recintoId: event.recintoId,
    );
    result.fold(
      (failure) => emit(RecintoError(failure.message)),
      (_) {
        emit(const RecintoActionSuccess('Mesa creada exitosamente'));
        add(LoadMesasEvent(event.recintoId));
      },
    );
  }

  Future<void> _onCreateVeedorMesa(CreateVeedorMesaEvent event, Emitter<RecintoState> emit) async {
    emit(RecintoLoading());
    final result = await createVeedorMesaUseCase(
      cedula: event.cedula,
      nombres: event.nombres,
      apellidos: event.apellidos,
      telefono: event.telefono,
      correo: event.correo,
      mesaId: event.mesaId,
      recintoId: event.recintoId,
    );
    result.fold(
      (failure) => emit(RecintoError(failure.message)),
      (_) {
        emit(const RecintoActionSuccess('Veedor creado y asignado a la mesa'));
        add(LoadMesasEvent(event.recintoId));
      },
    );
  }
}