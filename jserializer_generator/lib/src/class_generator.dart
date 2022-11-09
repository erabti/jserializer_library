import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/element_generator.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:source_gen/source_gen.dart';

const modelSerializerSuffix = 'Serializer';

const overrideAnnotation = Reference('override');

const jSerializerImport = 'package:jserializer/jserializer.dart';

const jSerializerRefer = Reference(
  'JSerializer',
  jSerializerImport,
);

const jSerializerInterfaceRefer = Reference(
  'JSerializerInterface',
  jSerializerImport,
);

const jSerializableChecker = TypeChecker.fromRuntime(JSerializable);

Reference get jsonTypeRefer => mapRefer(refer('String'), refer('dynamic'));

Expression literalMapJson(Map<String, dynamic> values) => literalMap(
      values,
      refer('String'),
      refer('dynamic'),
    );

Reference mapRefer(Reference k, Reference v) => TypeReference(
      (b) => b
        ..symbol = 'Map'
        ..types.addAll([k, v]),
    );

Reference listRefer(Reference itemRefer) => TypeReference(
      (b) => b
        ..symbol = 'List'
        ..types.add(itemRefer),
    );

class ClassGenerator extends ElementGenerator<Class> {
  ClassGenerator(
    this.config,
    this.modelConfig,
  );

  final JSerializable config;

  ClassElement get classElement => modelConfig.classElement;

  final ModelConfig modelConfig;

  String get className => classElement.name;

  Reader<ClassBuilder, ClassBuilder> appendSuffix() => Reader(
        (ClassBuilder b) => b..name = className + modelSerializerSuffix,
      );

  bool get isGeneric => modelConfig.hasGenericValue;

  Reference get thisRefer => modelConfig.type.baseRefer;

  Reader<ClassBuilder, ClassBuilder> addExtends() => Reader(
        (ClassBuilder b) {
          return b
            ..extend = TypeReference(
              (b) => b
                ..symbol = modelConfig.baseSerializeName
                ..url = jSerializerImport
                ..types.add(thisRefer),
            );
        },
      );

