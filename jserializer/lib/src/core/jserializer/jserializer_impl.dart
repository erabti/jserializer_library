import 'dart:async';
import 'dart:collection';

import 'package:jserializer/jserializer.dart';
import 'package:type_plus/type_plus.dart' show TypePlus, TypeRegistry, typeOf;

typedef BaseTypesSerializersMap = HashMap<Type, SerializerFactory>;
typedef CachedBaseTypesSerializersMap = HashMap<Type, Serializer>;
typedef BaseTypesMockersMap = HashMap<Type, MockerFactory>;

class JSerializerImpl extends JSerializerInterface {
  JSerializerImpl({
    TypeRegistry? typeRegistry,
  }) : typeRegistry = typeRegistry ?? TypeRegistry.newInstance();

  @override
  OnJserializerError? onError;
  @override
  FromJsonErrorHandler? fromJsonErrorHandler;
  @override
  ToJsonErrorHandler? toJsonErrorHandler;

  @override
  late final BaseTypesSerializersMap serializers = HashMap()
    ..addAll(
      {
        typeOf<void>(): (i) => PrimitiveSerializer<void>(jSerializer: i),
        Null: (i) => PrimitiveSerializer<void>(jSerializer: i),
        dynamic: (i) => PrimitiveSerializer<dynamic>(jSerializer: i),
        int: (i) => IntSerializer(jSerializer: i),
        String: (i) => StringSerializer(jSerializer: i),
        bool: (i) => BoolSerializer(jSerializer: i),
        num: (i) => NumSerializer(jSerializer: i),
        double: (i) => DoubleSerializer(jSerializer: i),
        List: (i) => ListSerializer(jSerializer: i),
        Map: (i) => MapSerializer(jSerializer: i),
      },
    );

  @override
  late final BaseTypesMockersMap mockers = HashMap()
    ..addAll(
      {
        typeOf<void>(): (i) => PrimitiveMocker<void>(
              jSerializer: i,
              mockBuilder: ([ctx]) {},
            ),
        Null: (i) => PrimitiveMocker<void>(
              jSerializer: i,
              mockBuilder: ([ctx]) {},
            ),
        dynamic: (i) => PrimitiveMocker<void>(
              jSerializer: i,
              mockBuilder: ([ctx]) {},
            ),
        int: (i) => IntMocker(jSerializer: i),
        String: (i) => StringMocker(jSerializer: i),
        bool: (i) => BoolMocker(jSerializer: i),
        num: (i) => NumMocker(jSerializer: i),
        double: (i) => DoubleMocker(jSerializer: i),
        List: (i) => ListMocker(jSerializer: i),
        Map: (i) => MapMocker(jSerializer: i),
      },
    );

  @override
  final TypeRegistry typeRegistry;

  late final CachedBaseTypesSerializersMap _cachedSerializers = HashMap();
  late final HashMap<Type, Type> _typeBaseCache = HashMap();
  Serializer? _listSerializerCache;
  Serializer? _mapSerializerCache;

  static const _fromJsonCall = #fromJsonCall;
  static const _toJsonCall = #toJsonCall;

