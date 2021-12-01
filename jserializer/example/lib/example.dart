import 'package:example/jserializer.dart';
import 'package:example/json.dart';
import 'package:jserializer/jserializer.dart';

import 'branch.dart';

final j = <dynamic, dynamic>{
  'v': 5, // T
  'location': <dynamic, dynamic>{
    "longitude": "13.126500258349715",
    "latitude": "32.873047700852226"
  },
  'city': <dynamic, dynamic>{"id": 1004, "name": "طرابلس"},
  'name': 'Whatever',
  'isRight': false,
  'value2': {
    'value': [
      [44444]
    ],
  },
  'value3': {
    'a': [55], // T,
    'b': false, // R
  },
  'hi': <dynamic>[true, true, false, false],
  'locations': [
    {'something': 'another thing'}
  ],
  'wrapper': {
    'a': [55], // T,
    'b': 4.3,
  },
  'extras': {'hi': 4324, 'ok': 'hi'},
  'value': //  Wrapper4<int, String, City, List<Branch>>
      {
    'location': <dynamic, dynamic>{
      "longitude": "13.282149196406856",
      "latitude": "32.852010010636796"
    },
    'a': [55, 33, 44],
    'b': 'lksdjldksfj',
    'c': {
      'skdfj': <dynamic, dynamic>{"id": 1004, "name": "طرابلس"},
    },
    'aaa': {
      "sdfkjo": <dynamic, dynamic>{"id": 1004, "name": "asdfsdf"},
    },
    'd': [
      {
        "id": 8658,
        "name": "فرع طريق المشتل",
        "description": "طريق المشتل بجوار جامع شبش",
        "phones": ["0911408686"],
        "emails": ["info@agartrading.com"],
        "location": <String, dynamic>{
          "longitude": "13.282149196406856",
          "latitude": "32.852010010636796"
        },
        "city": [
          <String, dynamic>{"id": 1004, "name": "طرابلس"}
        ]
      },
      {
        "id": 8658,
        "name": "فرع طريق المشتل",
        "description": "طريق المشتل بجوار جامع شبش",
        "phones": ["0911408686"],
        "emails": ["info@agartrading.com"],
        "location": <String, dynamic>{
          "longitude": "13.282149196406856",
          "latitude": "32.852010010636796"
        },
        "city": [
          <String, dynamic>{"id": 1004, "name": "طرابلس"}
        ]
      },
    ],
  },
};

void main() {
  initializeJSerializer();
  final serializer = Model2Serializer.from(
    serializer: PrimitiveSerializer<int>(),
    serializer2: PrimitiveSerializer<bool>(),
  );

  final branches = JSerializer.i.fromJson<List<Branch>>(json);
  print(JSerializer.toJson(branches));
  final model1 = serializer.fromJsonGeneric<Model2<int, bool>, int, bool>(j);
  final model2 = serializer.fromJson<Model2<int, bool>>(j);

  final model3 = JSerializer.fromJsonGeneric2<Model2<int, bool>, int, bool>(j);
  print(model3);
  print(JSerializer.toJson(model3));
  print(JSerializer.toJson(model1));
  print(JSerializer.toJson(model2));
  print(serializer.toJson(model1));
}
