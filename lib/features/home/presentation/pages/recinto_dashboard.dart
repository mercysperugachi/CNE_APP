import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
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
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocListener<RecintoBloc, RecintoState>(
                listenWhen: (prev, curr) => curr is RecintoActionSuccess,
                listener: (context, state) {
                  if (state is RecintoActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                child: BlocBuilder<RecintoBloc, RecintoState>(
                  builder: (context, state) {
                    if (user.recintoId == null || user.recintoId!.isEmpty) {
                      return const EmptyState(
                        icon: Icons.error_outline,
                        title: 'Sin recinto asignado',
                        subtitle: 'No tienes un recinto asignado.',
                      );
                    }
                    if (state is RecintoLoading) return const LoadingShimmer();
                    if (state is RecintoError) {
                      return ErrorState(
                        message: state.message,
                        onRetry: () => context.read<RecintoBloc>().add(LoadMesasEvent(user.recintoId!)),
                      );
                    }
                    if (state is RecintoMesasLoaded) {
                      final mesas = state.mesas;
                      if (mesas.isEmpty) {
                        return const EmptyState(
                          icon: Icons.table_rows_outlined,
                          title: 'No hay mesas registradas',
                          subtitle: 'Presiona el botón + para crear una nueva mesa.',
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<RecintoBloc>().add(LoadMesasEvent(user.recintoId!));
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
                    return const Center(child: Text('Cargando mesas...', style: TextStyle(color: AppTheme.textMuted)));
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            if (user.recintoId == null || user.recintoId!.isEmpty) return const SizedBox.shrink();
            return FloatingActionButton(
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
              backgroundColor: AppTheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add_rounded),
            );
          },
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
                    const Text('Coordinador de Recinto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
                    Text(user.nombres, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
        ),
      ),
    );
  }

  Widget _buildMesaCard(BuildContext context, dynamic mesa) {
    final hasVeedor = mesa.veedorId != null;
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (hasVeedor ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasVeedor ? Icons.check_circle_rounded : Icons.pending_rounded,
                  size: 22,
                  color: hasVeedor ? AppTheme.success : AppTheme.warning,
                ),
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
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (hasVeedor ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasVeedor ? 'Veedor asignado' : 'Sin veedor',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hasVeedor ? AppTheme.success : AppTheme.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _iconBtn(
                    Icons.assignment_outlined,
                    AppTheme.secondary,
                    'Ver actas',
                    () {
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
                  const SizedBox(height: 8),
                  _iconBtn(
                    hasVeedor ? Icons.edit_outlined : Icons.person_add_outlined,
                    hasVeedor ? AppTheme.textMuted : AppTheme.secondary,
                    hasVeedor ? 'Reasignar' : 'Asignar veedor',
                    () {
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
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
