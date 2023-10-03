import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/element_generator.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/from_json_generator.dart';
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:jserializer_generator/src/to_json_generator.dart';
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
  ClassGenerator({
    required this.config,
    required this.modelConfig,
    FromJsonGenerator? fromJsonGenerator,
    ToJsonGenerator? toJsonGenerator,
  })  : fromJsonGenerator = fromJsonGenerator ??
            FromJsonGenerator(modelConfig: modelConfig, config: config),
        toJsonGenerator = toJsonGenerator ??
            ToJsonGenerator(modelConfig: modelConfig, config: config);

  final FromJsonGenerator fromJsonGenerator;
  final ToJsonGenerator toJsonGenerator;
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
                ..types.add(modelConfig.type.baseRefer),
            );
        },
      );

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

  List<JFieldConfig> get serializableFields => modelConfig.fields
      .where(
        (m) => m.isSerializableModel,
      )
      .toList();

  ModelGenericConfig? getGenericConfigFromType(ResolvedType type) =>
      modelConfig.genericConfigs.firstWhereOrNull(
        (element) => element.type.name == type.name,
      );

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

  Field getJsonKeysField() => Field(
        (b) => b
          ..name = 'jsonKeys'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = literalSet(
            modelConfig.fields.map((e) => literalString(e.jsonKey)),
          ).code,
      );

  Reader<ClassBuilder, ClassBuilder> implement() {
    return Reader(
      (ClassBuilder b) {
        return b
          ..fields.addAll([
            ...getCustomAdapters(),
            ...fromJsonGenerator.getFields(),
            getJsonKeysField(),
          ])
          ..methods.addAll(
            [
              ...fromJsonGenerator.getMethods(),
              ...toJsonGenerator.getMethods(),
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
                    ..optionalParameters.addAll(
                      [
                        Parameter(
                          (b) => b
                            ..toSuper = true
                            ..name = 'jSerializer'
                            ..named = true,
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
