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
    final fallbackName = field.keyConfig.fallbackName;

    if (fallbackName != null) {
      exp = exp.ifNullThen(refer('json').index(literalString(fallbackName)));
    }

    if (field.hasCustomAdapters) {
      for (final adapter in field.customAdapters) {
        exp = refer(adapter.adapterFieldName).property('fromJson').call([
          exp,
          refer('json'),
        ]);
      }
    } else if (field.paramType.isPrimitive) {
      final isNullable = hasDefaultValue || field.paramType.isNullable;
      final typeName = field.paramType.name;

      if (typeName == 'int') {
        final numRef = TypeReference(
            (b) => b
              ..symbol = 'num'
              ..isNullable = isNullable);
        if (isNullable) {
          exp = exp.asA(numRef).nullSafeProperty('toInt').call([]);
        } else {
          exp = exp.asA(numRef).property('toInt').call([]);
        }
      } else if (typeName == 'double') {
        final numRef = TypeReference(
            (b) => b
              ..symbol = 'num'
              ..isNullable = isNullable);
        if (isNullable) {
          exp = exp.asA(numRef).nullSafeProperty('toDouble').call([]);
        } else {
          exp = exp.asA(numRef).property('toDouble').call([]);
        }
      } else if (typeName != 'dynamic') {
        // String, bool, num - direct cast
        final typeRef = TypeReference(
            (b) => b
              ..symbol = typeName
              ..isNullable = isNullable);
        exp = exp.asA(typeRef);
      }
      // dynamic: no cast needed, exp is already json['key']
    } else if (field.paramType.isPrimitiveList) {
      final isNullable = hasDefaultValue || field.paramType.isNullable;
      final innerType = field.paramType.typeArguments.first;
      final listRef = TypeReference(
          (b) => b
            ..symbol = 'List'
            ..isNullable = isNullable);
      if (isNullable) {
        exp = exp
            .asA(listRef)
            .nullSafeProperty('cast')
            .call([], {}, [refer(innerType.name)]);
      } else {
        exp = exp
            .asA(listRef)
            .property('cast')
            .call([], {}, [refer(innerType.name)]);
      }
    } else if (field.paramType.isList) {
      final elementType = field.paramType.typeArguments.first;
      final isNullable = hasDefaultValue || field.paramType.isNullable;
      final listRef = TypeReference(
          (b) => b
            ..symbol = 'List'
            ..isNullable = isNullable);
      final mapCallback = Method(
        (b) => b
          ..lambda = true
          ..requiredParameters.add(Parameter((b) => b..name = 'e'))
          ..body = refer('jSerializer').property('fromJson').call(
            [refer('e')],
            {},
            [elementType.refer],
          ).code,
      ).closure;
      if (isNullable) {
        exp = exp
            .asA(listRef)
            .nullSafeProperty('map')
            .call([mapCallback])
            .property('toList')
            .call([]);
      } else {
        exp = exp
            .asA(listRef)
            .property('map')
            .call([mapCallback])
            .property('toList')
            .call([]);
      }
    } else if (field.paramType.isMap &&
        !field.paramType.isPrimitiveNestedMapOrList) {
      final keyType = field.paramType.typeArguments[0];
      final valueType = field.paramType.typeArguments[1];
      final isNullable = hasDefaultValue || field.paramType.isNullable;
      final mapRef = TypeReference(
          (b) => b
            ..symbol = 'Map'
            ..isNullable = isNullable);
      final mapCallback = Method(
        (b) => b
          ..lambda = true
          ..requiredParameters.addAll([
            Parameter((b) => b..name = 'k'),
            Parameter((b) => b..name = 'v'),
          ])
          ..body = refer('MapEntry').call([
            refer('k').asA(keyType.refer),
            refer('jSerializer').property('fromJson').call(
              [refer('v')],
              {},
              [valueType.refer],
            ),
          ]).code,
      ).closure;
      if (isNullable) {
        exp = exp.asA(mapRef).nullSafeProperty('map').call([mapCallback]);
      } else {
        exp = exp.asA(mapRef).property('map').call([mapCallback]);
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

    if (config.safeLookup != false) {
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
    }

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
