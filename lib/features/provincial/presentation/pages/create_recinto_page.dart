import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
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
      appBar: AppBar(title: const Text('Crear Recinto')),
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
                  child: const Row(
                    children: [
                      Icon(Icons.location_city, size: 20, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete los datos del nuevo recinto electoral',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _cantonController,
                  decoration: AppTheme.inputDecoration(label: 'Cantón', prefixIcon: Icons.place_outlined),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parroquiaController,
                  decoration: AppTheme.inputDecoration(label: 'Parroquia', prefixIcon: Icons.map_outlined),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: AppTheme.inputDecoration(label: 'Nombre del Recinto', prefixIcon: Icons.business_outlined),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mesasController,
                  decoration: AppTheme.inputDecoration(label: 'Cantidad de Mesas (JRV)', prefixIcon: Icons.table_rows),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () {
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
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar Recinto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}