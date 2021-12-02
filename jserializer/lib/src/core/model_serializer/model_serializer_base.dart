import 'package:jserializer/jserializer.dart';
import 'package:jserializer/src/type_plus/type_plus.dart';

abstract class JSerializableBase<Model> {
  toJson(Model model) => throw UnimplementedError();

  Model fromJson(json) => throw UnimplementedError();
}

abstract class Serializer<Model> {
  Type get modelType => Model;

  Function get decoder => throw UnimplementedError();

  M decode<M extends Model>(json) {
    if (this is GenericModelSerializerBase) return decoder<M>(json);
    return decoder(json) as M;
  }

  const Serializer();

  toJson(Model model);
}

mixin FromJsonAdapter<T> {
  T fromJson(dynamic json);
}

mixin ToJsonAdapter<T> {
  T toJson(dynamic json);
}

abstract class CustomAdapter<Model, Json>
    with FromJsonAdapter<Model>, ToJsonAdapter<Json> {
  const CustomAdapter();
}

abstract class ModelSerializer<Model> extends Serializer<Model> {
  const ModelSerializer();

  @override
  Map<String, dynamic> toJson(Model model) => throw UnimplementedError();

  @override
  Function get decoder => fromJson;

  Model fromJson(json) => throw UnimplementedError();
}

abstract class GenericModelSerializerBase<Model> extends Serializer<Model> {
  const GenericModelSerializerBase({
    this.jSerializer,
    this.serializer,
  });

  final JSerializerInterface? jSerializer;
  final Serializer? serializer;

  M fromJson<M extends Model>(json);

  getGenericValueToJson(model, Serializer? serializer) {
    if (serializer == null) return jSerializer!.toJson(model);
    return serializer.toJson(model);
  }

  T getGenericValue<T>(json, Serializer? serializer) {
    if (serializer == null) return jSerializer!.fromJson<T>(json);
    if (serializer is GenericModelSerializerBase) {
      return serializer.decoder<T>();
    }

    return serializer.decoder(json);
  }

  T getGenericValue1<T, A>(json, Serializer? serializer) {
    if (serializer == null) return jSerializer!.fromJson<T>(json);
    final s = serializer as GenericModelSerializer;
    return s.fromJsonGeneric<T, A>(json);
  }

  T getGenericValue2<T, A, B>(json, Serializer? serializer) {
    if (serializer == null) return jSerializer!.fromJson<T>(json);
    final s = serializer as GenericModelSerializer2;
    return s.fromJsonGeneric<T, A, B>(json);
  }

  T getGenericValue3<T, A, B, C>(json, Serializer? serializer) {
    if (serializer == null) return jSerializer!.fromJson<T>(json);
    final s = serializer as GenericModelSerializer3;
    return s.fromJsonGeneric<T, A, B, C>(json);
  }

  T getGenericValue4<T, A, B, C, D>(json, Serializer? serializer) {
    if (serializer == null) return jSerializer!.fromJson<T>(json);
    final s = serializer as GenericModelSerializer4;
    return s.fromJsonGeneric<T, A, B, C, D>(json);
  }
}

abstract class GenericModelSerializer<Model>
    extends GenericModelSerializerBase<Model> {
  const GenericModelSerializer(JSerializerInterface jSerializer,)
      : super(jSerializer: jSerializer);

  const GenericModelSerializer.from({
    required Serializer serializer,
  }) : super(
    serializer: serializer,
  );

  @override
  Map<String, dynamic> toJson(Model model) => throw UnimplementedError();

  @override
  Function get decoder => fromJson;

  M fromJsonGeneric<M extends Model, T>(json) => throw UnimplementedError();

  @override
  M fromJson<M extends Model>(json) {
    return SuperTypeResolver.genericCallMulti(
      <T>() => fromJsonGeneric<M, T>(json),
      M.resolvedArgsAsType,
    );
  }
}

