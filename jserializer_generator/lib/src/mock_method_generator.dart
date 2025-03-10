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
        _getMockerMethod(),
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
    final contextRefer = refer('context');

    Expression exp;
    if (customMocker != null) {
      exp = refer(customMocker.adapterFieldName).property('createMock').call(
        [contextRefer],
      );
    } else if (hasValue) {
      exp = valueCode;
    } else {
      exp = refer('subMock').call(
        [],
        {
          'context': contextRefer,
          'fieldName': literalString(field.fieldName),
          'currentLevel': refer('currentLevel'),
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

  Method _getMockerMethod() {
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

    final unionConfig = modelConfig.unionConfig;

    if (unionConfig != null) {
      final fallback = unionConfig.fallbackValue;
      return Method(
        (b) => getMockerSign(
          b
            ..body = Block(
              (b) => b.statements.addAll(
                [
                  refer('optionallyRandomizedValueFromListLazy')
                      .call(
                        [
                          refer('context'),
                          literalList(
                            [
                              for (final item in unionConfig.values)
                                refer('() => jSerializer')
                                    .property('createMock')
                                    .call(
                                  [],
                                  {'context': refer('context')},
                                  [item.config.type.refer],
                                )
                            ],
                          ),
                        ],
                        {
                          if (fallback != null)
                            'fallback': refer('() => jSerializer')
                                .property('createMock')
                                .call(
                              [],
                              {'context': refer('context')},
                              [fallback.config.type.refer],
                            ),
                        },
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
      },
      [
        ...modelConfig.genericConfigs.map((e) => e.type.refer),
      ],
    );

    final prevLevelCode =
        refer('context?').property('currentDepthLevel').ifNullThen(refer('0'));
    final prevLevelStmt =
        declareFinal('prevLevel').assign(prevLevelCode).statement;

    //     final currentLevel = prevLevel + 1;
    final currentLevelCode = refer('prevLevel').operatorAdd(refer('1'));
    final currentLevelStmt =
        declareFinal('currentLevel').assign(currentLevelCode).statement;

    return Method(
      (b) => getMockerSign(
        b
          ..body = Block(
            (b) => b.statements.addAll(
              [
                prevLevelStmt,
                currentLevelStmt,
                ...statements,
                returnedModel.returned.statement,
              ],
            ),
          ),
      ),
    );
  }
}
