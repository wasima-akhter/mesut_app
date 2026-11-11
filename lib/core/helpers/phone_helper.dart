import 'package:intl_phone_field/countries.dart';

import '../localization/app_localization.dart';

class ParsedPhoneNumber {
  const ParsedPhoneNumber({
    required this.country,
    required this.nationalNumber,
    required this.completeNumber,
  });

  final Country country;
  final String nationalNumber;
  final String completeNumber;
}

abstract final class PhoneHelper {
  static const String defaultCountryCode = 'DE';

  static Country findCountryByIso(String isoCode) {
    final normalized = isoCode.trim().toUpperCase();
    return countries.firstWhere(
      (c) => c.code == normalized,
      orElse: () => countries.firstWhere((c) => c.code == defaultCountryCode),
    );
  }

  /// Parses a raw stored phone string (e.g. `+49 170 1234567`, `0125456566`)
  /// into a matching [Country] and stripped national digits.
  static ParsedPhoneNumber parseInitialPhone(
    String? raw, {
    String defaultIsoCode = defaultCountryCode,
  }) {
    final fallbackCountry = findCountryByIso(defaultIsoCode);
    if (raw == null || raw.trim().isEmpty) {
      return ParsedPhoneNumber(
        country: fallbackCountry,
        nationalNumber: '',
        completeNumber: '',
      );
    }

    var cleaned = raw.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('00')) {
      cleaned = '+${cleaned.substring(2)}';
    }

    if (cleaned.startsWith('+')) {
      final digitsAfterPlus = cleaned.substring(1).replaceAll(RegExp(r'\D'), '');
      final sorted = List<Country>.from(countries)
        ..sort((a, b) => b.fullCountryCode.length.compareTo(a.fullCountryCode.length));

      for (final country in sorted) {
        if (digitsAfterPlus.startsWith(country.fullCountryCode)) {
          final national = digitsAfterPlus.substring(country.fullCountryCode.length);
          return ParsedPhoneNumber(
            country: country,
            nationalNumber: national,
            completeNumber: '+${country.dialCode}$national',
          );
        }
      }
    }

    final digitsOnly = cleaned.replaceAll(RegExp(r'\D'), '');
    return ParsedPhoneNumber(
      country: fallbackCountry,
      nationalNumber: digitsOnly,
      completeNumber:
          digitsOnly.isEmpty ? '' : '+${fallbackCountry.dialCode}$digitsOnly',
    );
  }

  static String localizedCountryName(Country country, String languageCode) {
    final isGerman = languageCode.toLowerCase().startsWith('de');
    if (isGerman) {
      return country.nameTranslations['de'] ?? country.name;
    }
    return country.nameTranslations['en'] ?? country.name;
  }

  static String formatCompleteNumber(Country country, String nationalRaw) {
    final digits = nationalRaw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return '+${country.dialCode}$digits';
  }

  /// Comprehensive validation: required check, numeric format, repeating/zero digits,
  /// country-specific min/max length, and E.164 compliance.
  static String? validate({
    required String nationalNumber,
    required Country country,
    String? languageCode,
  }) {
    final loc = AppLocalization.current;
    final trimmed = nationalNumber.trim();
    if (trimmed.isEmpty) {
      return loc.phoneRequired;
    }

    // Reject non-phone characters (letters, unexpected symbols)
    if (RegExp(r'[^\d\s\-\(\)]').hasMatch(trimmed)) {
      return loc.invalidPhoneFormat;
    }

    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return loc.phoneRequired;
    }

    // Reject all zeros or single repeating digit (e.g. 00000000, 11111111)
    if (RegExp(r'^0+$').hasMatch(digits) ||
        (digits.length >= 4 && digits.split('').toSet().length == 1)) {
      return loc.phoneRepeatingDigits;
    }

    final countryName = localizedCountryName(
      country,
      languageCode ?? loc.localeCode,
    );

    if (digits.length < country.minLength) {
      return loc.phoneTooShort(countryName, '${country.minLength}');
    }

    if (digits.length > country.maxLength) {
      return loc.phoneTooLong(countryName, '${country.maxLength}');
    }

    final complete = '+${country.dialCode}$digits';
    if (!RegExp(r'^\+[1-9]\d{6,15}$').hasMatch(complete)) {
      return loc.invalidPhoneFormat;
    }

    return null;
  }
}
