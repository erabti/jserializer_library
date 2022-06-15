import 'package:jserializer/jserializer.dart';

@JSerializable()
class User<T, R> {
  const User({
    required this.name,
    required this.email,
    required this.a,
    required this.b,
  });

  final String name;
  final String email;
  final T a;
  final R b;

  void method(T other) {
    print('Call backend: $other same type as $a');
  }
}

@jSerializable
class Project<T> {
  const Project({
    required this.field,
    required this.name,
  });

  final T field;
  final String name;
}

class TOption<T> {
  const TOption.of(final T this.value);

  const TOption.none() : value = null;

  TOption.fromNullable(this.value);

  final T? value;

  R match<R>(R Function(T t) some, R Function() none) {
    final val = value;
    if (val == null) return none();
    return some(val);
  }

  @override
  String toString() {
    return 'TOption{value: $value}';
  }
}

@customJSerializer
class OptionSerializer extends GenericModelSerializer<TOption<dynamic>> {
  OptionSerializer(JSerializerInterface jSerializer) : super(jSerializer);

  OptionSerializer.from({required Serializer<dynamic> serializer})
      : super.from(serializer: serializer);

  static const valueKey = 'value';

  @override
  Map<String, dynamic> toJson(TOption<dynamic> model) => {
        valueKey: model.match(
          (t) => getGenericValueToJson(t, serializer),
          () => null,
        ),
      };

  @override
  M fromJsonGeneric<M extends TOption<dynamic>, T>(dynamic json) {
    if (json is M) return json;
    if (json is! Map) throw Exception('Option type is no a Map!\n$json');

    final value$Json = json['value'];
    if (value$Json == null) {
      return TOption<T>.none() as M;
    }

    final value$Value = safe<T>(
      call: () => getGenericValue<T>(value$Json, serializer),
      jsonName: valueKey,
      modelType: M,
    );

    return TOption<T>.of(value$Value) as M;
  }
}
