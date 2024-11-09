import 'package:jserializer/jserializer.dart';
import 'package:type_plus/type_plus.dart';
export 'jserializer_error_handler.dart';
export 'essential_serializers/essential_serializers.dart';

typedef SerializerFactory<T> = Serializer<T, dynamic> Function(
  JSerializerInterface s,
);

typedef MockerFactory<T> = JMocker<T> Function(
  JSerializerInterface s,
);

typedef OnJserializerError = void Function(OnJSerializerErrorArg arg);

typedef FromJsonErrorHandler<ModelT> = JSerializerErrorHandler<ModelT> Function(
  FromJsonErrorHandlerArg<ModelT> arg,
);

typedef ToJsonErrorHandler = dynamic Function(
  ToJsonErrorHandlerArg arg,
);

abstract class JSerializerInterface {
  T fromJson<T>(
    dynamic json, {
    OnJserializerError? onError,
    FromJsonErrorHandler<T>? handleError,
    Type? type,
  });

  T createMock<T>({
    Type? type,
    JMockerContext? context,
    JMocker? overriddenMocker,
  });

  toJson(
    model, {
    OnJserializerError? onError,
    ToJsonErrorHandler? handleError,
  });

  TypeRegistry get typeRegistry;

  /// Returns the serializer for the type of [t] or [T]
  ///
  /// You can either pass the type instance using the [t] param
  /// Or you can pass the type as generic [T] assignment.
  ///
  /// In case both passed, the [t] will be used.
  Serializer serializerOf<T>([Type? t]);

  /// Returns the mocker for the type of [t] or [T]
  ///
  /// You can either pass the type instance using the [t] param
  /// Or you can pass the type as generic [T] assignment.
  ///
  /// In case both passed, the [t] will be used.
  JMocker mockerOf<T>([Type? t]);

  /// Checks if the serializer for the type of [t] or [T] exist
  ///
  /// You can either pass the type instance using the [t] param
  /// Or you can pass the type as generic [T] assignment.
  ///
  /// In case both passed, the [t] will be used.
  bool hasSerializerOf<T>([Type? t]);

  /// Checks if the mocker for the type of [t] or [T] exist
  ///
  /// You can either pass the type instance using the [t] param
  /// Or you can pass the type as generic [T] assignment.
  ///
  /// In case both passed, the [t] will be used.
  bool hasMockerOf<T>([Type? t]);

  /// Registers a new type within [JSerializer] for the type [T]
  ///
  /// [factory] is a function that returns the serializer,
  /// it's a good practice to always pass the passed jSerializer
  /// instance to the serializer constructor
  ///
  /// [typeFactory] a type factory for the registered type:
  /// - if the type is simple (non-generic): (f) => f<User>
  /// - if the type is generic: <T>(f) => f<PagedData<T>>()
  ///
  /// [mockFactory] is a function that returns the mocker,
  void register<T>(
    SerializerFactory<T> factory,
    Function typeFactory, {
    MockerFactory<T> mockFactory,
  });

  /// Registers a new mocker for the type [T]
  void registerMocker<T>(MockerFactory<T> mockFactory);

  /// Unregisters the mocker from the serializers internal memory of the
  /// jserializer instance
  void unregisterMocker<T>();

  /// Unregisters the type from the serializers internal memory of the
  /// jserializer instance
  ///
  /// This does not unregister the typeFactory of the type, only removes the
  /// serializer itself
  void unregister<T>();

  set onError(OnJserializerError? error);

  set fromJsonErrorHandler(FromJsonErrorHandler? error);

  set toJsonErrorHandler(ToJsonErrorHandler? error);

  BaseTypesSerializersMap get serializers;

  BaseTypesMockersMap get mockers;
}

abstract class JSerializer {
  const JSerializer._();

  static final _instance = JSerializerImpl();

  static JSerializerInterface get i => _instance;

  static JSerializerInterface newInstance({
    JSerializerInterface? parent,
    bool forceFresh = false,
  }) {
    final theParent = forceFresh ? null : parent ?? _instance;

    final newInstance = JSerializerImpl(
      typeRegistry: theParent?.typeRegistry,
    );

    if (theParent != null) {
      newInstance.serializers.addAll(theParent.serializers);
      newInstance.mockers.addAll(theParent.mockers);
    }

    return newInstance;
  }

  static T fromJson<T>(
    dynamic json, {
    OnJserializerError? onError,
    FromJsonErrorHandler<T>? handleError,
  }) =>
      i.fromJson<T>(json, onError: onError, handleError: handleError);

  static T createMock<T>({
    JMockerContext? context,
    Type? type,
  }) =>
      i.createMock<T>(
        context: context,
      );

  static toJson(
    model, {
    OnJserializerError? onError,
    ToJsonErrorHandler? handleError,
  }) =>
      i.toJson(model, onError: onError, handleError: handleError);

  static Serializer serializerOf<T>([Type? t]) => i.serializerOf<T>(t);

  bool hasSerializerOf<T>([Type? t]) => i.hasSerializerOf<T>(t);

  static void register<T>(SerializerFactory<T> factory, Function typeFactory) =>
      i.register(factory, typeFactory);
}

class FromJsonErrorHandlerArg<ModelT> {
  const FromJsonErrorHandlerArg({
    required this.typeRegistry,
    required this.json,
    required this.error,
    required this.stackTrace,
    required this.type,
    required this.baseType,
  });

  final TypeRegistry typeRegistry;
  final dynamic json;
  final Object error;
  final StackTrace stackTrace;
  final Type type;
  final Type baseType;

  bool checkIfObjIsModelType(dynamic obj) => obj is ModelT;

  R callWithModelTypeAsGeneric<R>(R Function<MT extends ModelT>() func) {
    return func<ModelT>();
  }

  callWithModelTypeAsGenericBase(Function<MT>() func) {
    return func<ModelT>();
  }

  callWitTypeGenericArgs(Function func) {
    return func.callWith(
      typeRegistry: typeRegistry,
      parameters: [],
      typeArguments:
          ModelT.resolveWith(typeRegistry).argsAsTypes.reversed.toList(),
    );
  }

  bool doesTypeEqualsTypeOf<R>() => ModelT == R;

  bool doesBaseTypeEqualsTypeOf<R>() {
    final modelBase = ModelT.resolveWith(typeRegistry).base;
    final rBase = R.resolveWith(typeRegistry).base;

    return modelBase == rBase;
  }

  bool get doesTypeAcceptNull => ModelT == typeOf<ModelT?>();
}

class ToJsonErrorHandlerArg {
  const ToJsonErrorHandlerArg({
    required this.model,
    required this.error,
    required this.stackTrace,
  });

  final dynamic model;
  final Object error;
  final StackTrace stackTrace;
}

class OnJSerializerErrorArg {
  const OnJSerializerErrorArg({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;
}
