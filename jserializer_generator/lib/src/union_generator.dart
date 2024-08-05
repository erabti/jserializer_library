import 'package:code_builder/code_builder.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/serializer_class_generator.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/from_json_generator.dart';
import 'package:jserializer_generator/src/to_json_generator.dart';

class UnionGenerator {
  UnionGenerator({
    required this.globalConfig,
    required this.unionConfig,
    required this.modelConfig,
  });

  final JSerializable globalConfig;
  final UnionConfig unionConfig;
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
    assert(modelConfig.isUnionSuperType);

    final classGen = SerializerClassGenerator(
      config: globalConfig,
      modelConfig: modelConfig,
    );

    return Class(
      classGen
          .createConstructor()
          .andThen(classGen.appendSuffix)
          .andThen(classGen.addExtends)
          .andThen(
            () => implement(),
          )
          .run,
    );
  }

  Reader<ClassBuilder, ClassBuilder> implement() => Reader(
        (ClassBuilder b) => b
          ..methods.addAll(
            [
              getFromJson(),
              getToJson(),
              if (isGeneric)
                fromJsonGenerator.getDecoderGetterForGenericModels(),
            ],
          ),
      );

  Method getFromJson() {
    final type = modelConfig.type;

    final statements = <Code>[];

    for (final value in unionConfig.values) {
      final fallbackValue = unionConfig.fallbackValue;
      if (value.jsonKey == fallbackValue?.jsonKey) continue;
      statements.add(Code('case \'${value.jsonKey}\':'));

      statements.add(
        refer('jSerializer')
            .property('fromJson')
            .call(
              [refer('json')],
              {},
              [value.redirectedType.refer],
            )
            .returned
            .statement,
      );
    }

    return Method(
      (b) {
        fromJsonGenerator.getDecoderSign(b).body = Block(
          (b) {
            final fallbackValue = unionConfig.fallbackValue;

            b.statements.addAll(
              [
                Code("final type = json['${unionConfig.typeKey}'];"),
                Code("""if(type is! String){
               throw Exception(
                'Type passed to fromJson of ${type.refer.symbol}) is not a String!\\nvalue: \$type',
                );
              }"""),
                Code('switch(type){'),
                for (final statement in statements) statement,
                Code('default:'),
                if (fallbackValue != null)
                  Code('return ${fallbackValue.config.classElement.name}();')
                else
                  Code(
                      'throw Exception(\'Unknown type \$type of union type ${modelConfig.classElement.name}\');'),
                Code('}'),
              ],
            );
          },
        );
      },
    );
  }

  Method getToJson() {
    return Method(
      (b) => toJsonGenerator.toJsonSignature(b)
        ..body = Block(
          (b) {
            b.statements.addAll(
              [
                for (final type in unionConfig.values) Code("""
if(model is ${type.config.classElement.name}){
  return {
  '${unionConfig.typeKey}': '${type.jsonKey}',
    ...(jSerializer.toJson(model) as Map<String, dynamic>),
  };
}"""),
                Code('''
throw Exception('Unknown type of union value: \$model');
'''),
              ],
            );
          },
        ),
    );
  }
}