  @override
  T fromJson<T>(
    dynamic json, {
    OnJserializerError? onError,
    FromJsonErrorHandler<T>? handleError,
    Type? type,
  }) {
    // Skip zone creation for nested calls - already inside a serialization zone
    if (Zone.current[_fromJsonCall] != null) {
      return _fromJson<T>(json, type: type);
    }

    return runZoned(
      () {
        T handleFromJsonError(Object error, StackTrace stack) {
          _reportZonedError(error, stack, id: _toJsonCall, onError: onError);

          final handler = handleError ?? fromJsonErrorHandler;
          if (handler != null) {
            final handlerResult = handler(
              FromJsonErrorHandlerArg<T>(
                typeRegistry: typeRegistry,
                json: json,
                error: error,
                stackTrace: stack,
                type: T,
                baseType: _getTypeBase(T),
              ),
            );

            switch (handlerResult) {
              case JSerializerErrorHandlerThrow():
                Error.throwWithStackTrace(
                  handlerResult.error ?? error,
                  handlerResult.stackTrace ?? stack,
                );
              case JSerializerErrorHandlerHandle():
                final value = handlerResult.callback();
                if (value is T) return value;
            }
          }

          Error.throwWithStackTrace(
            error,
            stack,
          );
        }

        try {
          return _fromJson<T>(json, type: type);
        } catch (error, stack) {
          final String? message;
          if (error is TypeError) {
            final expectingJson = error
                .toString()
                .endsWith("is not a subtype of type 'Map<dynamic, dynamic>'");
            if (expectingJson) {
              message =
                  'Expecting a json object (Map) but got a ${json.runtimeType} '
                  'of value: ${json is String && json.isEmpty ? '[empty]' : json}\n'
                  'Original Error: $error';
            } else {
              message = error.toString();
            }
          } else {
            message = null;
          }

          return handleFromJsonError(
            FromJsonException<T>(
              modelType: T,
              error: error,
              message: message,
              stackTrace: stack,
            ),
            stack,
          );
        }
      },
      zoneValues: {_fromJsonCall: true},
    );
  }

  T _fromJson<T>(
    dynamic json, {
    Type? type,
  }) {
    // Fast path: type == null (common from generated code)
    if (type == null) {
      if (json is T || json == null) return json as T;
      final serializer = serializerOf<T>();
      if (serializer is ModelSerializer) return serializer.fromJson(json) as T;
      if (serializer is GenericSerializer) return serializer.fromJson<T>(json);
      return serializer.decoder(json) as T;
    }

    // Full path: explicit type passed (rare, from manual calls)
    final resolvedType = type.resolveWith(typeRegistry);

    final passedTypeCheck = resolvedType.provideTo(
      <T>() => json is T,
    );
    final sameType = json is T && passedTypeCheck;

    if (sameType || json == null) return json as T;
    final serializer = serializerOf<T>(type);

    if (serializer is! GenericSerializer &&
        T.resolveWith(typeRegistry).args.isNotEmpty) {
      throw NonGenericSerializerMisuseException(
        lookupType: T,
        serializer: serializer,
      );
    }

    if (serializer is GenericSerializer) {
      return resolvedType.provideTo(
        <R>() {
          return serializer.fromJson<R>(json) as T;
        },
      );
    }
    if (serializer is ModelSerializer) {
      return serializer.fromJson(json) as T;
    }

    return serializer.decoder(json) as T;
  }

  @override
  toJson(
    model, {
    OnJserializerError? onError,
    ToJsonErrorHandler? handleError,
  }) {
    // Skip zone creation for nested calls - already inside a serialization zone
    if (Zone.current[_toJsonCall] != null) {
      return _toJson(model);
    }

    return runZoned(() {
      try {
        return _toJson(model);
      } catch (error, stack) {
        _reportZonedError(error, stack, id: _toJsonCall, onError: onError);

        final handler = handleError ?? toJsonErrorHandler;

        if (handler != null) {
          final value = handler(
            ToJsonErrorHandlerArg(
              model: model,
              error: error,
              stackTrace: stack,
            ),
          );
          if (value != null) return value;
        }

        Error.throwWithStackTrace(
          error,
          stack,
        );
      }
    }, zoneValues: {_toJsonCall: true});
  }

  void _reportZonedError(
    Object error,
    StackTrace stack, {
    required Symbol id,
    OnJserializerError? onError,
  }) {
    final isFirstCall = Zone.current.parent?[id] == null;
    if (isFirstCall) {
      late final arg = OnJSerializerErrorArg(
        error: error,
        stackTrace: stack,
      );

      onError?.call(arg);
      this.onError?.call(arg);
    }
  }

  _toJson(model) {
    if (model == null || model is String || model is num || model is bool) {
      return model;
    }
    if (model is List) {
      return (_listSerializerCache ??= serializerOf(List)).toJson(model);
    }
    if (model is Map) {
      return (_mapSerializerCache ??= serializerOf(Map)).toJson(model);
    }
    return serializerOf(model.runtimeType).toJson(model);
  }

