import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/votos_consolidados_entity.dart';

class DashboardChart extends StatelessWidget {
  final List<VotosConsolidadosEntity> votos;
  final int total;

  const DashboardChart({
    super.key,
    required this.votos,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultados por Lista',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 20),
          ...votos.asMap().entries.map((entry) {
            final idx = entry.key;
            final v = entry.value;
            final pct = total == 0 ? 0.0 : v.totalVotos / total;
            final color = _colorForIndex(idx);
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (v.logoUrl != null && v.logoUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(v.logoUrl!, width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildColorDot(color)),
                        )
                      else
                        _buildColorDot(color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          v.candidatoNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${v.totalVotos}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${(pct * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceMuted,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reportado en ${v.cantidadMesas} mesa(s)',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Color _colorForIndex(int i) {
    const colors = [
      AppTheme.primary,
      AppTheme.ecRed,
      AppTheme.success,
      AppTheme.warning,
      Color(0xFF8B5CF6),
      Color(0xFF14B8A6),
      Color(0xFFF59E0B),
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFF78716C),
    ];
    return colors[i % colors.length];
  }
}