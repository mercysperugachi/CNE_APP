import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../home/presentation/pages/home_router_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 72, height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, size: 36, color: AppTheme.secondary),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Acción Requerida',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por políticas de seguridad, actualice su contraseña temporal antes de continuar.',
                      style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 32),
                    ModernCard(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _passwordController,
                              decoration: AppTheme.modernInput(
                                label: 'Nueva Contraseña',
                                hint: 'Ingrese su nueva contraseña',
                                prefixIcon: Icons.lock_outline,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 20,
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
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'REQUISITOS DE SEGURIDAD',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  _req(Icons.check_circle_outline, 'Mínimo 8 caracteres'),
                                  const SizedBox(height: 6),
                                  _req(Icons.check_circle_outline, 'Al menos una letra mayúscula'),
                                  const SizedBox(height: 6),
                                  _req(Icons.check_circle_outline, 'Al menos un símbolo (!, @, #, \$, etc.)'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _confirmController,
                              decoration: AppTheme.modernInput(
                                label: 'Confirmar Contraseña',
                                hint: 'Vuelva a ingresar la contraseña',
                                prefixIcon: Icons.lock_clock_outlined,
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            GradientButton(
                              label: 'Actualizar Contraseña',
                              icon: Icons.save_rounded,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    ChangePasswordRequestedEvent(_passwordController.text),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        const Text('Conexión Segura - CNE Ecuador', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _req(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}
