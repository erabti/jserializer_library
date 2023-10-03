import 'package:jserializer/src/core/annotations/jserializable_base.dart';

enum FieldNameCase { camel, pascal, snake, none }

const jSerializable = JSerializable();

class JSerializable implements JSerializableBase {
  const JSerializable({
    this.filterToJsonNulls,
    this.fieldNameCase,
    this.ignoreAll,
  });

  final FieldNameCase? fieldNameCase;
  final bool? filterToJsonNulls;
  final List<String>? ignoreAll;
}
