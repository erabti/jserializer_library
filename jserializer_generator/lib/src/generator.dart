import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:barbecue/barbecue.dart';
import 'package:build/build.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/mocker_class_generator.dart';
import 'package:jserializer_generator/src/serializer_class_generator.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/enum_generator.dart';
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:jserializer_generator/src/type_resolver.dart';
import 'package:jserializer_generator/src/union_generator.dart';
import 'package:jserializer_generator/src/util.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';

const customAdapterChecker = TypeChecker.fromRuntime(CustomAdapter);
const mockerChecker = TypeChecker.fromRuntime(JMocker);
const customModelSerializerChecker = TypeChecker.fromRuntime(CustomJSerializer);
const customModelMockerChecker = TypeChecker.fromRuntime(CustomJMocker);
const jUnionChecker = TypeChecker.fromRuntime(JUnion);
const jUnionValueChecker = TypeChecker.fromRuntime(JUnionValue);
const jEnumKeyChecker = TypeChecker.fromRuntime(JEnumKey);
const jEnumIdentifierChecker = TypeChecker.fromRuntime(JEnumIdentifier);
const jEnumChecker = TypeChecker.fromRuntime(JEnum);

class NoPrefixAllocator implements Allocator {
  final _imports = <String>{};

  @override
  String allocate(Reference reference) {
    final symbol = reference.symbol;
    final url = reference.url;
    if (url != null) _imports.add(url);
    final isPackage = url == 'package:jserializer/jserializer.dart';
    return isPackage ? 'js.$symbol' : symbol!;
  }

  @override
  Iterable<Directive> get imports => _imports.map(
        (u) {
          return Directive.import(
            u,
            as: u == 'package:jserializer/jserializer.dart' ? 'js' : null,
          );
        },
      );
}

