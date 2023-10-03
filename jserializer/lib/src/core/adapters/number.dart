import 'package:jserializer/src/core/core.dart';

mixin _NumAdapterBase<T extends num?> on CustomAdapter<T, dynamic> {
  T? get fallback;

  bool get handleBool;

  bool _isIdentical<A, N>() => A == N;

  bool _isEqual<A, N>() => _isIdentical<A, N>() || _isIdentical<A, N?>();

  Never _throwError() => throw TypeError();

  @override
  T fromJson(json) {
    if (json is T) {
      if (fallback is T) return (json ?? fallback) as T;
      return json;
    }

    if (json == null) return fallback ?? _throwError();

    if (handleBool && json is bool) {
      final isNum = _isEqual<T, num>();
      final isInt = !isNum && _isEqual<T, int>();
      if (isNum || isInt) return (json ? 1 : 0) as T;
      final isDouble = !isNum && _isEqual<T, double>();
      if (isDouble) return (json ? 1.0 : 0.0) as T;
    }

    return (num.tryParse(json.toString()) as T?) ?? fallback ?? _throwError();
  }

  @override
  toJson(T? model) => model;
}

class JNumAdapter extends CustomAdapter<num, dynamic>
    with _NumAdapterBase<num>
    implements JAdapters {
  const JNumAdapter({
    this.fallback,
    this.handleBool = false,
  });

  @override
  final num? fallback;

  @override
  final bool handleBool;
}

class JNumNullableAdapter extends CustomAdapter<num?, dynamic>
    with _NumAdapterBase<num?>
    implements JAdapters {
  const JNumNullableAdapter({
    this.fallback,
    this.handleBool = false,
  });

  @override
  final num? fallback;

  @override
  final bool handleBool;
}

class JIntAdapter extends CustomAdapter<int, dynamic>
    with _NumAdapterBase<int>
    implements JAdapters {
  const JIntAdapter({
    this.fallback,
    this.handleBool = false,
  });

  @override
  final int? fallback;

  @override
  final bool handleBool;
}

class JIntNullableAdapter extends CustomAdapter<int?, dynamic>
    with _NumAdapterBase<int?>
    implements JAdapters {
  const JIntNullableAdapter({
    this.fallback,
    this.handleBool = false,
  });

  @override
  final int? fallback;

  @override
  final bool handleBool;
}

class JDoubleAdapter extends CustomAdapter<double, dynamic>
    with _NumAdapterBase<double>
    implements JAdapters {
  const JDoubleAdapter({
    this.fallback,
    this.handleBool = false,
  });

  @override
  final double? fallback;

  @override
  final bool handleBool;
}

class JDoubleNullableAdapter extends CustomAdapter<double?, dynamic>
    with _NumAdapterBase<double?>
    implements JAdapters {
  const JDoubleNullableAdapter({
    this.fallback,
    this.handleBool = false,
  });

  @override
  final double? fallback;

  @override
  final bool handleBool;
}
