import 'package:jserializer/jserializer.dart';

@JSerializable()
class Model1 {
  const Model1({
    this.intField = 2,
    required this.intField2,
    required this.stringField,
    required this.stringFieldList,
  });

  @JAdapters.intNullable()
  final int? intField;
  final int? intField2;
  final String stringField;
  final List<String>? stringFieldList;
}

@JSerializable()
class Model2 {
  const Model2({
    required this.model1,
    required this.models1,
  });

  final Model1 model1;
  final List<Model1> models1;
}

@JSerializable()
class Model4 {
  const Model4({
    this.someText = 'Hey',
    this.listText = const [],
    this.listListText = const [],
    this.models = const [],
  });

  final String someText;
  final List<String> listText;
  final List<List<String>> listListText;
  final List<List<Model1>> models;
}

@JSerializable()
class Model3<T> {
  const Model3({
    required this.model1,
    required this.value,
    required this.extras,
  });

  final Model2 model1;
  final T value;
  final Map<String, dynamic> extras;
}

class IntStringAdapter extends CustomAdapter<int, String> {
  const IntStringAdapter([this.fallbackValue]);

  final int? fallbackValue;

  @override
  int fromJson(String json) =>
      int.tryParse(json) ??
      fallbackValue ??
      (throw FormatException(
        'Invalid String value',
        json,
      ));

  @override
  String toJson(int model) => model.toString();
}
