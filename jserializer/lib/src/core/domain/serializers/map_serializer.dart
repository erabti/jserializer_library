import 'package:jserializer/jserializer.dart';

class MapSerializer extends GenericModelSerializer<Map> {
  const MapSerializer({super.jSerializer});

  Map<K, V> _decoder<K, V>(Map json) {
    if (json is Map<K, V>) return json;

    return json.map<K, V>(
      (key, value) => MapEntry(
        jSerializer.fromJson<K>(key),
        jSerializer.fromJson<V>(value),
      ),
    );
  }

  @override
  Function get decoder => _decoder;

  @override
  Map toJson(Map model) => model.map(
        (k, v) => MapEntry(
          jSerializer.toJson(k),
          jSerializer.toJson(v),
        ),
      );
}
