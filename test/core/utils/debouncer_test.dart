import 'package:colways/core/utils/debouncer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debouncer', () {
    test('run executes after delay', () async {
      final debouncer = Debouncer(milliseconds: 50);
      int counter = 0;
      debouncer.run(() => counter++);
      expect(counter, 0);
      await Future.delayed(const Duration(milliseconds: 80));
      expect(counter, 1);
      debouncer.dispose();
    });

    test('run cancels previous call', () async {
      final debouncer = Debouncer(milliseconds: 50);
      int counter = 0;
      debouncer.run(() => counter++);
      debouncer.run(() => counter++);
      debouncer.run(() => counter++);
      await Future.delayed(const Duration(milliseconds: 80));
      expect(counter, 1); // Only the last one fires
      debouncer.dispose();
    });

    test('dispose cancels pending timer', () async {
      final debouncer = Debouncer(milliseconds: 50);
      int counter = 0;
      debouncer.run(() => counter++);
      debouncer.dispose();
      await Future.delayed(const Duration(milliseconds: 80));
      expect(counter, 0);
    });

    test('isActive reflects timer state', () async {
      final debouncer = Debouncer(milliseconds: 50);
      expect(debouncer.isActive, false);
      debouncer.run(() {});
      expect(debouncer.isActive, true);
      await Future.delayed(const Duration(milliseconds: 80));
      expect(debouncer.isActive, false);
      debouncer.dispose();
    });
  });
}