  Expression resolveFromJson(
    JFieldConfig field,
    ResolvedType type,
    Expression ref,
  ) {
    final serializerMethod = 'fromJson';
    final isRecursiveCall = field.paramType != type;

    if (type.isList) {
      final typeArg = type.typeArguments.first;

      Expression mapList(Expression e) => e.property('map').call(
            [
              Method(
                (b) => b
                  ..body = resolveFromJson(
                    field,
                    typeArg,
                    refer('e'),
                  ).code
                  ..requiredParameters.add(
                    Parameter(
                      (b) => b..name = 'e',
                    ),
                  ),
              ).closure
            ],
          );

      return listFromRef(type: typeArg.refer).call(
        [
          if (!typeArg.isPrimitive)
            mapList(
              ref.asA(
                refer('Iterable'),
              ),
            )
          else
            ref.asA(
              refer('List'),
            ),
        ],
      );
    }

    if (type.isMap) {
      final typeArg = type.typeArguments[1];

      Expression mapMap(Expression e) => e.property('map').call(
            [
              Method(
                (b) => b
                  ..body = refer('MapEntry').newInstance(
                    [
                      refer('key'),
                      resolveFromJson(
                        field,
                        typeArg,
                        refer('value'),
                      )
                    ],
                  ).code
                  ..requiredParameters.addAll([
                    Parameter(
                      (b) => b..name = 'key',
                    ),
                    Parameter(
                      (b) => b..name = 'value',
                    ),
                  ]),
              ).closure
            ],
          );

      return mapFromRef(types: type.refer.types.toList()).call(
        [
          if (!typeArg.isPrimitive)
            mapMap(
              ref.asA(
                refer('Map'),
              ),
            )
          else
            ref.asA(
              refer('Map'),
            ),
        ],
      );
    }

    if (type.isPrimitive) {
      return ref;
    }

    if (field.hasSerializableGenerics && !type.isListOrMap) {
      final String methodName;
      final length = type.typeArguments.length;
      final shouldSuffix =
          length > 0 && length < 5 && !field.paramType.isListOrMap;
      methodName = 'getGenericValue${shouldSuffix ? length : ''}';

      final isDependantOnUndefinedGeneric = field.genericConfig != null;
      final _refer = refer(methodName).call([
        ref,
        if (field.paramType.isListOrMap)
          refer(field.genericConfig!.serializerName)
        else if (field.isBaseSerializable)
          refer(field.fieldNameSerializerSuffixed)
        else if (field.genericConfig != null)
          refer(field.genericConfig!.serializerName),
      ], {}, [
        if (field.paramType.isListOrMap) field.genericType!.refer,
        if (!field.paramType.isListOrMap) ...[
          type.refer,
          if (shouldSuffix) ...type.typeArguments.map((e) => e.refer),
        ]
      ]);

      if (isDependantOnUndefinedGeneric && type.typeArguments.isNotEmpty) {
        final jSerializer = refer('jSerializer');
        return jSerializer.equalTo(literalNull).conditional(
              _refer,
              jSerializer.nullChecked
                  .property('serializerOf')
                  .call(
                    [],
                    {},
                    [type.baseRefer],
                  )
                  .asA(
                    refer(
                      'GenericModelSerializer${type.typeArguments.length == 1 ? '' : type.typeArguments.length}',
                      jSerializerImport,
                    ),
                  )
                  .property('fromJsonGeneric')
                  .call(
                    [ref],
                    {},
                    [
                      ...[
                        type.refer,
                        ...type.typeArguments.map((e) => e.refer),
                      ]
                    ],
                  ),
            );
      }

      return _refer;
    }

    if (isRecursiveCall
        ? type.typeArguments.isNotEmpty
        : field.isSerializableAndHasGenerics && !field.paramType.isListOrMap) {
      final methodName = 'fromJsonGeneric';
      return refer(isRecursiveCall
              ? type.fullNameAsSerializer
              : field.fieldNameSerializerSuffixed)
          .property(methodName)
          .call(
        [ref],
        {},
        [
          type.refer,
          ...type.typeArguments.map((e) => e.refer),
        ],
      );
    }

    if (field.isSerializableModel) {
      return refer(field.fieldNameSerializerSuffixed)
          .property(serializerMethod)
          .call([ref]);
    }

    return ref;
  }

  Expression resolveToJson(
    JFieldConfig field,
    ResolvedType type,
    Expression ref,
  ) {
    final serializerMethod = 'toJson';
    final isRecursiveCall = field.paramType != type;

    if (type.isList) {
      final typeArg = type.typeArguments.first;

      Expression mapList(Expression e) => e.property('map').call(
            [
              Method(
                (b) => b
                  ..body = resolveToJson(
                    field,
                    typeArg,
                    refer('e'),
                  ).code
                  ..requiredParameters.add(
                    Parameter(
                      (b) => b..name = 'e',
                    ),
                  ),
              ).closure
            ],
          );

      return mapList(ref).property('toList').call([]);
    }

    if (type.isMap) {
      final typeArg = type.typeArguments[1];

      Expression mapMap(Expression e) => e.property('map').call(
            [
              Method(
                (b) => b
                  ..body = refer('MapEntry').newInstance(
                    [
                      refer('key'),
                      resolveToJson(
                        field,
                        typeArg,
                        refer('value'),
                      )
                    ],
                  ).code
                  ..requiredParameters.addAll([
                    Parameter(
                      (b) => b..name = 'key',
                    ),
                    Parameter(
                      (b) => b..name = 'value',
                    ),
                  ]),
              ).closure
            ],
          );

      return mapMap(ref);
    }

    if (type.isPrimitive) {
      return ref;
    }

    if (field.hasSerializableGenerics && !type.isListOrMap) {
      final String methodName = 'getGenericValueToJson';

      final isDependantOnUndefinedGeneric = field.genericConfig != null;
      final _refer = refer(methodName).call([
        ref,
        if (field.paramType.isListOrMap)
          refer(field.genericConfig!.serializerName)
        else if (field.isBaseSerializable)
          refer(field.fieldNameSerializerSuffixed)
        else if (field.genericConfig != null)
          refer(field.genericConfig!.serializerName),
      ], {});

      if (isDependantOnUndefinedGeneric && type.typeArguments.isNotEmpty) {
        final jSerializer = refer('jSerializer');
        return jSerializer.equalTo(literalNull).conditional(
              _refer,
              jSerializer.nullChecked
                  .property('serializerOf')
                  .call(
                    [],
                    {},
                    [type.baseRefer],
                  )
                  .asA(
                    refer(
                      'GenericModelSerializer${type.typeArguments.length == 1 ? '' : type.typeArguments.length}',
                      jSerializerImport,
                    ),
                  )
                  .property('toJson')
                  .call(
                    [ref],
                    {},
                    [],
                  ),
            );
      }

      return _refer;
    }

    if (field.isSerializableModel) {
      return refer(isRecursiveCall
              ? type.fullNameAsSerializer
              : field.fieldNameSerializerSuffixed)
          .property(serializerMethod)
          .call([ref]);
    }

    return ref;
  }