  Type _getTypeBase(Type type) =>
      _typeBaseCache[type] ??= type.resolveWith(typeRegistry).base;

  @override
  void register<T>(
    SerializerFactory<T> factory,
    Function typeFactory, {
    MockerFactory<T>? mockFactory,
  }) {
    typeRegistry.add(typeFactory);
    _typeBaseCache.clear();
    final base = _getTypeBase(T);
    serializers[base] = factory;
    _cachedSerializers.remove(base);
    _listSerializerCache = null;
    _mapSerializerCache = null;
    if (mockFactory != null) mockers[base] = mockFactory;
  }

  @override
  void registerMocker<T>(MockerFactory<T> mockFactory) {
    mockers[_getTypeBase(T)] = mockFactory;
  }

  @override
  void unregisterMocker<T>() {
    mockers.remove(_getTypeBase(T));
  }

  @override
  void unregister<T>() {
    final base = _getTypeBase(T);
    serializers.remove(base);
    _cachedSerializers.remove(base);
    _listSerializerCache = null;
    _mapSerializerCache = null;
    mockers.remove(base);
  }

  @override
  Serializer serializerOf<T>([Type? t]) {
    if (t == null) {
      final cached = _cachedSerializers[T];
      if (cached != null) return cached;

      final genericType = _getTypeBase(typeOf<T>());
      final factory = serializers[genericType];
      if (factory == null) throw UnregisteredSerializableTypeException(T);

      final serializer = factory(this);
      _cachedSerializers[T] = serializer;
      return serializer;
    }

    // Slow path: explicit type passed (used by _toJson with runtimeType)
    final passedType = _getTypeBase(t);
    final cached = _cachedSerializers[passedType];
    if (cached != null) return cached;

    late final genericType = _getTypeBase(typeOf<T>());
    final factory = serializers[passedType] ?? serializers[genericType];
    if (factory == null) throw UnregisteredSerializableTypeException(t);

    final serializer = factory(this);
    _cachedSerializers[passedType] = serializer;
    return serializer;
  }

  @override
  JMocker mockerOf<T>([Type? t]) {
    final passedType = t != null ? _getTypeBase(t) : null;
    late final genericType = _getTypeBase(typeOf<T>());

    final mocker =
        (t == null ? null : mockers[passedType]) ?? mockers[genericType];

    if (mocker == null) throw UnregisteredMockerTypeException(t ?? T);

    return mocker(this);
  }

  @override
  bool hasSerializerOf<T>([Type? t]) {
    final passedType = t != null ? _getTypeBase(t) : null;
    final genericType = _getTypeBase(typeOf<T>());

    if (t == null) return serializers[genericType] != null;

    return (serializers[passedType] ?? serializers[genericType]) != null;
  }

  @override
  bool hasMockerOf<T>([Type? t]) {
    final passedType = t != null ? _getTypeBase(t) : null;
    final genericType = _getTypeBase(typeOf<T>());

    if (t == null) return mockers[genericType] != null;

    return (mockers[passedType] ?? mockers[genericType]) != null;
  }

  @override
  T createMock<T>({
    Type? type,
    JMockerContext? context,
    JMocker? overriddenMocker,
  }) {
    final mocker = overriddenMocker ?? mockerOf<T>(type);
    final ctxWrapper = CallCountWrapper<JMockerContext>(
      valueBuilder: (count) =>
          (context ?? JMockerContext())..setCallCount(count),
      key: T,
    );

    final ctx = ctxWrapper.getValue();

    if (mocker is JGenericMocker) {
      return mocker.createMock<T>(ctx);
    }

    if (mocker is JModelMocker) return mocker.createMock(ctx) as T;

    if (mocker.mocker is Function([JMockerContext? context])) {
      return mocker.mocker(ctx) as T;
    }

    if (mocker.mocker is Function<R>([JMockerContext? context])) {
      return mocker.mocker<T>(ctx) as T;
    }

    return mocker.mocker();
  }
}
