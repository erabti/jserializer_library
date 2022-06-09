// import 'package:jserializer/jserializer.dart';
//
// class GenericCustomModel<T> {
//   const GenericCustomModel(this.a, {this.value});
//
//   final String a;
//   final T? value;
// }
//
//
// @jSerializable
// class Nested<T> {
//   const Nested({
//     this.a,
//     this.b,
//     required this.c,
//   });
//
//   final int? a;
//   final GenericCustomModel<int>? b;
//   final GenericCustomModel<T?> c;
// }
//
// @customJSerializer
// class GenericCustomModelSerializer
//     extends GenericModelSerializer<GenericCustomModel<dynamic>> {
//   GenericCustomModelSerializer(JSerializerInterface jSerializer)
//       : super(jSerializer);
//
//   GenericCustomModelSerializer.from({required Serializer<dynamic> serializer})
//       : super.from(serializer: serializer);
//
//   static const jsonKeys = {'a', 'value'};
//
//   @override
//   M fromJsonGeneric<M extends GenericCustomModel<dynamic>, T>(dynamic json) {
//     if (json is! Map) throw Exception('Error');
//
//     final a$Value = mapLookup<String>(jsonName: 'a', json: json);
//
//     final value$Json = json['value'];
//
//     final value$Value = safe<T?>(
//       call: () => value$Json == null
//           ? null
//           : getGenericValue<T?>(value$Json, serializer),
//       jsonName: 'value',
//       modelType: M,
//     );
//
//     return GenericCustomModel<T>(a$Value, value: value$Value) as M;
//   }
//
//   @override
//   Map<String, dynamic> toJson(GenericCustomModel<dynamic> model) => {
//         'a': model.a,
//         'value': model.value == null
//             ? null
//             : getGenericValueToJson(model.value!, serializer)
//       };
// }
