import 'package:jserializer/jserializer.dart';

abstract class ModelSerializer<Model> extends Serializer<Model, Map> {
  const ModelSerializer({super.jSerializer});

  @override
  Function get decoder => fromJson;

  Model fromJson(Map json);
}
