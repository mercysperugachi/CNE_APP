class CedulaValidator {
  static const List<String> _provinciasValidas = [
    '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
    '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
    '21', '22', '23', '24', '30', '50',
  ];

  static bool isValid(String cedula) {
    if (cedula.isEmpty) return false;

    final clean = cedula.trim();

    if (clean.length != 10) return false;

    if (!RegExp(r'^\d{10}$').hasMatch(clean)) return false;

    final codigoProvincia = clean.substring(0, 2);
    if (!_provinciasValidas.contains(codigoProvincia)) return false;

    final tercerDigito = int.parse(clean[2]);
    if (tercerDigito < 0 || tercerDigito > 5) return false;

    final digitos = clean.split('').map(int.parse).toList();

    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    var suma = 0;

    for (var i = 0; i < 9; i++) {
      var producto = digitos[i] * coeficientes[i];
      if (producto >= 10) {
        producto -= 9;
      }
      suma += producto;
    }

    final digitoVerificadorCalculado = suma % 10 == 0 ? 0 : 10 - (suma % 10);
    final digitoVerificadorReal = digitos[9];

    return digitoVerificadorCalculado == digitoVerificadorReal;
  }

  static String formatMessage() {
    return 'Cédula ecuatoriana inválida. Verifique los 10 dígitos.';
  }
}