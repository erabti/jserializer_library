import 'package:jserializer/src/core/jserializer/jserializer_impl.dart';
import 'package:jserializer/src/core/model_serializer/model_serializer_base.dart';
import 'package:jserializer/src/type_plus/type_plus.dart';

typedef JSerializerFactory<T> = Serializer<T> Function(
  JSerializerInterface s,
);

abstract class JSerializerInterface {
  T fromJson<T>(dynamic json);

  T fromMap<T>(Map<String, dynamic> json);

  List<T> fromList<T>(List list);

  T fromJsonGeneric<T, R>(dynamic json);

  T fromJsonGeneric2<T, A, B>(dynamic json);

  T fromJsonGeneric3<T, A, B, C>(dynamic json);

  toJson(model);

  Serializer serializerOf<T>([Type? t]);

  ModelSerializer<T> modelSerializerOf<T>([Type? t]);
}

abstract class JSerializer {
  const JSerializer._();

  static late final _instance = JSerializerImpl();

  static JSerializerInterface get i => _instance;

  static T fromMap<T>(Map<String, dynamic> json) => i.fromMap<T>(json);

  static List<T> fromList<T>(List list) => i.fromList<T>(list);

  static T fromJsonGeneric<T, R>(dynamic json) => i.fromJsonGeneric<T, R>(json);

  static T fromJsonGeneric2<T, A, B>(dynamic json) =>
      i.fromJsonGeneric2<T, A, B>(json);

  static T fromJsonGeneric3<T, A, B, C>(dynamic json) =>
      i.fromJsonGeneric3<T, A, B, C>(json);

  static T fromJson<T>(Object json) => i.fromJson<T>(json);

  static toJson(model) => i.toJson(model);

  static Serializer serializerOf<T>([Type? t]) => i.serializerOf<T>(t);

  static ModelSerializer<T> modelSerializerOf<T>([Type? t]) =>
      i.modelSerializerOf<T>(t);

  static void registerType<T>(Function typeFactory) {
    TypePlus.addFactory(typeFactory);
    SuperTypeResolver.registerType<T>(typeFactory);
  }

  static void registerSerializer<T>(JSerializerFactory<T> factory) {
    _instance.addSerializerFactory<T>(factory);
  }

  static void register<T>(JSerializerFactory<T> factory, Function typeFactory) {
    registerType<T>(typeFactory);
    registerSerializer<T>(factory);
  }
}
