import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/element_generator.dart';
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

  Reader<ClassBuilder, ClassBuilder> _appendSuffix() => Reader(
        (ClassBuilder b) => b..name = className + modelSerializerSuffix,
      );

  bool get isGeneric => modelConfig.hasGenericValue;

  Reference get thisRefer => modelConfig.type.baseRefer;

  Reader<ClassBuilder, ClassBuilder> _addExtends() => Reader(
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

  Expression resolve(
    JFieldConfig field,
    ResolvedType type,
    Expression ref,
    bool isFromJson,
  ) {
    final serializerMethod = isFromJson ? 'fromJson' : 'toJson';

    if (type.isList) {
      final typeArg = type.typeArguments.first;

      Expression mapList(Expression e) => e.property('map').call(
            [
              Method(
                (b) => b
                  ..body = resolve(
                    field,
                    typeArg,
                    refer('e'),
                    isFromJson,
                  ).code
                  ..requiredParameters.add(
                    Parameter(
                      (b) => b..name = 'e',
                    ),
                  ),
              ).closure
            ],
          );

      if (!isFromJson) {
        return mapList(ref);
      }

      return listFromRef(type: typeArg.refer).call(
        [
          if (!typeArg.isPrimitive)
            mapList(
              ref.asA(
                refer('List'),
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
                      resolve(
                        field,
                        typeArg,
                        refer('value'),
                        isFromJson,
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

      if (!isFromJson) {
        return mapMap(ref);
      }

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

    if (type.isPrimitive) return ref;

    if (field.hasSerializableGenerics && !type.isListOrMap) {
      final String methodName;
      final length = type.typeArguments.length;
      final shouldSuffix = length > 0 && length < 5;
      if (isFromJson) {
        methodName = 'getGenericValue${shouldSuffix ? length : ''}';
      } else {
        methodName = 'getGenericValueToJson';
      }

      final isDependantOnUndefinedGeneric = field.genericConfig != null;
      final _refer = refer(methodName).call([
        ref,
        if (field.type.isListOrMap)
          refer(field.genericConfig!.serializerName)
        else if (field.isBaseSerializable)
          refer(field.fieldNameSerializerSuffixed)
        else if (field.genericConfig != null)
          refer(field.genericConfig!.serializerName),
      ], {}, [
        if (isFromJson && field.type.isListOrMap) field.genericType!.refer,
        if (isFromJson && !field.type.isListOrMap) ...[
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
                  .property(isFromJson ? 'fromJsonGeneric' : 'toJson')
                  .call(
                    [ref],
                    {},
                    [
                      if (isFromJson) ...[
                        type.refer,
                        ...type.typeArguments.map((e) => e.refer),
                      ]
                    ],
                  ),
            );
      }

      return _refer;
    }

    if (field.isSerializableAndHasGenerics &&
        isFromJson &&
        !field.type.isListOrMap) {
      final methodName = 'fromJsonGeneric';
      return refer(field.fieldNameSerializerSuffixed).property(methodName).call(
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

  Method getModelToJson() {
    final json = <Expression, Expression>{};
    for (final f in modelConfig.fields) {
      final value = refer('model').property(f.fieldName);
      final filterNulls = f.type.isNullable && config.filterToJsonNulls;

      final key = filterNulls
          ? CodeExpression(
              Code("if(model.${f.fieldName} != null) '${f.jsonName}'"),
            )
          : literalString(f.jsonName);

      if ((f.isSerializableModel || f.hasSerializableGenerics) &&
          config.deepToJson) {
        if (f.type.isNullable && !config.filterToJsonNulls) {
          json[key] = value.equalTo(literalNull).conditional(
                literalNull,
                resolveToJson(f, f.type, value.nullChecked),
              );
          continue;
        } else if (f.type.isNullable) {
          json[key] = resolveToJson(f, f.type, value.nullChecked);
          continue;
        }

        json[key] = resolveToJson(f, f.type, value);
        continue;
      }

      json[key] = value;
    }

    return Method(
      (b) => b
        ..name = 'toJson'
        ..returns = jsonTypeRefer
        ..lambda = true
        ..body = literalMap(json).code
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

  Expression resolveToJson(
    JFieldConfig field,
    ResolvedType type,
    Expression ref,
  ) =>
      resolve(
        field,
        type,
        ref,
        false,
      );

  Expression resolveFromJson(
    JFieldConfig field,
    ResolvedType type,
    Expression ref,
  ) =>
      resolve(
        field,
        type,
        ref,
        true,
      );

  Method getModelFromJson() {
    final statements = <Code>[];
    final fields = modelConfig.fields;

    for (final field in modelConfig.fields) {
      final hasDefaultValue = field.defaultValueCode != null;

      final defaultValueCode = !hasDefaultValue
          ? literalNull
          : CodeExpression(Code(field.defaultValueCode!));

      final jsonExp = refer('json').index(
        literalString(field.jsonName),
      );

      if (field.type.isPrimitive) {
        var exp = jsonExp;
        if (hasDefaultValue) {
          exp = exp.ifNullThen(defaultValueCode);
        }
        final s = exp
            .assignFinal(
              field.fieldNameValueSuffixed,
              field.type.refer,
            )
            .statement;
        statements.add(s);
      } else {
        final type = field.type.dartType;
        var jsonExp = refer('json')
            .index(
              literalString(field.jsonName),
            )
            .assignFinal(field.fieldNameJsonSuffixed);
        statements.add(jsonExp.statement);
        final jsonExpRefer = refer(field.fieldNameJsonSuffixed);

        var s = resolveFromJson(field, field.type, jsonExpRefer);

        if (field.type.isNullable) {
          s = jsonExpRefer.equalTo(literalNull).conditional(
                defaultValueCode,
                s,
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

    final returnedModel = thisRefer.newInstance(
      [
        ...positionalFields.map(
          (e) => refer(e.fieldNameValueSuffixed),
        )
      ],
      {
        for (final f in namedFields)
          f.fieldName: refer(f.fieldNameValueSuffixed),
      },
      [
        ...modelConfig.genericConfigs.map((e) => e.type.refer),
      ],
    );

    return Method(
      (b) => b
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

  List<ResolvedType> _flatTypesOf(ResolvedType type) {
    final result = <ResolvedType>[type];
    for (final t in type.typeArguments) {
      if (t.typeArguments.isEmpty) result.add(t);
      final inners = _flatTypesOf(t);
      result.addAll(inners);
    }

    return _getDistinctTypesWithDisplayNameOf(result.toSet().toList());
  }

  List<Field> getSubModelsSerializersFields() {
    final typesToBeSerialized = _getDistinctTypesWithDisplayNameOf(
      [
        ...modelConfig.fields
            .where(
              (f) {
                return f.isSerializableModel && !f.type.isListOrMap;
              },
            )
            .map((e) => _flatTypesOf(e.type))
            .expand((e) => e)
            .where(
              (t) => !modelConfig.genericConfigs
                  .map((e) => e.type.name)
                  .contains(t.name),
            )
            .toList(),
        ...serializableFields
            .where((element) => element.type.isListOrMap)
            .map((e) => e.serializableClassType!),
      ],
    );

    final fields = <Field>[];

    for (final e in typesToBeSerialized) {
      final serializerRefer = refer('${e.name}Serializer');

      final fieldName = e.fullNameAsSerializer;
      final isGeneric = e.typeArguments.isNotEmpty;
      final clazz = e.dartType.element!;
      final isSerializable = jSerializableChecker.hasAnnotationOf(clazz);
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
          ..static = !isGeneric
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

  Reader<ClassBuilder, ClassBuilder> _implement() {
    return Reader(
      (ClassBuilder b) {
        return b
          ..fields.addAll([
            ...getSubModelsSerializersFields(),
          ])
          ..methods.addAll(
            [
              if (config.fromJson) getModelFromJson(),
              if (config.toJson) getModelToJson(),
            ],
          );
      },
    );
  }

  Reader<ClassBuilder, ClassBuilder> _createConstructor() => Reader(
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
  Class onGenerate() => Class(
        _createConstructor()
            .andThen(_appendSuffix)
            .andThen(_addExtends)
            .andThen(_implement)
            .run,
      );
}

JKey jKeyFromDartObj(DartObject obj) => JKey(
      ignore: obj.getField('ignore')?.toBoolValue() ?? false,
      name: obj.getField('name')?.toStringValue(),
    );

class JFieldConfig {
  const JFieldConfig({
    this.genericType,
    required this.hasSerializableGenerics,
    required this.type,
    required this.jsonName,
    required this.isNamed,
    required this.keyConfig,
    required this.genericConfig,
    required this.fieldName,
    required this.serializableClassElement,
    required this.serializableClassType,
    this.isSerializableModel = false,
    this.defaultValueCode,
    required this.neededSubSerializers,
  });

  final List<ResolvedType> neededSubSerializers;
  final ModelGenericConfig? genericConfig;
  final bool hasSerializableGenerics;
  final ResolvedType? genericType;
  final String? defaultValueCode;
  final bool isSerializableModel;
  final String fieldName;
  final String jsonName;
  final bool isNamed;
  final ResolvedType type;
  final JKey keyConfig;
  final ClassElement? serializableClassElement;
  final ResolvedType? serializableClassType;

  bool get isBaseSerializable =>
      isSerializableModel &&
      serializableClassType != null &&
      serializableClassType!.name == type.name;

  bool get hasTypeArguments => type.typeArguments.isNotEmpty;

  bool get isSerializableAndHasGenerics =>
      hasTypeArguments && isSerializableModel;

  Reference? get serializableClassTypeReferNullable =>
      serializableClassType?.refer;

  Reference get serializableClassTypeRefer =>
      serializableClassTypeReferNullable!;

  String get fieldNameJsonSuffixed => '${fieldName}\$Json';

  String get serializableClassName => serializableClassElement!.name;

  String get serializableClassNameLowerCase =>
      serializableClassName.firstLowerCase();

  String get fieldNameValueSuffixed => '${fieldName}\$Value';

  String get fieldNameSerializerSuffixed {
    return type.isListOrMap
        ? serializableClassType!.fullNameAsSerializer
        : type.fullNameAsSerializer;
  }

  String get modelSerializerName =>
      '${serializableClassType?.name ?? type.name}Serializer';

  Reference get modelSerializerRefer => refer(modelSerializerName);
}

extension StringX on String {
  String firstLowerCase() =>
      isEmpty ? '' : this[0].toLowerCase() + substring(1);
}
