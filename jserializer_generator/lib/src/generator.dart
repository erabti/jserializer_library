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
import 'package:jserializer_generator/src/class_generator.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:jserializer_generator/src/type_resolver.dart';
import 'package:jserializer_generator/src/union_generator.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';

const fromJsonAdapterChecker = TypeChecker.fromRuntime(FromJsonAdapter);
const customAdapterChecker = TypeChecker.fromRuntime(CustomAdapter);
const toJsonAdapterChecker = TypeChecker.fromRuntime(ToJsonAdapter);
const customModelSerializerChecker = TypeChecker.fromRuntime(CustomJSerializer);
const jUnionChecker = TypeChecker.fromRuntime(JUnion);
const jUnionValueChecker = TypeChecker.fromRuntime(JUnionValue);

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

      final classes = models.where((e) => !e.isCustomSerializer).map(
        (e) {
          final unionConfig = e.unionConfig;

          if (unionConfig != null) {
            return UnionGenerator.generate(
              unionConfig: unionConfig,
              modelConfig: e,
              globalConfig: getConfig(e.classElement),
            );
          }

          return ClassGenerator(
            getConfig(e.classElement),
            e,
          ).onGenerate();
        },
      ).toList();

      final lib = Library(
        (b) => b
          ..body.addAll(
            [
              ...classes,
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
                      Cell(field.jsonName),
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
    final registerSerializerStatements = models.map(
      (e) {
        final customType = e.customSerializableType;

        return refer('JSerializer', jSerializerImport)
            .property('register')
            .call(
          [
            Method(
              (b) => b
                ..requiredParameters.addAll([
                  Parameter(
                    (b) => b..name = e.hasGenericValue ? 's' : '_',
                  ),
                ])
                ..body = e.hasGenericValue
                    ? (!e.isCustomSerializer
                            ? refer('${e.type.name}Serializer')
                            : e.type.refer)
                        .newInstance(
                        [
                          if (e.hasGenericValue) refer('s'),
                        ],
                      ).code
                    : (!e.isCustomSerializer
                            ? refer('${e.type.name}Serializer')
                            : e.type.refer)
                        .constInstance(
                        [
                          if (e.hasGenericValue) refer('s'),
                        ],
                      ).code,
            ).closure,
            Method(
              (b) => b
                ..lambda = true
                ..types.addAll(
                  e.genericConfigs.map((e) => e.type.refer),
                )
                ..requiredParameters.add(
                  Parameter(
                    (b) => b
                      ..name = 'f'
                      ..type = refer('Function'),
                  ),
                )
                ..body = refer('f').call([], {}, [
                  (customType ?? e.type).refer,
                ]).code,
            ).genericClosure,
          ],
          {},
          [
            (customType ?? e.type).baseRefer,
          ],
        ).statement;
      },
    );

    return Method(
      (b) => b
        ..name = 'initializeJSerializer'
        ..body = Block.of(
          [
            ...registerSerializerStatements,
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

    for (final annotatedElement in library.annotatedWith(typeChecker)) {
      final clazz = annotatedElement.element;
      if (clazz is! ClassElement) {
        throw Exception(
          'JSerializable does not support any types other than classes!',
        );
      }

      final isJUnion = jUnionChecker.hasAnnotationOf(clazz);

      if (clazz.unnamedConstructor == null && !isJUnion) {
        throw Exception('Class must have a default constructor!');
      }

      if (isJUnion) {
        final subTypes = <UnionValueConfig>[];

        for (final c in clazz.constructors) {
          final jUnionValue = getJUnionValue(c);

          final redirect = c.redirectedConstructor;
          if (redirect == null || jUnionValue.ignore) {
            continue;
          }

          final subClass = redirect.enclosingElement;

          final config = generateStreamItemForAnnotatedElement(
            subClass,
            annotatedElement.annotation,
            buildStep,
            resolver: resolver,
            customConstructor: redirect.redirectedConstructor,
          );

          yield config;

          subTypes.add(
            UnionValueConfig(
              config: config,
              annotation: jUnionValue,
              typeName: jUnionValue.name ?? c.name,
            ),
          );
        }

        if (subTypes.isEmpty) {
          throw Exception('Union type has no subtypes!');
        }

        final jUnion = getJUnion(clazz);
        final fallbackName = jUnion.fallbackName;
        final fallbackValue = subTypes.firstWhereOrNull(
          (element) => element.typeName == fallbackName,
        );

        //verify fallbackValue exists
        if (fallbackName != null) {
          if (fallbackValue == null) {
            throw Exception(
              'Fallback value ($fallbackName) of union ${clazz.name} '
              'has no matching constructor name!',
            );
          }
          if (fallbackValue.config.classElement.unnamedConstructor
                  ?.isDefaultConstructor ==
              false) {
            throw Exception(
              'Fallback value ($fallbackName) of union ${clazz.name} '
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
          customSerializableType: null,
          isCustomSerializer: false,
          unionConfig: UnionConfig(
            values: subTypes,
            annotation: jUnion,
            fallbackValue: fallbackValue,
          ),
        );

        return;
      }

      yield generateStreamItemForAnnotatedElement(
        clazz,
        annotatedElement.annotation,
        buildStep,
        resolver: resolver,
      );
    }
  }

  JSerializable getConfig(ClassElement clazz) {
    final _a = jSerializableChecker.firstAnnotationOf(clazz);

    if (_a == null) return globalOptions;
    final i = _a.getField('fieldNameCase')?.getField('index')?.toIntValue() ??
        globalOptions.fieldNameCase!.index;
    final fieldNameCase = FieldNameCase.values[i];

    return JSerializable(
      toJson: _a.getField('toJson')?.toBoolValue() ?? globalOptions.toJson,
      fromJson:
          _a.getField('fromJson')?.toBoolValue() ?? globalOptions.fromJson,
      deepToJson:
          _a.getField('deepToJson')?.toBoolValue() ?? globalOptions.deepToJson,
      guardedLookup: _a.getField('guardedLookup')?.toBoolValue() ??
          globalOptions.deepToJson,
      fieldNameCase: fieldNameCase,
      filterToJsonNulls: _a.getField('filterToJsonNulls')?.toBoolValue() ??
          globalOptions.filterToJsonNulls,
      ignoreAll: _a
              .getField('ignoreAll')
              ?.toListValue()
              ?.map((e) => e.toString())
              .cast<String>()
              .toList() ??
          globalOptions.ignoreAll,
    );
  }

  JUnion getJUnion(ClassElement clazz) {
    final a = jUnionChecker.firstAnnotationOf(clazz);

    if (a == null) return const JUnion();

    return JUnion(
      typeKey: a.getField('typeKey')?.toStringValue(),
      fallbackName: a.getField('fallbackName')?.toStringValue(),
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

  @override
  ModelConfig generateStreamItemForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep, {
    TypeResolver? resolver,
    ConstructorElement? customConstructor,
  }) {
    assert(element is ClassElement);
    assert(resolver is TypeResolver);
    final clazz = element as ClassElement;

    final isCustomSerializer =
        customModelSerializerChecker.hasAnnotationOf(clazz);

    final custom = getSerializableTypeOfCustomSerializer(clazz);
    final customType =
        custom == null ? null : resolver!.resolveType(custom.thisType);

    final config = getConfig(clazz);

    final type = resolver!.resolveType(clazz.thisType);

    final customSerializers = resolver.libs
        .map((lib) =>
            LibraryReader(lib).annotatedWith(customModelSerializerChecker))
        .flattened
        .map((e) => e.element)
        .whereType<ClassElement>()
        .where((e) =>
            e.allSupertypes.firstWhereOrNull(
              (element) => TypeChecker.fromRuntime(Serializer)
                  .isExactly(element.element),
            ) !=
            null)
        .toList();

    final _fields = resolveFields(
      resolver,
      clazz,
      config,
      customSerializers,
      customConstructor: customConstructor,
    );

    final extraFields = _fields
        .where(
          (e) => e.keyConfig.isExtras,
        )
        .toList();

    if (extraFields.length > 1) {
      throw Exception(
        'Error parsing ${clazz.name}: You have declared more than one field as extras field.\n',
      );
    }

    final extraField = extraFields.firstOrNull;
    final fields = _fields.where((e) => !e.keyConfig.isExtras).toList();

    final fieldTypes = fields.map(
      (e) => e.paramType,
    );

    for (final generic in type.typeArguments) {
      final genericName = generic.dartType.getDisplayString(
        withNullability: false,
      );

      final correspondingField = fieldTypes.firstWhereOrNull(
        (element) =>
            genericName ==
                element.dartType.getDisplayString(withNullability: false) ||
            element.hasDeepGenericOf(generic.dartType),
      );

      if (correspondingField == null) {
        continue;
      }
    }

    final genericConfigs = (customType ?? type)
        .typeArguments
        .mapIndexed(
          (i, e) => ModelGenericConfig(e, i),
        )
        .toList();

    return ModelConfig(
      customSerializableType: customType,
      isCustomSerializer: isCustomSerializer,
      genericConfigs: genericConfigs,
      extrasField: extraField,
      hasGenericValue: genericConfigs.isNotEmpty,
      fields: fields,
      classElement: clazz,
      type: type,
    );
  }

  int typeGenericIndex(ClassElement classElement, DartType type) =>
      classElement.typeParameters.indexWhere(
        (element) => element.toString() == type.toString(),
      );

  List<CustomAdapterConfig> getAdapterOf({
    required TypeChecker typeChecker,
    required Element element,
    required TypeResolver typeResolver,
  }) {
    return element.metadata
        .map(
          (element) => element.computeConstantValue(),
        )
        .where(
          (element) =>
              element?.type?.element != null &&
              typeChecker.isAssignableFrom(element!.type!.element!),
        )
        .whereType<DartObject>()
        .map(
          (e) => ConstantReader(e),
        )
        .where((e) => !e.revive().isPrivate)
        .map(
      (e) {
        final canFromJson =
            fromJsonAdapterChecker.isAssignableFromType(e.objectValue.type!);
        final canToJson =
            toJsonAdapterChecker.isAssignableFromType(e.objectValue.type!);

        final resolvedType = typeResolver.resolveType(e.objectValue.type!);
        final clazz = e.objectValue.type!.element! as ClassElement;
        final superType = clazz.supertype;
        final superName = superType?.element.displayName;

        InterfaceType? mixedWith(String name) => clazz.mixins
            .firstWhereOrNull((element) => element.element.displayName == name);

        InterfaceType? implementedWith(String name) => clazz.interfaces
            .firstWhereOrNull((element) => element.element.displayName == name);

        InterfaceType? extendsWith(String name) =>
            (superName == name ? superType : null) ??
            mixedWith(name) ??
            implementedWith(name);

        final isFromJsonAdapterType = extendsWith('FromJsonAdapter');
        final isToJsonAdapterType = extendsWith('ToJsonAdapter');
        final isCustomAdapterType = extendsWith('CustomAdapter');

        final adapterType = isFromJsonAdapterType ??
            isToJsonAdapterType ??
            isCustomAdapterType!;

        final resolvedAdapter = typeResolver.resolveType(adapterType);

        return CustomAdapterConfig(
          reader: e,
          revivable: e.revive(),
          type: resolvedType,
          canFromJson: canFromJson,
          canToJson: canToJson,
          jsonType: resolvedAdapter.typeArguments[1],
          modelType: resolvedAdapter.typeArguments[0],
        );
      },
    ).toList();
  }

  ClassElement? getSerializableTypeOfCustomSerializer(
      ClassElement customSerializer) {
    final serializerInterface = customSerializer.allSupertypes.firstWhereOrNull(
        (element) =>
            TypeChecker.fromRuntime(Serializer).isExactly(element.element));
    if (serializerInterface == null) return null;
    final type = serializerInterface.typeArguments.firstOrNull;
    if (type == null) return null;
    final element = type.element;

    if (element is! ClassElement) return null;

    return element;
  }

  List<JFieldConfig> resolveFields(
    TypeResolver typeResolver,
    ClassElement classElement,
    JSerializable config,
    List<ClassElement> customSerializers, {
    ConstructorElement? customConstructor,
  }) {
    final isClassCustomSerializer =
        customModelSerializerChecker.hasAnnotationOf(classElement);

    if (isClassCustomSerializer) return [];

    final sortedParams =
        (customConstructor ?? classElement.unnamedConstructor)!.parameters;
    final className = classElement.name;
    final classType = typeResolver.resolveType(classElement.thisType);

    final allAnnotatedClasses = typeResolver.libs
        .map((lib) => LibraryReader(lib).annotatedWith(typeChecker))
        .flattened;

    final customSerializableModels = customSerializers
        .map(getSerializableTypeOfCustomSerializer)
        .whereType<ClassElement>();

    return sortedParams.map(
      (param) {
        final classFieldLib = typeResolver.libs.firstWhereOrNull(
          (lib) =>
              classElement.lookUpGetter(
                param.name,
                lib,
              ) !=
              null,
        );

        late final classFieldLib2 = classElement.library.parts
            .map(
              (e) => e.library,
            )
            .firstWhereOrNull(
              (lib) =>
                  classElement.lookUpGetter(
                    param.name,
                    lib,
                  ) !=
                  null,
            );

        late final fieldLib = classFieldLib ?? classFieldLib2;

        final classField = fieldLib == null
            ? null
            : classElement.lookUpGetter(param.name, fieldLib);

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
            return e.dartType.getDisplayString(withNullability: false) ==
                    paramType.getDisplayString(withNullability: false) ||
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
                  final clazz = c.element as ClassElement;
                  final classType = typeResolver.resolveType(clazz.thisType);

                  return classType.name == resolvedType.name ||
                      resolvedType.hasDeepGenericOf(
                        clazz.thisType,
                      );
                },
              )
              .map((e) => e.element as ClassElement)
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
                        e.typeArguments.first.element is ClassElement &&
                        (e.typeArguments.first.element as ClassElement)
                                .thisType ==
                            serializableClass.thisType,
                  );

                  if (serializer == null) return false;
                  return true;
                },
              );

        final annotation =
            TypeChecker.fromRuntime(JKey).firstAnnotationOf(param) ??
                TypeChecker.fromRuntime(JKey).firstAnnotationOf(classField);

        final jKey = annotation == null ? null : jKeyFromDartObj(annotation);

        final fromJsonAdapters = [
          ...getAdapterOf(
            typeChecker: fromJsonAdapterChecker,
            element: param,
            typeResolver: typeResolver,
          ),
          ...getAdapterOf(
            typeChecker: fromJsonAdapterChecker,
            element: classField,
            typeResolver: typeResolver,
          ),
        ];

        final toJsonAdapters = [
          ...getAdapterOf(
            typeChecker: toJsonAdapterChecker,
            element: param,
            typeResolver: typeResolver,
          ),
          ...getAdapterOf(
            typeChecker: toJsonAdapterChecker,
            element: classField,
            typeResolver: typeResolver,
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

        final String jsonName;
        if (jKey?.name != null) {
          jsonName = jKey!.name!;
        } else {
          switch (config.fieldNameCase) {
            case FieldNameCase.camel:
              jsonName = param.name.toCamelCase();
              break;
            case FieldNameCase.pascal:
              jsonName = param.name.toPascalCase();
              break;
            case FieldNameCase.snake:
              jsonName = param.name.toSnakeCase();
              break;
            default:
              jsonName = param.name;
          }
        }

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
                            serializableClass.getDisplayString(
                              withNullability: false,
                            ) ==
                            n.dartType.getDisplayString(withNullability: false),
                      ) !=
                      null,
            ) &&
            !isSerializable &&
            fromJsonAdapters.isEmpty &&
            toJsonAdapters.isEmpty &&
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

        final paramDefaultValueCode = param.defaultValueCode;

        final defaultValueCode = param.defaultValueCode;

        return JFieldConfig(
          customSerializerClass: customSerializerClass,
          customSerializerClassType: customSerializerClassType,
          fromJsonAdapters: fromJsonAdapters,
          toJsonAdapters: toJsonAdapters,
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
          keyConfig: jKey ?? JKey(),
          paramType: typeResolver.resolveType(param.type),
          jsonName: jsonName,
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

class CustomAdapterConfig {
  const CustomAdapterConfig({
    required this.reader,
    required this.revivable,
    required this.type,
    required this.canFromJson,
    required this.canToJson,
    required this.modelType,
    required this.jsonType,
  });

  final bool canFromJson;
  final bool canToJson;

  final ConstantReader reader;
  final Revivable revivable;
  final ResolvedType type;

  final ResolvedType jsonType;
  final ResolvedType modelType;

  String get adapterFieldName => '_\$${type.fullName}';
}

final _header = '$_ignores\n\n$_welcome\n\n';

const _welcome = '''
// **************************************************************************
// JSerializer: Serialization Done Right
// **************************************************************************
''';

const _rules = <String>[
  'unused_field',
  'unnecessary_null_checks',
  'prefer-match-file-name',
  'depend_on_referenced_packages',
  'lines_longer_than_80_chars',
  'non_constant_identifier_names',
  'constant_identifier_names',
  'prefer_const_constructors',
  'strict_raw_type',
  'omit_local_variable_types',
  'avoid_dynamic_calls',
  'unnecessary_parenthesis',
  'unnecessary_nullable_for_final_variable_declarations',
  'annotate_overrides',
  'type_annotate_public_apis',
  'newline-before-return',
  'prefer-trailing-comma',
  'directives_ordering',
  'long-method',
  'use_named_constants',
];

final _ignores = '// ignore_for_file: ${_rules.join(',')}';
