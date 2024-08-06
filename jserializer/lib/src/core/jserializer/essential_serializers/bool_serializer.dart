import 'package:jserializer/jserializer.dart';

class BoolSerializer extends Serializer<bool, dynamic> {
  const BoolSerializer({super.jSerializer});

  @override
  dynamic toJson(bool model) => model;

  @override
  Function get decoder => fromJson;

  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is num) return json != 0;
    if (json is String) return json != 'false' && json != '0';

    return json;
  }
}

class BoolMocker extends JModelMocker<bool> {
  const BoolMocker({super.jSerializer});

  @override
  Function get mocker => createMock;

  @override
  bool createMock([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<bool>(
      randomizer: (random) => random.nextBool(),
      fallback: () => true,
    );
  }
}
