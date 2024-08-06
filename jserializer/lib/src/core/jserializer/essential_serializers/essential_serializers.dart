import 'dart:math' as math;

export 'int_serializer.dart';
export 'double_serializer.dart';
export 'string_serializer.dart';
export 'num_serializer.dart';
export 'bool_serializer.dart';

extension JMockRandomObjX on math.Random {
  int nextIntInRange(
    int min,
    int max, {
    bool? inclusive,
  }) {
    return min + nextInt((max + ((inclusive ?? false) ? 1 : 0)) - min);
  }

  double nextDoubleInRange(
    double min,
    double max, {
    bool? inclusive,
    int? precision,
  }) {
    assert(min < max, 'min must be less than max');
    if (min >= max) return min;

    final range = max - min;
    final randomValue = nextDouble() *
        (range + ((inclusive ?? false) ? double.minPositive : 0));

    final result = min + randomValue;

    if (precision != null) {
      return double.parse(result.toStringAsFixed(precision));
    }

    return result;
  }
}
