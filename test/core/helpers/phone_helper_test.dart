import 'package:construction_app/core/helpers/phone_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneHelper.parseInitialPhone', () {
    test('parses German international number into DE country and national digits', () {
      final parsed = PhoneHelper.parseInitialPhone('+49 170 1234567');
      expect(parsed.country.code, 'DE');
      expect(parsed.nationalNumber, '1701234567');
      expect(parsed.completeNumber, '+491701234567');
    });

    test('parses Bangladesh international number into BD country', () {
      final parsed = PhoneHelper.parseInitialPhone('+8801712345678');
      expect(parsed.country.code, 'BD');
      expect(parsed.nationalNumber, '1712345678');
      expect(parsed.completeNumber, '+8801712345678');
    });

    test('falls back to DE for national-only number', () {
      final parsed = PhoneHelper.parseInitialPhone('0125456566');
      expect(parsed.country.code, 'DE');
      expect(parsed.nationalNumber, '0125456566');
    });
  });

  group('PhoneHelper.validate', () {
    final germany = PhoneHelper.findCountryByIso('DE');
    final us = PhoneHelper.findCountryByIso('US');

    test('rejects empty, non-numeric, repeating, too short, and too long', () {
      expect(
        PhoneHelper.validate(nationalNumber: '', country: germany),
        isNotNull,
      );
      expect(
        PhoneHelper.validate(nationalNumber: '123abc456', country: germany),
        isNotNull,
      );
      expect(
        PhoneHelper.validate(nationalNumber: '000000000', country: germany),
        isNotNull,
      );
      expect(
        PhoneHelper.validate(nationalNumber: '111111111', country: germany),
        isNotNull,
      );
      expect(
        PhoneHelper.validate(nationalNumber: '12345', country: germany),
        isNotNull,
      );
      expect(
        PhoneHelper.validate(nationalNumber: '123456789012345', country: us),
        isNotNull,
      );
    });

    test('accepts valid country phone numbers', () {
      expect(
        PhoneHelper.validate(nationalNumber: '1701234567', country: germany),
        isNull,
      );
      expect(
        PhoneHelper.validate(nationalNumber: '4155550199', country: us),
        isNull,
      );
    });
  });
}
