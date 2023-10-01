import 'dart:collection';

import 'package:jserializer/src/core/domain/serializers/list_serializer.dart';
import 'package:jserializer/src/core/domain/serializers/map_serializer.dart';
import 'package:jserializer/src/core/jserializer/jserializer.dart';
import 'package:jserializer/src/core/domain/domain.dart';
import 'package:type_plus/type_plus.dart';

typedef BaseTypesSerializersMap = HashMap<Type, SerializerFactory>;
typedef CachedBaseTypesSerializersMap = HashMap<Type, Serializer>;

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
  void register<T>(SerializerFactory<T> factory, Function typeFactory) {
    TypePlus.addFactory(typeFactory);
    serializers[T.base] = factory;
  }

  @override
  void unregister<T>() {
    serializers.remove(T.base);
  }

  @override
  Serializer serializerOf<T>([Type? t]) {
    final serializer = serializers[(t ?? T).base];
    if (serializer == null) throw UnregisteredTypeError(T);

    return serializer(this);
  }

  @override
  bool hasSerializerOf<T>([Type? t]) => serializers[(t ?? T).base] != null;

  late final BaseTypesSerializersMap serializers = HashMap()
    ..addAll(
      {
        typeOf<void>(): (i) => PrimitiveSerializer<void>(jSerializer: i),
        Null: (i) => PrimitiveSerializer<void>(jSerializer: i),
        dynamic: (i) => PrimitiveSerializer<dynamic>(jSerializer: i),
        int: (i) => PrimitiveSerializer<int>(jSerializer: i),
        String: (i) => PrimitiveSerializer<String>(jSerializer: i),
        bool: (i) => PrimitiveSerializer<bool>(jSerializer: i),
        num: (i) => PrimitiveSerializer<num>(jSerializer: i),
        double: (i) => PrimitiveSerializer<double>(jSerializer: i),
        List: (i) => ListSerializer(jSerializer: i),
        Map: (i) => MapSerializer(jSerializer: i),
      },
    );
}
