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
        if (isGeneric) _getDecoderGetterForGenericModels(),
      ];
  List<Field> getFields() => [];

  Method _getDecoderGetterForGenericModels() => Method(
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

    final isPrimitive = field.paramType.isPrimitive;
    final typeRefer = field.paramType.refer;

    Expression exp = refer('json').index(literalString(field.jsonKey));
    if (field.hasCustomAdapters) {
      for (final adapter in field.customAdapters) {
        exp = refer(adapter.adapterFieldName).property('fromJson').call([
          exp,
        ]);

        final firstAdapterIsNullable =
            field.customAdapters.firstOrNull?.modelType.isNullable ?? true;

        if (hasDefaultValue && firstAdapterIsNullable) {
          exp = exp.ifNullThen(defaultValueCode);
        }
      }
    } else if (!isPrimitive) {
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
    if (defaultValueCode != null) {
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
      (b) => b
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
        ..body = Block(
          (b) => b.statements.addAll(
            [...statements, returnedModel.returned.statement],
          ),
        )
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'json'
              ..type =
                  isGeneric ? TypeReference((b) => b..symbol = 'Map') : null,
          ),
        ),
    );

    //
    // for (final field in fields) {
    //   final hasDefaultValue = field.defaultValueCode != null;
    //
    //   final defaultValueCode = !hasDefaultValue
    //       ? literalNull
    //       : CodeExpression(Code(field.defaultValueCode!));
    //
    //   final guardedLookup = config.guardedLookup == true;
    //
    //   final Expression jsonExp = refer('json').index(
    //     literalString(field.jsonName),
    //   );
    //
    //   if (field.hasCustomAdapters) {
    //     var exp = jsonExp;
    //
    //     for (final adapter in field.customAdapters) {
    //       exp = refer(adapter.adapterFieldName).property('fromJson').call([
    //         exp,
    //       ]);
    //     }
    //
    //     final firstAdapterIsNullable =
    //         field.customAdapters.firstOrNull?.modelType.isNullable ?? true;
    //
    //     if (hasDefaultValue && firstAdapterIsNullable) {
    //       exp = exp.ifNullThen(defaultValueCode);
    //     }
    //
    //     final typeRefer = field.paramType.refer;
    //
    //     if (guardedLookup) {
    //       exp = refer('safe').call(
    //         [],
    //         {
    //           'call': Method(
    //             (b) => b
    //               ..lambda = true
    //               ..body = exp.code,
    //           ).closure,
    //           'jsonName': literalString(field.jsonName),
    //           if (field.jsonName != field.fieldName)
    //             'fieldName': literalString(field.fieldName),
    //         },
    //         [typeRefer],
    //       );
    //     }
    //
    //     final s =
    //         declareFinal(field.fieldNameValueSuffixed).assign(exp).statement;
    //
    //     statements.add(s);
    //   } else if (field.paramType.isPrimitive) {
    //     var exp = jsonExp;
    //
    //     if (guardedLookup) {
    //       exp = refer('mapLookup').call(
    //         [],
    //         {
    //           'jsonName': literalString(field.jsonName),
    //           if (field.jsonName != field.fieldName)
    //             'fieldName': literalString(field.fieldName),
    //           'json': refer('json'),
    //         },
    //         // [
    //         //   field.type.referNullAware.rebuild(
    //         //     (b) =>
    //         //         b..isNullable = hasDefaultValue || (b.isNullable ?? false),
    //         //   ),
    //         // ],
    //       );
    //     }
    //
    //     if (hasDefaultValue) {
    //       exp = exp.ifNullThen(defaultValueCode);
    //     }
    //
    //     final s = declareFinal(
    //       field.fieldNameValueSuffixed,
    //       type: refer(
    //         field.paramType.dartType.getDisplayString(withNullability: true),
    //       ),
    //     ).assign(exp).statement;
    //
    //     statements.add(s);
    //   } else {
    //     final type = field.paramType.dartType;
    //
    //     var jsonExp = declareFinal(field.fieldNameJsonSuffixed).assign(
    //       refer('json').index(literalString(field.jsonName)),
    //     );
    //
    //     statements.add(jsonExp.statement);
    //     final jsonExpRefer = refer(field.fieldNameJsonSuffixed);
    //
    //     var s = resolveFromJson(field, field.paramType, jsonExpRefer);
    //
    //     if (field.paramType.isNullable || hasDefaultValue) {
    //       s = jsonExpRefer.equalTo(literalNull).conditional(
    //             defaultValueCode,
    //             s,
    //           );
    //     }
    //
    //     if (guardedLookup) {
    //       final type =
    //           field.paramType.dartType.getDisplayString(withNullability: true);
    //       final typeRefer = refer(type);
    //
    //       s = refer('safe').call(
    //         [],
    //         {
    //           'call': Method(
    //             (b) => b
    //               ..lambda = true
    //               ..body = s.code,
    //           ).closure,
    //           'jsonName': literalString(field.jsonName),
    //           if (isGeneric) 'modelType': refer('M'),
    //           if (field.jsonName != field.fieldName)
    //             'fieldName': literalString(field.fieldName),
    //         },
    //         [typeRefer],
    //       );
    //     }
    //
    //     s = s.assignFinal(
    //       field.fieldNameValueSuffixed,
    //       refer(type.getDisplayString(withNullability: true)),
    //     );
    //
    //     statements.add(s.statement);
    //   }
    // }
    //

    // if (modelConfig.extrasField != null) {
    //   final jsonKeyRefer = refer('jsonKeys');
    //   final extrasBody = TypeReference((b) => b
    //         ..symbol = 'Map'
    //         ..types.addAll(
    //           [refer('String'), refer('dynamic')],
    //         ))
    //       .property('from')
    //       .call([refer('json')])
    //       .cascade('removeWhere')
    //       .call([
    //         Method(
    //           (b) => b
    //             ..lambda = true
    //             ..requiredParameters.addAll(
    //               [
    //                 Parameter((b) => b..name = 'key'),
    //                 Parameter((b) => b..name = '_'),
    //               ],
    //             )
    //             ..body = jsonKeyRefer.property('contains').call(
    //               [refer('key')],
    //             ).code,
    //         ).closure,
    //       ])
    //       .assignFinal(modelConfig.extrasField!.fieldNameValueSuffixed);
    //   statements.add(extrasBody.statement);
    // }
    // final positionalFields = fields.where((e) => !e.isNamed).toList();
    // final namedFields = fields.where((e) => e.isNamed).toList();
    //
    // final returnedModel = thisRefer.newInstance(
    //   [
    //     ...positionalFields.map(
    //       (e) => refer(e.fieldNameValueSuffixed),
    //     ),
    //     if (modelConfig.extrasField?.isNamed == false)
    //       refer(modelConfig.extrasField!.fieldNameValueSuffixed),
    //   ],
    //   {
    //     for (final f in namedFields)
    //       f.fieldName: refer(f.fieldNameValueSuffixed),
    //     if (modelConfig.extrasField?.isNamed == true)
    //       modelConfig.extrasField!.fieldName:
    //           refer(modelConfig.extrasField!.fieldNameValueSuffixed),
    //   },
    //   [
    //     ...modelConfig.genericConfigs.map((e) => e.type.refer),
    //   ],
    // );
    //
    // return Method(
    //   (b) => b
    //     ..annotations.add(overrideAnnotation)
    //     ..name = isGeneric ? 'fromJsonGeneric' : 'fromJson'
    //     ..types.addAll([
    //       if (isGeneric) ...[
    //         TypeReference(
    //           (b) => b
    //             ..bound = modelConfig.type.baseRefer
    //             ..symbol = 'M',
    //         ),
    //         for (final t in modelConfig.type.typeArguments)
    //           TypeReference(
    //             (b) => b..symbol = t.name,
    //           ),
    //       ]
    //     ])
    //     ..returns = isGeneric ? refer('M') : modelConfig.type.refer
    //     ..body = Block(
    //       (b) => b.statements.addAll(
    //         [
    //           ...statements,
    //           isGeneric
    //               ? returnedModel.asA(refer('M')).returned.statement
    //               : returnedModel.returned.statement,
    //         ],
    //       ),
    //     )
    //     ..requiredParameters.add(
    //       Parameter((b) => b..name = 'json'),
    //     ),
    // );
  }
}
