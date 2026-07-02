import 'package:equatable/equatable.dart';

class OrganizacionEntity extends Equatable {
  final String id;
  final String nombre;
  final String siglas;
  final String candidatoNombres;
  final String candidatoApellidos;
  final String dignidad;
  final int numeroLista;
  final String? colorHex;
  final String? logoUrl;

  const OrganizacionEntity({
    required this.id,
    required this.nombre,
    required this.siglas,
    required this.candidatoNombres,
    required this.candidatoApellidos,
    required this.dignidad,
    required this.numeroLista,
    this.colorHex,
    this.logoUrl,
  });

  String get candidatoCompleto => '$candidatoNombres $candidatoApellidos';

  String get nombreCompleto => '$siglas - $candidatoCompleto';

  @override
  List<Object?> get props => [
        id,
        nombre,
        siglas,
        candidatoNombres,
        candidatoApellidos,
        dignidad,
        numeroLista,
        colorHex,
        logoUrl,
      ];
}