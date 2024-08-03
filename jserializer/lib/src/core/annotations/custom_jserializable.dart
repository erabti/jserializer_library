import 'package:jserializer/jserializer.dart';
import 'package:jserializer/src/core/annotations/jserializable_base.dart';

const customJSerializer = CustomJSerializer();

class CustomJSerializer implements JSerializableBase {
  const CustomJSerializer();
}

class CustomJMocker implements JSerializableBase {
  const CustomJMocker({
    this.applyOnlyToFieldNames,
  });

  final List<String>? applyOnlyToFieldNames;
}

const customJMocker = CustomJMocker();
