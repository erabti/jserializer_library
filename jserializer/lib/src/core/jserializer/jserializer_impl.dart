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
//
// class SuperTypeResolver {
//   static final _types = <Type, dynamic>{
//     typeOf<void>(): (f) => f<void>(),
//     Null: (f) => f<void>(),
//     dynamic: (f) => f<dynamic>(),
//     int: (f) => f<int>(),
//     Object: (f) => f<Object>(),
//     String: (f) => f<String>(),
//     double: (f) => f<double>(),
//     num: (f) => f<num>(),
//     bool: (f) => f<bool>(),
//     List: <T>(f) => f<List<T>>(),
//     Map: <K, V>(f) => f<Map<K, V>>(),
//   };
//
//   static void _registerType<T>(Function fn) {
//     _types[T] = fn;
//   }
//
//   static T _genericCall<T>(Function fn, Type type) {
//     if (type == Null) return fn<void>();
//     final base = type.base;
//     final _fn = _types[base];
//     if (_fn == null) {
//       throw Exception('Cannot generic call of undefined type of $base');
//     }
//     return _fn!.call(fn);
//   }
//
//   static T _genericCallDeep<T>(Function fn, Type type) {
//     final args = type.args;
//     if (args.isNotEmpty) {
//       final base = type.base;
//       switch (args.length) {
//         case 1:
//           final _fn = (<T>() => _types[base].call<T>(fn));
//           return _genericCallDeep(_fn, args[0]);
//         case 2:
//           return _genericCallMulti(
//               <A, B>() => _types[base].call<A, B>(fn), args);
//         case 3:
//           return _genericCallMulti(
//               <A, B, C>() => _types[base].call<A, B, C>(fn), args);
//         case 4:
//           return _genericCallMulti(
//               <A, B, C, D>() => _types[base].call<A, B, C, D>(fn), args);
//       }
//     }
//     final base = type.base;
//
//     try {
//       return _types[base]!.call(fn);
//     } on JSerializationError {
//       rethrow;
//     } catch (e, s) {
//       throw Exception('Error resolving type of $type of base $base: $e\n$s');
//     }
//   }
//
//   static T _genericCallMulti<T>(Function fn, List<Type> typeArgs) {
//     switch (typeArgs.length) {
//       case 0:
//         return fn();
//       case 1:
//         return _genericCallDeep(
//           fn,
//           typeArgs[0],
//         );
//       case 2:
//         return _genericCallDeep(
//           _genericCallDeep(<A>() => <B>() => fn<A, B>(), typeArgs[0]),
//           typeArgs[1],
//         );
//       case 3:
//         return _genericCallDeep(
//           _genericCallDeep(
//               _genericCallDeep(
//                   <A>() => <B>() => <C>() => fn<A, B, C>(), typeArgs[0]),
//               typeArgs[1]),
//           typeArgs[2],
//         );
//       case 4:
//         return _genericCallDeep(
//           _genericCallDeep(
//             _genericCallDeep(
//                 _genericCallDeep(
//                     <A>() => <B>() => <C>() => <D>() => fn<A, B, C, D>(),
//                     typeArgs[0]),
//                 typeArgs[1]),
//             typeArgs[2],
//           ),
//           typeArgs[3],
//         );
//     }
//     throw UnimplementedError();
//   }
//
//   static _castList(Iterable iterable, Type type) =>
//       _genericCall(<T>() => List<T>.from(iterable), type);
// }