  Method getModelToJson() {
    final json = <Object?, Object?>{};
    for (final f in modelConfig.fields) {
      final filterNulls = f.fieldType.isNullable && config.filterToJsonNulls!;

      final value = filterNulls
          ? refer('model').property(f.fieldName).nullChecked
          : refer('model').property(f.fieldName);

      final key = filterNulls
          ? CodeExpression(
              Code("if(model.${f.fieldName} != null) '${f.jsonName}'"),
            )
          : literalString(f.jsonName);

      if (f.hasToJsonAdapters) {
        var exp = value;

        for (final adapter in f.toJsonAdapters) {
          exp = refer(adapter.adapterFieldName).property('toJson').call([
            exp,
          ]);
        }
        json[key] = exp;
        continue;
      }
      if ((f.isSerializableModel || f.hasSerializableGenerics) &&
          config.deepToJson!) {
        if (f.fieldType.isNullable && !config.filterToJsonNulls!) {
          json[key] = value.equalTo(literalNull).conditional(
                literalNull,
                resolveToJson(f, f.fieldType, value.nullChecked),
              );
          continue;
        } else if (f.fieldType.isNullable) {
          json[key] = resolveToJson(
              f, f.fieldType, filterNulls ? value : value.nullChecked);
          continue;
        }

        json[key] = resolveToJson(f, f.fieldType, value);
        continue;
      }

      json[key] = value;
    }

    Expression body = literalMap(json);

    if (modelConfig.extrasField != null) {
      if (modelConfig.extrasField!.keyConfig.overridesFields) {
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
          [
            body,
          ],
        );
      }
    }

