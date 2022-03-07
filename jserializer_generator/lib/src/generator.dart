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
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:jserializer_generator/src/type_resolver.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';

const fromJsonAdapterChecker = TypeChecker.fromRuntime(FromJsonAdapter);
const customAdapterChecker = TypeChecker.fromRuntime(CustomAdapter);
const toJsonAdapterChecker = TypeChecker.fromRuntime(ToJsonAdapter);

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

class ModelGenericConfig {
  const ModelGenericConfig(this.type, this.index);

  final ResolvedType type;
  final int index;

  String get serializerName => 'serializer${index == 0 ? '' : index + 1}';
}

class ModelConfig {
  const ModelConfig({
    required this.type,
    required this.classElement,
    this.fields = const [],
    required this.hasGenericValue,
    required this.genericConfigs,
    // this.isCustomSerializer = false,
    this.extrasField,
  });

  final JFieldConfig? extrasField;

  String get baseSerializeName {
    if (genericConfigs.isEmpty) return 'ModelSerializer';
    return 'GenericModelSerializer' +
        (genericConfigs.length == 1 ? '' : genericConfigs.length.toString());
  }

  final bool hasGenericValue;

  // final bool isCustomSerializer;

  final ClassElement classElement;
  final List<ModelGenericConfig> genericConfigs;

  final ResolvedType type;

  final List<JFieldConfig> fields;

  List<JFieldConfig> get namedFields => fields.where((f) => f.isNamed).toList();

  List<JFieldConfig> get positionalFields =>
      fields.where((f) => !f.isNamed).toList();
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

