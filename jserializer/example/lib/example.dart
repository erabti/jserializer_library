// ignore_for_file: type=lint,prefer-match-file-name,newline-before-return,prefer-trailing-comma,long-method,STRICT_RAW_TYPE

import 'package:jserializer/jserializer.dart';

@JSerializable(filterToJsonNulls: true)
class User<T, R> {
  const User({
    required this.name,
    @CustomAdapterImpl() this.email = '',
    required this.a,
    required this.b,
    required this.projects,
    this.projects2 = const [],
  });

  final String? name;
  final String? email;
  final T a;
  final R b;
  final List<Project<Map<int, int>>> projects;
  final List<Project<String>> projects2;

  void method(T other) {
    print('Call backend: $other same type as $a');
  }
}

class CustomAdapterImpl extends CustomAdapter<String?, dynamic> {
  const CustomAdapterImpl();

  @override
  String? fromJson(json) => json;
  @override
  toJson(String? model) => model;
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

@jSerializable
class CustomA {
  const CustomA({
    @AAAdapter() required this.aa,
  });

  final AA aa;
}

enum AA { a, b, c }

class AAAdapter extends CustomAdapter<AA, String> {
  const AAAdapter();

  @override
  AA fromJson(String json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  String toJson(AA model) {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
//
// @customJSerializer
// class OptionSerializer extends GenericModelSerializer<TOption<dynamic>> {
//   OptionSerializer(JSerializerInterface jSerializer) : super(jSerializer);
//
//   static const valueKey = 'value';
//
//   @override
//   Map<String, dynamic> toJson(TOption<dynamic> model) => {
//         valueKey: model.match(
//           jSerializer.toJson,
//           () => null,
//         ),
//       };
//
//   @override
//   M fromJsonGeneric<M extends TOption<dynamic>, T>(dynamic json) {
//     if (json is M) return json;
//     if (json is! Map) throw Exception('Option type is no a Map!\n$json');
//
//     final value$Json = json['value'];
//     if (value$Json == null) {
//       return TOption<T>.none() as M;
//     }
//
//     final value$Value = safe<T>(
//       call: () => getGenericValue<T>(value$Json, serializer),
//       jsonName: valueKey,
//       modelType: M,
//     );
//
//     return TOption<T>.of(value$Value) as M;
//   }
// }
