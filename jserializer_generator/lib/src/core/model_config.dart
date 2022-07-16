import 'package:analyzer/dart/element/element.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/class_generator.dart';
import 'package:jserializer_generator/src/resolved_type.dart';

class ModelConfig {
  const ModelConfig({
    required this.type,
    required this.classElement,
    this.fields = const [],
    required this.hasGenericValue,
    required this.genericConfigs,
    // this.isCustomSerializer = false,
    this.extrasField,
    required this.customSerializableType,
    required this.isCustomSerializer,
    this.unionConfig,
  });

  final UnionConfig? unionConfig;

  bool get isUnionSuperType => unionConfig != null;

  final ResolvedType? customSerializableType;
  final bool isCustomSerializer;

  final JFieldConfig? extrasField;

  String get baseSerializeName {
    if (genericConfigs.isEmpty) return 'ModelSerializer';
    return 'GenericModelSerializer${genericConfigs.length == 1 ? '' : genericConfigs.length.toString()}';
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

class ModelGenericConfig {
  const ModelGenericConfig(this.type, this.index);

  final ResolvedType type;
  final int index;

  String get serializerName => 'serializer${index == 0 ? '' : index + 1}';
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

  final String typeName;

  const UnionValueConfig({
    required this.annotation,
    required this.config,
    required this.typeName,
  });
}
