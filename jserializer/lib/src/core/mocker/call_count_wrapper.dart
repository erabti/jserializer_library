class CallCountWrapper<T> {
  CallCountWrapper({
    required this.valueBuilder,
    required this.key,
  });

  static final _callCount = <dynamic, int>{};
  final dynamic key;
  final T Function(int count) valueBuilder;

  T getValue() {
    final callCount = _callCount[key] ?? 0;
    _callCount[key] = callCount + 1;
    return valueBuilder(callCount);
  }

  int get callCount => _callCount[key] ?? 0;
}
