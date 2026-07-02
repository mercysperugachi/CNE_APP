import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/shared_widgets.dart';
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
      body: Column(
        children: [
          const ModernAppBar(title: 'Crear Mesa'),
          Expanded(
            child: BlocListener<RecintoBloc, RecintoState>(
              listener: (context, state) {
                if (state is RecintoError) {
                  setState(() => _submitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger, behavior: SnackBarBehavior.floating),
                  );
                } else if (state is RecintoActionSuccess) {
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
                              child: const Icon(Icons.info_outline, size: 20, color: AppTheme.secondary),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
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
                        decoration: AppTheme.modernInput(label: 'Número o Nombre de la Mesa', prefixIcon: Icons.tag_rounded),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: _submitting ? 'Guardando...' : 'Guardar Mesa',
                        icon: _submitting ? null : Icons.save_rounded,
                        isLoading: _submitting,
                        onPressed: _submitting ? null : () {
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
