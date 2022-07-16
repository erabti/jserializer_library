library jserializer;

import 'package:jserializer/src/core/core.dart';

export 'src/src.dart';
export 'src/type_plus/type_plus.dart' show typeOf;

enum FieldNameCase { camel, pascal, snake, none }

const jSerializable = JSerializable();

class JSerializable implements JSerializableBase {
  const JSerializable({
    this.fromJson,
    this.toJson,
    this.deepToJson,
    this.filterToJsonNulls,
    this.fieldNameCase,
    this.guardedLookup,
    this.ignoreAll,
  });

  final FieldNameCase? fieldNameCase;
  final bool? fromJson;
  final bool? toJson;
  final bool? deepToJson;
  final bool? filterToJsonNulls;
  final bool? guardedLookup;
  final List<String>? ignoreAll;
}

const jUnion = JUnion();



class JKey {
  const JKey({
    this.name,
    this.ignore = false,
  })  : isExtras = false,
        overridesFields = false;

  const JKey.extras({
    this.overridesFields = false,
  })  : name = null,
        ignore = true,
        isExtras = true;

  final bool isExtras;
  final bool ignore;
  final String? name;
  final bool overridesFields;
}

class JUnion implements JSerializableBase {
  const JUnion({this.typeKey, this.fallbackName});

  final String? typeKey;
  final String? fallbackName;
}

class JUnionValue {
  const JUnionValue({this.name});

  final String? name;
}
