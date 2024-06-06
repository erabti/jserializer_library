import 'package:code_builder/code_builder.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';

class FromJsonGenerator {
  FromJsonGenerator({
    required this.modelConfig,
    required this.config,
  });

  final ModelConfig modelConfig;
  final JSerializable config;

  bool get isGeneric => modelConfig.hasGenericValue;

  List<Method> getMethods() => [
        _getDecoder(),
        if (isGeneric) getDecoderGetterForGenericModels(),
      ];

  List<Field> getFields() => [];

  Method getDecoderGetterForGenericModels() => Method(
        (b) => b
          ..type = MethodType.getter
          ..annotations.add(refer('override'))
          ..name = 'decoder'
          ..lambda = true
          ..body = refer('decode').code
          ..returns = refer('Function'),
      );

  Expression _getExtrasBodyExp() => TypeReference((b) => b
        ..symbol = 'Map'
        ..types.addAll(
          [refer('String'), refer('dynamic')],
        )).property('from').call([refer('json')]).cascade('removeWhere').call([
        Method(
          (b) => b
            ..lambda = true
            ..requiredParameters.addAll(
              [
                Parameter((b) => b..name = 'key'),
                Parameter((b) => b..name = '_'),
              ],
            )
            ..body = refer('jsonKeys').property('contains').call(
              [refer('key')],
            ).code,
        ).closure,
      ]);

  Code resolveFieldToCode(JFieldConfig field) {
    final rawDefaultValueCode = field.defaultValueCode;
    final defaultValueCode = rawDefaultValueCode == null
        ? null
        : CodeExpression(Code(rawDefaultValueCode));
    final hasDefaultValue = defaultValueCode != null;

    final typeRefer = field.paramType.refer;

    final firstAdapterIsNullable =
        field.customAdapters.firstOrNull?.modelType.isNullable;

    Expression exp = refer('json').index(literalString(field.jsonKey));

    if (field.hasCustomAdapters) {
      for (final adapter in field.customAdapters) {
        exp = refer(adapter.adapterFieldName).property('fromJson').call([exp]);
      }
    } else {
      exp = refer('jSerializer').property('fromJson').call(
        [exp],
        {},
        [
          if (hasDefaultValue)
            field.paramType.copyWith(isNullable: true).refer
          else
            field.paramType.refer,
        ],
      );
    }

    if ((defaultValueCode != null) &&
        (firstAdapterIsNullable == null || firstAdapterIsNullable)) {
      exp = exp.ifNullThen(defaultValueCode);
    }

    exp = refer('safeLookup').call(
      [],
      {
        'call': Method(
          (b) => b
            ..lambda = true
            ..body = exp.code,
        ).closure,
        'jsonKey': literalString(field.jsonKey),
        if (field.jsonKey != field.fieldName)
          'fieldName': literalString(field.fieldName),
      },
      [typeRefer],
    );

    return declareFinal(field.fieldNameValueSuffixed).assign(exp).statement;
  }

  MethodBuilder getDecoderSign(
    MethodBuilder builder,
  ) {
    return builder
      ..annotations.addAll(
        [if (!isGeneric) refer('override')],
      )
      ..name = isGeneric ? 'decode' : 'fromJson'
      ..types.addAll([
        if (isGeneric) ...[
          for (final t in modelConfig.type.typeArguments)
            TypeReference(
              (b) => b..symbol = t.name,
            ),
        ]
      ])
      ..returns = modelConfig.type.refer
      ..requiredParameters.add(
        Parameter(
          (b) => b
            ..name = 'json'
            ..type = isGeneric ? TypeReference((b) => b..symbol = 'Map') : null,
        ),
      );
  }

  Method _getDecoder() {
    final fields = modelConfig.fields;
    final statements = fields.map(resolveFieldToCode).toList();

    final extrasField = modelConfig.extrasField;
    if (extrasField != null) {
      final extrasBodyVarName = extrasField.fieldNameValueSuffixed;
      statements.add(
        declareFinal(extrasBodyVarName).assign(_getExtrasBodyExp()).statement,
      );
    }

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
      (b) => getDecoderSign(
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
