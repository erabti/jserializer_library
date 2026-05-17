import 'package:jserializer/jserializer.dart';

class MapSerializer extends GenericModelSerializer<Map> {
  const MapSerializer({super.jSerializer});

  Map<K, V> _decoder<K, V>(Map json) {
    if (json is Map<K, V>) return json;

    // Fast path for primitive key-value types
    if ((K == String ||
            K == int ||
            K == double ||
            K == num ||
            K == bool ||
            K == dynamic) &&
        (V == String ||
            V == int ||
            V == double ||
            V == num ||
            V == bool ||
            V == dynamic)) {
      return json.cast<K, V>();
    }

    final result = <K, V>{};
    for (final entry in json.entries) {
      result[jSerializer.fromJson<K>(entry.key)] =
          jSerializer.fromJson<V>(entry.value);
    }
    return result;
  }

  @override
  Function get decoder => _decoder;

  @override
  Map toJson(Map model) {
    if (model is Map<String, String> ||
        model is Map<String, num> ||
        model is Map<String, bool>) {
      return model;
    }
    return model.map(
      (k, v) => MapEntry(
        jSerializer.toJson(k),
        jSerializer.toJson(v),
      ),
    );
  }
}

class MapMocker extends JGenericMocker<Map> {
  const MapMocker({super.jSerializer});

  @override
  Function get mocker => _mock;

  Map<K, V> _mock<K, V>([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<Map<K, V>>(
      randomizer: (random) => Map.fromEntries(
        List.generate(
          random.nextInt(ctx.mapMaxCount),
          (index) => MapEntry(
            jSerializer.createMock<K>(context: ctx),
            jSerializer.createMock<V>(context: ctx),
          ),
        ),
      ),
      fallback: () => {
        jSerializer.createMock<K>(context: ctx):
            jSerializer.createMock<V>(context: ctx),
        jSerializer.createMock<K>(context: ctx):
            jSerializer.createMock<V>(context: ctx),
        jSerializer.createMock<K>(context: ctx):
            jSerializer.createMock<V>(context: ctx),
      },
    );
  }
}
