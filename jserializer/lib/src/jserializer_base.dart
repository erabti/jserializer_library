// import 'package:jserializer/src/core/jserializer/jserializer.dart';
// import 'package:type_plus/type_plus.dart';
//
// import 'core/model_serializer/model_serializer_base.dart';
//
// final _typeFactories = [
//   (f) => f<User>(),
//   <T>(f) => f<Wrapper<T>>(),
// ];
//
// class WrapperSerializer extends ModelSerializer<Wrapper> {
//   const WrapperSerializer(JSerializerInterface jSerializer)
//       : super(jSerializer);
//
//   @override
//   Function get $create => <T>(T innerValue) => Wrapper<T>(innerValue);
//
//   @override
//   List<JField<Wrapper>> getFields(List<Type> genericArgs) => [
//         JField(
//           name: 'innerValue',
//           isNullable: true,
//           type: genericArgs[0],
//           valueGetter: (model) => model.innerValue,
//         ),
//       ];
// }
//
// class UserSerializer extends ModelSerializer<User> {
//   const UserSerializer(JSerializerInterface jSerializer) : super(jSerializer);
//
//   @override
//   Function get $create => (String? name) => User(name);
//
//   @override
//   List<JField<User>> getFields(List<Type> genericArgs) {
//     return [
//       JField(
//         name: 'name',
//         type: String,
//         isNullable: true,
//         valueGetter: (model) => model.name,
//       ),
//     ];
//   }
// }
//
// void initializeSerializer() {
//   _typeFactories.forEach(TypePlus.addFactory);
//
//   JSerializer.register<Wrapper>(
//     (s) => WrapperSerializer(s),
//   );
//
//   JSerializer.register<User>(
//     (s) => UserSerializer(s),
//   );
// }
//
// class Wrapper<T> {
//   const Wrapper(this.innerValue);
//
//   final T innerValue;
// }
//
// class User {
//   const User(this.name);
//
//   final String? name;
// }
//
// void main() {
//   initializeSerializer();
//   final json = {
//     'innerValue': [
//       {'name': 'Ali'}
//     ]
//   };
//
//   final Wrapper<List<User>> model = JSerializer.fromJson(json);
//
//   print(JSerializer.fromJson<Wrapper<List<User>>>(JSerializer.toJson(model)));
// }
