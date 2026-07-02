import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/services/connectivity_service.dart';
import '../../../veedor/data/services/sync_service.dart';
import '../../../veedor/presentation/bloc/veedor_bloc.dart';
import '../../../veedor/presentation/bloc/veedor_event.dart';
import '../../../veedor/presentation/bloc/veedor_state.dart';
import '../../../veedor/presentation/pages/acta_form_page.dart';
import '../../../provincial/domain/usecases/get_organizaciones_by_dignidad_usecase.dart';
import '../../../veedor/presentation/pages/pending_actas_page.dart';

class VeedorDashboard extends StatefulWidget {
  final UserEntity user;
  const VeedorDashboard({super.key, required this.user});

  @override
  State<VeedorDashboard> createState() => _VeedorDashboardState();
}

class _VeedorDashboardState extends State<VeedorDashboard> {
  @override
  void initState() {
    super.initState();
    final syncService = di.sl<SyncService>();
    final connectivity = di.sl<ConnectivityService>();
    syncService.startAutoSync();
    connectivity.onStatusChanged.listen((results) {
      final hasInternet = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn);
      if (hasInternet) syncService.syncNow();
    });
    final orgUseCase = di.sl<GetOrganizacionesByDignidadUseCase>();
    orgUseCase('Alcalde');
    orgUseCase('Prefecto');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<VeedorBloc>()..add(LoadMesasByVeedorEvent(widget.user.id)),
      child: Builder(
        builder: (innerContext) => Scaffold(
          body: Column(
            children: [
              _buildHeader(innerContext),
              Expanded(
                child: BlocBuilder<VeedorBloc, VeedorState>(
                  builder: (context, state) {
                    if (state is VeedorLoading) return const LoadingShimmer();
                    if (state is VeedorError) return ErrorState(message: state.message, onRetry: () => context.read<VeedorBloc>().add(LoadMesasByVeedorEvent(widget.user.id)));
                    if (state is VeedorMesasListLoaded) {
                      final mesas = state.mesas;
                      if (mesas.isEmpty) {
                        return const EmptyState(
                          icon: Icons.how_to_vote_outlined,
                          title: 'Sin mesas asignadas',
                          subtitle: 'No tienes mesas asignadas actualmente.',
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<VeedorBloc>().add(LoadMesasByVeedorEvent(widget.user.id));
                          await Future<void>.delayed(const Duration(milliseconds: 400));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: mesas.length,
                          itemBuilder: (context, index) {
                            final mesa = mesas[index];
                            return _buildMesaCard(context, mesa);
                          },
                        ),
                      );
                    }
                    return const Center(child: Text('Cargando tus mesas...', style: TextStyle(color: AppTheme.textMuted)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 24),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Veedor de Mesa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
                    Text(widget.user.nombres, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cloud_sync_outlined, color: Colors.white),
                tooltip: 'Actas pendientes',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (navContext) => BlocProvider(
                        create: (_) => di.sl<VeedorBloc>(),
                        child: const PendingActasPage(),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Cerrar sesión',
                onPressed: () {
                  di.sl<SyncService>().stopAutoSync();
                  context.read<AuthBloc>().add(LogoutRequestedEvent());
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMesaCard(BuildContext context, dynamic mesa) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.how_to_vote_rounded, size: 22, color: AppTheme.secondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${mesa.numeroMesa}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const Text(
                      'Seleccione el acta a registrar',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActaButton(context, 'Alcalde', mesa.id, mesa.recintoId, Icons.location_city_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActaButton(context, 'Prefecto', mesa.id, mesa.recintoId, Icons.account_balance_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActaButton(BuildContext context, String tipoActa, String mesaId, String recintoId, IconData iconData) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<VeedorBloc>()..add(CheckActaStatusEvent(mesaId, tipoActa)),
                  child: Scaffold(
                    body: _ActaFormWrapper(mesaId: mesaId, recintoId: recintoId, tipoActa: tipoActa),
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(iconData, size: 22, color: AppTheme.secondary),
                const SizedBox(height: 6),
                Text(
                  tipoActa,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActaFormWrapper extends StatelessWidget {
  final String mesaId;
  final String recintoId;
  final String tipoActa;

  const _ActaFormWrapper({required this.mesaId, required this.recintoId, required this.tipoActa});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VeedorBloc, VeedorState>(
      listener: (context, state) {
        if (state is VeedorActaSubmittedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Acta subida con éxito'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
          );
          context.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
        } else if (state is VeedorActaSavedOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sin conexión: acta guardada localmente.'), backgroundColor: Color(0xFFFFC107), behavior: SnackBarBehavior.floating),
          );
          context.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
        }
      },
      builder: (context, state) {
        if (state is VeedorLoading) return const LoadingShimmer();
        if (state is VeedorActaStatus) {
          if (state.acta != null) {
            return _ActaStatusView(
              tipoActa: tipoActa,
              acta: state.acta,
              mesaId: mesaId,
              recintoId: recintoId,
            );
          }
          return ActaFormPage(mesaId: mesaId, recintoId: recintoId, tipoActa: tipoActa);
        }
        if (state is VeedorError) {
          return ErrorState(message: state.message, onRetry: () => context.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa)));
        }
        return const Center(child: Text('Cargando estado...', style: TextStyle(color: AppTheme.textMuted)));
      },
    );
  }
}

class _ActaStatusView extends StatelessWidget {
  final String tipoActa;
  final dynamic acta;
  final String mesaId;
  final String recintoId;

  const _ActaStatusView({required this.tipoActa, required this.acta, required this.mesaId, required this.recintoId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, tipoActa),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 56),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Acta de $tipoActa registrada',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Puede editarla si necesita hacer correcciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: 'Editar Acta',
                    icon: Icons.edit_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<VeedorBloc>(),
                            child: Scaffold(
                              body: _EditActaWrapper(
                                mesaId: mesaId,
                                recintoId: recintoId,
                                tipoActa: tipoActa,
                                acta: acta,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String tipoActa) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Acta', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
                  Text('Acta de $tipoActa', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditActaWrapper extends StatelessWidget {
  final String mesaId;
  final String recintoId;
  final String tipoActa;
  final dynamic acta;

  const _EditActaWrapper({required this.mesaId, required this.recintoId, required this.tipoActa, required this.acta});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VeedorBloc, VeedorState>(
      listener: (innerCtx, innerState) {
        if (innerState is VeedorActaSubmittedSuccess) {
          ScaffoldMessenger.of(innerCtx).showSnackBar(
            const SnackBar(content: Text('Acta actualizada con éxito'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
          );
          innerCtx.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
          Navigator.of(innerCtx).pop();
        } else if (innerState is VeedorActaSavedOffline) {
          ScaffoldMessenger.of(innerCtx).showSnackBar(
            const SnackBar(content: Text('Acta guardada localmente.'), backgroundColor: Color(0xFFFFC107), behavior: SnackBarBehavior.floating),
          );
          innerCtx.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
          Navigator.of(innerCtx).pop();
        }
      },
      builder: (innerCtx, innerState) {
        return _ActaFormWrapper(
          mesaId: mesaId,
          recintoId: recintoId,
          tipoActa: tipoActa,
        );
      },
    );
  }
}
