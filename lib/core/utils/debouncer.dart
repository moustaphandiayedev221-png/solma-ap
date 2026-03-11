import 'dart:async';

/// Debouncer pour limiter la fréquence d'exécution d'une action.
///
/// Usage :
/// ```dart
/// final _debouncer = Debouncer(milliseconds: 300);
/// _debouncer.run(() => _doSomething());
/// ```
class Debouncer {
  Debouncer({this.milliseconds = 300});

  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Exécute immédiatement si aucun timer n'est actif, sinon debounce.
  /// Utile pour les actions "premier clic immédiat, suivants debounced".
  void runImmediate(void Function() action) {
    if (_timer == null || !_timer!.isActive) {
      action();
      _timer = Timer(Duration(milliseconds: milliseconds), () {});
    } else {
      run(action);
    }
  }

  void dispose() {
    _timer?.cancel();
  }

  bool get isActive => _timer?.isActive ?? false;
}
