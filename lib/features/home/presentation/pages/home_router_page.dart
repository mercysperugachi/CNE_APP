import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'provincial_dashboard.dart';
import 'recinto_dashboard.dart';
import 'veedor_dashboard.dart';

class HomeRouterPage extends StatelessWidget {
  final UserEntity user;

  const HomeRouterPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Ruteo inteligente basado en el rol del usuario
    switch (user.rol) {
      case AppConstants.rolProvincial:
        return ProvincialDashboard(user: user);
      case AppConstants.rolRecinto:
        return RecintoDashboard(user: user);
      case AppConstants.rolVeedor:
      default:
        return VeedorDashboard(user: user);
    }
  }
}