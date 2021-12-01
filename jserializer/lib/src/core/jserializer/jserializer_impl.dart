import 'dart:collection';

import 'package:jserializer/src/core/jserializer/jserializer.dart';
import 'package:jserializer/src/core/model_serializer/model_serializer_base.dart';
import 'package:jserializer/src/type_plus/type_plus.dart';

typedef BaseTypesSerializersMap = HashMap<Type, JSerializerFactory>;
typedef CachedBaseTypesSerializersMap = HashMap<Type, Serializer>;

class JSerializerImpl extends JSerializerInterface {
  late final BaseTypesSerializersMap serializers = HashMap()
    ..addAll(
      {
        int: (_) => PrimitiveSerializer<int>(),
        String: (_) => PrimitiveSerializer<String>(),
        bool: (_) => PrimitiveSerializer<bool>(),
        num: (_) => PrimitiveSerializer<num>(),
        double: (_) => PrimitiveSerializer<double>(),
        // List: (s) => ListSerializer(s),
      },
    );
  late final CachedBaseTypesSerializersMap _serializers = HashMap();

  @override
  ModelSerializer<T> modelSerializerOf<T>([Type? t]) {
    var serializerType = (t ?? T).base;

    final cachedSerializer = _serializers[serializerType];
    if (cachedSerializer != null) return cachedSerializer as ModelSerializer<T>;

    final serializer = serializers[serializerType];

    if (serializer == null) {
      throw Exception(
        'Cannot find serializer for type of '
        '${serializerType == UnresolvedType ? '$serializerType of ${t ?? T}' : serializerType}',
      );
    }

    return _serializers[serializerType] =
        serializer.call(this) as ModelSerializer<T>;
  }

  @override
  Serializer serializerOf<T>([Type? t]) {
    var serializerType = (t ?? T).base;
    final cachedSerializer = _serializers[serializerType];
    if (cachedSerializer != null) return cachedSerializer;

    final serializer = serializers[serializerType];

    if (serializer == null) {
      print(serializers);
      throw Exception(
        'Cannot find serializer for type of '
        '${serializerType == UnresolvedType ? '$serializerType of ${t ?? T}' : serializerType}',
      );
    }

    return _serializers[serializerType] = serializer.call(this);
  }

  void addSerializerFactory<T>(JSerializerFactory<T> factory) {
    serializers[T.base] = factory;
  }

  List toList(List list, {Type? type}) {
    if (list.isEmpty) return list;
    final first = list.first;
    final serializer = serializerOf(
      type ?? first.runtimeType,
    );
    return List.of(
      list.map((e) => serializer.toJson(e)),
    );
  }

  @override
  List<T> fromList<T>(List list, {Type? type}) {
    final serializer = serializerOf<T>(type);

    if (type != null) {
      return SuperTypeResolver.castList(
        list.map((e) => serializer.decoder(e)),
        type,
      );
    }

    return List<T>.of(
      list.map((e) => serializer.decoder(e)),
    );
  }

  @override
  T fromJsonGeneric<T, R>(
    dynamic json, {
    Type? type,
  }) {
    final _serializer = (serializerOf<T>(type)) as GenericModelSerializer;

    return _serializer.fromJsonGeneric<T, R>(json);
  }

  @override
  T fromJsonGeneric2<T, A, B>(
    dynamic json, {
    Type? type,
  }) {
    final _serializer = (serializerOf<T>(type)) as GenericModelSerializer2;

    return _serializer.fromJsonGeneric<T, A, B>(json);
  }

  @override
  T fromJsonGeneric3<T, A, B, C>(
    dynamic json, {
    Type? type,
  }) {
    final _serializer = (serializerOf<T>(type)) as GenericModelSerializer3;

    return _serializer.fromJsonGeneric<T, A, B, C>(json);
  }

  @override
  T fromMap<T>(Map<String, dynamic> json) => fromJson(json);

  @override
  T fromJson<T>(dynamic json) {
    if (json is T || json == null) {
      return json as T;
    }

    if (json is List) {
      final t = T.resolvedArgsAsType.first;
      final list = fromList(json, type: t);
      final castedList = list as T;
      return castedList;
    }

    final serializer = serializerOf<T>();

    if (serializer is GenericModelSerializerBase) {
      return serializer.decoder<T>(json);
    }

    if (serializer is ModelSerializer) {
      return serializer.fromJson(json) as T;
    }

    return serializer.decoder(json) as T;
  }

  @override
  toJson(model) {
    final Type type;
    if (model is Map) {
      type = Map;
    } else if (model is List) {
      return toList(model);
    } else {
      type = model.runtimeType;
    }

    return serializerOf(type).toJson(model);
  }
}

class SuperTypeResolver {
  static final _types = <Type, dynamic>{
    dynamic: (f) => f<dynamic>(),
    int: (f) => f<int>(),
    Object: (f) => f<Object>(),
    String: (f) => f<String>(),
    double: (f) => f<double>(),
    num: (f) => f<num>(),
    bool: (f) => f<bool>(),
    List: <T>(f) => f<List<T>>(),
    Map: <K, V>(f) => f<Map<K, V>>(),
  };

  static void registerType<T>(Function fn) {
    _types[T] = fn;
  }

  static T genericCall<T>(Function fn, Type type) {
    final base = type.base;
    final _fn = _types[base];
    if (_fn == null) {
      throw Exception('Cannot generic call of undefined type of $base');
    }
    return _fn!.call(fn);
  }

  static T genericCallDeep<T>(Function fn, Type type) {
    final args = type.resolvedArgsAsType;
    if (args.isNotEmpty) {
      final base = type.base;
      switch (args.length) {
        case 1:
          final _fn = (<T>() => _types[base].call<T>(fn));
          return genericCallDeep(_fn, args[0]);
        case 2:
          return genericCallMulti(
              <A, B>() => _types[base].call<A, B>(fn), args);
        case 3:
          return genericCallMulti(
              <A, B, C>() => _types[base].call<A, B, C>(fn), args);
        case 4:
          return genericCallMulti(
              <A, B, C, D>() => _types[base].call<A, B, C, D>(fn), args);
      }
    }
    try {
      return _types[type.base]!.call(fn);
    } catch (e, s) {
      throw Exception('Error resolving type of $type: $e\n$s');
    }
  }

  static T genericCallMulti<T>(Function fn, List<Type> typeArgs) {
    switch (typeArgs.length) {
      case 0:
        return fn();
      case 1:
        return genericCallDeep(
          fn,
          typeArgs[0],
        );
      case 2:
        return genericCallDeep(
          genericCallDeep(<A>() => <B>() => fn<A, B>(), typeArgs[0]),
          typeArgs[1],
        );
      case 3:
        return genericCallDeep(
          genericCallDeep(
              genericCallDeep(
                  <A>() => <B>() => <C>() => fn<A, B, C>(), typeArgs[0]),
              typeArgs[1]),
          typeArgs[2],
        );
      case 4:
        return genericCallDeep(
          genericCallDeep(
            genericCallDeep(
                genericCallDeep(
                    <A>() => <B>() => <C>() => <D>() => fn<A, B, C, D>(),
                    typeArgs[0]),
                typeArgs[1]),
            typeArgs[2],
          ),
          typeArgs[3],
        );
    }
    throw UnimplementedError();
  }

  static castList(Iterable iterable, Type type) =>
      genericCall(<T>() => List<T>.from(iterable), type);
}
