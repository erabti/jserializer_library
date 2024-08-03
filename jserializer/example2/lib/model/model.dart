import 'package:jserializer/jserializer.dart';

@JSerializable()
class SomeModel {
  const SomeModel({
    required this.field1,
    required this.field2,
    @JKey.extras(overridesToJsonModelFields: false) this.extras = const {},
  });

  final String field1;
  final String field2;

  final Map<String, dynamic> extras;
}

@JSerializable()
class SomeGenericModel<T> {
  const SomeGenericModel({
    required this.value,
    @JKey.extras() this.extras = const {},
  });

  final T value;
  final Map<String, dynamic> extras;
}


class SomeCustomModel {
  const SomeCustomModel({
    required this.value,
  });

  final String value;
}

@customJSerializer
class SomeCustomModelCustomSerializer
    extends CustomModelSerializer<SomeCustomModel, Map<String, dynamic>> {
  const SomeCustomModelCustomSerializer({super.jSerializer});

  @override
  SomeCustomModel fromJson(Map<String, dynamic> json) {
    return SomeCustomModel(
      value: safeLookup<String>(
        call: () => jSerializer.fromJson<String>(json['value']),
        jsonKey: 'value',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(SomeCustomModel model) {
    return {
      'value': jSerializer.toJson(model.value),
    };
  }
}

@CustomJMocker()
class SomeCustomModelMocker extends JModelMocker<SomeCustomModel> {
  const SomeCustomModelMocker({
    super.jSerializer,
  });

  @override
  SomeCustomModel createMock({JMockerContext? context}) =>
      const SomeCustomModel(value: 'mocked_value');
}
