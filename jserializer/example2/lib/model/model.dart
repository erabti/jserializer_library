import 'package:jserializer/jserializer.dart';

@JSerializable()
class Model {
  const Model({
    required this.field1,
    required this.field2,
    this.extras = const {},
  });

  final String field1;
  final String field2;

  @JKey.extras(overridesFields: true)
  final Map<String, dynamic> extras;
}
