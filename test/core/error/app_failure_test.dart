import 'package:colways/core/error/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure', () {
    test('toString includes message and code', () {
      const f = AppFailure(message: 'Test', type: AppFailureType.generic, code: 'ERR');
      expect(f.toString(), contains('Test'));
      expect(f.toString(), contains('ERR'));
    });

    test('toAppFailure on AppFailure returns same', () {
      const f = AppFailure(message: 'M', type: AppFailureType.generic);
      expect(identical(f.toAppFailure(), f), true);
    });

    test('toAppFailure on Object with fallback', () {
      final f = Exception('x').toAppFailure(fallbackMessage: 'Fallback');
      expect(f.message, 'Fallback');
    });
  });
}
