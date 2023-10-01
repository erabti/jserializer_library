import 'package:jserializer/jserializer.dart';

@JSerializable()
class Model {
  const Model({
    required this.field1,
    required this.field2,
    @JKey.extras(overridesToJsonModelFields: false) this.extras = const {},
  });

  final String field1;
  final String field2;

  final Map<String, dynamic> extras;
}
