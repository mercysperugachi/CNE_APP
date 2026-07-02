import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_theme.dart';
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
      if (mounted) {
        _loadData(context);
      }
    });
  }

  void _loadData(BuildContext context) {
    final dignidad = _tabController.index == 0
        ? AppConstants.dignidadAlcalde
        : AppConstants.dignidadPrefecto;
    _bloc?.add(
      LoadVotosConsolidadosEvent(
        dignidad: dignidad,
        recintoId: _selectedRecintoId,
      ),
    );
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
        final dignidad = _tabController.index == 0
            ? AppConstants.dignidadAlcalde
            : AppConstants.dignidadPrefecto;
        bloc.add(LoadVotosConsolidadosEvent(
          dignidad: dignidad,
          recintoId: _selectedRecintoId,
        ));
        return bloc;
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard de Votos', style: TextStyle(fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _loadData(context),
                  tooltip: 'Actualizar',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: CircleAvatar(
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    child: Icon(Icons.person, color: AppTheme.secondary),
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                onTap: (_) => _loadData(context),
                indicatorColor: AppTheme.primaryContainer,
                indicatorWeight: 4,
                labelColor: AppTheme.onSurface,
                unselectedLabelColor: AppTheme.onSurfaceVariant,
                tabs: const [
                  Tab(icon: Icon(Icons.location_city, size: 18), text: 'ALCALDES'),
                  Tab(icon: Icon(Icons.account_balance, size: 18), text: 'PREFECTOS'),
                ],
              ),
            ),
            body: BlocBuilder<ProvincialBloc, ProvincialState>(
              builder: (context, state) {
                if (state is ProvincialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProvincialError) {
                  return _buildError(context, state.message);
                }
                if (state is ProvincialVotosConsolidadosLoaded) {
                  return _buildContent(context, state);
                }
                return const Center(child: Text('Seleccione una opción', style: TextStyle(color: AppTheme.onSurfaceVariant)));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error.withOpacity(0.7), size: 56),
            const SizedBox(height: 16),
            Text('Error al cargar datos', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              onPressed: () => _loadData(context),
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
      color: AppTheme.primaryContainer,
      onRefresh: () async {
        _loadData(context);
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Panel de Control Provincial', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Vista consolidada de escrutinio y avance de recintos.', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 24),

          // Bento Grid: Main KPI Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outlineVariantSolid),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  color: AppTheme.primaryContainer,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Votos Consolidados - ${state.dignidad}', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text('Escrutinio actual', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.how_to_vote, color: AppTheme.primaryContainer, size: 36),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$total', style: Theme.of(context).textTheme.displayLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('$totalMesas Mesas', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSecondaryContainer)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: total > 0 ? 0.68 : 0.0, // Mock progress, as we don't have total expected
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Chart Section (Original functionality wrapped in design)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Resultados', style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('Ver detalles'),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.votos.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceContainerHigh),
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 56, color: AppTheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'Aún no hay actas registradas para esta dignidad.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineVariantSolid),
              ),
              padding: const EdgeInsets.all(16),
              child: DashboardChart(votos: state.votos, total: total),
            ),
          
          const SizedBox(height: 32),
          // Quick Actions Grid
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariantSolid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppTheme.secondary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}