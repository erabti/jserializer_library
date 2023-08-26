import 'package:jserializer/jserializer.dart';

class PrimitiveSerializer<T> extends Serializer<T, T> {
  const PrimitiveSerializer({super.jSerializer});

  @override
  T toJson(T model) => model;

  @override
  Function get decoder => fromJson;

  T fromJson(T json) => json;
}
