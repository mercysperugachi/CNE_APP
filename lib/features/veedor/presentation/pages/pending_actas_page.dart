import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../../domain/entities/acta_pendiente_entity.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';

class PendingActasPage extends StatefulWidget {
  const PendingActasPage({super.key});

  @override
  State<PendingActasPage> createState() => _PendingActasPageState();
}

class _PendingActasPageState extends State<PendingActasPage> {
  late final ConnectivityService _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = di.sl<ConnectivityService>();
    context.read<VeedorBloc>().add(LoadPendingActasEvent());
    _connectivity.onStatusChanged.listen((_) {
      if (mounted) context.read<VeedorBloc>().add(SyncPendingActasEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ModernAppBar(
            title: 'Actas Pendientes',
            actions: [
              IconButton(
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
                tooltip: 'Sincronizar ahora',
                onPressed: () => context.read<VeedorBloc>().add(SyncPendingActasEvent()),
              ),
            ],
          ),
          Expanded(
            child: BlocConsumer<VeedorBloc, VeedorState>(
              listener: (context, state) {
                if (state is VeedorSyncResult) {
                  if (state.synced > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sincronización completa: ${state.synced} actas subidas.'),
                        backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (state.failed > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al subir: ${state.errors.isNotEmpty ? state.errors.first : "Error desconocido"}'),
                        backgroundColor: AppTheme.danger, behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No hay actas pendientes o ya fueron subidas.'),
                        backgroundColor: AppTheme.info, behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  context.read<VeedorBloc>().add(LoadPendingActasEvent());
                }
              },
              builder: (context, state) {
                if (state is VeedorLoading || state is VeedorSyncResult) return const LoadingShimmer();
                if (state is VeedorError) {
                  return ErrorState(
                    message: state.message,
                    onRetry: () => context.read<VeedorBloc>().add(LoadPendingActasEvent()),
                  );
                }
                if (state is VeedorPendingActasLoaded) {
                  if (state.actas.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<VeedorBloc>().add(LoadPendingActasEvent());
                        await Future<void>.delayed(const Duration(milliseconds: 400));
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_done_rounded, size: 48, color: AppTheme.success),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '¡Todo sincronizado!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No hay actas pendientes de sincronización.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<VeedorBloc>().add(LoadPendingActasEvent());
                      await Future<void>.delayed(const Duration(milliseconds: 400));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: state.actas.length,
                      itemBuilder: (context, index) => _buildActaCard(context, state.actas[index]),
                    ),
                  );
                }
                return const Center(child: Text('Cargando...', style: TextStyle(color: AppTheme.textMuted)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActaCard(BuildContext context, ActaPendienteEntity acta) {
    Color color;
    IconData icon;
    String statusText;
    switch (acta.estado) {
      case ActaSyncStatus.pending:
        color = AppTheme.warning;
        icon = Icons.schedule_rounded;
        statusText = 'PENDIENTE';
        break;
      case ActaSyncStatus.syncing:
        color = AppTheme.info;
        icon = Icons.sync_rounded;
        statusText = 'SINCRONIZANDO';
        break;
      case ActaSyncStatus.synced:
        color = AppTheme.success;
        icon = Icons.check_circle_rounded;
        statusText = 'SINCRONIZADO';
        break;
      case ActaSyncStatus.error:
        color = AppTheme.danger;
        icon = Icons.error_rounded;
        statusText = 'ERROR';
        break;
    }
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mesa ${acta.mesaId}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('Acta de ${acta.tipoActa}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('Votos: ${acta.sumaVotos} / Sufragantes: ${acta.totalSufragantes}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                if (acta.lastError != null) ...[
                  const SizedBox(height: 4),
                  Text('Error: ${acta.lastError}', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                ],
                const SizedBox(height: 4),
                Text('Intentos: ${acta.attemptCount}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(statusText, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
