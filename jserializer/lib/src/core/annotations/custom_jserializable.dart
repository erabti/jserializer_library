import 'package:jserializer/jserializer.dart';
import 'package:jserializer/src/core/annotations/jserializable_base.dart';

const customJSerializer = CustomJSerializer();

class CustomJSerializer implements JSerializableBase {
  const CustomJSerializer();
}
