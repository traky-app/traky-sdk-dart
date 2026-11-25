import 'errors.dart';

/// `null` si no hay tipo. `OTHER` si el tipo no se consulta.
enum IdentityKind { cedula, ruc, passport, other }

const _cedulaNames =
    'Con cédula no envíes firstName, lastName ni companyName. La verificación completa el nombre y el apellido.';
const _rucNames =
    'Con RUC no envíes firstName, lastName ni companyName. La verificación completa la razón social.';
const _passportNames =
    'Con pasaporte envía identityNumber, firstName y lastName. Ese documento no se consulta en el registro.';
const _passportCompany =
    'Con pasaporte no envíes companyName. El nombre va en firstName y lastName.';

IdentityKind? identityKind(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final raw = trimmed
      .toUpperCase()
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('Ü', 'U')
      .replaceAll('Ñ', 'N')
      .replaceAll(RegExp(r'[^A-Z0-9_]'), '');
  if (raw.isEmpty) return null;
  if (raw == 'CEDULA' || raw == 'EC_CEDULA') return IdentityKind.cedula;
  if (raw == 'RUC' || raw == 'EC_RUC') return IdentityKind.ruc;
  if (raw == 'PASSPORT' || raw == 'PASAPORTE') return IdentityKind.passport;
  return IdentityKind.other;
}

String? _text(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// Valida el cuerpo antes de enviarlo.
///
/// Cédula y RUC solo llevan el número. Pasaporte lleva número, nombre y apellido.
/// En un update sin [identityType] no se adivina el documento guardado.
void assertCustomerIdentityWrite({
  required bool creating,
  String? identityType,
  String? identityNumber,
  String? firstName,
  String? lastName,
  String? companyName,
}) {
  final kind = creating || identityType != null ? identityKind(identityType) : null;
  if (kind == null || kind == IdentityKind.other) return;

  if (kind == IdentityKind.passport) {
    if (_text(companyName) != null) throw TrakyException(_passportCompany);
    if (_text(firstName) == null || _text(lastName) == null) {
      throw TrakyException(_passportNames);
    }
    final number =
        (_text(identityNumber) ?? '').toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (number.length < 5 || number.length > 20) {
      throw TrakyException(
        'El número de pasaporte debe tener entre 5 y 20 letras o números.',
      );
    }
    return;
  }

  if (_text(firstName) != null ||
      _text(lastName) != null ||
      _text(companyName) != null) {
    throw TrakyException(kind == IdentityKind.cedula ? _cedulaNames : _rucNames);
  }
  final digits = (_text(identityNumber) ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    throw TrakyException(
      kind == IdentityKind.cedula
          ? 'La cédula es obligatoria.'
          : 'El RUC es obligatorio.',
    );
  }
  if (kind == IdentityKind.cedula && digits.length != 10) {
    throw TrakyException('La cédula debe tener 10 dígitos.');
  }
  if (kind == IdentityKind.ruc && digits.length != 13) {
    throw TrakyException('El RUC debe tener 13 dígitos.');
  }
}