    return Method(
      (b) => b
        ..name = 'toJson'
        ..annotations.add(overrideAnnotation)
        ..returns = jsonTypeRefer
        ..lambda = true
        ..body = body.code
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'model'
              ..type = thisRefer,
          ),
        ),
    );
  }

  Expression listFromRef({
    Reference? type,
  }) {
    return TypeReference(
      (b) => b
        ..symbol = 'List'
        ..types.addAll([if (type != null) type]),
    ).property('from');
  }

  Expression mapFromRef({
    List<Reference>? types,
  }) {
    return TypeReference(
      (b) => b
        ..symbol = 'Map'
        ..types.addAll([...?types]),
    ).property('from');
  }

  Method getModelFromJson() {
    final statements = <Code>[];
    final fields = modelConfig.fields;

    for (final field in fields) {
      final hasDefaultValue = field.defaultValueCode != null;

      final defaultValueCode = !hasDefaultValue
          ? literalNull
          : CodeExpression(Code(field.defaultValueCode!));

      final guardedLookup = config.guardedLookup == true;

      final Expression jsonExp = refer('json').index(
        literalString(field.jsonName),
      );

      if (field.hasFromJsonAdapters) {
        var exp = jsonExp;

        for (final adapter in field.fromJsonAdapters) {
          exp = refer(adapter.adapterFieldName).property('fromJson').call([
            exp,
          ]);
        }

        final firstAdapterIsNullable =
            field.fromJsonAdapters.firstOrNull?.modelType.isNullable ?? true;

        if (hasDefaultValue && firstAdapterIsNullable) {
          exp = exp.ifNullThen(defaultValueCode);
        }

        final typeRefer = field.paramType.refer;

        if (guardedLookup) {
          exp = refer('safe').call(
            [],
            {
              'call': Method(
                (b) => b
                  ..lambda = true
                  ..body = exp.code,
              ).closure,
              'jsonName': literalString(field.jsonName),
              if (field.jsonName != field.fieldName)
                'fieldName': literalString(field.fieldName),
            },
            [typeRefer],
          );
        }

        final s = exp.assignFinal(field.fieldNameValueSuffixed).statement;

        statements.add(s);
      } else if (field.paramType.isPrimitive) {
        var exp = jsonExp;

        if (guardedLookup) {
          exp = refer('mapLookup').call(
            [],
            {
              'jsonName': literalString(field.jsonName),
              if (field.jsonName != field.fieldName)
                'fieldName': literalString(field.fieldName),
              'json': refer('json'),
            },
            // [
            //   field.type.referNullAware.rebuild(
            //     (b) =>
            //         b..isNullable = hasDefaultValue || (b.isNullable ?? false),
            //   ),
            // ],
          );
        }

        if (hasDefaultValue) {
          exp = exp.ifNullThen(defaultValueCode);
        }

        final s = exp
            .assignFinal(
              field.fieldNameValueSuffixed,
              refer(field.paramType.dartType
                  .getDisplayString(withNullability: true)),
            )
            .statement;
        statements.add(s);
      } else {
        final type = field.paramType.dartType;

        var jsonExp = refer('json')
            .index(
              literalString(field.jsonName),
            )
            .assignFinal(field.fieldNameJsonSuffixed);

        statements.add(jsonExp.statement);
        final jsonExpRefer = refer(field.fieldNameJsonSuffixed);

        var s = resolveFromJson(field, field.paramType, jsonExpRefer);

        if (field.paramType.isNullable || hasDefaultValue) {
          s = jsonExpRefer.equalTo(literalNull).conditional(
                defaultValueCode,
                s,
              );
        }

        if (guardedLookup) {
          final type =
              field.paramType.dartType.getDisplayString(withNullability: true);
          final typeRefer = refer(type);

          s = refer('safe').call(
            [],
            {
              'call': Method(
                (b) => b
                  ..lambda = true
                  ..body = s.code,
              ).closure,
              'jsonName': literalString(field.jsonName),
              if (isGeneric) 'modelType': refer('M'),
              if (field.jsonName != field.fieldName)
                'fieldName': literalString(field.fieldName),
            },
            [typeRefer],
          );
        }

        s = s.assignFinal(
          field.fieldNameValueSuffixed,
          refer(type.getDisplayString(withNullability: true)),
        );

        statements.add(s.statement);
      }
    }

    final positionalFields = fields.where((e) => !e.isNamed).toList();
    final namedFields = fields.where((e) => e.isNamed).toList();

    if (modelConfig.extrasField != null) {
      final jsonKeyRefer = refer('jsonKeys');
      final extrasBody = TypeReference((b) => b
            ..symbol = 'Map'
            ..types.addAll(
              [refer('String'), refer('dynamic')],
            ))
          .property('from')
          .call([refer('json')])
          .cascade('removeWhere')
          .call([
            Method(
              (b) => b
                ..lambda = true
                ..requiredParameters.addAll(
                  [
                    Parameter((b) => b..name = 'key'),
                    Parameter((b) => b..name = '_'),
                  ],
                )
                ..body = jsonKeyRefer.property('contains').call(
                  [refer('key')],
                ).code,
            ).closure,
          ])
          .assignFinal(modelConfig.extrasField!.fieldNameValueSuffixed);
      statements.add(extrasBody.statement);
    }

    final returnedModel = thisRefer.newInstance(
      [
        ...positionalFields.map(
          (e) => refer(e.fieldNameValueSuffixed),
        ),
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
        ..annotations.add(overrideAnnotation)
        ..name = isGeneric ? 'fromJsonGeneric' : 'fromJson'
        ..types.addAll([
          if (isGeneric) ...[
            TypeReference(
              (b) => b
                ..bound = modelConfig.type.baseRefer
                ..symbol = 'M',
            ),
            for (final t in modelConfig.type.typeArguments)
              TypeReference(
                (b) => b..symbol = t.name,
              ),
          ]
        ])
        ..returns = isGeneric ? refer('M') : modelConfig.type.refer
        ..body = Block(
          (b) => b.statements.addAll(
            [
              ...statements,
              isGeneric
                  ? returnedModel.asA(refer('M')).returned.statement
                  : returnedModel.returned.statement,
            ],
          ),
        )
        ..requiredParameters.add(
          Parameter((b) => b..name = 'json'),
        ),
    );
  }

  List<JFieldConfig> get serializableFields => modelConfig.fields
      .where(
        (m) => m.isSerializableModel,
      )
      .toList();

  ModelGenericConfig? getGenericConfigFromType(ResolvedType type) =>
      modelConfig.genericConfigs.firstWhereOrNull(
        (element) => element.type.name == type.name,
      );

  List<ResolvedType> _getDistinctTypesWithDisplayNameOf(
    List<ResolvedType> types,
  ) {
    final typeNames = <String>{};
    final typeNamesDistinct = <ResolvedType>[];

    for (final f in types) {
      if (typeNames.add(
        f.dartType.getDisplayString(withNullability: false),
      )) typeNamesDistinct.add(f);
    }

    return typeNamesDistinct;
  }

  List<Field> getCustomAdapters() {
    final fields = <Field>[];
    final ids = <String>{};

    for (final field in modelConfig.fields) {
      for (final adapter in field.allAdapters) {
        adapter.adapterFieldName;
        if (ids.contains(adapter.adapterFieldName)) continue;

        final f = Field(
          (b) => b
            ..name = adapter.adapterFieldName
            ..modifier = FieldModifier.constant
            ..static = true
            ..assignment = adapter.type.refer.newInstance(
              [
                for (final x in adapter.revivable.positionalArguments)
                  literal(ConstantReader(x).literalValue),
              ],
              {
                ...adapter.revivable.namedArguments.map(
                  (key, value) => MapEntry(
                      key, literal(ConstantReader(value).literalValue)),
                ),
              },
              [],
            ).code,
        );
        fields.add(f);
        ids.add(adapter.adapterFieldName);
      }
    }

    return fields;
  }

  List<Field> getSubModelsSerializersFields() {
    final types = [
      ...modelConfig.fields
          .where((f) => f.isSerializableModel)
          .map((e) => e.paramType.distinctFlatTypes())
          .expand((e) => e)
          .where((f) => !f.isList)
          .where(
            (t) => !modelConfig.genericConfigs
                .map((e) => e.type.name)
                .contains(t.name),
          )
          .toList(),
      ...serializableFields
          .where((element) => element.paramType.isListOrMap)
          .map((e) => e.serializableClassType!),
    ];

    final typesToBeSerialized = _getDistinctTypesWithDisplayNameOf(types);

    final fields = <Field>[];

    for (final e in typesToBeSerialized) {
      final serializableField = serializableFields.firstWhereOrNull(
        (field) => field.serializableClassType?.name == e.name,
      );

      final serializerRefer = serializableField?.modelSerializerRefer ??
          refer('${e.name}Serializer');

      final fieldName = e.fullNameAsSerializer;
      final isGeneric = e.typeArguments.isNotEmpty;
      final clazz = e.dartType.element!;

      final isSerializable = jSerializableChecker.hasAnnotationOf(clazz) ||
          customModelSerializerChecker.hasAnnotationOf(clazz);

      final Code instance;

      if (isSerializable && isGeneric) {
        final args = e.typeArguments;

        Expression getRefer(int index) {
          final type = args[index];
          final g = modelConfig.genericConfigs
              .firstWhereOrNull((e) => e.type.name == type.name);
          return g != null
              ? refer(g.serializerName).nullChecked
              : refer(type.fullNameAsSerializer);
        }

        String getSerializerKey(int index) =>
            'serializer${index == 0 ? '' : index + 1}';

        instance = serializerRefer.newInstanceNamed('from', [], {
          for (var i = 0; i < args.length; i++)
            getSerializerKey(i): getRefer(i),
        }).code;
      } else if (e.isPrimitive) {
        instance = TypeReference((b) => b
          ..symbol = 'PrimitiveSerializer'
          ..types.add(e.refer)
          ..url = jSerializerImport).newInstance([]).code;
      } else if (e.isList) {
        instance = refer('ListSerializer', jSerializerImport).newInstance(
          [
            refer(e.typeArguments.first.fullNameAsSerializer),
          ],
          {},
          e.typeArguments.map((e) => e.refer).toList(),
        ).code;
      } else {
        instance = serializerRefer.newInstance([]).code;
      }

      final f = Field(
        (b) => b
          ..static = !isGeneric || classElement.typeParameters.isEmpty
          ..modifier =
              !isGeneric ? FieldModifier.constant : FieldModifier.final$
          ..assignment = instance
          ..late = isGeneric
          ..name = fieldName,
      );
      fields.add(f);
    }

    return fields;
  }

  Field getJsonKeysField() => Field(
        (b) => b
          ..name = 'jsonKeys'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = literalSet(
            modelConfig.fields.map((e) => literalString(e.jsonName)),
          ).code,
      );

  Reader<ClassBuilder, ClassBuilder> implement() {
    return Reader(
      (ClassBuilder b) {
        return b
          ..fields.addAll([
            ...getSubModelsSerializersFields(),
            ...getCustomAdapters(),
            getJsonKeysField(),
          ])
          ..methods.addAll(
            [
              if (config.fromJson!) getModelFromJson(),
              if (config.toJson!) getModelToJson(),
            ],
          );
      },
    );
  }

  Reader<ClassBuilder, ClassBuilder> createConstructor() => Reader(
        (ClassBuilder b) {
          return b
            ..constructors.addAll(
              [
                Constructor(
                  (b) => b
                    ..constant = !modelConfig.hasGenericValue
                    ..initializers.addAll([
                      if (isGeneric)
                        refer('super').call(
                          [refer('jSerializer')],
                        ).code,
                    ])
                    ..requiredParameters.addAll(
                      [
                        if (isGeneric)
                          Parameter(
                            (b) => b
                              ..type = jSerializerInterfaceRefer
                              ..name = 'jSerializer',
                          ),
                      ],
                    ),
                ),
                if (isGeneric)
                  Constructor(
                    (b) => b
                      ..name = 'from'
                      ..initializers.addAll([
                        refer('super').property('from').call(
                          [],
                          {
                            for (final g in modelConfig.genericConfigs)
                              g.serializerName: refer(g.serializerName),
                          },
                        ).code,
                      ])
                      ..optionalParameters.addAll(
                        [
                          for (final g in modelConfig.genericConfigs)
                            Parameter(
                              (b) => b
                                ..named = true
                                ..required = true
                                ..type = refer('Serializer', jSerializerImport)
                                ..name = g.serializerName,
                            ),
                        ],
                      ),
                  ),
              ],
            );
        },
      );

  @override
  Class onGenerate() {
    return Class(
      createConstructor()
          .andThen(appendSuffix)
          .andThen(addExtends)
          .andThen(implement)
          .run,
    );
  }
}

