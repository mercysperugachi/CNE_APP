import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../provincial/domain/entities/organizacion_entity.dart';
import '../../../provincial/domain/usecases/get_organizaciones_by_dignidad_usecase.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/entities/acta_pendiente_entity.dart';
import '../../domain/services/sharpness_validator.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';

class ActaFormPage extends StatefulWidget {
  final String mesaId;
  final String recintoId;
  final String tipoActa;
  final ActaEntity? actaExistente;

  const ActaFormPage({
    super.key,
    required this.mesaId,
    required this.recintoId,
    required this.tipoActa,
    this.actaExistente,
  });

  @override
  State<ActaFormPage> createState() => _ActaFormPageState();
}

class _ActaFormPageState extends State<ActaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _novedadesController = TextEditingController();
  final Map<int, TextEditingController> _votosControllers = {};
  final _votosBlancosController = TextEditingController(text: '0');
  final _votosNulosController = TextEditingController(text: '0');
  final _totalSufragantesController = TextEditingController(text: '0');

  File? _imageFile;
  String? _existingFotoUrl;
  final ImagePicker _picker = ImagePicker();

  List<OrganizacionEntity> _organizaciones = [];
  bool _loadingOrganizaciones = true;
  bool _isOfflineMode = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (var i = 1; i <= 5; i++) {
      _votosControllers[i] = TextEditingController(text: '0');
    }
    if (widget.actaExistente != null) {
      final acta = widget.actaExistente!;
      _novedadesController.text = acta.novedades;
      _votosControllers[1]!.text = acta.votosCandidato1.toString();
      _votosControllers[2]!.text = acta.votosCandidato2.toString();
      _votosControllers[3]!.text = acta.votosCandidato3.toString();
      _votosControllers[4]!.text = acta.votosCandidato4.toString();
      _votosControllers[5]!.text = acta.votosCandidato5.toString();
      _votosBlancosController.text = acta.votosBlancos.toString();
      _votosNulosController.text = acta.votosNulos.toString();
      _totalSufragantesController.text = acta.totalSufragantes.toString();
      
      if (acta.fotoUrl.isNotEmpty) {
        if (acta.fotoUrl.startsWith('http')) {
          _existingFotoUrl = acta.fotoUrl;
        } else {
          _imageFile = File(acta.fotoUrl);
        }
      }
    }
    _loadOrganizaciones();
  }

  Future<void> _loadOrganizaciones() async {
    final orgUseCase = di.sl<GetOrganizacionesByDignidadUseCase>();
    final dignidad = widget.tipoActa;
    final res = await orgUseCase(dignidad);
    res.fold(
      (failure) {
        setState(() {
          _organizaciones = List.generate(5, (i) => OrganizacionEntity(
            id: 'c${i + 1}',
            nombre: 'Lista ${i + 1}',
            siglas: 'L${i + 1}',
            candidatoNombres: 'Candidato',
            candidatoApellidos: '${i + 1}',
            dignidad: dignidad,
            numeroLista: i + 1,
          ));
          _loadingOrganizaciones = false;
        });
      },
      (orgs) {
        setState(() {
          _organizaciones = orgs;
          _loadingOrganizaciones = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _novedadesController.dispose();
    for (final c in _votosControllers.values) {
      c.dispose();
    }
    _votosBlancosController.dispose();
    _votosNulosController.dispose();
    _totalSufragantesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                SizedBox(width: 12),
                Text('Analizando nitidez de la foto...'),
              ],
            ),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final bool esNitida = await compute(
        _verificarNitidezEnIsolate,
        pickedFile.path,
      );

      if (!esNitida && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.blur_on, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('La foto está borrosa o no es legible. Por favor, tome otra foto con mejor iluminación.'),
                ),
              ],
            ),
            backgroundColor: AppTheme.warning,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      setState(() {
        _imageFile = File(pickedFile.path);
        _existingFotoUrl = null;
      });
    }
  }

  Future<Position?> _obtenerUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showGpsRequiredDialog('Los servicios de ubicación están desactivados. Actívelos para continuar.');
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showGpsRequiredDialog('Se requiere permiso de ubicación para registrar el acta. Otorgue el permiso en los ajustes de la aplicación.');
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showGpsRequiredDialog(
          'Los permisos de ubicación están denegados permanentemente. Abra los ajustes de la aplicación para habilitarlos.',
          showSettingsButton: true,
        );
      }
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showGpsRequiredDialog(String message, {bool showSettingsButton = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: AppTheme.danger, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text('GPS Requerido', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          if (showSettingsButton)
            ElevatedButton.icon(
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('Abrir Ajustes'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Geolocator.openAppSettings();
              },
            ),
        ],
      ),
    );
  }

  Future<bool> _checkOnline() async {
    final svc = di.sl<ConnectivityService>();
    return svc.isOnline();
  }

  void _submitForm() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null && _existingFotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Debe adjuntar la foto del acta'),
            ],
          ),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final v1 = int.tryParse(_votosControllers[1]!.text) ?? 0;
    final v2 = int.tryParse(_votosControllers[2]!.text) ?? 0;
    final v3 = int.tryParse(_votosControllers[3]!.text) ?? 0;
    final v4 = int.tryParse(_votosControllers[4]!.text) ?? 0;
    final v5 = int.tryParse(_votosControllers[5]!.text) ?? 0;
    final blancos = int.tryParse(_votosBlancosController.text) ?? 0;
    final nulos = int.tryParse(_votosNulosController.text) ?? 0;
    final total = int.tryParse(_totalSufragantesController.text) ?? 0;

    if ([v1, v2, v3, v4, v5, blancos, nulos].any((v) => v > total)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Los votos individuales no pueden superar al total de sufragantes.'),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final sumaCalculada = v1 + v2 + v3 + v4 + v5 + blancos + nulos;
    if (sumaCalculada != total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La suma de votos ($sumaCalculada) no coincide con el total de sufragantes ($total).'),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final position = await _obtenerUbicacion();
    if (position == null) return;

    final lat = position.latitude;
    final lng = position.longitude;

    if (!mounted) return;
    setState(() => _submitting = true);

    final online = await _checkOnline();
    if (!mounted) return;
    setState(() => _isOfflineMode = !online);

    if (online) {
      if (!mounted) return;
      context.read<VeedorBloc>().add(
        SubmitActaEvent(
          mesaId: widget.mesaId,
          recintoId: widget.recintoId,
          tipoActa: widget.tipoActa,
          novedades: _novedadesController.text,
          imagePath: _imageFile?.path ?? _existingFotoUrl ?? '',
          votosCandidato1: v1,
          votosCandidato2: v2,
          votosCandidato3: v3,
          votosCandidato4: v4,
          votosCandidato5: v5,
          votosBlancos: blancos,
          votosNulos: nulos,
          totalSufragantes: total,
          latitud: lat,
          longitud: lng,
        ),
      );
    } else {
      final now = DateTime.now();
      final pending = ActaPendienteEntity(
        mesaId: widget.mesaId,
        recintoId: widget.recintoId,
        tipoActa: widget.tipoActa,
        novedades: _novedadesController.text,
        imageLocalPath: _imageFile?.path,
        imageRemoteUrl: _existingFotoUrl,
        votosCandidato1: v1,
        votosCandidato2: v2,
        votosCandidato3: v3,
        votosCandidato4: v4,
        votosCandidato5: v5,
        votosBlancos: blancos,
        votosNulos: nulos,
        totalSufragantes: total,
        latitud: lat,
        longitud: lng,
        estado: ActaSyncStatus.pending,
        createdAt: now,
        updatedAt: now,
      );
      if (!mounted) return;
      context.read<VeedorBloc>().add(SaveActaOfflineEvent(pending));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VeedorBloc, VeedorState>(
      listener: (context, state) {
        if (state is VeedorError) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.danger),
          );
        } else if (state is VeedorActaSubmittedSuccess) {
          setState(() => _submitting = false);
        } else if (state is VeedorActaSavedOffline) {
          setState(() => _submitting = false);
        } else if (state is VeedorSyncResult) {
          if (state.synced > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sincronización: ${state.synced} actas enviadas correctamente'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
          if (state.failed > 0 && state.errors.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fallaron ${state.failed} actas: ${state.errors.first}'),
                backgroundColor: AppTheme.danger,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment, size: 20, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acta de ${widget.tipoActa}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Mesa ${widget.mesaId}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isOfflineMode) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: AppTheme.warning, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Modo offline: los datos se guardarán localmente.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Votos por Organización Política',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            if (_loadingOrganizaciones)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: LinearProgressIndicator(minHeight: 4),
              )
            else
              ..._organizaciones.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final org = entry.value;
                return _buildVoteField(
                  _votosControllers[idx]!,
                  '${org.siglas}',
                  '${org.candidatoNombres} ${org.candidatoApellidos}',
                  logoUrl: org.logoUrl,
                );
              }),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildVoteField(_votosBlancosController, 'Blancos', 'Votos en blanco'),
            _buildVoteField(_votosNulosController, 'Nulos', 'Votos nulos'),
            const SizedBox(height: 4),
            _buildVoteField(
              _totalSufragantesController,
              'Total',
              'Total de Sufragantes',
              isHighlight: true,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _novedadesController,
              decoration: AppTheme.inputDecoration(
                label: 'Novedades (Opcional)',
                prefixIcon: Icons.note_outlined,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            const Text(
              'Foto del Acta Física',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            _buildImageSection(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Cámara'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Galería'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('ENVIAR ACTA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Foto OK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_existingFotoUrl != null && _existingFotoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(_existingFotoUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    } else {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.textMuted),
            SizedBox(height: 8),
            Text('Ninguna foto seleccionada', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      );
    }
  }

  Widget _buildVoteField(TextEditingController controller, String shortLabel, String subtitle, {bool isHighlight = false, String? logoUrl}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (logoUrl != null && logoUrl.isNotEmpty) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 16)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isHighlight ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty && subtitle != shortLabel)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: isHighlight,
                fillColor: isHighlight ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isHighlight ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isHighlight ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isHighlight ? AppTheme.primary : AppTheme.textPrimary,
              ),
              validator: (v) => v!.isEmpty ? 'Req' : null,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _verificarNitidezEnIsolate(String path) async {
  return SharpnessValidator().isSharp(path);
}