import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/theme/app_theme.dart';
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
      if (hasInternet) {
        syncService.syncNow();
      }
    });

    // Precargar organizaciones en caché para el modo offline
    final orgUseCase = di.sl<GetOrganizacionesByDignidadUseCase>();
    orgUseCase('Alcalde');
    orgUseCase('Prefecto');
  }

  @override
  Widget build(BuildContext context) {
    final syncService = di.sl<SyncService>();
    
    return BlocProvider(
      create: (_) => di.sl<VeedorBloc>()..add(LoadMesasByVeedorEvent(widget.user.id)),
      child: Builder(
        builder: (innerContext) => Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Veedor de Mesa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.textMuted)),
                Text(widget.user.nombres, style: const TextStyle(fontSize: 17)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.cloud_sync_outlined),
                tooltip: 'Actas pendientes',
                onPressed: () {
                  Navigator.of(innerContext).push(
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
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: () {
                  syncService.stopAutoSync();
                  innerContext.read<AuthBloc>().add(LogoutRequestedEvent());
                  Navigator.of(innerContext).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        body: BlocBuilder<VeedorBloc, VeedorState>(
          builder: (context, state) {
            if (state is VeedorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VeedorError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 56, color: AppTheme.danger.withValues(alpha: 0.7)),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reintentar'),
                        onPressed: () => context.read<VeedorBloc>().add(LoadMesasByVeedorEvent(widget.user.id)),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is VeedorMesasListLoaded) {
              final mesas = state.mesas;
              if (mesas.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<VeedorBloc>().add(LoadMesasByVeedorEvent(widget.user.id));
                    await Future<void>.delayed(const Duration(milliseconds: 400));
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 100),
                      Icon(Icons.how_to_vote_outlined, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes mesas asignadas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  context.read<VeedorBloc>().add(LoadMesasByVeedorEvent(widget.user.id));
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: mesas.length,
                  itemBuilder: (context, index) {
                    final mesa = mesas[index];
                    return _buildMesaExpansion(context, mesa);
                  },
                ),
              );
            }
            return const Center(child: Text('Cargando tus mesas...', style: TextStyle(color: AppTheme.textMuted)));
          },
        ),
      ),
      ),
    );
  }

  Widget _buildMesaExpansion(BuildContext context, dynamic mesa) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.cardDecoration(),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.how_to_vote, size: 20, color: AppTheme.primary),
          ),
          title: Text(
            'Mesa ${mesa.numeroMesa}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          subtitle: const Text(
            'Seleccione el acta a registrar',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildActaButton(context, 'Alcalde', mesa.id, mesa.recintoId, Icons.location_city),
                  const SizedBox(height: 8),
                  _buildActaButton(context, 'Prefecto', mesa.id, mesa.recintoId, Icons.account_balance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActaButton(BuildContext context, String tipoActa, String mesaId, String recintoId, IconData iconData) {
    return OutlinedButton.icon(
      icon: Icon(iconData, size: 18),
      label: Text('Acta de $tipoActa'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppTheme.border),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => di.sl<VeedorBloc>()..add(CheckActaStatusEvent(mesaId, tipoActa)),
              child: Scaffold(
                appBar: AppBar(title: Text('Acta de $tipoActa')),
                body: BlocConsumer<VeedorBloc, VeedorState>(
                  listener: (context, state) {
                    if (state is VeedorActaSubmittedSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Acta subida con éxito'), backgroundColor: AppTheme.success),
                      );
                      context.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
                    } else if (state is VeedorActaSavedOffline) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sin conexión: acta guardada localmente.'), backgroundColor: AppTheme.warning),
                      );
                      context.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
                    }
                  },
                  builder: (context, state) {
                    if (state is VeedorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is VeedorActaStatus) {
                      if (state.acta != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle, color: AppTheme.success, size: 40),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Acta de $tipoActa registrada',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Puede editarla si necesita hacer correcciones',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                ),
                                const SizedBox(height: 28),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Editar Acta'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<VeedorBloc>(),
                                          child: Scaffold(
                                            appBar: AppBar(title: Text('Editar Acta $tipoActa')),
                                            body: BlocConsumer<VeedorBloc, VeedorState>(
                                              listener: (innerCtx, innerState) {
                                                if (innerState is VeedorActaSubmittedSuccess || innerState is VeedorActaSavedOffline) {
                                                  if (innerState is VeedorActaSubmittedSuccess) {
                                                    ScaffoldMessenger.of(innerCtx).showSnackBar(
                                                      const SnackBar(content: Text('Acta actualizada con éxito'), backgroundColor: AppTheme.success),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(innerCtx).showSnackBar(
                                                      const SnackBar(content: Text('Acta guardada localmente.'), backgroundColor: AppTheme.warning),
                                                    );
                                                  }
                                                  innerCtx.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
                                                  Navigator.of(innerCtx).pop(); // Volver a la pantalla de estado
                                                }
                                              },
                                              builder: (innerCtx, innerState) {
                                                return ActaFormPage(
                                                  mesaId: mesaId,
                                                  recintoId: recintoId,
                                                  tipoActa: tipoActa,
                                                  actaExistente: state.acta,
                                                );
                                              },
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
                        );
                      }
                      return BlocProvider.value(
                        value: context.read<VeedorBloc>(),
                        child: ActaFormPage(mesaId: mesaId, recintoId: recintoId, tipoActa: tipoActa),
                      );
                    } else if (state is VeedorError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: AppTheme.danger.withValues(alpha: 0.7)),
                              const SizedBox(height: 12),
                              Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<VeedorBloc>().add(CheckActaStatusEvent(mesaId, tipoActa));
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const Center(child: Text('Cargando estado...', style: TextStyle(color: AppTheme.textMuted)));
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}