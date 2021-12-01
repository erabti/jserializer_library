library jserializer;

export 'package:type_plus/type_plus.dart' show typeOf;

export 'src/src.dart';

class JSerializable {
  const JSerializable({
    this.fromJson = true,
    this.toJson = true,
    this.deepToJson = true,
    this.filterToJsonNulls = false,
  });

  final bool fromJson;
  final bool toJson;
  final bool deepToJson;
  final bool filterToJsonNulls;
}

class JKey {
  const JKey({
    this.name,
    this.ignore = false,
  });

  final bool ignore;
  final String? name;
}
