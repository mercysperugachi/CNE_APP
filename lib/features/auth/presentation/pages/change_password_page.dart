import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../home/presentation/pages/home_router_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeRouterPage(user: state.user)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.outlineVariantSolid),
                        ),
                        child: const Icon(Icons.lock_reset, size: 32, color: AppTheme.secondary),
                      ),
                      Text(
                        'Acción Requerida',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Por políticas de seguridad, es necesario que actualice su contraseña temporal en su primer inicio de sesión.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outlineVariantSolid),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // New Password Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nueva Contraseña', style: Theme.of(context).textTheme.labelLarge),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      hintText: 'Ingrese su nueva contraseña',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        ),
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                    obscureText: _obscure,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Ingrese su nueva contraseña';
                                      if (value.length < 8) return 'Mínimo 8 caracteres';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Password Requirements Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.surfaceContainerHigh),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'REQUISITOS DE SEGURIDAD',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildRequirementRow(Icons.check_circle_outline, 'Mínimo 8 caracteres'),
                                    const SizedBox(height: 8),
                                    _buildRequirementRow(Icons.check_circle_outline, 'Al menos una letra mayúscula'),
                                    const SizedBox(height: 8),
                                    _buildRequirementRow(Icons.check_circle_outline, 'Al menos un símbolo (!, @, #, \$, etc.)'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Confirm Password Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Confirmar Nueva Contraseña', style: Theme.of(context).textTheme.labelLarge),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _confirmController,
                                    decoration: const InputDecoration(
                                      hintText: 'Vuelva a ingresar la contraseña',
                                      prefixIcon: Icon(Icons.lock_clock_outlined),
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Action Button
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      ChangePasswordRequestedEvent(_passwordController.text),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: AppTheme.primaryContainer,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 20),
                                    SizedBox(width: 8),
                                    Text('Actualizar Contraseña'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Footer Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: AppTheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('Conexión Segura - CNE Ecuador', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequirementRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}