import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';

class CreateMesaPage extends StatefulWidget {
  final String recintoId;
  const CreateMesaPage({super.key, required this.recintoId});

  @override
  State<CreateMesaPage> createState() => _CreateMesaPageState();
}

class _CreateMesaPageState extends State<CreateMesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroMesaController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _numeroMesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Mesa')),
      body: BlocListener<RecintoBloc, RecintoState>(
        listener: (context, state) {
          if (state is RecintoError) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger),
            );
          } else if (state is RecintoActionSuccess) {
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
                      Icon(Icons.table_rows, size: 20, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Registre una nueva mesa electoral (JRV) en este recinto.',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _numeroMesaController,
                  decoration: AppTheme.inputDecoration(label: 'Número o Nombre de la Mesa', prefixIcon: Icons.tag),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _submitting = true);
                            context.read<RecintoBloc>().add(
                              CreateMesaEvent(
                                numeroMesa: _numeroMesaController.text,
                                recintoId: widget.recintoId,
                              ),
                            );
                          }
                        },
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar Mesa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}