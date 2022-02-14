import 'package:jserializer/jserializer.dart';

class JNumToBoolAdapter extends CustomAdapter<bool, num> implements JAdapters {
  const JNumToBoolAdapter({this.fallback});

  final bool? fallback;

  @override
  bool fromJson(num json) {
    final n = json.toDouble();
    if (n == 0.0) return false;
    if (n == 1.0) return true;
    if (fallback != null) return fallback!;

    throw FormatException('Cannot convert num ($json) to bool');
  }

  @override
  num toJson(bool model) => model ? 1 : 0;
}

class JNumToBoolNullableAdapter extends CustomAdapter<bool?, num?>
    implements JAdapters {
  const JNumToBoolNullableAdapter({this.fallback});

  final bool? fallback;

  @override
  bool? fromJson(num? json) {
    final n = json?.toDouble();
    if (n == 0.0) return false;
    if (n == 1.0) return true;
    return fallback;
  }

  @override
  num? toJson(bool? model) {
    if (model == null) return null;

    return model ? 1 : 0;
  }
}
