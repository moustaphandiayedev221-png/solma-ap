import 'package:colways/core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogger', () {
    test('info does not throw', () {
      expect(() => AppLogger.info('Test', 'Info message'), returnsNormally);
    });

    test('warn does not throw', () {
      expect(() => AppLogger.warn('Test', 'Warning message'), returnsNormally);
    });

    test('error does not throw with all params', () {
      expect(
        () => AppLogger.error(
          'Test',
          'Error message',
          Exception('test'),
          StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('error does not throw without optional params', () {
      expect(() => AppLogger.error('Test', 'Error message'), returnsNormally);
    });
  });
}
