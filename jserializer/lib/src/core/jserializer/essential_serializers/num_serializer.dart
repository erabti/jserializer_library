import 'package:jserializer/jserializer.dart';

class NumSerializer extends Serializer<num, dynamic> {
  const NumSerializer({super.jSerializer});

  @override
  dynamic toJson(num model) => model;

  @override
  Function get decoder => fromJson;

  num fromJson(dynamic json) {
    if (json is num) return json;
    if (json is bool) return json ? 1 : 0;
    if (json is String) {
      return safeLookup(
        call: () => num.tryParse(json) ?? json as num,
      );
    }

    return json;
  }
}

class NumMocker extends JModelMocker<num> {
  const NumMocker({
    super.jSerializer,
    this.maxValue,
    this.minValue,
    this.maxInclusive,
    this.precision,
  });

  final num? maxValue;
  final num? minValue;
  final bool? maxInclusive;
  final int? precision;

  @override
  Function get mocker => createMock;

  @override
  num createMock([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<num>(
      randomizer: (random) {
        final precision = this.precision ?? ctx.numPrecision;
        final shouldBeInt = precision != null && precision == 0;
        late final intVal = jSerializer.createMock<int>(context: context);
        late final doubleVal = jSerializer.createMock<double>(context: context);
        if (shouldBeInt) return intVal;
        if (random.nextBool()) return intVal;
        return doubleVal;
      },
      fallback: () => 0,
    );
  }
}
