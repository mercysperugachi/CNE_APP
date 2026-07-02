import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
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
      appBar: AppBar(title: Text('Asignar a: ${widget.nombreRecinto}')),
      body: BlocListener<ProvincialBloc, ProvincialState>(
        listener: (context, state) {
          if (state is ProvincialError) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger),
            );
          } else if (state is ProvincialActionSuccess) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.success),
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
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text('Información', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Se creará la cuenta con la clave "Ecuador2026" y se enviará un correo de confirmación.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _cedulaController,
                  decoration: AppTheme.inputDecoration(label: 'Cédula (10 dígitos)', prefixIcon: Icons.badge_outlined),
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
                  decoration: AppTheme.inputDecoration(label: 'Nombres', prefixIcon: Icons.person_outline),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apellidosController,
                  decoration: AppTheme.inputDecoration(label: 'Apellidos', prefixIcon: Icons.person_outline),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  decoration: AppTheme.inputDecoration(label: 'Teléfono', prefixIcon: Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  decoration: AppTheme.inputDecoration(label: 'Correo Electrónico', prefixIcon: Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
                    if (!emailRegex.hasMatch(v)) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () {
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
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Crear y Asignar Coordinador'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}