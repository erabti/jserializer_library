
import 'package:jserializer/jserializer.dart';

const jUnion = JUnion();

class JUnion implements JSerializableBase {
  const JUnion({this.typeKey, this.fallbackName});

  final String? typeKey;
  final String? fallbackName;
}

class JUnionValue {
  const JUnionValue({
    this.name,
    this.ignore = false,
  });

  final bool ignore;
  final String? name;
}
