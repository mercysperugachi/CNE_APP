import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../../../veedor/domain/entities/acta_entity.dart';
import '../../../veedor/presentation/bloc/veedor_bloc.dart';
import '../../../veedor/presentation/bloc/veedor_event.dart';
import '../../../veedor/presentation/bloc/veedor_state.dart';
import '../../../veedor/presentation/pages/acta_form_page.dart';

class ActasListPage extends StatelessWidget {
  final String mesaId;
  final String numeroMesa;
  final String recintoId;

  const ActasListPage({super.key, required this.mesaId, required this.numeroMesa, required this.recintoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<VeedorBloc>()..add(LoadActasByMesaEvent(mesaId)),
      child: Scaffold(
        body: Column(
          children: [
            ModernAppBar(
              title: 'Actas',
              subtitle: 'Mesa $numeroMesa',
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  tooltip: 'Recargar',
                  onPressed: () => context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId)),
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<VeedorBloc, VeedorState>(
                builder: (context, state) {
                  if (state is VeedorLoading) return const LoadingShimmer();
                  if (state is VeedorError) {
                    return ErrorState(
                      message: state.message,
                      onRetry: () => context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId)),
                    );
                  }
                  if (state is VeedorActasListLoaded) {
                    return RefreshIndicator(
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
                          _buildActaCard(context, 'Alcalde', Icons.location_city_rounded, _findActa(state.actas, 'Alcalde')),
                          const SizedBox(height: 12),
                          _buildActaCard(context, 'Prefecto', Icons.account_balance_rounded, _findActa(state.actas, 'Prefecto')),
                          const SizedBox(height: 24),
                          ModernCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textMuted),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Como Coordinador, puede tocar un acta subida para ver o corregir sus datos.',
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, List<ActaEntity> actas) {
    final totalSubidas = actas.length;
    final porcentaje = (totalSubidas / 2) * 100;
    return ModernCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.info_outline_rounded, color: AppTheme.secondary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mesa $numeroMesa', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
                  Text('Recinto $recintoId', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalSubidas / 2,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceGray,
              color: totalSubidas == 2 ? AppTheme.success : AppTheme.warning,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$totalSubidas de 2 actas subidas', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              Text('${porcentaje.toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: totalSubidas == 2 ? AppTheme.success : AppTheme.warning)),
            ],
          ),
        ],
      ),
    );
  }

  ActaEntity? _findActa(List<ActaEntity> actas, String dignidad) {
    try { return actas.firstWhere((a) => a.tipoActa == dignidad); } catch (_) { return null; }
  }

  Widget _buildActaCard(BuildContext context, String dignidad, IconData icon, ActaEntity? acta) {
    final isSubida = acta != null;
    final color = isSubida ? AppTheme.success : AppTheme.warning;
    return ModernCard(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isSubida ? () => _abrirFormularioEdicion(context, dignidad, acta) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(isSubida ? Icons.check_circle_rounded : Icons.pending_actions_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Acta de $dignidad', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(isSubida ? 'SUBIDA' : 'PENDIENTE', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ],
            ),
            if (isSubida) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _infoRow(Icons.how_to_vote_rounded, 'Sufragantes: ${acta.totalSufragantes}'),
              _infoRow(Icons.ballot_outlined, 'Candidatos: ${acta.votosCandidato1 + acta.votosCandidato2 + acta.votosCandidato3 + acta.votosCandidato4 + acta.votosCandidato5}'),
              _infoRow(Icons.do_not_disturb_alt_rounded, 'Blancos: ${acta.votosBlancos}  ·  Nulos: ${acta.votosNulos}'),
              _infoRow(Icons.location_on_rounded, 'GPS: ${acta.latitud.toStringAsFixed(5)}, ${acta.longitud.toStringAsFixed(5)}'),
              if (acta.novedades.isNotEmpty) _infoRow(Icons.note_rounded, 'Novedades: ${acta.novedades}'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Tocar para editar', style: TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: AppTheme.secondary, size: 16),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('El veedor aún no ha subido el acta.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
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
            body: BlocConsumer<VeedorBloc, VeedorState>(
              listener: (innerCtx, innerState) {
                if (innerState is VeedorActaSubmittedSuccess) {
                  ScaffoldMessenger.of(innerCtx).showSnackBar(const SnackBar(content: Text('Acta actualizada con éxito'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating));
                  Navigator.of(innerCtx).pop();
                } else if (innerState is VeedorActaSavedOffline) {
                  ScaffoldMessenger.of(innerCtx).showSnackBar(const SnackBar(content: Text('Acta guardada localmente.'), backgroundColor: Color(0xFFFFC107), behavior: SnackBarBehavior.floating));
                  Navigator.of(innerCtx).pop();
                }
              },
              builder: (innerCtx, innerState) {
                return ActaFormPage(mesaId: mesaId, recintoId: recintoId, tipoActa: dignidad, actaExistente: acta);
              },
            ),
          ),
        ),
      ),
    );
    if (context.mounted) context.read<VeedorBloc>().add(LoadActasByMesaEvent(mesaId));
  }
}
