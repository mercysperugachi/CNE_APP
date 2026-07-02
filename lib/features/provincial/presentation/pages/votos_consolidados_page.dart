import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../widgets/dashboard_chart.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';

class VotosConsolidadosPage extends StatefulWidget {
  final UserEntity user;
  const VotosConsolidadosPage({super.key, required this.user});

  @override
  State<VotosConsolidadosPage> createState() => _VotosConsolidadosPageState();
}

class _VotosConsolidadosPageState extends State<VotosConsolidadosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedRecintoId;
  RealtimeSubscription? _subscription;
  ProvincialBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupRealtime();
  }

  void _setupRealtime() {
    final client = di.sl<AppwriteConfig>().client;
    final realtime = Realtime(client);
    _subscription = realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.actasCollectionId}.documents'
    ]);
    _subscription?.stream.listen((response) {
      if (mounted) _loadData(context);
    });
  }

  void _loadData(BuildContext context) {
    final dignidad = _tabController.index == 0
        ? AppConstants.dignidadAlcalde
        : AppConstants.dignidadPrefecto;
    _bloc?.add(LoadVotosConsolidadosEvent(
      dignidad: dignidad,
      recintoId: _selectedRecintoId,
    ));
  }

  @override
  void dispose() {
    _subscription?.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = di.sl<ProvincialBloc>();
        _bloc = bloc;
        bloc.add(LoadVotosConsolidadosEvent(
          dignidad: AppConstants.dignidadAlcalde,
          recintoId: _selectedRecintoId,
        ));
        return bloc;
      },
      child: Scaffold(
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(gradient: AppTheme.headerGradient),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                        child: Row(
                          children: [
                            if (Navigator.of(context).canPop())
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            const Expanded(
                              child: Text(
                                'Dashboard de Votos',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              onPressed: () => _loadData(context),
                              tooltip: 'Actualizar',
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        controller: _tabController,
                        onTap: (_) => _loadData(context),
                        indicatorColor: Colors.white,
                        indicatorWeight: 4,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        tabs: const [
                          Tab(icon: Icon(Icons.location_city_rounded, size: 18), text: 'ALCALDES'),
                          Tab(icon: Icon(Icons.account_balance_rounded, size: 18), text: 'PREFECTOS'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<ProvincialBloc, ProvincialState>(
                  builder: (context, state) {
                    if (state is ProvincialLoading) return const LoadingShimmer();
                    if (state is ProvincialError) {
                      return ErrorState(message: state.message, onRetry: () => _loadData(context));
                    }
                    if (state is ProvincialVotosConsolidadosLoaded) {
                      return _buildContent(context, state);
                    }
                    return const Center(child: Text('Seleccione una opción', style: TextStyle(color: AppTheme.onSurfaceVariant)));
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildContent(BuildContext context, ProvincialVotosConsolidadosLoaded state) {
    final total = state.votos.fold<int>(0, (acc, v) => acc + v.totalVotos);
    final totalMesas = state.votos.fold<int>(0, (acc, v) => acc + v.cantidadMesas);

    return RefreshIndicator(
      onRefresh: () async {
        _loadData(context);
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Panel de Control Provincial', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Vista consolidada de escrutinio y avance de recintos.', style: Theme.of(context).textTheme.bodyLarge),
          ]),
          const SizedBox(height: 20),
          // KPI Card
          ModernCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4, width: 60,
                  decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Votos Consolidados - ${state.dignidad}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Escrutinio actual', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.how_to_vote_rounded, color: AppTheme.primaryContainer, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$total', style: Theme.of(context).textTheme.displayLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('$totalMesas Mesas', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: total > 0 ? 0.68 : 0.0,
                    backgroundColor: AppTheme.surfaceGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(title: 'Resultados'),
              TextButton(
                onPressed: () {},
                child: const Row(children: [Text('Ver detalles'), Icon(Icons.arrow_forward_rounded, size: 16)]),
              ),
            ],
          ),
          if (state.votos.isEmpty)
            ModernCard(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(Icons.inbox_rounded, size: 56, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                const Text('Aún no hay actas registradas para esta dignidad.', textAlign: TextAlign.center),
              ]),
            )
          else
            DashboardChart(votos: state.votos, total: total),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildActionCard('Nueva Acta', Icons.add_box_outlined, context),
              _buildActionCard('Coordinadores', Icons.group_outlined, context),
              _buildActionCard('Incidencias', Icons.warning_amber_outlined, context),
              _buildActionCard('Reportes', Icons.print_outlined, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 24, color: AppTheme.secondary),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
