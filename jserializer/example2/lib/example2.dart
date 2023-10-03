library example2;

import 'package:example2/jserializer.dart';
import 'package:example2/model/model.dart';
import 'package:jserializer/jserializer.dart';

void main() {
  initializeJSerializer();

  const modelJson = <String, dynamic>{
    'field1': 'Hello',
    'field2': 'Hello2',
    'field3': 'Bye',
    'field4': 'Okay',
  };

  final model = JSerializer.fromJson<Model?>(modelJson);
  print(model);

  final genericIntModelJson = <String, dynamic>{'value': 1};
  final genericIntModel =
      JSerializer.fromJson<GenericModel<int>?>(genericIntModelJson);
  print(genericIntModel);

  final listJson = <dynamic>[
    {'field1': 'Hello', 'field2': 'Hello2'},
    {'field1': 'Hello', 'field2': 'Hello2'},
  ];
  // final list = JSerializer.fromJson<List<Model>?>(listJson);
  // print(list);
}
