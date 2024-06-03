import 'package:jserializer/jserializer.dart';

const jEnum = JEnum();

class JEnum implements JSerializableBase {
  const JEnum();
}

class JEnumKey {
  const JEnumKey({this.isFallback = false});

  const JEnumKey.fallback() : isFallback = true;

  final bool isFallback;
}

const jEnumId = JEnumIdentifier();

class JEnumIdentifier {
  const JEnumIdentifier();
}
