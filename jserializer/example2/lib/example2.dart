library example2;

import 'package:example2/jserializer.dart';
import 'package:example2/model/model.dart';
import 'package:jserializer/jserializer.dart';

void main() {
  initializeJSerializer();

  const json = <String, dynamic>{
    'field1': 'Hello',
    'field2': 'Hello2',
    'field3': 'Bye',
    'field4': 'Okay',
  };

  final model = JSerializer.fromJson<Model>(json);
  print(model.extras);
}
