import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
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
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<ProvincialBloc, ProvincialState>(
                builder: (context, state) {
                  if (state is ProvincialLoading) return const LoadingShimmer();
                  if (state is ProvincialError) {
                    return ErrorState(message: state.message, onRetry: () => context.read<ProvincialBloc>().add(LoadRecintosEvent()));
                  }
                  if (state is ProvincialRecintosLoaded) {
                    final recintos = state.recintos;
                    if (recintos.isEmpty) {
                      return const EmptyState(
                        icon: Icons.location_city_outlined,
                        title: 'No hay recintos registrados',
                        subtitle: 'Presiona el botón + para crear uno nuevo.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProvincialBloc>().add(LoadRecintosEvent());
                        await Future<void>.delayed(const Duration(milliseconds: 400));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: recintos.length,
                        itemBuilder: (context, index) => _buildRecintoCard(context, recintos[index]),
                      ),
                    );
                  }
                  return const Center(child: Text('Cargando datos...', style: TextStyle(color: AppTheme.textMuted)));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
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
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded),
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
                    const Text('Coordinador Provincial', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
                    Text(user.nombres, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                tooltip: 'Dashboard de votos',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => VotosConsolidadosPage(user: user)),
                  );
                },
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

  Widget _buildRecintoCard(BuildContext context, dynamic recinto) {
    final hasCoordinador = recinto.coordinadorId != null;
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_city_rounded, size: 22, color: AppTheme.secondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recinto.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${recinto.canton} · ${recinto.parroquia}', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              if (hasCoordinador)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Coord.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.success)),
                )
              else
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProvincialBloc>(),
                          child: CreateCoordinadorPage(recintoId: recinto.id, nombreRecinto: recinto.nombre),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.warning,
                    side: BorderSide(color: AppTheme.warning.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Asignar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.table_rows_rounded, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Text('${recinto.cantidadMesas} mesas', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          const SectionHeader(title: 'Avance de Escrutinio'),
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
              final progressColor = progreso == 1.0 ? AppTheme.success : AppTheme.secondary;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progreso,
                      backgroundColor: AppTheme.surfaceGray,
                      color: progressColor,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$actasSubidas / $actasTotalesEsperadas actas', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      Text('${(progreso * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: progressColor)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  final mockUser = UserEntity(
                    id: user.id, cedula: user.cedula,
                    nombres: 'Auditoría: ${recinto.nombre}',
                    apellidos: user.apellidos,
                    rol: 'coordinador_recinto',
                    recintoId: recinto.id,
                    requiresPasswordChange: false,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RecintoDashboard(user: mockUser)),
                  );
                },
                icon: const Icon(Icons.table_view_rounded, size: 16),
                label: const Text('Auditar Mesas'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => VotosConsolidadosPage(user: user)),
                  );
                },
                icon: const Icon(Icons.bar_chart_rounded, size: 16),
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
    );
  }
}