JKeyConfig jKeyFromDartObj(DartObject obj) => JKeyConfig(
      ignore: obj.getField('ignore')?.toBoolValue() ?? false,
      name: obj.getField('name')?.toStringValue(),
      isExtras: obj.getField('isExtras')?.toBoolValue() ?? false,
      overridesFields: obj.getField('overridesFields')?.toBoolValue() ?? false,
    );

class JKeyConfig implements JKey {
  const JKeyConfig({
    required this.ignore,
    required this.isExtras,
    this.name,
    required this.overridesFields,
  });

  @override
  final bool ignore;

  @override
  final bool isExtras;

  @override
  final String? name;

  @override
  final bool overridesFields;
}

class JFieldConfig {
  const JFieldConfig({
    this.genericType,
    required this.hasSerializableGenerics,
    required this.paramType,
    required this.jsonName,
    required this.isNamed,
    required this.keyConfig,
    required this.genericConfig,
    required this.fieldName,
    required this.serializableClassElement,
    required this.serializableClassType,
    this.isSerializableModel = false,
    this.defaultValueCode,
    required this.fromJsonAdapters,
    required this.toJsonAdapters,
    required this.customSerializerClass,
    required this.customSerializerClassType,
    required this.fieldType,
  });

  // final bool hasCustomSerializer;
  final ClassElement? customSerializerClass;
  final ResolvedType? customSerializerClassType;

