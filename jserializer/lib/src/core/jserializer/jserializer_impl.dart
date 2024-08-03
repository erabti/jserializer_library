import 'dart:collection';

import 'package:jserializer/jserializer.dart';
import 'package:jserializer/src/core/jserializer/essential_serializers.dart';
import 'package:type_plus/type_plus.dart';

typedef BaseTypesSerializersMap = HashMap<Type, SerializerFactory>;
typedef CachedBaseTypesSerializersMap = HashMap<Type, Serializer>;
typedef BaseTypesMockersMap = HashMap<Type, MockerFactory>;

class JSerializerImpl extends JSerializerInterface {
  @override
  T fromJson<T>(dynamic json) {
    if (json is T || json == null) return json as T;
    final serializer = serializerOf<T>();

    if (serializer is! GenericSerializer && T.args.isNotEmpty) {
      throw NonGenericSerializerMisuseError(
        lookupType: T,
        serializer: serializer,
      );
    }
    if (serializer is GenericSerializer) {
      return serializer.fromJson<T>(json);
    }
    if (serializer is ModelSerializer) return serializer.fromJson(json) as T;

    return serializer.decoder(json) as T;
  }

  @override
  toJson(model) {
    final Type type;
    if (model is Map) {
      type = Map;
    } else {
      type = model.runtimeType;
    }

    return serializerOf(type).toJson(model);
  }

  @override
  void register<T>(
    SerializerFactory<T> factory,
    Function typeFactory, {
    MockerFactory<T>? mockFactory,
  }) {
    TypePlus.addFactory(typeFactory);
    serializers[T.base] = factory;
    if (mockFactory != null) mockers[T.base] = mockFactory;
  }

  @override
  void unregister<T>() {
    serializers.remove(T.base);
    mockers.remove(T.base);
  }

  @override
  Serializer serializerOf<T>([Type? t]) {
    final serializer = serializers[(t ?? T).base];
    if (serializer == null) throw UnregisteredSerializableTypeError(T);

    return serializer(this);
  }

  @override
  JMocker mockerOf<T>([Type? t]) {
    final mocker = mockers[(t ?? T).base];
    if (mocker == null) throw UnregisteredMockerTypeError(T);

    return mocker(this);
  }

  @override
  bool hasSerializerOf<T>([Type? t]) => serializers[(t ?? T).base] != null;

  @override
  bool hasMockerOf<T>([Type? t]) => mockers[(t ?? T).base] != null;

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

  late final BaseTypesMockersMap mockers = HashMap()
    ..addAll(
      {
        typeOf<void>(): (i) => PrimitiveMocker<void>(
              jSerializer: i,
              mockBuilder: () {},
            ),
        Null: (i) => PrimitiveMocker<void>(
              jSerializer: i,
              mockBuilder: () {},
            ),
        dynamic: (i) => PrimitiveMocker<void>(
              jSerializer: i,
              mockBuilder: () {},
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
  T createMock<T>({JMockerContext? context}) {
    final mocker = mockerOf<T>();
    final ctxWrapper = CallCountWrapper<JMockerContext>(
      valueBuilder: (count) => (context ?? JMockerContext()).copyWith(
        callCount: count,
      ),
      key: T,
    );

    final ctx = ctxWrapper.getValue();

    if (mocker is JGenericMocker) {
      return mocker.createMock<T>(context: ctx);
    }

    if (mocker is JModelMocker) return mocker.createMock(context: ctx) as T;
    final rawMocker = mocker.mocker;

    if (rawMocker is Function({JMockerContext? context})) {
      return rawMocker(context: ctx) as T;
    }

    if (rawMocker is Function<R>({JMockerContext? context})) {
      return rawMocker<T>(context: ctx) as T;
    }

    return mocker.mocker();
  }
}
