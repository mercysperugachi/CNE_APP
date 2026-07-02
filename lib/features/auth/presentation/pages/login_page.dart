import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/val_cedula.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'change_password_page.dart';
import '../../../home/presentation/pages/home_router_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
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
          } else if (state is AuthRequiresPasswordChange) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeRouterPage(user: state.user)),
            );
          } else if (state is AuthRecoveryEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Correo de recuperación enviado'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              // Static Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridBackgroundPainter(),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 440),
                      padding: const EdgeInsets.all(32),
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header & Branding
                            Column(
                              children: [
                                // Ecuador Flag Accent
                                Container(
                                  height: 6,
                                  width: 96,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 2, child: Container(color: AppTheme.primaryContainer)),
                                      Expanded(flex: 1, child: Container(color: AppTheme.secondary)),
                                      Expanded(flex: 1, child: Container(color: AppTheme.tertiary)),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Control Electoral',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sistema de Monitoreo Oficial',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Cédula Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cédula de Identidad', style: Theme.of(context).textTheme.labelLarge),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _cedulaController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ingrese su cédula',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Ingrese su cédula';
                                    if (!CedulaValidator.isValid(value)) return CedulaValidator.formatMessage();
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Password Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Contraseña', style: Theme.of(context).textTheme.labelLarge),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _showRecoverPasswordDialog(context),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      '¿Olvidó su contraseña?',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Submit Action
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    LoginRequestedEvent(
                                      _cedulaController.text,
                                      _passwordController.text,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Ingresar'),
                                  SizedBox(width: 8),
                                  Icon(Icons.login, size: 18),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Security Trust Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.surfaceContainerHigh),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.gpp_good_outlined, size: 16, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text('Conexión Segura CNE', style: Theme.of(context).textTheme.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRecoverPasswordDialog(BuildContext context) {
    final formKeyRecovery = GlobalKey<FormState>();
    final cedulaRecoveryController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Recuperar Contraseña',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          backgroundColor: AppTheme.surface,
          content: Form(
            key: formKeyRecovery,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingresa tu cédula y enviaremos un enlace de recuperación a tu correo electrónico.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: cedulaRecoveryController,
                  decoration: const InputDecoration(
                    labelText: 'Cédula',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese su cédula';
                    if (!CedulaValidator.isValid(v)) return CedulaValidator.formatMessage();
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKeyRecovery.currentState!.validate()) {
                  context.read<AuthBloc>().add(RecoverPasswordRequestedEvent(cedulaRecoveryController.text));
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Enviar Enlace'),
            ),
          ],
        );
      },
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.outlineVariantSolid.withOpacity(0.3)
      ..strokeWidth = 1.0;
      
    const double spacing = 40.0;
    
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
