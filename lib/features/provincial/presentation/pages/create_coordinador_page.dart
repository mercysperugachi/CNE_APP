import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../../../../core/utils/val_cedula.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateCoordinadorPage extends StatefulWidget {
  final String recintoId;
  final String nombreRecinto;

  const CreateCoordinadorPage({super.key, required this.recintoId, required this.nombreRecinto});

  @override
  State<CreateCoordinadorPage> createState() => _CreateCoordinadorPageState();
}

class _CreateCoordinadorPageState extends State<CreateCoordinadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ModernAppBar(title: 'Asignar Coordinador', subtitle: widget.nombreRecinto),
          Expanded(
            child: BlocListener<ProvincialBloc, ProvincialState>(
              listener: (context, state) {
                if (state is ProvincialError) {
                  setState(() => _submitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger, behavior: SnackBarBehavior.floating),
                  );
                } else if (state is ProvincialActionSuccess) {
                  setState(() => _submitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ModernCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.info_outline, size: 16, color: AppTheme.secondary),
                                ),
                                const SizedBox(width: 8),
                                const Text('Información', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.secondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Se creará la cuenta con la clave "Ecuador2026" y se enviará un correo de confirmación.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _cedulaController,
                        decoration: AppTheme.modernInput(label: 'Cédula (10 dígitos)', prefixIcon: Icons.badge_outlined),
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (!CedulaValidator.isValid(v)) return CedulaValidator.formatMessage();
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombresController,
                        decoration: AppTheme.modernInput(label: 'Nombres', prefixIcon: Icons.person_outline),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apellidosController,
                        decoration: AppTheme.modernInput(label: 'Apellidos', prefixIcon: Icons.person_outline),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoController,
                        decoration: AppTheme.modernInput(label: 'Teléfono', prefixIcon: Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _correoController,
                        decoration: AppTheme.modernInput(label: 'Correo Electrónico', prefixIcon: Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
                          if (!emailRegex.hasMatch(v)) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: _submitting ? 'Creando...' : 'Crear y Asignar Coordinador',
                        icon: _submitting ? null : Icons.person_add_rounded,
                        isLoading: _submitting,
                        onPressed: _submitting ? null : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _submitting = true);
                            context.read<ProvincialBloc>().add(
                              CreateCoordinadorRecintoEvent(
                                cedula: _cedulaController.text,
                                nombres: _nombresController.text,
                                apellidos: _apellidosController.text,
                                telefono: _telefonoController.text,
                                correo: _correoController.text,
                                recintoId: widget.recintoId,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
