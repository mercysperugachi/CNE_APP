import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../provincial/presentation/bloc/provincial_bloc.dart';
import '../../../provincial/presentation/bloc/provincial_event.dart';
import '../../../provincial/presentation/bloc/provincial_state.dart';
import '../../../provincial/presentation/pages/create_recinto_page.dart';
import '../../../provincial/presentation/pages/create_coordinador_page.dart';
import '../../../provincial/presentation/pages/votos_consolidados_page.dart';
import '../../../provincial/domain/usecases/get_actas_count_by_recinto_usecase.dart';
import 'recinto_dashboard.dart';

class ProvincialDashboard extends StatelessWidget {
  final UserEntity user;
  const ProvincialDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProvincialBloc>()..add(LoadRecintosEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coordinador Provincial', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.textMuted)),
              Text(user.nombres, style: const TextStyle(fontSize: 17)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Dashboard de votos',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => VotosConsolidadosPage(user: user)),
                );
              },
            ),
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
        body: BlocBuilder<ProvincialBloc, ProvincialState>(
          builder: (context, state) {
            if (state is ProvincialLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProvincialError) {
              return _buildError(state.message, context);
            } else if (state is ProvincialRecintosLoaded) {
              final recintos = state.recintos;
              if (recintos.isEmpty) {
                return _buildEmpty(context);
              }
              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  context.read<ProvincialBloc>().add(LoadRecintosEvent());
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: recintos.length,
                  itemBuilder: (context, index) {
                    return _buildRecintoCard(context, recintos[index]);
                  },
                ),
              );
            }
            return const Center(child: Text('Cargando datos...', style: TextStyle(color: AppTheme.textMuted)));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProvincialBloc>(),
                      child: const CreateRecintoPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nuevo Recinto'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppTheme.danger.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text('Error al cargar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              onPressed: () => context.read<ProvincialBloc>().add(LoadRecintosEvent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProvincialBloc>().add(LoadRecintosEvent());
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.location_city_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No hay recintos registrados',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Presiona el botón + para crear uno nuevo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildRecintoCard(BuildContext context, dynamic recinto) {
    final hasCoordinador = recinto.coordinadorId != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recinto.nombre,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recinto.canton} · ${recinto.parroquia}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (hasCoordinador)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: AppTheme.statusBadge(color: AppTheme.success),
                    child: const Text(
                      'Coord. Asignado',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.success),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProvincialBloc>(),
                            child: CreateCoordinadorPage(
                              recintoId: recinto.id,
                              nombreRecinto: recinto.nombre,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Asignar', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.warning,
                      side: BorderSide(color: AppTheme.warning.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.table_rows, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${recinto.cantidadMesas} mesas',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Avance de Escrutinio',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: di.sl<GetActasCountByRecintoUseCase>()(recinto.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(minHeight: 6);
                }
                int actasSubidas = 0;
                if (snapshot.hasData) {
                  snapshot.data!.fold((l) => null, (r) => actasSubidas = r);
                }
                int actasTotalesEsperadas = recinto.cantidadMesas * 2;
                double progreso = actasTotalesEsperadas == 0 ? 0 : actasSubidas / actasTotalesEsperadas;
                final progressColor = progreso == 1.0 ? AppTheme.success : AppTheme.primary;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progreso,
                        backgroundColor: AppTheme.surfaceMuted,
                        color: progressColor,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$actasSubidas / $actasTotalesEsperadas actas',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        Text(
                          '${(progreso * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: progressColor),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    final mockUser = UserEntity(
                      id: user.id,
                      cedula: user.cedula,
                      nombres: 'Auditoría: ${recinto.nombre}',
                      apellidos: user.apellidos,
                      rol: 'coordinador_recinto',
                      recintoId: recinto.id,
                      requiresPasswordChange: false,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecintoDashboard(user: mockUser),
                      ),
                    );
                  },
                  icon: const Icon(Icons.table_view, size: 16),
                  label: const Text('Auditar Mesas'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => VotosConsolidadosPage(user: user)),
                    );
                  },
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Ver votos'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}