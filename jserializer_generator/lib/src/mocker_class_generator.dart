import 'package:analyzer/dart/element/element.dart' show InterfaceElement;
import 'package:code_builder/code_builder.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/element_generator.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:jserializer_generator/src/mock_method_generator.dart';
import 'package:jserializer_generator/src/serializer_class_generator.dart';
import 'package:source_gen/source_gen.dart';

class MockerClassGenerator extends ElementGenerator<Class> {
  MockerClassGenerator({
    required this.config,
    required this.modelConfig,
    MockMethodGenerator? mockGenerator,
  }) : mockGenerator = mockGenerator ??
            MockMethodGenerator(modelConfig: modelConfig, config: config);

  final MockMethodGenerator mockGenerator;
  final JSerializable config;
  final ModelConfig modelConfig;

  InterfaceElement get classElement => modelConfig.classElement;

  String get className => classElement.name;

  Reader<ClassBuilder, ClassBuilder> setClassName() => Reader(
        (ClassBuilder b) => b..name = '${className}Mocker',
      );

  bool get isGeneric => modelConfig.hasGenericValue;

  Reference get thisRefer => modelConfig.type.baseRefer;

  Reader<ClassBuilder, ClassBuilder> addExtends({
    Reference? secondTypeRefer,
  }) =>
      Reader(
        (ClassBuilder b) {
          return b
            ..extend = TypeReference(
              (b) => b
                ..symbol = modelConfig.baseMockerName
                ..url = jSerializerImport
                ..types.addAll(
                  [
                    modelConfig.type.baseRefer,
                    if (secondTypeRefer != null) secondTypeRefer,
                  ],
                ),
            );
        },
      );

  List<JFieldConfig> get serializableFields =>
      modelConfig.fields.where((m) => m.isSerializableModel).toList();

  List<Field> getCustomMockers() {
    final fields = <Field>[];
    final ids = <String>{};

    for (final field in modelConfig.fields) {
      for (final adapter in field.uniqueMockers) {
        adapter.adapterFieldName;
        if (ids.contains(adapter.adapterFieldName)) continue;
        final bodyAccessor = adapter.revivable.accessor;

        final f = Field(
          (b) => b
            ..name = adapter.adapterFieldName
            ..modifier = FieldModifier.constant
            ..static = true
            ..assignment = adapter.type.refer.newInstance(
              [
                for (final x in adapter.revivable.positionalArguments)
                  refer(x.toCodeString()),
              ],
              {
                ...adapter.revivable.namedArguments.map(
                  (key, value) {
                    return MapEntry(
                      key,
                      refer(value.toCodeString()),
                    );
                  },
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

  Reader<ClassBuilder, ClassBuilder> implement() {
    return Reader(
      (ClassBuilder b) {
        return b
          ..fields.addAll([
            ...getCustomMockers(),
          ])
          ..methods.addAll(
            [
              ...mockGenerator.getMethods(),
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
          .andThen(setClassName)
          .andThen(addExtends)
          .andThen(implement)
          .run,
    );
  }
}
