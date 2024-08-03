import 'package:jserializer/jserializer.dart';

typedef SerializerFactory<T> = Serializer<T, dynamic> Function(
  JSerializerInterface s,
);

typedef MockerFactory<T> = JMocker<T> Function(
  JSerializerInterface s,
);

abstract class JSerializerInterface {
  T fromJson<T>(dynamic json);

  T createMock<T>({JMockerContext? context});

  toJson(model);

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
  void register<T>(
    SerializerFactory<T> factory,
    Function typeFactory, {
    MockerFactory<T> mockFactory,
  });

  /// Unregisters the type from the serializers internal memory of the
  /// jserializer instance
  ///
  /// This does not unregister the typeFactory of the type, only removes the
  /// serializer itself
  void unregister<T>();
}

abstract class JSerializer {
  const JSerializer._();

  static final _instance = JSerializerImpl();

  static JSerializerInterface get i => _instance;

  static T fromJson<T>(json) => i.fromJson<T>(json);

  static T createMock<T>({JMockerContext? context}) => i.createMock<T>(
        context: context,
      );

  static toJson(model) => i.toJson(model);

  static Serializer serializerOf<T>([Type? t]) => i.serializerOf<T>(t);

  bool hasSerializerOf<T>([Type? t]) => i.hasSerializerOf<T>(t);

  static void register<T>(SerializerFactory<T> factory, Function typeFactory) =>
      i.register(factory, typeFactory);
}