class JSerializerGenerator
    extends MergingGenerator<ModelConfig, JSerializableBase> {
  JSerializerGenerator(
    this.globalOptions, {
    this.shouldAddAnalysisOptions = false,
  });

  final JSerializable globalOptions;
  final bool shouldAddAnalysisOptions;

  @override
  FutureOr<String> generateMergedContent(Stream<ModelConfig> stream) async {
    try {
      final models = await stream.toList();

      final primaryClasses =
          models.where((e) => !e.isCustomMockerOrSerializer).map(
        (e) {
          final unionConfig = e.unionConfig;
          final enumConfig = e.enumConfig;

          if (enumConfig != null) {
            if (e.hasGenericValue) {
              throw Exception(
                'JSerializationGenerationError in ${e.classElement.name}:\n'
                'Serializable enums cannot have generic values!',
              );
            }

            return EnumGenerator(
              modelConfig: e,
              enumConfig: enumConfig,
              globalConfig: getConfig(e.classElement),
            ).generate();
          }

          if (unionConfig != null) {
            return UnionGenerator(
              unionConfig: unionConfig,
              modelConfig: e,
              globalConfig: getConfig(e.classElement),
            ).generate();
          }

          return SerializerClassGenerator(
            config: getConfig(e.classElement),
            modelConfig: e,
          ).onGenerate();
        },
      ).toList();

      final mockClasses =
          models.where((e) => !e.isCustomMockerOrSerializer).map(
        (e) {
          return MockerClassGenerator(
            config: getConfig(e.classElement),
            modelConfig: e,
          ).onGenerate();
        },
      ).toList();

      final lib = Library(
        (b) => b
          ..body.addAll(
            [
              ...primaryClasses,
              ...mockClasses,
              getInitializerMethod(models),
            ],
          ),
      );

      if (shouldAddAnalysisOptions) {
        final result = <String>[];

        for (final model in models) {
          final table = Table(
            tableStyle: TableStyle(border: true),
            cellStyle: CellStyle(
              paddingRight: 2,
              paddingLeft: 2,
              borderBottom: true,
              borderTop: true,
              borderLeft: true,
              borderRight: true,
              alignment: TextAlignment.MiddleLeft,
            ),
            header: TableSection(
              rows: [
                Row(
                  cells: [Cell(model.type.name)],
                ),
                Row(
                  cells: [Cell("Field"), Cell("Type"), Cell("Default")],
                ),
              ],
            ),
            body: TableSection(
              rows: [
                for (final field in model.fields)
                  Row(
                    cells: [
                      Cell(field.jsonKey),
                      Cell(field.paramType.name),
                      Cell(field.defaultValueCode ?? '-')
                    ],
                  ),
              ],
            ),
          );
          result.add(table.render());
        }

        File('./models_analysis').writeAsStringSync(result.join('\n\n'));
      }

      final emitter = DartEmitter(
        useNullSafetySyntax: true,
        allocator: NoPrefixAllocator(),
      );
      final code = DartFormatter().format(
        lib.accept(emitter).toString(),
      );

      return '$_header\n$code';
    } catch (e, s) {
      print('$e: $s');
      rethrow;
    }
  }

  Method getInitializerMethod(List<ModelConfig> models) {
    final instanceStmt = declareFinal('instance')
        .assign(
          refer('jSerializer').ifNullThen(
            refer('JSerializer', jSerializerImport).property('i'),
          ),
        )
        .statement;

    final registerStatements = <Code>[];
    final resolvedModels = <String, Map>{};

    for (final model in models) {
      final typeRefer = model.customSerializableModelType ??
          model.customMockerModelType ??
          model.type;
      resolvedModels[typeRefer.name] ??= {};

      if (!model.isCustomMockerOrSerializer) {
        resolvedModels[typeRefer.name]!['isGenerated'] = true;
      }
      if (model.isCustomSerializer) {
        resolvedModels[typeRefer.name]!['hasCustomSerializer'] = true;
        resolvedModels[typeRefer.name]!['serializerModel'] = model;
      }
      if (model.isCustomMocker) {
        resolvedModels[typeRefer.name]!['hasCustomMocker'] = true;
        resolvedModels[typeRefer.name]!['mockerModel'] = model;
      }

      resolvedModels[typeRefer.name]!['model'] = model;
    }

    for (final resolvedModel in resolvedModels.values) {
      final model = resolvedModel['model'] as ModelConfig;
      final isGenerated = resolvedModel['isGenerated'] as bool? ?? false;
      final hasCustomSerializer =
          resolvedModel['hasCustomSerializer'] as bool? ?? false;
      final hasCustomMocker =
          resolvedModel['hasCustomMocker'] as bool? ?? false;
      final mockerModel = resolvedModel['mockerModel'] as ModelConfig?;
      final serializerModel = resolvedModel['serializerModel'] as ModelConfig?;

      if (isGenerated && (hasCustomMocker || hasCustomSerializer)) {
        throw Exception(
          'JSerializationGenerationError in ${model.classElement.name}:\n'
          'You cannot annotate a model with JSerializable and have a custom '
          'serializer or a mocker',
        );
      }

      final typeRefer = model.customSerializableModelType ??
          model.customMockerModelType ??
          model.type;

      final instanceRefer = !hasCustomSerializer
          ? refer('${model.type.name}Serializer')
          : (serializerModel?.type.refer ?? model.type.refer);

      final serializerFactory = Method(
        (b) => b
          ..requiredParameters.addAll([Parameter((b) => b..name = 's')])
          ..body = instanceRefer.newInstance(
            [],
            {'jSerializer': refer('s')},
          ).code,
      ).closure;

      final typeFactory = Method(
        (b) => b
          ..lambda = true
          ..types.addAll(
            model.genericConfigs.map((e) => e.type.refer),
          )
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = 'f'
                ..type = refer('Function'),
            ),
          )
          ..body = refer('f').call([], {}, [typeRefer.refer]).code,
      ).genericClosure;

      late final mockFactory = Method(
        (b) => b
          ..requiredParameters.addAll([Parameter((b) => b..name = 's')])
          ..body = refer(
            hasCustomMocker
                ? model.type.name
                : '${(mockerModel ?? model).type.name}Mocker',
          ).newInstance(
            [],
            {'jSerializer': refer('s')},
          ).code,
      ).closure;

      final registerMethod = refer('instance').property('register');

      registerStatements.add(
        registerMethod.call(
          [
            serializerFactory,
            typeFactory,
          ],
          {
            if (hasCustomMocker || isGenerated) 'mockFactory': mockFactory,
          },
          [typeRefer.baseRefer],
        ).statement,
      );
    }

    return Method(
      (b) => b
        ..name = 'initializeJSerializer'
        ..optionalParameters.addAll([
          Parameter(
            (b) => b
              ..name = 'jSerializer'
              ..named = true
              ..type = TypeReference(
                (b) => b
                  ..url = jSerializerImport
                  ..isNullable = true
                  ..symbol = 'JSerializerInterface',
              ),
          ),
        ])
        ..body = Block.of(
          [
            if (models.isNotEmpty) instanceStmt,
            ...registerStatements,
          ],
        )
        ..returns = refer('void'),
    );
  }

  @override
  Stream<ModelConfig> generateStream(
    LibraryReader library,
    BuildStep buildStep,
  ) async* {
    final libs = await buildStep.resolver.libraries.toList();
    final resolver = TypeResolver(libs, null);
    final allAnnotatedElements = library.annotatedWith(typeChecker);

    for (final annotatedElement in allAnnotatedElements) {
      final clazz = annotatedElement.element;
      final className = clazz.name;

      late final errorHeader = 'JSerializableGenerationError in $className:\n';

      if (clazz is! InterfaceElement) {
        throw Exception('${errorHeader}The item is not a class');
      }

      final isJUnion = jUnionChecker.hasAnnotationOf(clazz);
      final isJEnum = jEnumChecker.hasAnnotationOf(clazz);

      if (clazz.unnamedConstructor == null && !isJUnion) {
        throw Exception('${errorHeader}Must have a default constructor!');
      }

      EnumConfig? enumConfig;

      if (clazz is EnumElement && isJEnum) {
        final fields = clazz.fields;
        final resolvedFields = <EnumKeyConfig>[];

        final nonEnumFields = fields.where((e) => !e.isEnumConstant).toList();
        final identifierField = nonEnumFields.firstWhereOrNull((field) {
          final a = jEnumIdentifierChecker.firstAnnotationOf(field);
          return a != null;
        });

        EnumIdentifierConfig? identifierConfig;

        if (identifierField != null) {
          if (!identifierField.isFinal) {
            throw Exception(
              '$errorHeader the id field ${identifierField.name} must be final!',
            );
          }
          final type = resolver.resolveType(identifierField.type);
          if (!type.isPrimitive) {
            throw Exception(
              '$errorHeader the id field ${identifierField.name} must be a primitive type!',
            );
          }

          identifierConfig = EnumIdentifierConfig(
            field: identifierField,
            type: type,
          );
        }

        EnumKeyConfig? fallbackField;

        for (final field in fields) {
          if (!field.isEnumConstant) continue;
          final jEnumKey = getJEnumKey(field);

          final String jsonName;

          if (identifierConfig == null) {
            jsonName = "'${reCase(
              field.name,
              nameCase: globalOptions.fieldNameCase,
            )}'";
          } else {
            jsonName =
                '${clazz.name}.${field.name}.${identifierConfig.field.name}';
          }

          final config = EnumKeyConfig(
            fieldName: field.name,
            jsonName: jsonName,
          );

          final isFallback = jEnumKey.isFallback;
          if (isFallback && fallbackField != null) {
            throw Exception(
              '$errorHeader only one fallback field is allowed! you '
              'defined ${fallbackField.fieldName} and ${field.name} as fallback fields!',
            );
          }

          if (isFallback) {
            fallbackField = config;
          }

          resolvedFields.add(config);
        }

        enumConfig = EnumConfig(
          values: resolvedFields,
          fallback: fallbackField,
          identifier: identifierConfig,
        );
      }

      final jUnion = getJUnion(clazz);

      if (isJUnion) {
        final generatedSubTypes = <String>[];
        final subTypes = <UnionValueConfig>[];

        for (final c in clazz.constructors) {
          final jUnionValue = getJUnionValue(c);

          final redirect = c.redirectedConstructor;
          if (redirect == null || jUnionValue.ignore) {
            continue;
          }

          final subClass = redirect.enclosingElement;
          final subClassType = resolver.resolveType(redirect.returnType);
          final jsonKey = jUnionValue.name ??
              reCase(
                c.name,
                nameCase: globalOptions.fieldNameCase,
              );

          final config = getModelConfigFromElement(
            subClass,
            annotatedElement.annotation,
            buildStep,
            resolver: resolver,
            customConstructor: redirect.redirectedConstructor,
            unionSubTypeMeta: UnionSubTypeMeta(
              typeJsonValue: jsonKey,
              unionAnnotation: jUnion,
              unionValueAnnotation: jUnionValue,
            ),
          );

          final unionValue = UnionValueConfig(
            config: config,
            constructor: c,
            redirectedType: subClassType,
            annotation: jUnionValue,
            jsonKey: jsonKey,
          );

          if (!generatedSubTypes.contains(config.classElement.name)) {
            yield config;
            generatedSubTypes.add(config.classElement.name);
          }

          subTypes.add(unionValue);
        }

        if (subTypes.isEmpty) {
          throw Exception('${errorHeader}Union type has no subtypes!');
        }

        final fallbackName = jUnion.fallbackName;
        final fallbackValue = subTypes.firstWhereOrNull(
          (element) => element.jsonKey == fallbackName,
        );

        //verify fallbackValue exists
        if (fallbackName != null) {
          if (fallbackValue == null) {
            throw Exception(
              '${errorHeader}Fallback value ($fallbackName) of union ${clazz.name} '
              'has no matching constructor name!',
            );
          }
          if (fallbackValue.config.classElement.unnamedConstructor
                  ?.isDefaultConstructor ==
              false) {
            throw Exception(
              '${errorHeader}Fallback value ($fallbackName) of union ${clazz.name} '
              'has required fields! That is not possible.',
            );
          }
        }

        final type = resolver.resolveType(clazz.thisType);

        final genericConfigs = type.typeArguments
            .mapIndexed(
              (i, e) => ModelGenericConfig(e, i),
            )
            .toList();

        yield ModelConfig(
          type: type,
          classElement: clazz,
          hasGenericValue: genericConfigs.isNotEmpty,
          genericConfigs: genericConfigs,
          customSerializableModelType: null,
          customMockerModelType: null,
          isCustomSerializer: false,
          isCustomMocker: false,
          unionConfig: UnionConfig(
            values: subTypes,
            annotation: jUnion,
            fallbackValue: fallbackValue,
          ),
        );
      } else {
        yield generateStreamItemForAnnotatedElement(
          clazz,
          annotatedElement.annotation,
          buildStep,
          enumConfig: enumConfig,
          resolver: resolver,
        );
      }
    }
  }

  JSerializable getConfig(InterfaceElement clazz) {
    final a = jSerializableChecker.firstAnnotationOf(clazz);

    if (a == null) return globalOptions;
    final i = a.getField('fieldNameCase')?.getField('index')?.toIntValue() ??
        globalOptions.fieldNameCase!.index;
    final fieldNameCase = FieldNameCase.values[i];

    return JSerializable(
      fieldNameCase: fieldNameCase,
      filterToJsonNulls: a.getField('filterToJsonNulls')?.toBoolValue() ??
          globalOptions.filterToJsonNulls,
      ignoreAll: a
              .getField('ignoreAll')
              ?.toListValue()
              ?.map((e) => e.toString())
              .cast<String>()
              .toList() ??
          globalOptions.ignoreAll,
    );
  }

  JUnion getJUnion(InterfaceElement clazz) {
    final a = jUnionChecker.firstAnnotationOf(clazz);

    if (a == null) return const JUnion();

    return JUnion(
      typeKey: a.getField('typeKey')?.toStringValue(),
      fallbackName: a.getField('fallbackName')?.toStringValue(),
    );
  }

  JEnumKey getJEnumKey(FieldElement element) {
    final a = jEnumKeyChecker.firstAnnotationOf(element);

    if (a == null) {
      return JEnumKey();
    }

    return JEnumKey(
      isFallback: a.getField('isFallback')?.toBoolValue() ?? false,
    );
  }

  JUnionValue getJUnionValue(ConstructorElement element) {
    final a = jUnionValueChecker.firstAnnotationOf(element);

    if (a == null) return const JUnionValue();

    return JUnionValue(
      name: a.getField('name')?.toStringValue(),
      ignore: a.getField('ignore')?.toBoolValue() ?? false,
    );
  }

  ModelConfig getModelConfigFromElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep, {
    TypeResolver? resolver,
    ConstructorElement? customConstructor,
    EnumConfig? enumConfig,
    UnionSubTypeMeta? unionSubTypeMeta,
  }) {
    assert(element is InterfaceElement);
    assert(resolver is TypeResolver);
    final clazz = element as InterfaceElement;

    final isCustomSerializer =
        customModelSerializerChecker.hasAnnotationOf(clazz);

    final isCustomMocker = customModelMockerChecker.hasAnnotationOf(clazz);

    final customSerializerModel = getSuperTypeFirstTypeArg(clazz, Serializer);
    final customMockerModel = getSuperTypeFirstTypeArg(clazz, JMocker);

    final customSerializableModelType = customSerializerModel == null
        ? null
        : resolver!.resolveType(customSerializerModel.thisType);

    final customMockerModelType = customMockerModel == null
        ? null
        : resolver!.resolveType(customMockerModel.thisType);

    final config = getConfig(clazz);

    final type = resolver!.resolveType(clazz.thisType);

    final customSerializers = resolver.libs
        .map((lib) =>
            LibraryReader(lib).annotatedWith(customModelSerializerChecker))
        .flattened
        .map((e) => e.element)
        .whereType<InterfaceElement>()
        .where((e) =>
            e.allSupertypes.firstWhereOrNull(
              (element) => TypeChecker.fromRuntime(Serializer)
                  .isExactly(element.element),
            ) !=
            null)
        .toList();

    final theFields = resolveFields(
      resolver,
      clazz,
      config,
      customSerializers,
      customConstructor: customConstructor,
    );

    final extraFields = theFields
        .where(
          (e) => e.keyConfig.isExtras,
        )
        .toList();

    if (extraFields.length > 1) {
      throw Exception(
        'JserializationGenerationError in ${clazz.name}:\n'
        'You have declared more than one field as extras field.\n',
      );
    }

    final extraField = extraFields.firstOrNull;
    final fields = theFields.where((e) => !e.keyConfig.isExtras).toList();

    final fieldTypes = fields.map(
      (e) => e.paramType,
    );

    for (final generic in type.typeArguments) {
      final genericName = generic.dartType.getDisplayStringWithoutNullability();

      final correspondingField = fieldTypes.firstWhereOrNull(
        (element) =>
            genericName ==
                element.dartType.getDisplayStringWithoutNullability() ||
            element.hasDeepGenericOf(generic.dartType),
      );

      if (correspondingField == null) {
        continue;
      }
    }

    final genericConfigs = (customSerializableModelType ?? type)
        .typeArguments
        .mapIndexed(
          (i, e) => ModelGenericConfig(e, i),
        )
        .toList();

    return ModelConfig(
      isCustomMocker: isCustomMocker,
      customSerializableModelType: customSerializableModelType,
      customMockerModelType: customMockerModelType,
      isCustomSerializer: isCustomSerializer,
      genericConfigs: genericConfigs,
      extrasField: extraField,
      hasGenericValue: genericConfigs.isNotEmpty,
      fields: fields,
      classElement: clazz,
      type: type,
      enumConfig: enumConfig,
      unionSubTypeMeta: unionSubTypeMeta,
    );
  }

  @override
  ModelConfig generateStreamItemForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep, {
    TypeResolver? resolver,
    ConstructorElement? customConstructor,
    EnumConfig? enumConfig,
  }) {
    return getModelConfigFromElement(
      element,
      annotation,
      buildStep,
      resolver: resolver,
      customConstructor: customConstructor,
      enumConfig: enumConfig,
    );
  }

  int typeGenericIndex(InterfaceElement classElement, DartType type) =>
      classElement.typeParameters.indexWhere(
        (element) => element.toString() == type.toString(),
      );

  InterfaceElement? getSuperTypeFirstTypeArg(
    InterfaceElement elm,
    Type superType,
  ) {
    final interface = elm.allSupertypes.firstWhereOrNull(
      (element) =>
          TypeChecker.fromRuntime(superType).isExactly(element.element),
    );

    if (interface == null) return null;
    final type = interface.typeArguments.firstOrNull;
    if (type == null) return null;
    final element = type.element;

    if (element is! InterfaceElement) return null;

    return element;
  }

  List<JFieldConfig> resolveFields(
    TypeResolver typeResolver,
    InterfaceElement classElement,
    JSerializable config,
    List<InterfaceElement> customSerializers, {
    ConstructorElement? customConstructor,
  }) {
    final isClassCustomSerializer =
        customModelSerializerChecker.hasAnnotationOf(classElement);
    final isClassCustomMocker =
        customModelMockerChecker.hasAnnotationOf(classElement);

    if (isClassCustomSerializer || isClassCustomMocker) return [];

    final sortedParams =
        (customConstructor ?? classElement.unnamedConstructor)!.parameters;
    final className = classElement.name;
    final classType = typeResolver.resolveType(classElement.thisType);

    final allAnnotatedClasses = typeResolver.libs
        .map((lib) => LibraryReader(lib).annotatedWith(typeChecker))
        .flattened;

    final customSerializableModels = customSerializers
        .map(
          (e) => getSuperTypeFirstTypeArg(e, Serializer),
        )
        .whereType<InterfaceElement>();

    return sortedParams.map(
      (param) {
        final classFieldLib = typeResolver.libs.firstWhereOrNull(
          (lib) =>
              classElement.safeLookupGetter(
                name: param.name,
                library: lib,
              ) !=
              null,
        );

        late final classFieldLib2 = classElement.library.parts
            .map(
              (e) => e.library,
            )
            .firstWhereOrNull(
              (lib) =>
                  classElement.safeLookupGetter(
                    name: param.name,
                    library: lib,
                  ) !=
                  null,
            );

        late final fieldLib = classFieldLib ?? classFieldLib2;

        final classField = fieldLib == null
            ? null
            : classElement.safeLookupGetter(
                name: param.name,
                library: fieldLib,
              );

        if (classField == null) {
          throw Exception(
            'Error reading model ${classElement.name}!\n'
            'Param ${param.name} has no matching field name!\n'
            'All accessors: ${classElement.accessors.map((e) => e.name).join(',')}\n'
            '',
          );
        }

        final paramType = param.type;

        final resolvedType = typeResolver.resolveType(paramType);

        var genericType = classType.typeArguments.firstWhereOrNull(
          (e) {
            return e.dartType.getDisplayStringWithoutNullability() ==
                    paramType.getDisplayStringWithoutNullability() ||
                resolvedType.hasDeepGenericOf(e.dartType);
          },
        );

        final genericConfig = genericType == null
            ? null
            : ModelGenericConfig(
                genericType,
                classType.typeArguments.indexOf(genericType),
              );

        final customSerializableModelType =
            customSerializableModels.firstWhereOrNull(
          (element) {
            final classType = typeResolver.resolveType(element.thisType);

            return classType.name == resolvedType.name ||
                resolvedType.hasDeepGenericOf(element.thisType);
          },
        );

        late final serializableClasses = [
          ...allAnnotatedClasses
              .where(
                (c) {
                  final clazz = c.element as InterfaceElement;
                  final classType = typeResolver.resolveType(clazz.thisType);

                  return classType.name == resolvedType.name ||
                      resolvedType.hasDeepGenericOf(
                        clazz.thisType,
                      );
                },
              )
              .map((e) => e.element as InterfaceElement)
              .toList(),
        ];

        final isSerializable = customSerializableModelType != null ||
            serializableClasses.isNotEmpty;

        final serializableClass =
            customSerializableModelType ?? serializableClasses.firstOrNull;

        final customSerializerClass = serializableClass == null
            ? null
            : customSerializers.firstWhereOrNull(
                (c) {
                  final serializer = c.allSupertypes.firstWhereOrNull(
                    (e) =>
                        TypeChecker.fromRuntime(Serializer)
                            .isExactly(e.element) &&
                        e.typeArguments.firstOrNull != null &&
                        e.typeArguments.first.element is InterfaceElement &&
                        (e.typeArguments.first.element as InterfaceElement)
                                .thisType ==
                            serializableClass.thisType,
                  );

                  if (serializer == null) return false;
                  return true;
                },
              );

        final jKeyObj =
            TypeChecker.fromRuntime(JKey).firstAnnotationOf(param) ??
                TypeChecker.fromRuntime(JKey).firstAnnotationOf(classField);

        final jKey = jKeyObj == null ? null : JKeyConfig.fromDartObj(jKeyObj);

        final customAdapters = [
          ...getParamAdapters(
            parentClass: classElement,
            typeChecker: customAdapterChecker,
            param: param,
            typeResolver: typeResolver,
            parentAdapterClassName: 'CustomAdapter',
          ),
        ];

        final customMockers = [
          ...getParamAdapters(
            parentClass: classElement,
            typeChecker: mockerChecker,
            param: param,
            typeResolver: typeResolver,
            parentAdapterClassName: 'JMocker',
          ),
        ];

        if (jKey?.isExtras == true) {
          if (!resolvedType.isJson) {
            throw Exception(
              'Error generating ${className}Serializer:\n'
              'Extras field of [$className.${param.type} ${param.name}] is not Map<String, dynamic>\n',
            );
          }
          if (param.isRequired) {
            throw Exception(
              'Error generating ${className}Serializer:\n'
              'Extras field of [$className.${param.type} ${param.name}] is not optional\n',
            );
          }
        }

        if (jKey?.ignore == true && param.isRequired) {
          throw Exception(
            'Error generating ${className}Serializer:\n'
            '[$className.${param.type} ${param.name}] is required and marked as ignored\n',
          );
        }

        final ignoreAll = config.ignoreAll ?? [];
        if (ignoreAll.contains(param.name) && param.isRequired) {
          throw Exception(
            'Error generating ${className}Serializer:\n'
            '[$className.${param.type} ${param.name}] is required and marked as ignored\n'
            'in ignoreAll',
          );
        }

        final jKeyName = jKey?.name;
        final jsonName = jKeyName ??
            reCase(
              param.name,
              nameCase: config.fieldNameCase,
            );

        final customSerializerClassType = customSerializerClass == null
            ? null
            : typeResolver.resolveType(customSerializerClass.thisType);

        if (!resolvedType.isPrimitiveOrListOrMap(
              skip: (n) =>
                  classElement.typeParameters
                      .map((e) => e.name)
                      .contains(n.name) ||
                  serializableClasses.firstWhereOrNull(
                        (serializableClass) =>
                            serializableClass
                                .getDisplayStringWithoutNullability() ==
                            n.dartType.getDisplayStringWithoutNullability(),
                      ) !=
                      null,
            ) &&
            !isSerializable &&
            !resolvedType.isListOrMap &&
            customAdapters.isEmpty &&
            jKey?.ignore != true &&
            !ignoreAll.contains(param.name)) {
          throw Exception(
            '\nUnSerializable field type in the field ${classElement.name}.${param.name} '
            'of type ${resolvedType.name}\n'
            'I do not know how to serialize that type, did you forget to annotate it with @JSerializable()?\n'
            'In case you do not have access to the class (third-party type) you can create'
            ' a custom serializer for it and annotate it with @CustomJSerializer().\n',
          );
        }

        final defaultValueCode = param.defaultValueCode;

        return JFieldConfig(
          customSerializerClass: customSerializerClass,
          customSerializerClassType: customSerializerClassType,
          customAdapters: customAdapters,
          customMockers: customMockers,
          genericConfig: genericConfig,
          hasSerializableGenerics: genericType != null,
          genericType: genericType,
          defaultValueCode: defaultValueCode,
          serializableClassType: serializableClass == null
              ? null
              : typeResolver.resolveType(
                  serializableClass.thisType,
                ),
          serializableClassElement: serializableClass,
          isSerializableModel: isSerializable,
          keyConfig: jKey ?? JKeyConfig(),
          paramType: typeResolver.resolveType(param.type),
          jsonKey: jsonName,
          fieldName: param.name,
          isNamed: param.isNamed,
          fieldType: typeResolver.resolveType(classField.type.returnType),
        );
      },
    ).where(
      (element) {
        return !(element.keyConfig.ignore ||
                (config.ignoreAll ?? []).contains(element.fieldName)) ||
            element.keyConfig.isExtras;
      },
    ).toList();
  }
}

