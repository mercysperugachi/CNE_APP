import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/theme/app_theme.dart';
import '../../../veedor/domain/entities/acta_entity.dart';
import '../../../veedor/presentation/bloc/veedor_bloc.dart';
import '../../../veedor/presentation/bloc/veedor_event.dart';
import '../../../veedor/presentation/bloc/veedor_state.dart';
import '../../../veedor/presentation/pages/acta_form_page.dart';

class ActasListPage extends StatelessWidget {
  final String mesaId;
  final String numeroMesa;
  final String recintoId;

  const ActasListPage({
    super.key,
    required this.mesaId,
    required this.numeroMesa,
    required this.recintoId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<VeedorBloc>()..add(LoadActasByMesaEvent(mesaId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Actas · Mesa $numeroMesa'),
          actions: [
            IconButton(
              tooltip: 'Recargar',
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId)),
            ),
          ],
        ),
        body: BlocBuilder<VeedorBloc, VeedorState>(
          builder: (context, state) {
            if (state is VeedorLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VeedorError) {
              return _buildError(context, state.message);
            }
            if (state is VeedorActasListLoaded) {
              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId));
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHeaderInfo(context, state.actas),
                    const SizedBox(height: 16),
                    _buildActaCard(
                      context: context,
                      dignidad: 'Alcalde',
                      icon: Icons.location_city,
                      acta: _findActa(state.actas, 'Alcalde'),
                    ),
                    const SizedBox(height: 12),
                    _buildActaCard(
                      context: context,
                      dignidad: 'Prefecto',
                      icon: Icons.account_balance,
                      acta: _findActa(state.actas, 'Prefecto'),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Como Coordinador de Recinto, puede tocar un acta subida para ver o corregir sus datos.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Cargando...', style: TextStyle(color: AppTheme.textMuted)));
          },
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, List<ActaEntity> actas) {
    final totalSubidas = actas.length;
    final porcentaje = (totalSubidas / 2) * 100;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa $numeroMesa',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Recinto $recintoId',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalSubidas / 2,
              minHeight: 6,
              backgroundColor: AppTheme.surfaceMuted,
              color: totalSubidas == 2 ? AppTheme.success : AppTheme.warning,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalSubidas de 2 actas subidas',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              Text(
                '${porcentaje.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: totalSubidas == 2 ? AppTheme.success : AppTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ActaEntity? _findActa(List<ActaEntity> actas, String dignidad) {
    try {
      return actas.firstWhere((a) => a.tipoActa == dignidad);
    } catch (_) {
      return null;
    }
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.danger.withOpacity(0.7), size: 56),
            const SizedBox(height: 16),
            Text('Error al cargar las actas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              onPressed: () => context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActaCard({
    required BuildContext context,
    required String dignidad,
    required IconData icon,
    required ActaEntity? acta,
  }) {
    final isSubida = acta != null;
    final colorPrincipal = isSubida ? AppTheme.success : AppTheme.warning;

    return Container(
      decoration: AppTheme.cardDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSubida ? () => _abrirFormularioEdicion(context, dignidad, acta) : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorPrincipal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSubida ? Icons.check_circle : Icons.pending_actions,
                      color: colorPrincipal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Acta de $dignidad',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: AppTheme.statusBadge(color: colorPrincipal),
                    child: Text(
                      isSubida ? 'SUBIDA' : 'PENDIENTE',
                      style: TextStyle(color: colorPrincipal, fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ),
                ],
              ),
              if (isSubida) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.how_to_vote, 'Sufragantes: ${acta.totalSufragantes}'),
                _buildInfoRow(Icons.ballot_outlined,
                    'Candidatos: ${acta.votosCandidato1 + acta.votosCandidato2 + acta.votosCandidato3 + acta.votosCandidato4 + acta.votosCandidato5}'),
                _buildInfoRow(Icons.do_not_disturb_alt, 'Blancos: ${acta.votosBlancos}  ·  Nulos: ${acta.votosNulos}'),
                _buildInfoRow(Icons.location_on, 'GPS: ${acta.latitud.toStringAsFixed(5)}, ${acta.longitud.toStringAsFixed(5)}'),
                if (acta.novedades.isNotEmpty)
                  _buildInfoRow(Icons.note, 'Novedades: ${acta.novedades}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Tocar para editar',
                      style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: AppTheme.primary, size: 16),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'El veedor aún no ha subido el acta de esta dignidad.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        ],
      ),
    );
  }

  Future<void> _abrirFormularioEdicion(BuildContext context, String dignidad, ActaEntity acta) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<VeedorBloc>.value(
          value: context.read<VeedorBloc>(),
          child: Scaffold(
            appBar: AppBar(title: Text('Editar Acta $dignidad')),
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
                  Navigator.of(innerCtx).pop(); // Cerrar el formulario
                }
              },
              builder: (innerCtx, innerState) {
                return ActaFormPage(
                  mesaId: mesaId,
                  recintoId: recintoId,
                  tipoActa: dignidad,
                  actaExistente: acta,
                );
              },
            ),
          ),
        ),
      ),
    );
    if (context.mounted) {
      context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId));
    }
  }
}