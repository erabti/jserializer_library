import 'dart:collection';

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
    serializer.decoder;
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
        int: (i) => IntSerializer(jSerializer: i),
        String: (i) => StringSerializer(jSerializer: i),
        bool: (i) => BoolSerializer(jSerializer: i),
        num: (i) => NumSerializer(jSerializer: i),
        double: (i) => DoubleSerializer(jSerializer: i),
        List: (i) => ListSerializer(jSerializer: i),
        Map: (i) => MapSerializer(jSerializer: i),
      },
    );
}

class BoolSerializer extends Serializer<bool, dynamic> {
  const BoolSerializer({super.jSerializer});

  @override
  dynamic toJson(bool model) => model;

  @override
  Function get decoder => fromJson;

  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is num) return json != 0;
    if (json is String) return json != 'false' && json != '0';

    return json;
  }
}

class NumSerializer extends Serializer<num, dynamic> {
  const NumSerializer({super.jSerializer});

  @override
  dynamic toJson(num model) => model;

  @override
  Function get decoder => fromJson;

  num fromJson(dynamic json) {
    if (json is num) return json;
    if (json is String) return num.parse(json);

    return json;
  }
}

class StringSerializer extends Serializer<String, dynamic> {
  const StringSerializer({super.jSerializer});

  @override
  dynamic toJson(String model) => model;

  @override
  Function get decoder => fromJson;

  String fromJson(dynamic json) {
    if (json is String) return json;
    if (json is num) return json.toString();
    if (json is bool) return json.toString();

    return json;
  }
}

class DoubleSerializer extends Serializer<double, dynamic> {
  const DoubleSerializer({super.jSerializer});

  @override
  dynamic toJson(double model) => model;

  @override
  Function get decoder => fromJson;

  double fromJson(dynamic json) {
    if (json is double) return json;
    if (json is num) return json.toDouble();
    if (json is String) return double.parse(json);

    return json;
  }
}

class IntSerializer extends Serializer<int, dynamic> {
  const IntSerializer({super.jSerializer});

  @override
  dynamic toJson(int model) => model;

  @override
  Function get decoder => fromJson;

  int fromJson(dynamic json) {
    if (json is int) return json;
    if (json is num) return json.round();
    if (json is String) return int.parse(json);

    return json;
  }
}
