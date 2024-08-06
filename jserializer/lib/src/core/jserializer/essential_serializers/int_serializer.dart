import 'package:jserializer/jserializer.dart';

class IntSerializer extends Serializer<int, dynamic> {
  const IntSerializer({super.jSerializer});

  @override
  dynamic toJson(int model) => model;

  @override
  Function get decoder => fromJson;

  int fromJson(dynamic json) {
    if (json is int) return json;
    if (json is num) return json.round();
    if (json is String) {
      return safeLookup(
        call: () => num.tryParse(json)?.round() ?? json as int,
      );
    }
    if (json is bool) return json ? 1 : 0;

    return json;
  }
}

class IntMocker extends JModelMocker<int> {
  const IntMocker({
    super.jSerializer,
    this.maxValue,
    this.minValue,
    this.maxInclusive,
  });

  final int? maxValue;
  final int? minValue;
  final bool? maxInclusive;

  @override
  Function get mocker => createMock;

  @override
  int createMock([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();
    final maxValue = (this.maxValue ?? ctx.numMaxValue).toInt();
    final minValue = (this.minValue ?? ctx.numMinValue).toInt();
    final inclusive = maxInclusive ?? ctx.numMaxInclusive;

    return ctx.getValue<int>(
      randomizer: (random) {
        return random.nextIntInRange(
          minValue,
          maxValue,
          inclusive: inclusive,
        );
      },
      fallback: () => 0,
    );
  }
}