  final List<CustomAdapterConfig> fromJsonAdapters;
  final List<CustomAdapterConfig> toJsonAdapters;

  List<CustomAdapterConfig> get allAdapters {
    final id = <String>{};
    final List<CustomAdapterConfig> result = [];
    final list = [...fromJsonAdapters, ...toJsonAdapters];
    for (final i in list) {
      if (id.add(i.adapterFieldName)) result.add(i);
    }
    return result;
  }

  bool get hasFromJsonAdapters => fromJsonAdapters.isNotEmpty;

  bool get hasToJsonAdapters => toJsonAdapters.isNotEmpty;

  bool get hasCustomAdapters => hasFromJsonAdapters || hasToJsonAdapters;

  final ModelGenericConfig? genericConfig;
  final bool hasSerializableGenerics;
  final ResolvedType? genericType;
  final String? defaultValueCode;
  final bool isSerializableModel;
  final String fieldName;
  final String jsonName;
  final bool isNamed;
  final ResolvedType paramType;
  final ResolvedType fieldType;

  final JKey keyConfig;
  final ClassElement? serializableClassElement;
  final ResolvedType? serializableClassType;

  bool get isBaseSerializable =>
      isSerializableModel &&
      serializableClassType != null &&
      serializableClassType!.name == paramType.name;

  bool get hasTypeArguments => paramType.typeArguments.isNotEmpty;

  bool get isSerializableAndHasGenerics =>
      hasTypeArguments && isSerializableModel;

  Reference? get serializableClassTypeReferNullable =>
      serializableClassType?.refer;

  Reference get serializableClassTypeRefer =>
      serializableClassTypeReferNullable!;

  String get fieldNameJsonSuffixed => '$fieldName\$Json';

  String get serializableClassName => serializableClassElement!.name;

  String get serializableClassNameLowerCase =>
      serializableClassName.firstLowerCase();

  String get fieldNameValueSuffixed => '$fieldName\$Value';

  String get fieldNameSerializerSuffixed {
    return paramType.isListOrMap
        ? serializableClassType!.fullNameAsSerializer
        : paramType.fullNameAsSerializer;
  }

  String get modelSerializerName =>
      customSerializerClass?.name ??
      '${serializableClassType?.name ?? paramType.name}Serializer';

  Reference get modelSerializerRefer => refer(
        modelSerializerName,
      );
}

extension StringX on String {
  String firstLowerCase() =>
      isEmpty ? '' : this[0].toLowerCase() + substring(1);
}
