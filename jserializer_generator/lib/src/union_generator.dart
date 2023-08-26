import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/class_generator.dart';
import 'package:jserializer_generator/src/core/model_config.dart';

class UnionGenerator {
  static Class generate({
    required UnionConfig unionConfig,
    required ModelConfig modelConfig,
    required JSerializable globalConfig,
  }) {
    assert(modelConfig.isUnionSuperType);

    final classGen = ClassGenerator(
      config: globalConfig,
      modelConfig: modelConfig,
    );

    return Class(
      classGen
          .createConstructor()
          .andThen(classGen.appendSuffix)
          .andThen(classGen.addExtends)
          .andThen(
            () => implement(
              unionConfig: unionConfig,
              modelConfig: modelConfig,
              globalConfig: globalConfig,
            ),
          )
          .run,
    );
  }

  static Reader<ClassBuilder, ClassBuilder> implement({
    required UnionConfig unionConfig,
    required ModelConfig modelConfig,
    required JSerializable globalConfig,
  }) =>
      Reader(
        (ClassBuilder b) {
          final subTypes = unionConfig.values;

          return b
            ..fields.addAll(subTypes.map(getUnionSerializerField))
            ..methods.addAll(
              [
                getFromJson(
                  unionConfig: unionConfig,
                  modelConfig: modelConfig,
                  globalConfig: globalConfig,
                ),
                getToJson(
                  unionConfig: unionConfig,
                  modelConfig: modelConfig,
                  globalConfig: globalConfig,
                ),
              ],
            );
        },
      );

  static Method getFromJson({
    required UnionConfig unionConfig,
    required ModelConfig modelConfig,
    required JSerializable globalConfig,
  }) {
    final type = modelConfig.type;
    final isGeneric = type.typeArguments.isNotEmpty;

    final returnType = isGeneric ? refer('M') : modelConfig.type.refer;

    return Method(
      (b) => b
        ..name = isGeneric ? 'fromJsonGeneric' : 'fromJson'
        ..types.addAll(
          [
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
          ],
        )
        ..returns = returnType
        ..requiredParameters.add(
          Parameter((b) => b..name = 'json'),
        )
        ..body = Block(
          (b) {
            final fallbackValue = unionConfig.fallbackValue;

            b.statements.addAll(
              [
                Code(
                    'if(json is ${type.typeArguments.isNotEmpty ? 'M' : type.refer.symbol}) return json;'),
                Code("""if(json is! Map){
               throw Exception(
                'JSON passed to fromJson of ${type.refer.symbol}) is not a Map!\\njson: \$json',
                );
              }"""),
                Code("final type = json['${unionConfig.typeKey}'];"),
                Code("""if(type is! String){
               throw Exception(
                'Type passed to fromJson of ${type.refer.symbol}) is not a String!\\nvalue: \$type',
                );
              }"""),
                for (final type in unionConfig.values) Code("""
if(json[type] == '${type.typeName}'){
  return ${type.config.type.fullNameAsSerializer}.fromJson(json);
}"""),
                if (fallbackValue != null) Code('''
else {
return ${fallbackValue.config.classElement.name}();
}''') else Code('''
else {
throw Exception('Unknown type \$type of union type ${modelConfig.classElement.name}');
}'''),
              ],
            );
          },
        ),
    );
  }

  static Method getToJson({
    required UnionConfig unionConfig,
    required ModelConfig modelConfig,
    required JSerializable globalConfig,
  }) {
    return Method(
      (b) => b
        ..name = 'toJson'
        ..requiredParameters.add(
          Parameter(
            (b) => b
              ..name = 'model'
              ..type = modelConfig.type.baseRefer,
          ),
        )
        ..returns = mapRefer(refer('String'), refer('dynamic'))
        ..body = Block(
          (b) {
            final fallbackValue = unionConfig.fallbackValue;

            b.statements.addAll(
              [
                for (final type in unionConfig.values) Code("""
if(model is ${type.config.classElement.name}){
  return {
  '${unionConfig.typeKey}': '${type.typeName}',
   ...${type.config.type.fullNameAsSerializer}.toJson(model),
  };
}"""),
                if (fallbackValue != null) Code('''
else {
return {'${unionConfig.typeKey}': '${fallbackValue.typeName}'};
}''') else Code('''
else {
throw Exception('Unknown type of union value: \$model');
}'''),
              ],
            );
          },
        ),
    );
  }

  static Field getUnionSerializerField(UnionValueConfig unionConfig) {
    final modelConfig = unionConfig.config;

    final serializerRefer = refer('${modelConfig.classElement.name}Serializer');
    final type = modelConfig.type;
    final fieldName = type.fullNameAsSerializer;
    final isGeneric = type.typeArguments.isNotEmpty;
    final clazz = modelConfig.classElement;
    final Code instance;

    if (!isGeneric) {
      instance = serializerRefer.newInstance([]).code;
    } else {
      final args = type.typeArguments;

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
        for (var i = 0; i < args.length; i++) getSerializerKey(i): getRefer(i),
      }).code;
    }

    return Field(
      (b) => b
        ..static = !isGeneric || clazz.typeParameters.isEmpty
        ..modifier = !isGeneric ? FieldModifier.constant : FieldModifier.final$
        ..assignment = instance
        ..late = isGeneric
        ..name = fieldName,
    );
  }
}
