import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../recinto/presentation/bloc/recinto_bloc.dart';
import '../../../recinto/presentation/bloc/recinto_event.dart';
import '../../../recinto/presentation/bloc/recinto_state.dart';
import '../../../recinto/presentation/pages/create_mesa_page.dart';
import '../../../recinto/presentation/pages/create_veedor_page.dart';
import '../../../recinto/presentation/pages/actas_list_page.dart';

class RecintoDashboard extends StatelessWidget {
  final UserEntity user;
  const RecintoDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RecintoBloc>()..add(LoadMesasEvent(user.recintoId ?? '')),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coordinador de Recinto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.textMuted)),
              Text(user.nombres, style: const TextStyle(fontSize: 17)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequestedEvent());
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
        body: BlocListener<RecintoBloc, RecintoState>(
          listenWhen: (prev, curr) => curr is RecintoActionSuccess,
          listener: (context, state) {
            if (state is RecintoActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppTheme.success),
              );
            }
          },
          child: BlocBuilder<RecintoBloc, RecintoState>(
            builder: (context, state) {
              if (user.recintoId == null || user.recintoId!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Error: No tienes un recinto asignado.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.danger)),
                  ),
                );
              }
              if (state is RecintoLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RecintoError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 56, color: AppTheme.danger.withOpacity(0.7)),
                        const SizedBox(height: 16),
                        Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reintentar'),
                          onPressed: () => context.read<RecintoBloc>().add(LoadMesasEvent(user.recintoId!)),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is RecintoMesasLoaded) {
                final mesas = state.mesas;
                if (mesas.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 100),
                      Icon(Icons.table_rows_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay mesas registradas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async {
                    context.read<RecintoBloc>().add(LoadMesasEvent(user.recintoId!));
                    await Future<void>.delayed(const Duration(milliseconds: 400));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: mesas.length,
                    itemBuilder: (context, index) {
                      final mesa = mesas[index];
                      return _buildMesaCard(context, mesa);
                    },
                  ),
                );
              }
              return const Center(child: Text('Cargando mesas...', style: TextStyle(color: AppTheme.textMuted)));
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            if (user.recintoId == null || user.recintoId!.isEmpty) return const SizedBox.shrink();
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<RecintoBloc>(),
                      child: CreateMesaPage(recintoId: user.recintoId!),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nueva Mesa'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMesaCard(BuildContext context, dynamic mesa) {
    final hasVeedor = mesa.veedorId != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.table_rows, size: 22, color: AppTheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesa ${mesa.numeroMesa}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        hasVeedor ? Icons.check_circle : Icons.pending,
                        size: 14,
                        color: hasVeedor ? AppTheme.success : AppTheme.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasVeedor ? 'Veedor asignado' : 'Sin veedor',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasVeedor ? AppTheme.success : AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildIconButton(
                  icon: Icons.assignment_outlined,
                  color: AppTheme.primary,
                  tooltip: 'Ver actas',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActasListPage(
                          mesaId: mesa.id,
                          numeroMesa: mesa.numeroMesa,
                          recintoId: user.recintoId!,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                _buildIconButton(
                  icon: hasVeedor ? Icons.edit_outlined : Icons.person_add_outlined,
                  color: hasVeedor ? AppTheme.onSurfaceVariant : AppTheme.onSurface,
                  bgColor: hasVeedor ? null : AppTheme.primaryContainer,
                  tooltip: hasVeedor ? 'Reasignar veedor' : 'Asignar veedor',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<RecintoBloc>(),
                          child: CreateVeedorPage(
                            mesaId: mesa.id,
                            numeroMesa: mesa.numeroMesa,
                            recintoId: user.recintoId!,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    Color? bgColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: bgColor ?? color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}