// GENERATED CODE. DO NOT MODIFY. Generated by JSerializerGenerator.

// ignore_for_file: type=lint,prefer-match-file-name,newline-before-return,prefer-trailing-comma,long-method,STRICT_RAW_TYPE

// **************************************************************************
// JSerializer: Serialization Done Right
// **************************************************************************

import 'package:jserializer/jserializer.dart' as js;
import 'package:example2/model/model.dart';

class ModelSerializer extends js.ModelSerializer<Model> {
  const ModelSerializer({super.jSerializer});

  static const jsonKeys = {
    'field1',
    'field2',
  };

  @override
  Model fromJson(json) {
    final field1$Value = safeLookup<String>(
      call: () => json['field1'],
      jsonKey: 'field1',
    );
    final field2$Value = safeLookup<String>(
      call: () => json['field2'],
      jsonKey: 'field2',
    );
    final extras$Value = Map<String, dynamic>.from(json)
      ..removeWhere((
        key,
        _,
      ) =>
          jsonKeys.contains(key));
    return Model(
      field1: field1$Value,
      field2: field2$Value,
      extras: extras$Value,
    );
  }

  @override
  Map<String, dynamic> toJson(Model model) => model.extras
    ..addAll({
      'field1': model.field1,
      'field2': model.field2,
    });
}

class GenericModelSerializer extends js.GenericModelSerializer<GenericModel> {
  GenericModelSerializer({super.jSerializer});

  static const jsonKeys = {'value'};

  GenericModel<T> decode<T>(Map json) {
    final value$Value = safeLookup<T>(
      call: () => jSerializer.fromJson<T>(json['value']),
      jsonKey: 'value',
    );
    final extras$Value = Map<String, dynamic>.from(json)
      ..removeWhere((
        key,
        _,
      ) =>
          jsonKeys.contains(key));
    return GenericModel<T>(
      value: value$Value,
      extras: extras$Value,
    );
  }

  @override
  Function get decoder => decode;
  @override
  Map<String, dynamic> toJson(GenericModel model) =>
      model.extras..addAll({'value': jSerializer.toJson(model.value)});
}

void initializeJSerializer({js.JSerializerInterface? jSerializer}) {
  final instance = jSerializer ?? js.JSerializer.i;
  instance.register<Model>(
    (s) => ModelSerializer(jSerializer: s),
    (Function f) => f<Model>(),
  );
  instance.register<GenericModel>(
    (s) => GenericModelSerializer(jSerializer: s),
    <T>(Function f) => f<GenericModel<T>>(),
  );
}
