import 'package:code_builder/code_builder.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';

class ToJsonGenerator {
  ToJsonGenerator({
    required this.modelConfig,
    required this.config,
  });

  final ModelConfig modelConfig;
  final JSerializable config;

  bool get isGeneric => modelConfig.hasGenericValue;

  List<Method> getMethods() => [
        _getToJson(),
      ];

  Expression _addAdaptersIfNeeded(JFieldConfig f, Expression exp) {
    for (final adapter in f.customAdapters) {
      exp = refer(adapter.adapterFieldName).property('toJson').call([exp]);
    }

    return exp;
  }

  bool shouldFilterNulls(JFieldConfig f) =>
      f.fieldType.isNullable && config.filterToJsonNulls!;

  Expression _getPropertyCall(JFieldConfig f) {
    final filterNulls = shouldFilterNulls(f);

    return filterNulls
        ? refer('model').property(f.fieldName).nullChecked
        : refer('model').property(f.fieldName);
  }

  MapEntry<Object, Object?> _fieldToCode(JFieldConfig f) {
    final filterNulls = shouldFilterNulls(f);

    final key = filterNulls
        ? CodeExpression(
            Code("if(model.${f.fieldName} != null) '${f.jsonKey}'"),
          )
        : literalString(f.jsonKey);

    final exp = _getPropertyCall(f);

    if (f.hasCustomAdapters) {
      return MapEntry(key, _addAdaptersIfNeeded(f, exp));
    } else if (!f.fieldType.isPrimitive) {
      final jSerializerCall =
          refer('jSerializer').property('toJson').call([exp]).code;
      return MapEntry(key, jSerializerCall);
    }

    return MapEntry(key, exp);
  }

  MethodBuilder toJsonSignature(MethodBuilder builder) {
    return builder
      ..name = 'toJson'
      ..annotations.add(refer('override'))
      ..returns = refer('Map<String, dynamic>')
      ..requiredParameters.add(
        Parameter(
          (b) => b
            ..name = 'model'
            ..type = modelConfig.type.baseRefer,
        ),
      );
  }

  Method _getToJson() {
    final mapEntries = modelConfig.fields.map(_fieldToCode);
    Expression body = literalMap(Map.fromEntries(mapEntries));
    if (modelConfig.extrasField != null) {
      if (modelConfig.extrasField!.keyConfig.overridesToJsonModelFields) {
        body = body.cascade('addAll').call(
          [
            refer('model').property(modelConfig.extrasField!.fieldName),
          ],
        );
      } else {
        body = refer('model')
            .property(modelConfig.extrasField!.fieldName)
            .cascade('addAll')
            .call(
          [body],
        );
      }
    }

    return Method(
      (b) => toJsonSignature(b)
        ..lambda = true
        ..body = body.code,
    );
  }
}