      final classes = models
          .map(
            (e) => ClassGenerator(
              getConfig(e.classElement),
              e,
            ).onGenerate(),
          )
          .toList();

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
                      Cell(field.type.name),
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
                    ? refer('${e.type.name}Serializer').newInstance(
                        [
                          if (e.hasGenericValue) refer('s'),
                        ],
                      ).code
                    : refer('${e.type.name}Serializer').constInstance(
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
                ..body = refer('f').call([], {}, [e.type.refer]).code,
            ).genericClosure,
          ],
          {},
          [e.type.baseRefer],
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
      yield generateStreamItemForAnnotatedElement(
        annotatedElement.element,
        annotatedElement.annotation,
        buildStep,
        resolver,
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
    );
  }

  @override
  ModelConfig generateStreamItemForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep, [
    TypeResolver? resolver,
  ]) {
    assert(element is ClassElement);
    assert(resolver is TypeResolver);
    final clazz = element as ClassElement;

    final config = getConfig(clazz);

    final _fields = resolveFields(resolver!, clazz, config);
    final extraFields = _fields
        .where(
          (e) => e.keyConfig.isExtras,
        )
        .toList();
    if (extraFields.length > 1) {
      throw Exception(
        'Error parsing ${clazz.name}: You have declared more than one field as extras field.',
      );
    }
    final extraField = extraFields.firstOrNull;
    final fields = _fields.where((e) => !e.keyConfig.isExtras).toList();

    final type = resolver.resolveType(clazz.thisType);

    final fieldTypes = fields.map(
      (e) => e.type,
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
        throw Exception(
          'Error parsing ${clazz.name}: You have to use the generic of $genericName in a field',
        );
      }
    }

    final genericConfigs = type.typeArguments
        .mapIndexed(
          (i, e) => ModelGenericConfig(e, i),
        )
        .toList();

    return ModelConfig(
      // isCustomSerializer: customModelSerializerChecker.hasAnnotationOf(clazz),
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
        final isCustomAdapter =
            customAdapterChecker.isAssignableFromType(e.objectValue.type!);

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

  List<JFieldConfig> resolveFields(
    TypeResolver typeResolver,
    ClassElement classElement,
    JSerializable config,
  ) {
    final sortedFields = classElement.unnamedConstructor!.parameters;
    final className = classElement.name;
    final classType = typeResolver.resolveType(classElement.thisType);
    final allAnnotatedClasses = typeResolver.libs
        .map(
          (lib) => LibraryReader(lib).annotatedWith(typeChecker),
        )
        .flattened;
    //
    // final customSerializers = allAnnotatedClasses.where(
    //   (e) => customModelSerializerChecker.hasAnnotationOf(e.element),
    // );

    // final customSerializersClasses =
    //     customSerializers.map((e) => e.element as ClassElement);

    // final customSerializableModels = customSerializersClasses
    //     .map((e) => e.supertype)
    //     .whereType<InterfaceType>()
    //     .where(
    //       (element) =>
    //           TypeChecker.fromRuntime(Serializer).isAssignableFromType(element),
    //     )
    //     .map((e) => e.typeArguments.firstOrNull)
    //     .whereType<DartType>();

    // final resolvedCustomSerializableModels = customSerializableModels.map(
    //   (e) => typeResolver.resolveType(e),
    // );

    return sortedFields
        .map(
          (param) {
            final classField = classElement.fields
                .firstWhereOrNull((element) => element.name == param.name);
            final type = (classField ?? param).type;
            final resolvedType = typeResolver.resolveType(type);

            var genericType = classType.typeArguments.firstWhereOrNull(
              (e) {
                return e.dartType.getDisplayString(withNullability: false) ==
                        type.getDisplayString(withNullability: false) ||
                    resolvedType.hasDeepGenericOf(e.dartType);
              },
            );

            final genericConfig = genericType == null
                ? null
                : ModelGenericConfig(
                    genericType,
                    classType.typeArguments.indexOf(genericType),
                  );

            var serializableClasses = allAnnotatedClasses
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
                .toList();
            // ..addAll(
            //   resolvedCustomSerializableModels
            //       .map((e) => e.dartType.element! as ClassElement),
            // );

            // final isCustomSerialized =
            //     resolvedCustomSerializableModels.firstWhereOrNull(
            //             (element) => element.name == resolvedType.name) !=
            //         null;

            final isSerializable = serializableClasses.isNotEmpty;

            final serializableClass = serializableClasses.firstOrNull;
            serializableClasses = serializableClasses.skip(1).toList();

            final annotation = TypeChecker.fromRuntime(JKey)
                .firstAnnotationOf(classField ?? param);

            final fromJsonAdapters = getAdapterOf(
              typeChecker: fromJsonAdapterChecker,
              element: (classField ?? param),
              typeResolver: typeResolver,
            );

            final toJsonAdapters = getAdapterOf(
              typeChecker: toJsonAdapterChecker,
              element: (classField ?? param),
              typeResolver: typeResolver,
            );

            final jKey =
                annotation == null ? null : jKeyFromDartObj(annotation);

            if (jKey?.isExtras == true) {
              if (!resolvedType.isJson) {
                throw Exception(
                  'Error generating ${className}Serializer: '
                  'Extras field of [$className.${param.type} ${param.name}] is not Map<String, dynamic>',
                );
              }
              if (param.isNotOptional) {
                throw Exception(
                  'Error generating ${className}Serializer: '
                  'Extras field of [$className.${param.type} ${param.name}] is not optional',
                );
              }
            }

            if (jKey?.ignore == true && param.isNotOptional) {
              throw Exception(
                'Error generating ${className}Serializer: '
                '[$className.${param.type} ${param.name}] is required and marked as ignored',
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

            return JFieldConfig(
              fromJsonAdapters: fromJsonAdapters,
              toJsonAdapters: toJsonAdapters,
              genericConfig: genericConfig,
              hasSerializableGenerics: genericType != null,
              genericType: genericType,
              defaultValueCode: param.defaultValueCode,
              serializableClassType: serializableClass == null
                  ? null
                  : typeResolver.resolveType(
                      serializableClass.thisType,
                    ),
              serializableClassElement: serializableClass,
              isSerializableModel: isSerializable,
              keyConfig: jKey ?? JKey(),
              type: typeResolver.resolveType(param.type),
              jsonName: jsonName,
              fieldName: param.name,
              isNamed: param.isNamed,
            );
          },
        )
        .where(
          (element) => !element.keyConfig.ignore || element.keyConfig.isExtras,
        )
        .toList();
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
