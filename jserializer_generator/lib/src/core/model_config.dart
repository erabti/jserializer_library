import 'package:analyzer/dart/element/element.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/resolved_type.dart';

class ModelConfig {
  const ModelConfig({
    required this.type,
    required this.classElement,
    required this.isCustomMocker,
    this.fields = const [],
    required this.hasGenericValue,
    required this.genericConfigs,
    // this.isCustomSerializer = false,
    this.extrasField,
    required this.customSerializableModelType,
    required this.customMockerModelType,
    required this.isCustomSerializer,
    this.unionConfig,
    this.enumConfig,
    this.unionSubTypeMeta,
  });

  final EnumConfig? enumConfig;
  final UnionConfig? unionConfig;
  final UnionSubTypeMeta? unionSubTypeMeta;

  bool get isEnum => enumConfig != null;

  bool get isUnionSuperType => unionConfig != null;

  final ResolvedType? customSerializableModelType;
  final ResolvedType? customMockerModelType;

  final bool isCustomSerializer;
  final bool isCustomMocker;

  bool get isCustomMockerOrSerializer => isCustomMocker || isCustomSerializer;

  final JFieldConfig? extrasField;

  String get baseSerializeName {
    if (isEnum) return 'CustomModelSerializer';
    if (genericConfigs.isEmpty) return 'ModelSerializer';
    return 'GenericModelSerializer';
  }

  String get baseMockerName {
    if (isEnum) return 'JCustomMocker';
    if (isUnionSuperType) return 'JCustomMocker';

    if (genericConfigs.isEmpty) return 'JModelMocker';
    return 'JGenericMocker';
  }

  final bool hasGenericValue;

  // final bool isCustomSerializer;

  final InterfaceElement classElement;
  final List<ModelGenericConfig> genericConfigs;

  final ResolvedType type;

  final List<JFieldConfig> fields;

  List<JFieldConfig> get namedFields => fields.where((f) => f.isNamed).toList();

  List<JFieldConfig> get positionalFields =>
      fields.where((f) => !f.isNamed).toList();
}

class ModelGenericConfig {
  const ModelGenericConfig(this.type, this.index);

  final ResolvedType type;
  final int index;

  String get serializerName => 'serializer${index == 0 ? '' : index + 1}';
}

class EnumConfig {
  final List<EnumKeyConfig> values;
  final EnumKeyConfig? fallback;
  final EnumIdentifierConfig? identifier;

  const EnumConfig({
    required this.values,
    this.fallback,
    this.identifier,
  });
}

class EnumIdentifierConfig {
  final FieldElement field;
  final ResolvedType type;

  const EnumIdentifierConfig({
    required this.field,
    required this.type,
  });
}

class EnumKeyConfig {
  final String fieldName;
  final String jsonName;

  const EnumKeyConfig({
    required this.fieldName,
    required this.jsonName,
  });
}

class UnionConfig {
  final List<UnionValueConfig> values;
  final JUnion annotation;

  String get typeKey => annotation.typeKey ?? 'type';

  final UnionValueConfig? fallbackValue;

  const UnionConfig({
    required this.values,
    required this.annotation,
    required this.fallbackValue,
  });
}

class UnionValueConfig {
  final JUnionValue annotation;
  final ModelConfig config;

  // useful when the union type is not generic but the value is
  final ResolvedType redirectedType;
  final String jsonKey;
  final ConstructorElement constructor;

  const UnionValueConfig({
    required this.redirectedType,
    required this.annotation,
    required this.config,
    required this.jsonKey,
    required this.constructor,
  });
}

class UnionSubTypeMeta {
  const UnionSubTypeMeta({
    required this.typeJsonValue,
    required this.unionAnnotation,
    required this.unionValueAnnotation,
  });

  final String typeJsonValue;
  final JUnion unionAnnotation;
  final JUnionValue unionValueAnnotation;

  String get typeKey => unionAnnotation.typeKey ?? 'type';
}
