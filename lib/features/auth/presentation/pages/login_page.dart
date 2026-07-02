import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../../../../core/utils/val_cedula.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'change_password_page.dart';
import '../../../home/presentation/pages/home_router_page.dart';
import 'package:appwrite/appwrite.dart'; // Para el Client
import '../../../../core/config/constants.dart'; // Ruta a tus constantes
import '../../../../core/utils/db_seeder.dart'; // Ruta donde guardaste el seeder

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
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
          return Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.loginGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: const Icon(Icons.how_to_vote_rounded, size: 40, color: AppTheme.secondary),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Control Electoral',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sistema de Monitoreo Oficial',
                            style: TextStyle(fontSize: 14, color: AppTheme.onSurface.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _flagDot(AppTheme.primaryContainer),
                              const SizedBox(width: 4),
                              _flagDot(AppTheme.secondary),
                              const SizedBox(width: 4),
                              _flagDot(AppTheme.tertiary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Bienvenido',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ingrese sus credenciales para acceder',
                            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 28),
                          TextFormField(
                            controller: _cedulaController,
                            decoration: AppTheme.modernInput(
                              label: 'Cédula',
                              hint: 'Ingrese su cédula',
                              prefixIcon: Icons.badge_outlined,
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingrese su cédula';
                              if (!CedulaValidator.isValid(value)) return CedulaValidator.formatMessage();
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: AppTheme.modernInput(
                              label: 'Contraseña',
                              hint: 'Ingrese su contraseña',
                              prefixIcon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showRecoverPasswordDialog(context),
                              child: const Text(
                                '¿Olvidó su contraseña?',
                                style: TextStyle(color: AppTheme.secondary, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GradientButton(
                            label: 'Ingresar',
                            icon: Icons.login_rounded,
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
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.gpp_good_outlined, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 6),
                              const Text(
                                'Conexión Segura - CNE Ecuador',
                                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final client = Client()
                                ..setEndpoint('https://cloud.appwrite.io/v1') // o http://localhost/v1 si es local
                                ..setProject(AppConstants.projectId);
                                
                              final seeder = DatabaseSeeder(client);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cargando datos en Appwrite...')),
                              );
                              
                              await seeder.cargarDatosDePrueba();
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('¡Datos cargados! Revisa la consola y Appwrite.')),
                                );
                              }
                            },
                            icon: const Icon(Icons.cloud_upload, color: Colors.white),
                            label: const Text('CARGAR DATOS DE PRUEBA', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              elevation: 0,
                            ),
                          ),
                        ],
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

  Widget _flagDot(Color color) {
    return Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  void _showRecoverPasswordDialog(BuildContext context) {
    final formKeyRecovery = GlobalKey<FormState>();
    final cedulaRecoveryController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKeyRecovery,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40, height: 4,
                  alignment: Alignment.center,
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recuperar Contraseña',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tu cédula y enviaremos un enlace de recuperación a tu correo.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: cedulaRecoveryController,
                  decoration: AppTheme.modernInput(label: 'Cédula', prefixIcon: Icons.badge_outlined),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese su cédula';
                    if (!CedulaValidator.isValid(v)) return CedulaValidator.formatMessage();
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Enviar Enlace',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    if (formKeyRecovery.currentState!.validate()) {
                      context.read<AuthBloc>().add(RecoverPasswordRequestedEvent(cedulaRecoveryController.text));
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
                const SizedBox(height: 24),

                
              ],
            ),
          ),
        );
      },
    );
  }
  
}