abstract class GenericModelSerializer2<Model>
    extends GenericModelSerializerBase<Model> {
  const GenericModelSerializer2(JSerializerInterface jSerializer,)
      : serializer2 = null,
        super(jSerializer: jSerializer);

  const GenericModelSerializer2.from({
    required Serializer serializer,
    required Serializer serializer2,
  })
      : serializer2 = serializer2,
        super(serializer: serializer);

  final Serializer? serializer2;

  @override
  Map<String, dynamic> toJson(Model model) => throw UnimplementedError();

  @override
  Function get decoder => fromJson;

  M fromJsonGeneric<M extends Model, A, B>(json) => throw UnimplementedError();

  @override
  M fromJson<M extends Model>(json) {
    return SuperTypeResolver.genericCallMulti(
      <A, B>() => fromJsonGeneric<M, A, B>(json),
      M.resolvedArgsAsType,
    );
  }
}

abstract class GenericModelSerializer3<Model>
    extends GenericModelSerializerBase<Model> {
  const GenericModelSerializer3(JSerializerInterface jSerializer,)
      : serializer2 = null,
        serializer3 = null,
        super(jSerializer: jSerializer);

  const GenericModelSerializer3.from({
    required Serializer serializer,
    required Serializer serializer2,
    required Serializer serializer3,
  })
      : serializer2 = serializer2,
        serializer3 = serializer3,
        super(serializer: serializer);

  final Serializer? serializer2;
  final Serializer? serializer3;

  @override
  Map<String, dynamic> toJson(Model model) => throw UnimplementedError();

  @override
  Function get decoder => fromJson;

  M fromJsonGeneric<M extends Model, A, B, C>(json) =>
      throw UnimplementedError();

  @override
  M fromJson<M extends Model>(json) {
    return SuperTypeResolver.genericCallMulti(
      <A, B, C>() => fromJsonGeneric<M, A, B, C>(json),
      M.resolvedArgsAsType,
    );
  }
}

abstract class GenericModelSerializer4<Model>
    extends GenericModelSerializerBase<Model> {
  const GenericModelSerializer4(JSerializerInterface jSerializer,)
      : serializer2 = null,
        serializer3 = null,
        serializer4 = null,
        super(jSerializer: jSerializer);

  const GenericModelSerializer4.from({
    required Serializer serializer,
    required Serializer serializer2,
    required Serializer serializer3,
    required Serializer serializer4,
  })
      : serializer2 = serializer2,
        serializer3 = serializer3,
        serializer4 = serializer4,
        super(serializer: serializer);

  final Serializer? serializer2;
  final Serializer? serializer3;
  final Serializer? serializer4;

  @override
  Map<String, dynamic> toJson(Model model) => throw UnimplementedError();

  @override
  Function get decoder => fromJson;

  M fromJsonGeneric<M extends Model, A, B, C, D>(json) =>
      throw UnimplementedError();

  @override
  M fromJson<M extends Model>(json) {
    return SuperTypeResolver.genericCallMulti(
      <A, B, C, D>() => fromJsonGeneric<M, A, B, C, D>(json),
      M.resolvedArgsAsType,
    );
  }
}

class PrimitiveSerializer<T> extends Serializer<T> {
  const PrimitiveSerializer();

  @override
  toJson(model) => model;

  @override
  Function get decoder => fromJson;

  T fromJson(json) => json;
}

class ListSerializer<M> extends Serializer<List<M>> {
  const ListSerializer(this.serializer);

  final Serializer serializer;

  @override
  Function get decoder => fromJson;

  @override
  toJson(List<M> model) => model.map((e) => serializer.toJson(e));

  List<M> fromJson(json) =>
      (json as List)
          .map(
            (e) => serializer.decoder(e) as M,
      )
          .toList();
}

class MapSerializer<K, V> extends Serializer<Map<K, V>> {
  const MapSerializer(this.serializer);

  final Serializer serializer;

  @override
  Function get decoder => fromJson;

  @override
  toJson(Map<K, V> model) =>
      model.map(
            (k, v) =>
            MapEntry(
              k,
              serializer.toJson(v),
            ),
      );

  Map<K, V> fromJson(json) =>
      (json as Map).map(
            (k, v) => MapEntry(k, serializer.decoder(v) as V),
      );
}
