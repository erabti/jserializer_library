import 'package:code_builder/code_builder.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/serializer_class_generator.dart';

class MockMethodGenerator {
  MockMethodGenerator({
    required this.modelConfig,
    required this.config,
  });

  final ModelConfig modelConfig;
  final JSerializable config;

  bool get isGeneric => modelConfig.hasGenericValue;

  List<Method> getMethods() => [
        _getMocker(),
        if (isGeneric) geMockerGetterForGenericModels(),
      ];

  Method geMockerGetterForGenericModels() => Method(
        (b) => b
          ..type = MethodType.getter
          ..annotations.add(refer('override'))
          ..name = 'mocker'
          ..lambda = true
          ..body = refer('mock').code
          ..returns = refer('Function'),
      );

  Code resolveFieldToCode(JFieldConfig field) {
    final rawMockValueCode = field.keyConfig.mockValueCode;

    late final mockValueCode = rawMockValueCode == null
        ? null
        : CodeExpression(Code(rawMockValueCode));

    final valueCode = mockValueCode;
    final hasValue = valueCode != null;
    final customMocker = field.customMockers.firstOrNull;

    Expression exp;
    if (customMocker != null) {
      exp = refer(customMocker.adapterFieldName).property('createMock').call(
        [],
        {
          'context': refer('context'),
        },
      );
    } else if (hasValue) {
      exp = valueCode;
    } else {
      exp = refer('jSerializer').property('createMock').call(
        [],
        {
          'context': refer('context'),
        },
        [field.paramType.refer],
      );
    }

    return declareFinal(field.fieldNameValueSuffixed).assign(exp).statement;
  }

  MethodBuilder getMockerSign(
    MethodBuilder builder,
  ) {
    return builder
      ..annotations.addAll(
        [if (!isGeneric) refer('override')],
      )
      ..name = isGeneric ? 'mock' : 'createMock'
      ..optionalParameters.addAll([
        Parameter(
          (b) => b
            ..named = true
            ..name = 'context'
            ..type = TypeReference((b) => b
              ..symbol = 'JMockerContext'
              ..isNullable = true
              ..url = jSerializerImport),
        ),
      ])
      ..types.addAll(
        [
          if (isGeneric) ...[
            for (final t in modelConfig.type.typeArguments)
              TypeReference(
                (b) => b..symbol = t.name,
              ),
          ],
        ],
      )
      ..returns = modelConfig.type.refer;
  }

  Method _getMocker() {
    final enumConfig = modelConfig.enumConfig;

    if (enumConfig != null) {
      return Method(
        (b) => getMockerSign(
          b
            ..body = Block(
              (b) => b.statements.addAll(
                [
                  refer('optionallyRandomizedValueFromList')
                      .call(
                        [
                          refer('context'),
                          refer(modelConfig.classElement.name)
                              .property('values'),
                        ],
                      )
                      .returned
                      .statement,
                ],
              ),
            ),
        ),
      );
    }

    final fields = modelConfig.fields;
    final statements = fields.map(resolveFieldToCode).toList();

    final positionalFields = fields.where((e) => !e.isNamed).toList();
    final namedFields = fields.where((e) => e.isNamed).toList();

    final returnedModel = modelConfig.type.baseRefer(
      [
        ...positionalFields.map((e) => refer(e.fieldNameValueSuffixed)),
        if (modelConfig.extrasField?.isNamed == false)
          refer(modelConfig.extrasField!.fieldNameValueSuffixed),
      ],
      {
        for (final f in namedFields)
          f.fieldName: refer(f.fieldNameValueSuffixed),
        if (modelConfig.extrasField?.isNamed == true)
          modelConfig.extrasField!.fieldName:
              refer(modelConfig.extrasField!.fieldNameValueSuffixed),
      },
      [
        ...modelConfig.genericConfigs.map((e) => e.type.refer),
      ],
    );

    return Method(
      (b) => getMockerSign(
        b
          ..body = Block(
            (b) => b.statements.addAll(
              [...statements, returnedModel.returned.statement],
            ),
          ),
      ),
    );
  }
}
