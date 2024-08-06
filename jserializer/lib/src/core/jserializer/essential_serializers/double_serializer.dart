import 'package:jserializer/jserializer.dart';

class DoubleSerializer extends Serializer<double, dynamic> {
  const DoubleSerializer({super.jSerializer});

  @override
  dynamic toJson(double model) => model;

  @override
  Function get decoder => fromJson;

  double fromJson(dynamic json) {
    if (json is num) return json.toDouble();
    if (json is String) {
      return safeLookup(
        call: () => double.tryParse(json) ?? json as double,
      );
    }

    if (json is bool) return json ? 1 : 0;

    return json;
  }
}

class DoubleMocker extends JModelMocker<double> {
  const DoubleMocker({
    super.jSerializer,
    this.maxValue,
    this.minValue,
    this.maxInclusive,
    this.precision,
  });

  final double? maxValue;
  final double? minValue;
  final bool? maxInclusive;
  final int? precision;

  @override
  double createMock([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();
    late final maxValue = (this.maxValue ?? ctx.numMaxValue).toDouble();
    late final minValue = (this.minValue ?? ctx.numMinValue).toDouble();
    late final inclusive = maxInclusive ?? ctx.numMaxInclusive;
    late final precision = this.precision ?? ctx.numPrecision;

    return ctx.getValue<double>(
      randomizer: (random) {
        return random.nextDoubleInRange(
          minValue,
          maxValue,
          inclusive: inclusive,
          precision: precision ?? random.nextIntInRange(0, 4),
        );
      },
      fallback: () => 0,
    );
  }
}
