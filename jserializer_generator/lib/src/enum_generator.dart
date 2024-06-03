import 'package:code_builder/code_builder.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/class_generator.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/from_json_generator.dart';
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
    final fallbackName = enumConfig.fallback?.name;

    final orElseCode =
        fallbackName != null ? getDefaultValueCode(fallbackName) : throwCode;

    final body = Block(
      (b) => b
        ..statements.add(
          Code(
            """
return ${modelConfig.classElement.name}.values.firstWhere(
    (e) => e.$identifierName == json,
    orElse: () {
$orElseCode
    },
);
""",
          ),
        ),
    );

    return Method(
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
  }

  Method getToJson() {
    return Method((b) => b
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
        (b) => b
          ..statements.add(
            Code(
              """
return model.$identifierName;
""",
            ),
          ),
      ));
  }
}
