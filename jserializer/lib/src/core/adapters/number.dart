import 'package:jserializer/src/core/core.dart';

mixin _NumAdapterBase<T extends num?, Json> on CustomAdapter<T, Json> {
  T? get fallback;

  bool get handleBool;

  bool _isIdentical<A, N>() => A == N;

  bool _isEqual<A, N>() => _isIdentical<A, N>() || _isIdentical<A, N?>();

  Never _throwError() => throw TypeError();

  @override
  T fromJson(Json json) {
    if (json is T) {
      if (fallback is T) return (json ?? fallback) as T;
      return json;
    }

    if (json == null) return fallback ?? _throwError();

    if (json is String) {
      return (num.tryParse(json) as T?) ?? fallback ?? _throwError();
    }

    if (handleBool && json is bool) {
      final isNum = _isEqual<T, num>();
      final isInt = !isNum && _isEqual<T, int>();
      if (isNum || isInt) return (json ? 1 : 0) as T;
      final isDouble = !isNum && _isEqual<T, double>();
      if (isDouble) return (json ? 1.0 : 0.0) as T;
    }

    _throwError();
  }

  @override
  Json toJson(T model) => model as Json;
}

class JNumAdapter extends CustomAdapter<num, dynamic>
    with _NumAdapterBase<num, dynamic>
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
    with _NumAdapterBase
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
    with _NumAdapterBase
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
    with _NumAdapterBase
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
    with _NumAdapterBase
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
    with _NumAdapterBase
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
