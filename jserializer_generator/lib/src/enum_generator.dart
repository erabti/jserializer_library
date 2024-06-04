import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/class_generator.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/from_json_generator.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:jserializer_generator/src/to_json_generator.dart';

class EnumGenerator {
  EnumGenerator({
    required this.globalConfig,
    required this.modelConfig,
    required this.enumConfig,
  });

  final EnumConfig enumConfig;
  final JSerializable globalConfig;
  final ModelConfig modelConfig;

  late final fromJsonGenerator = FromJsonGenerator(
    config: globalConfig,
    modelConfig: modelConfig,
  );

  bool get isGeneric => modelConfig.hasGenericValue;

  late final toJsonGenerator = ToJsonGenerator(
    config: globalConfig,
    modelConfig: modelConfig,
  );

  Class generate() {
    final classGen = ClassGenerator(
      config: globalConfig,
      modelConfig: modelConfig,
    );

    return Class(
      classGen
          .createConstructor()
          .andThen(classGen.appendSuffix)
          .andThen(
            () => classGen.addExtends(secondTypeRefer: jsonTypeRefer),
          )
          .andThen(() => implement())
          .run,
    );
  }

  Reader<ClassBuilder, ClassBuilder> implement() => Reader(
        (ClassBuilder b) => b
          ..methods.addAll(
            [
              getFromJson(),
              getToJson(),
            ],
          ),
      );

  Reference get jsonTypeRefer =>
      enumConfig.identifier?.type.refer ?? refer('String');

  String get identifierName => enumConfig.identifier?.field.name ?? 'name';

  Method getFromJson() {
    late final throwCode = """
throw Exception(
  'JSerializationException in Enum of type \$${modelConfig.classElement.name} '
  'Unknown enum value: \$json',
);
""";

    String getDefaultValueCode(String fallbackName) => """
return ${modelConfig.classElement.name}.$fallbackName;
""";

    final fallbackName = enumConfig.fallback?.fieldName;

    final orElseCode =
        fallbackName != null ? getDefaultValueCode(fallbackName) : throwCode;

    final cases = <String>[];
    for (final value in enumConfig.values) {
      final fieldName = value.fieldName;
      final jsonName = value.jsonName;

      final code = """
if(json == $jsonName) return ${modelConfig.classElement.name}.$fieldName;
""";

      cases.add(code);
    }

    final casesCode = cases.join('\n');

    final body = Block(
      (b) => b
        ..statements.add(
          Code(
            """
$casesCode
$orElseCode
""",
          ),
        ),
    );

    final method = Method(
      (b) => b
        ..name = 'fromJson'
        ..returns = modelConfig.type.refer
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'json'
              ..type = jsonTypeRefer,
          ),
        )
        ..body = body,
    );

    return method;
  }

  Method getToJson() {
    final identifier = enumConfig.identifier;

    final String body;

    if (identifier != null) {
      body = """
return model.$identifierName;
""";
    } else {
      final cases = <String>[];

      for (final field in enumConfig.values) {
        final fieldName = field.fieldName;
        final jsonName = field.jsonName;

        final code = """
case ${modelConfig.classElement.name}.$fieldName:
    return $jsonName;
""";
        cases.add(code);
      }

      final casesCode = cases.join('\n');

      body = """
switch(model) {
$casesCode
}
""";
    }

    return Method(
      (b) => b
        ..name = 'toJson'
        ..returns = jsonTypeRefer
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'model'
              ..type = modelConfig.type.refer,
          ),
        )
        ..body = Block(
          (b) => b..statements.add(Code(body)),
        ),
    );
  }
}