String reCase(
  String identifier, {
  FieldNameCase? nameCase,
}) {
  switch (nameCase) {
    case FieldNameCase.camel:
      return identifier.toCamelCase();
    case FieldNameCase.pascal:
      return identifier.toPascalCase();
    case FieldNameCase.snake:
      return identifier.toSnakeCase();
    default:
      return identifier;
  }
}

class CustomAdapterConfig {
  const CustomAdapterConfig({
    required this.reader,
    required this.revivable,
    required this.type,
    required this.modelType,
    required this.jsonType,
    required this.param,
  });

  final ConstantReader reader;
  final Revivable revivable;
  final ResolvedType type;
  final ResolvedType jsonType;
  final ResolvedType modelType;
  final ParameterElement param;

  String get adapterFieldName => '_\$${param.name}_\$${type.fullName}';
}

extension ReviveDartObjX on DartObject {
  String toCodeString() => _reviveConstantObj(this);

  String _reviveConstantObj(DartObject obj) {
    final object = obj.variable?.computeConstantValue() ?? obj;

    String reviveArgument(DartObject obj) {
      final object = obj.variable?.computeConstantValue() ?? obj;
      final reader = ConstantReader(object);
      if (reader.isString) {
        return "'${reader.stringValue}'";
      } else if (reader.isInt) {
        return reader.intValue.toString();
      } else if (reader.isDouble) {
        return reader.doubleValue.toString();
      } else if (reader.isBool) {
        return reader.boolValue.toString();
      } else if (reader.isList) {
        return 'const [${reader.listValue.map((e) => reviveArgument(e)).join(', ')}]';
      } else if (reader.isSet) {
        return 'const {${reader.listValue.map((e) => reviveArgument(e)).join(', ')}}';
      } else if (reader.isMap) {
        final entries = reader.mapValue.entries.map((e) {
          final key = reviveArgument(e.key!);
          final value = reviveArgument(e.value!);
          return '$key: $value';
        }).join(', ');
        return 'const {$entries}';
      } else {
        return _reviveConstantObj(object);
      }
    }

    final reader = ConstantReader(object);
    if (reader.isLiteral) return reviveArgument(object);
    final revived = reader.revive();
    final accessor = revived.accessor;
    if (accessor.isNotEmpty) return accessor;
    final positionalArguments =
        revived.positionalArguments.map(reviveArgument).join(', ');
    final namedArguments = revived.namedArguments.entries
        .map((e) => '${e.key}: ${reviveArgument(e.value)}')
        .join(', ');

    if (positionalArguments.isNotEmpty && namedArguments.isNotEmpty) {
      return '${revived.source.fragment}($positionalArguments, $namedArguments)';
    } else if (positionalArguments.isNotEmpty) {
      return '${revived.source.fragment}($positionalArguments)';
    } else {
      return '${revived.source.fragment}($namedArguments)';
    }
  }
}

final _header = '$_ignores\n\n$_welcome\n\n';

const _welcome = '''
// **************************************************************************
// JSerializer: Serialization Done Right
// **************************************************************************
''';

const _rules = <String>[
  'type=lint',
  'unnecessary_import',
  'return_of_invalid_type_from_closure',
  'STRICT_RAW_TYPE',
  'prefer-match-file-name',
  'newline-before-return',
  'prefer-trailing-comma',
  'long-method',
];

final _ignores = '''
// ignore_for_file: ${_rules.join(',')}
''';
