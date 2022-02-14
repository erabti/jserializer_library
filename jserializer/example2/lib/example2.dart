library example2;

import 'package:example2/jserializer.dart';
import 'package:example2/model/model1.dart';
import 'package:jserializer/jserializer.dart';

void main() {
  initializeJSerializer();

  // final error1 = JSerializerLookupError(
  //   fieldName: 'field1',
  //   modelName: int,
  //   message: 'Hello',
  // );
  //
  // final error2 = JSerializerLookupError(
  //   fieldName: 'field2',
  //   modelName: String,
  //   child: error1,
  // );

  const json = <String, dynamic>{
    'model1': {
      'model1': {
        'intField': 1,
        'intField2': 2,
        'stringField': '5',
        'stringFieldList': [],
      },
      'models1': [],
    },
    'value': {
      // 'intField': 1,
      'intField2': 2,
      'stringField': '5',
      'stringFieldList': [],
    },
    'extras': {
      '1': 2,
      '2': 3,
    },
  };

  final model = JSerializer.fromJson<Model3<Model1>>(json);
  print(model);
}
