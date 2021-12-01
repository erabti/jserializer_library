library jserializer;

export 'src/src.dart';
export 'src/type_plus/type_plus.dart' show typeOf;

enum FieldNameCase { camel, pascal, snake, none }

class JSerializable {
  const JSerializable({
    this.fromJson = true,
    this.toJson = true,
    this.deepToJson = true,
    this.filterToJsonNulls = false,
    this.fieldNameCase = FieldNameCase.none,
  });

  final FieldNameCase fieldNameCase;
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
