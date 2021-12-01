library jserializer;

import 'package:jserializer/src/core/core.dart';

export 'src/src.dart';
export 'src/type_plus/type_plus.dart' show typeOf;

enum FieldNameCase { camel, pascal, snake, none }

class JSerializable {
  const JSerializable({
    this.fromJson,
    this.toJson,
    this.deepToJson,
    this.filterToJsonNulls,
    this.fieldNameCase,
  });

  final FieldNameCase? fieldNameCase;
  final bool? fromJson;
  final bool? toJson;
  final bool? deepToJson;
  final bool? filterToJsonNulls;
}

class JKey {
  const JKey({
    this.name,
    this.adapter,
    this.ignore = false,
  });

  final bool ignore;
  final CustomSerializer? adapter;
  final String? name;
}
