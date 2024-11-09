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

  static const _fromJsonCall = #fromJsonCall;
  static const _toJsonCall = #toJsonCall;

  @override
  T fromJson<T>(
    dynamic json, {
    OnJserializerError? onError,
    FromJsonErrorHandler<T>? handleError,
    Type? type,
  }) {
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
    final resolvedType = type?.resolveWith(typeRegistry);

    final passedTypeCheck = resolvedType?.provideTo(
          <T>() => json is T,
        ) ??
        true;
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
      if (resolvedType != null) {
        return resolvedType.provideTo(
          <R>() {
            return serializer.fromJson<R>(json) as T;
          },
        );
      }

      return serializer.fromJson<T>(json);
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
    final Type type;
    if (model is Map) {
      type = Map;
    } else {
      type = model.runtimeType;
    }

    return serializerOf(type).toJson(model);
  }

  Type _getTypeBase(Type type) => type.resolveWith(typeRegistry).base;

  @override
  void register<T>(
    SerializerFactory<T> factory,
    Function typeFactory, {
    MockerFactory<T>? mockFactory,
  }) {
    typeRegistry.add(typeFactory);
    serializers[_getTypeBase(T)] = factory;
    if (mockFactory != null) mockers[_getTypeBase(T)] = mockFactory;
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
    serializers.remove(_getTypeBase(T));
    mockers.remove(_getTypeBase(T));
  }

  @override
  Serializer serializerOf<T>([Type? t]) {
    final serializer = serializers[_getTypeBase((t ?? T))];
    if (serializer == null) throw UnregisteredSerializableTypeException(T);

    return serializer(this);
  }

  @override
  JMocker mockerOf<T>([Type? t]) {
    final mocker = mockers[_getTypeBase(t ?? T)];
    if (mocker == null) throw UnregisteredMockerTypeException(T);

    return mocker(this);
  }

  @override
  bool hasSerializerOf<T>([Type? t]) =>
      serializers[_getTypeBase(t ?? T)] != null;

  @override
  bool hasMockerOf<T>([Type? t]) => mockers[_getTypeBase(t ?? T)] != null;

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
