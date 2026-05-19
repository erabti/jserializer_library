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
