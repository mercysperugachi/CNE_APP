import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
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
      if (mounted) {
        context.read<VeedorBloc>().add(SyncPendingActasEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actas Pendientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar ahora',
            onPressed: () {
              context.read<VeedorBloc>().add(SyncPendingActasEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<VeedorBloc, VeedorState>(
        listener: (context, state) {
          if (state is VeedorSyncResult) {
            if (state.synced > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sincronización completa: ${state.synced} actas subidas.'),
                  backgroundColor: AppTheme.success,
                ),
              );
            } else if (state.failed > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al subir: ${state.errors.isNotEmpty ? state.errors.first : "Error desconocido"}'),
                  backgroundColor: AppTheme.danger,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No hay actas pendientes o ya fueron subidas.'),
                  backgroundColor: AppTheme.info,
                ),
              );
            }
            // Después de sincronizar, recargar la lista
            context.read<VeedorBloc>().add(LoadPendingActasEvent());
          }
        },
        builder: (context, state) {
          if (state is VeedorLoading || state is VeedorSyncResult) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VeedorError) {
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
                      onPressed: () => context.read<VeedorBloc>().add(LoadPendingActasEvent()),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is VeedorPendingActasLoaded) {
            if (state.actas.isEmpty) {
              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  context.read<VeedorBloc>().add(LoadPendingActasEvent());
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 100),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_done, size: 36, color: AppTheme.success),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Todo sincronizado!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No hay actas pendientes de sincronización.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async {
                context.read<VeedorBloc>().add(LoadPendingActasEvent());
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: state.actas.length,
                itemBuilder: (context, index) {
                  final acta = state.actas[index];
                  return _buildActaCard(context, acta);
                },
              ),
            );
          }
          return const Center(child: Text('Cargando...', style: TextStyle(color: AppTheme.textMuted)));
        },
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
        icon = Icons.schedule;
        statusText = 'PENDIENTE';
        break;
      case ActaSyncStatus.syncing:
        color = AppTheme.info;
        icon = Icons.sync;
        statusText = 'SINCRONIZANDO';
        break;
      case ActaSyncStatus.synced:
        color = AppTheme.success;
        icon = Icons.check_circle;
        statusText = 'SINCRONIZADO';
        break;
      case ActaSyncStatus.error:
        color = AppTheme.danger;
        icon = Icons.error;
        statusText = 'ERROR';
        break;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesa ${acta.mesaId}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Acta de ${acta.tipoActa}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Votos: ${acta.sumaVotos} / Sufragantes: ${acta.totalSufragantes}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  if (acta.lastError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Error: ${acta.lastError}',
                      style: const TextStyle(color: AppTheme.danger, fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Intentos: ${acta.attemptCount}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: AppTheme.statusBadge(color: color),
              child: Text(
                statusText,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}