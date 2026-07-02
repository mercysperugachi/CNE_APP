import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateRecintoPage extends StatefulWidget {
  const CreateRecintoPage({super.key});

  @override
  State<CreateRecintoPage> createState() => _CreateRecintoPageState();
}

class _CreateRecintoPageState extends State<CreateRecintoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cantonController = TextEditingController();
  final _parroquiaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _mesasController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _cantonController.dispose();
    _parroquiaController.dispose();
    _nombreController.dispose();
    _mesasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ModernAppBar(title: 'Crear Recinto'),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_city_rounded, size: 20, color: AppTheme.secondary),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Complete los datos del nuevo recinto electoral.',
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _cantonController,
                        decoration: AppTheme.modernInput(label: 'Cantón', prefixIcon: Icons.place_outlined),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _parroquiaController,
                        decoration: AppTheme.modernInput(label: 'Parroquia', prefixIcon: Icons.map_outlined),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombreController,
                        decoration: AppTheme.modernInput(label: 'Nombre del Recinto', prefixIcon: Icons.business_outlined),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mesasController,
                        decoration: AppTheme.modernInput(label: 'Cantidad de Mesas (JRV)', prefixIcon: Icons.table_rows_rounded),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: _submitting ? 'Guardando...' : 'Guardar Recinto',
                        icon: _submitting ? null : Icons.save_rounded,
                        isLoading: _submitting,
                        onPressed: _submitting ? null : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _submitting = true);
                            context.read<ProvincialBloc>().add(
                              CreateRecintoEvent(
                                canton: _cantonController.text,
                                parroquia: _parroquiaController.text,
                                nombre: _nombreController.text,
                                cantidadMesas: int.parse(_mesasController.text),
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
