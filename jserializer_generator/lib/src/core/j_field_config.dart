import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:jserializer_generator/src/resolved_type.dart';

class JKeyConfig implements JKey {
  const JKeyConfig({
    required this.ignore,
    required this.isExtras,
    this.name,
    required this.overridesFields,
  });

  factory JKeyConfig.fromDartObj(DartObject obj) => JKeyConfig(
        ignore: obj.getField('ignore')?.toBoolValue() ?? false,
        name: obj.getField('name')?.toStringValue(),
        isExtras: obj.getField('isExtras')?.toBoolValue() ?? false,
        overridesFields:
            obj.getField('overridesFields')?.toBoolValue() ?? false,
      );

  @override
  final bool ignore;

  @override
  final bool isExtras;

  @override
  final String? name;

  @override
  final bool overridesFields;
}

class JFieldConfig {
  const JFieldConfig({
    this.genericType,
    required this.hasSerializableGenerics,
    required this.paramType,
    required this.jsonKey,
    required this.isNamed,
    required this.keyConfig,
    required this.genericConfig,
    required this.fieldName,
    required this.serializableClassElement,
    required this.serializableClassType,
    this.isSerializableModel = false,
    this.defaultValueCode,
    required this.customAdapters,
    required this.customSerializerClass,
    required this.customSerializerClassType,
    required this.fieldType,
  });

  // final bool hasCustomSerializer;
  final ClassElement? customSerializerClass;
  final ResolvedType? customSerializerClassType;

  final List<CustomAdapterConfig> customAdapters;

  List<CustomAdapterConfig> get allAdapters {
    final id = <String>{};
    final List<CustomAdapterConfig> result = [];
    final list = [...customAdapters];
    for (final i in list) {
      if (id.add(i.adapterFieldName)) result.add(i);
    }
    return result;
  }

  bool get hasCustomAdapters => customAdapters.isNotEmpty;

  final ModelGenericConfig? genericConfig;
  final bool hasSerializableGenerics;
  final ResolvedType? genericType;
  final String? defaultValueCode;
  final bool isSerializableModel;
  final String fieldName;
  final String jsonKey;
  final bool isNamed;
  final ResolvedType paramType;
  final ResolvedType fieldType;

  final JKey keyConfig;
  final ClassElement? serializableClassElement;
  final ResolvedType? serializableClassType;

  bool get isBaseSerializable =>
      isSerializableModel &&
      serializableClassType != null &&
      serializableClassType!.name == paramType.name;

  bool get hasTypeArguments => paramType.typeArguments.isNotEmpty;

  bool get isSerializableAndHasGenerics =>
      hasTypeArguments && isSerializableModel;

  Reference? get serializableClassTypeReferNullable =>
      serializableClassType?.refer;

  Reference get serializableClassTypeRefer =>
      serializableClassTypeReferNullable!;

  String get fieldNameJsonSuffixed => '$fieldName\$Json';

  String get serializableClassName => serializableClassElement!.name;

  String get serializableClassNameLowerCase =>
      serializableClassName.firstLowerCase();

  String get fieldNameValueSuffixed => '$fieldName\$Value';

  String get fieldNameSerializerSuffixed {
    return paramType.isListOrMap
        ? serializableClassType!.fullNameAsSerializer
        : paramType.fullNameAsSerializer;
  }

  String get modelSerializerName =>
      customSerializerClass?.name ??
      '${serializableClassType?.name ?? paramType.name}Serializer';

  Reference get modelSerializerRefer => refer(
        modelSerializerName,
      );
}

extension StringX on String {
  String firstLowerCase() =>
      isEmpty ? '' : this[0].toLowerCase() + substring(1);
}
