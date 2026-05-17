// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/j_key_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Fake DartType
// ---------------------------------------------------------------------------
class FakeDartType implements DartType {
  final String _displayString;
  final bool _isDartCoreMap;
  final bool _isDartCoreList;
  final bool _isDartCoreBool;
  final bool _isDartCoreString;
  final bool _isDartCoreInt;
  final bool _isDartCoreDouble;
  final bool _isDartCoreNum;
  final NullabilitySuffix _nullability;
  final Element? _element;

  FakeDartType(
    this._displayString, {
    bool isDartCoreMap = false,
    bool isDartCoreList = false,
    bool isDartCoreBool = false,
    bool isDartCoreString = false,
    bool isDartCoreInt = false,
    bool isDartCoreDouble = false,
    bool isDartCoreNum = false,
    NullabilitySuffix nullability = NullabilitySuffix.none,
    Element? element,
  })  : _isDartCoreMap = isDartCoreMap,
        _isDartCoreList = isDartCoreList,
        _isDartCoreBool = isDartCoreBool,
        _isDartCoreString = isDartCoreString,
        _isDartCoreInt = isDartCoreInt,
        _isDartCoreDouble = isDartCoreDouble,
        _isDartCoreNum = isDartCoreNum,
        _nullability = nullability,
        _element = element;

  @override
  String getDisplayString({bool withNullability = true}) => _displayString;

  @override
  bool get isDartCoreMap => _isDartCoreMap;
  @override
  bool get isDartCoreList => _isDartCoreList;
  @override
  bool get isDartCoreBool => _isDartCoreBool;
  @override
  bool get isDartCoreString => _isDartCoreString;
  @override
  bool get isDartCoreInt => _isDartCoreInt;
  @override
  bool get isDartCoreDouble => _isDartCoreDouble;
  @override
  bool get isDartCoreNum => _isDartCoreNum;
  @override
  NullabilitySuffix get nullabilitySuffix => _nullability;
  @override
  Element? get element => _element;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

// ---------------------------------------------------------------------------
// Fake DynamicType
// ---------------------------------------------------------------------------
class FakeDynamicType extends FakeDartType implements DynamicType {
  FakeDynamicType() : super('dynamic');

  @override
  Element? get element => null;
}

// ---------------------------------------------------------------------------
// Fake InterfaceElement
// ---------------------------------------------------------------------------
class FakeInterfaceElement implements InterfaceElement {
  final String? _name;

  FakeInterfaceElement([this._name = 'TestClass']);

  @override
  String? get name => _name;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
ResolvedType makeResolvedType(
  String name, {
  List<ResolvedType> typeArguments = const [],
  bool isNullable = false,
  DartType? dartType,
}) {
  return ResolvedType(
    name: name,
    dartType: dartType ?? FakeDartType(name),
    typeArguments: typeArguments,
    isNullable: isNullable,
  );
}

/// Create a minimal JFieldConfig for testing.
JFieldConfig makeFieldConfig({
  String fieldName = 'field',
  String jsonKey = 'field',
  bool isNamed = true,
  bool isSerializableModel = false,
  ResolvedType? paramType,
  ResolvedType? fieldType,
  ResolvedType? serializableClassType,
  InterfaceElement? serializableClassElement,
  InterfaceElement? customSerializerClass,
  ResolvedType? customSerializerClassType,
  List<CustomAdapterConfig> customAdapters = const [],
  List<CustomAdapterConfig> customMockers = const [],
  ModelGenericConfig? genericConfig,
  bool hasSerializableGenerics = false,
  ResolvedType? genericType,
  String? defaultValueCode,
  JKeyConfig? keyConfig,
}) {
  final pt = paramType ?? makeResolvedType('String');
  final ft = fieldType ?? pt;
  return JFieldConfig(
    fieldName: fieldName,
    jsonKey: jsonKey,
    isNamed: isNamed,
    paramType: pt,
    fieldType: ft,
    keyConfig: keyConfig ?? const JKeyConfig(),
    genericConfig: genericConfig,
    hasSerializableGenerics: hasSerializableGenerics,
    genericType: genericType,
    isSerializableModel: isSerializableModel,
    serializableClassElement: serializableClassElement,
    serializableClassType: serializableClassType,
    customAdapters: customAdapters,
    customMockers: customMockers,
    customSerializerClass: customSerializerClass,
    customSerializerClassType: customSerializerClassType,
    defaultValueCode: defaultValueCode,
  );
}

/// Create a minimal ModelConfig for testing.
ModelConfig makeModelConfig({
  ResolvedType? type,
  InterfaceElement? classElement,
  bool isCustomMocker = false,
  bool isCustomSerializer = false,
  List<JFieldConfig>? fields,
  bool hasGenericValue = false,
  List<ModelGenericConfig> genericConfigs = const [],
  ResolvedType? customSerializableModelType,
  ResolvedType? customMockerModelType,
  EnumConfig? enumConfig,
  UnionConfig? unionConfig,
  UnionSubTypeMeta? unionSubTypeMeta,
  JFieldConfig? extrasField,
}) {
  return ModelConfig(
    type: type ?? makeResolvedType('TestClass'),
    classElement: classElement ?? FakeInterfaceElement(),
    isCustomMocker: isCustomMocker,
    isCustomSerializer: isCustomSerializer,
    fields: fields ?? [],
    hasGenericValue: hasGenericValue,
    genericConfigs: genericConfigs,
    customSerializableModelType: customSerializableModelType,
    customMockerModelType: customMockerModelType,
    enumConfig: enumConfig,
    unionConfig: unionConfig,
    unionSubTypeMeta: unionSubTypeMeta,
    extrasField: extrasField,
  );
}

// ===========================================================================
// Fake CustomAdapterConfig
// ===========================================================================
/// Build a CustomAdapterConfig with the minimum fields needed for uniqueness
/// tests.  The only thing the tested code accesses is [adapterFieldName],
/// which in the real class is `'_\$${param.name}_\$${type.fullName}'`.
/// We provide a thin fake that computes the same value.
class FakeFormalParameterElement implements FormalParameterElement {
  final String _name;

  FakeFormalParameterElement(this._name);

  @override
  String get name => _name;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

CustomAdapterConfig makeFakeAdapter({
  required String paramName,
  required String typeName,
}) {
  final param = FakeFormalParameterElement(paramName);
  final resolvedType = makeResolvedType(typeName);
  return CustomAdapterConfig(
    param: param,
    // reader and revivable are not accessed by uniqueAdapters/uniqueMockers
    reader: _FakeConstantReader(),
    revivable: _FakeRevivable(),
    type: resolvedType,
    jsonType: makeResolvedType('dynamic'),
    modelType: makeResolvedType(typeName),
  );
}

// Minimal stubs for ConstantReader and Revivable – never actually called in
// the tests that exercise uniqueAdapters / uniqueMockers.
class _FakeConstantReader implements ConstantReader {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeRevivable implements Revivable {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

// ===========================================================================
// Tests
// ===========================================================================
void main() {
  // -------------------------------------------------------------------------
  // ModelConfig
  // -------------------------------------------------------------------------
  group('ModelConfig', () {
    group('isEnum', () {
      test('returns true when enumConfig is not null', () {
        final config = makeModelConfig(
          enumConfig: const EnumConfig(values: []),
        );
        expect(config.isEnum, isTrue);
      });

      test('returns false when enumConfig is null', () {
        final config = makeModelConfig();
        expect(config.isEnum, isFalse);
      });
    });

    group('isUnionSuperType', () {
      test('returns true when unionConfig is not null', () {
        final config = makeModelConfig(
          unionConfig: UnionConfig(
            values: [],
            annotation: const JUnion(),
            fallbackValue: null,
          ),
        );
        expect(config.isUnionSuperType, isTrue);
      });

      test('returns false when unionConfig is null', () {
        final config = makeModelConfig();
        expect(config.isUnionSuperType, isFalse);
      });
    });

    group('isCustomMockerOrSerializer', () {
      test('returns true when isCustomMocker is true', () {
        final config = makeModelConfig(isCustomMocker: true);
        expect(config.isCustomMockerOrSerializer, isTrue);
      });

      test('returns true when isCustomSerializer is true', () {
        final config = makeModelConfig(isCustomSerializer: true);
        expect(config.isCustomMockerOrSerializer, isTrue);
      });

      test('returns true when both are true', () {
        final config = makeModelConfig(
          isCustomMocker: true,
          isCustomSerializer: true,
        );
        expect(config.isCustomMockerOrSerializer, isTrue);
      });

      test('returns false when both are false', () {
        final config = makeModelConfig();
        expect(config.isCustomMockerOrSerializer, isFalse);
      });
    });

    group('baseSerializeName', () {
      test('returns CustomModelSerializer for enums', () {
        final config = makeModelConfig(
          enumConfig: const EnumConfig(values: []),
        );
        expect(config.baseSerializeName, 'CustomModelSerializer');
      });

      test('returns ModelSerializer for non-generic, non-enum', () {
        final config = makeModelConfig();
        expect(config.baseSerializeName, 'ModelSerializer');
      });

      test('returns GenericModelSerializer when genericConfigs is non-empty',
          () {
        final config = makeModelConfig(
          genericConfigs: [
            ModelGenericConfig(makeResolvedType('T'), 0),
          ],
        );
        expect(config.baseSerializeName, 'GenericModelSerializer');
      });

      test('enum takes precedence over generic', () {
        final config = makeModelConfig(
          enumConfig: const EnumConfig(values: []),
          genericConfigs: [
            ModelGenericConfig(makeResolvedType('T'), 0),
          ],
        );
        expect(config.baseSerializeName, 'CustomModelSerializer');
      });
    });

    group('baseMockerName', () {
      test('returns JCustomMocker for enums', () {
        final config = makeModelConfig(
          enumConfig: const EnumConfig(values: []),
        );
        expect(config.baseMockerName, 'JCustomMocker');
      });

      test('returns JCustomMocker for unions', () {
        final config = makeModelConfig(
          unionConfig: UnionConfig(
            values: [],
            annotation: const JUnion(),
            fallbackValue: null,
          ),
        );
        expect(config.baseMockerName, 'JCustomMocker');
      });

      test('returns JModelMocker for non-generic, non-enum, non-union', () {
        final config = makeModelConfig();
        expect(config.baseMockerName, 'JModelMocker');
      });

      test('returns JGenericMocker when genericConfigs is non-empty', () {
        final config = makeModelConfig(
          genericConfigs: [
            ModelGenericConfig(makeResolvedType('T'), 0),
          ],
        );
        expect(config.baseMockerName, 'JGenericMocker');
      });

      test('enum takes precedence over generic', () {
        final config = makeModelConfig(
          enumConfig: const EnumConfig(values: []),
          genericConfigs: [
            ModelGenericConfig(makeResolvedType('T'), 0),
          ],
        );
        expect(config.baseMockerName, 'JCustomMocker');
      });

      test('union takes precedence over generic', () {
        final config = makeModelConfig(
          unionConfig: UnionConfig(
            values: [],
            annotation: const JUnion(),
            fallbackValue: null,
          ),
          genericConfigs: [
            ModelGenericConfig(makeResolvedType('T'), 0),
          ],
        );
        expect(config.baseMockerName, 'JCustomMocker');
      });
    });

    group('namedFields / positionalFields', () {
      test('namedFields returns only named fields', () {
        final named1 = makeFieldConfig(fieldName: 'a', isNamed: true);
        final named2 = makeFieldConfig(fieldName: 'b', isNamed: true);
        final positional = makeFieldConfig(fieldName: 'c', isNamed: false);

        final config = makeModelConfig(fields: [named1, positional, named2]);

        expect(config.namedFields, hasLength(2));
        expect(config.namedFields.map((f) => f.fieldName), ['a', 'b']);
      });

      test('positionalFields returns only positional fields', () {
        final named = makeFieldConfig(fieldName: 'a', isNamed: true);
        final pos1 = makeFieldConfig(fieldName: 'b', isNamed: false);
        final pos2 = makeFieldConfig(fieldName: 'c', isNamed: false);

        final config = makeModelConfig(fields: [named, pos1, pos2]);

        expect(config.positionalFields, hasLength(2));
        expect(config.positionalFields.map((f) => f.fieldName), ['b', 'c']);
      });

      test('namedFields is empty when all fields are positional', () {
        final pos = makeFieldConfig(fieldName: 'a', isNamed: false);
        final config = makeModelConfig(fields: [pos]);
        expect(config.namedFields, isEmpty);
      });

      test('positionalFields is empty when all fields are named', () {
        final named = makeFieldConfig(fieldName: 'a', isNamed: true);
        final config = makeModelConfig(fields: [named]);
        expect(config.positionalFields, isEmpty);
      });

      test('both are empty when fields is empty', () {
        final config = makeModelConfig(fields: []);
        expect(config.namedFields, isEmpty);
        expect(config.positionalFields, isEmpty);
      });
    });
  });

  // -------------------------------------------------------------------------
  // ModelGenericConfig
  // -------------------------------------------------------------------------
  group('ModelGenericConfig', () {
    test('serializerName returns "serializer" for index 0', () {
      final gc = ModelGenericConfig(makeResolvedType('T'), 0);
      expect(gc.serializerName, 'serializer');
    });

    test('serializerName returns "serializer2" for index 1', () {
      final gc = ModelGenericConfig(makeResolvedType('U'), 1);
      expect(gc.serializerName, 'serializer2');
    });

    test('serializerName returns "serializer3" for index 2', () {
      final gc = ModelGenericConfig(makeResolvedType('V'), 2);
      expect(gc.serializerName, 'serializer3');
    });
  });

  // -------------------------------------------------------------------------
  // JFieldConfig
  // -------------------------------------------------------------------------
  group('JFieldConfig', () {
    group('uniqueAdapters', () {
      test('returns all adapters when names are unique', () {
        final a1 = makeFakeAdapter(paramName: 'x', typeName: 'IntAdapter');
        final a2 = makeFakeAdapter(paramName: 'y', typeName: 'StrAdapter');
        final field = makeFieldConfig(customAdapters: [a1, a2]);
        expect(field.uniqueAdapters, hasLength(2));
      });

      test('deduplicates adapters with the same adapterFieldName', () {
        final a1 = makeFakeAdapter(paramName: 'x', typeName: 'IntAdapter');
        final a2 = makeFakeAdapter(paramName: 'x', typeName: 'IntAdapter');
        final field = makeFieldConfig(customAdapters: [a1, a2]);
        expect(field.uniqueAdapters, hasLength(1));
      });

      test('returns empty list when no adapters', () {
        final field = makeFieldConfig(customAdapters: []);
        expect(field.uniqueAdapters, isEmpty);
      });
    });

    group('uniqueMockers', () {
      test('returns all mockers when names are unique', () {
        final m1 = makeFakeAdapter(paramName: 'a', typeName: 'MockerA');
        final m2 = makeFakeAdapter(paramName: 'b', typeName: 'MockerB');
        final field = makeFieldConfig(customMockers: [m1, m2]);
        expect(field.uniqueMockers, hasLength(2));
      });

      test('deduplicates mockers with the same adapterFieldName', () {
        final m1 = makeFakeAdapter(paramName: 'a', typeName: 'MockerA');
        final m2 = makeFakeAdapter(paramName: 'a', typeName: 'MockerA');
        final field = makeFieldConfig(customMockers: [m1, m2]);
        expect(field.uniqueMockers, hasLength(1));
      });

      test('returns empty list when no mockers', () {
        final field = makeFieldConfig(customMockers: []);
        expect(field.uniqueMockers, isEmpty);
      });
    });

    group('hasCustomAdapters', () {
      test('returns true when customAdapters is non-empty', () {
        final a1 = makeFakeAdapter(paramName: 'x', typeName: 'IntAdapter');
        final field = makeFieldConfig(customAdapters: [a1]);
        expect(field.hasCustomAdapters, isTrue);
      });

      test('returns false when customAdapters is empty', () {
        final field = makeFieldConfig(customAdapters: []);
        expect(field.hasCustomAdapters, isFalse);
      });
    });

    group('hasCustomMockers', () {
      test('returns true when customMockers is non-empty', () {
        final m1 = makeFakeAdapter(paramName: 'a', typeName: 'MockerA');
        final field = makeFieldConfig(customMockers: [m1]);
        expect(field.hasCustomMockers, isTrue);
      });

      test('returns false when customMockers is empty', () {
        final field = makeFieldConfig(customMockers: []);
        expect(field.hasCustomMockers, isFalse);
      });
    });

    group('isBaseSerializable', () {
      test('returns true when all conditions met', () {
        final rt = makeResolvedType('MyModel');
        final field = makeFieldConfig(
          isSerializableModel: true,
          paramType: rt,
          serializableClassType: rt,
        );
        expect(field.isBaseSerializable, isTrue);
      });

      test('returns false when isSerializableModel is false', () {
        final rt = makeResolvedType('MyModel');
        final field = makeFieldConfig(
          isSerializableModel: false,
          paramType: rt,
          serializableClassType: rt,
        );
        expect(field.isBaseSerializable, isFalse);
      });

      test('returns false when serializableClassType is null', () {
        final field = makeFieldConfig(
          isSerializableModel: true,
          serializableClassType: null,
        );
        expect(field.isBaseSerializable, isFalse);
      });

      test('returns false when names differ', () {
        final field = makeFieldConfig(
          isSerializableModel: true,
          paramType: makeResolvedType('Foo'),
          serializableClassType: makeResolvedType('Bar'),
        );
        expect(field.isBaseSerializable, isFalse);
      });
    });

    group('hasTypeArguments', () {
      test('returns true when paramType has type arguments', () {
        final inner = makeResolvedType('String');
        final listType = makeResolvedType(
          'List',
          typeArguments: [inner],
          dartType: FakeDartType('List<String>', isDartCoreList: true),
        );
        final field = makeFieldConfig(paramType: listType);
        expect(field.hasTypeArguments, isTrue);
      });

      test('returns false when paramType has no type arguments', () {
        final field = makeFieldConfig(paramType: makeResolvedType('int'));
        expect(field.hasTypeArguments, isFalse);
      });
    });

    group('isSerializableAndHasGenerics', () {
      test('returns true when both conditions hold', () {
        final inner = makeResolvedType('MyModel');
        final listType = makeResolvedType(
          'List',
          typeArguments: [inner],
          dartType: FakeDartType('List<MyModel>', isDartCoreList: true),
        );
        final field = makeFieldConfig(
          paramType: listType,
          isSerializableModel: true,
        );
        expect(field.isSerializableAndHasGenerics, isTrue);
      });

      test('returns false when isSerializableModel is false', () {
        final inner = makeResolvedType('String');
        final listType = makeResolvedType(
          'List',
          typeArguments: [inner],
          dartType: FakeDartType('List<String>', isDartCoreList: true),
        );
        final field = makeFieldConfig(
          paramType: listType,
          isSerializableModel: false,
        );
        expect(field.isSerializableAndHasGenerics, isFalse);
      });

      test('returns false when no type arguments', () {
        final field = makeFieldConfig(
          paramType: makeResolvedType('MyModel'),
          isSerializableModel: true,
        );
        expect(field.isSerializableAndHasGenerics, isFalse);
      });
    });

    group('fieldNameJsonSuffixed', () {
      test('appends \$Json to field name', () {
        final field = makeFieldConfig(fieldName: 'age');
        expect(field.fieldNameJsonSuffixed, r'age$Json');
      });

      test('works with longer field names', () {
        final field = makeFieldConfig(fieldName: 'firstName');
        expect(field.fieldNameJsonSuffixed, r'firstName$Json');
      });
    });

    group('fieldNameValueSuffixed', () {
      test('appends \$Value to field name', () {
        final field = makeFieldConfig(fieldName: 'age');
        expect(field.fieldNameValueSuffixed, r'age$Value');
      });

      test('works with longer field names', () {
        final field = makeFieldConfig(fieldName: 'firstName');
        expect(field.fieldNameValueSuffixed, r'firstName$Value');
      });
    });

    group('fieldNameSerializerSuffixed', () {
      test('uses serializableClassType fullNameAsSerializer for list', () {
        final innerType = makeResolvedType('MyModel');
        final listDartType =
            FakeDartType('List<MyModel>', isDartCoreList: true);
        final listType = makeResolvedType(
          'List',
          typeArguments: [innerType],
          dartType: listDartType,
        );
        final serType = makeResolvedType('MyModel');

        final field = makeFieldConfig(
          paramType: listType,
          isSerializableModel: true,
          serializableClassType: serType,
          serializableClassElement: FakeInterfaceElement('MyModel'),
        );
        expect(field.fieldNameSerializerSuffixed, serType.fullNameAsSerializer);
      });

      test('uses serializableClassType fullNameAsSerializer for map', () {
        final keyType = makeResolvedType(
          'String',
          dartType: FakeDartType('String', isDartCoreString: true),
        );
        final valType = makeResolvedType('MyModel');
        final mapDartType = FakeDartType('Map<String, MyModel>',
            isDartCoreMap: true);
        final mapType = makeResolvedType(
          'Map',
          typeArguments: [keyType, valType],
          dartType: mapDartType,
        );
        final serType = makeResolvedType('MyModel');

        final field = makeFieldConfig(
          paramType: mapType,
          isSerializableModel: true,
          serializableClassType: serType,
          serializableClassElement: FakeInterfaceElement('MyModel'),
        );
        expect(field.fieldNameSerializerSuffixed, serType.fullNameAsSerializer);
      });

      test('uses paramType fullNameAsSerializer for non-list-non-map', () {
        final pt = makeResolvedType('MyModel');
        final field = makeFieldConfig(
          paramType: pt,
          isSerializableModel: true,
          serializableClassType: makeResolvedType('MyModel'),
          serializableClassElement: FakeInterfaceElement('MyModel'),
        );
        expect(field.fieldNameSerializerSuffixed, pt.fullNameAsSerializer);
      });
    });

    group('modelSerializerName', () {
      test('uses customSerializerClass name when present', () {
        final field = makeFieldConfig(
          customSerializerClass: FakeInterfaceElement('MyCustomSerializer'),
        );
        expect(field.modelSerializerName, 'MyCustomSerializer');
      });

      test('uses serializableClassType name + Serializer when no custom', () {
        final field = makeFieldConfig(
          serializableClassType: makeResolvedType('Person'),
        );
        expect(field.modelSerializerName, 'PersonSerializer');
      });

      test('falls back to paramType name + Serializer', () {
        final field = makeFieldConfig(
          paramType: makeResolvedType('Animal'),
          serializableClassType: null,
        );
        expect(field.modelSerializerName, 'AnimalSerializer');
      });
    });
  });

  // -------------------------------------------------------------------------
  // StringX extension
  // -------------------------------------------------------------------------
  group('StringX.firstLowerCase', () {
    test('lowercases the first character', () {
      expect('Hello'.firstLowerCase(), 'hello');
    });

    test('returns empty string for empty input', () {
      expect(''.firstLowerCase(), '');
    });

    test('single character string is lowercased', () {
      expect('A'.firstLowerCase(), 'a');
    });

    test('already lowercase is unchanged', () {
      expect('hello'.firstLowerCase(), 'hello');
    });

    test('handles uppercase abbreviations', () {
      expect('URL'.firstLowerCase(), 'uRL');
    });
  });

  // -------------------------------------------------------------------------
  // JKeyConfig
  // -------------------------------------------------------------------------
  group('JKeyConfig', () {
    group('default constructor', () {
      test('has correct defaults', () {
        const config = JKeyConfig();
        expect(config.ignore, isFalse);
        expect(config.isExtras, isFalse);
        expect(config.name, isNull);
        expect(config.overridesToJsonModelFields, isFalse);
        expect(config.fallbackName, isNull);
        expect(config.mockValueCode, isNull);
      });
    });

    group('custom values', () {
      test('stores ignore = true', () {
        const config = JKeyConfig(ignore: true);
        expect(config.ignore, isTrue);
      });

      test('stores isExtras = true', () {
        const config = JKeyConfig(isExtras: true);
        expect(config.isExtras, isTrue);
      });

      test('stores name', () {
        const config = JKeyConfig(name: 'my_key');
        expect(config.name, 'my_key');
      });

      test('stores overridesToJsonModelFields = true', () {
        const config = JKeyConfig(overridesToJsonModelFields: true);
        expect(config.overridesToJsonModelFields, isTrue);
      });

      test('stores fallbackName', () {
        const config = JKeyConfig(fallbackName: 'fallback');
        expect(config.fallbackName, 'fallback');
      });

      test('stores mockValueCode', () {
        const config = JKeyConfig(mockValueCode: "'test'");
        expect(config.mockValueCode, "'test'");
      });

      test('stores all custom values together', () {
        const config = JKeyConfig(
          ignore: true,
          isExtras: true,
          name: 'key_name',
          overridesToJsonModelFields: true,
          fallbackName: 'fb',
          mockValueCode: '42',
        );
        expect(config.ignore, isTrue);
        expect(config.isExtras, isTrue);
        expect(config.name, 'key_name');
        expect(config.overridesToJsonModelFields, isTrue);
        expect(config.fallbackName, 'fb');
        expect(config.mockValueCode, '42');
      });
    });
  });

  // -------------------------------------------------------------------------
  // ResolvedType computed properties
  // -------------------------------------------------------------------------
  group('ResolvedType', () {
    group('fullName', () {
      test('strips nullability suffix and special chars', () {
        final rt = makeResolvedType(
          'String',
          dartType: FakeDartType('String'),
        );
        expect(rt.fullName, 'String');
      });

      test('transforms generic type display string', () {
        final rt = makeResolvedType(
          'Map',
          dartType: FakeDartType('Map<String, int>'),
        );
        // 'Map<String, int>' -> remove spaces -> 'Map<String,int>'
        // -> replace , and < with _ -> 'Map_String_int>'
        // -> remove > -> 'Map_String_int'
        expect(rt.fullName, 'Map_String_int');
      });
    });

    group('fullNameAsSerializer', () {
      test('prepends underscore and appends Serializer', () {
        final rt = makeResolvedType(
          'MyModel',
          dartType: FakeDartType('MyModel'),
        );
        expect(rt.fullNameAsSerializer, '_MyModelSerializer');
      });
    });

    group('isMap / isList', () {
      test('isMap returns true for map types', () {
        final rt = makeResolvedType(
          'Map',
          dartType: FakeDartType('Map', isDartCoreMap: true),
        );
        expect(rt.isMap, isTrue);
        expect(rt.isList, isFalse);
      });

      test('isList returns true for list types', () {
        final rt = makeResolvedType(
          'List',
          dartType: FakeDartType('List', isDartCoreList: true),
        );
        expect(rt.isList, isTrue);
        expect(rt.isMap, isFalse);
      });

      test('isListOrMap returns true for either', () {
        final listRt = makeResolvedType(
          'List',
          dartType: FakeDartType('List', isDartCoreList: true),
        );
        final mapRt = makeResolvedType(
          'Map',
          dartType: FakeDartType('Map', isDartCoreMap: true),
        );
        expect(listRt.isListOrMap, isTrue);
        expect(mapRt.isListOrMap, isTrue);
      });

      test('isListOrMap returns false for plain types', () {
        final rt = makeResolvedType(
          'String',
          dartType: FakeDartType('String', isDartCoreString: true),
        );
        expect(rt.isListOrMap, isFalse);
      });
    });

    group('isPrimitive', () {
      test('returns true for String', () {
        final rt = makeResolvedType(
          'String',
          dartType: FakeDartType('String', isDartCoreString: true),
        );
        expect(rt.isPrimitive, isTrue);
      });

      test('returns true for int', () {
        final rt = makeResolvedType(
          'int',
          dartType: FakeDartType('int', isDartCoreInt: true),
        );
        expect(rt.isPrimitive, isTrue);
      });

      test('returns true for double', () {
        final rt = makeResolvedType(
          'double',
          dartType: FakeDartType('double', isDartCoreDouble: true),
        );
        expect(rt.isPrimitive, isTrue);
      });

      test('returns true for bool', () {
        final rt = makeResolvedType(
          'bool',
          dartType: FakeDartType('bool', isDartCoreBool: true),
        );
        expect(rt.isPrimitive, isTrue);
      });

      test('returns true for num', () {
        final rt = makeResolvedType(
          'num',
          dartType: FakeDartType('num', isDartCoreNum: true),
        );
        expect(rt.isPrimitive, isTrue);
      });

      test('returns true for dynamic', () {
        final rt = makeResolvedType(
          'dynamic',
          dartType: FakeDynamicType(),
        );
        expect(rt.isPrimitive, isTrue);
      });

      test('returns false for non-primitive', () {
        final rt = makeResolvedType(
          'MyClass',
          dartType: FakeDartType('MyClass'),
        );
        expect(rt.isPrimitive, isFalse);
      });
    });

    group('isJson', () {
      test('returns true for Map<String, dynamic>', () {
        final strType = makeResolvedType(
          'String',
          dartType: FakeDartType('String', isDartCoreString: true),
        );
        final dynType = makeResolvedType(
          'dynamic',
          dartType: FakeDynamicType(),
        );
        final mapType = makeResolvedType(
          'Map',
          typeArguments: [strType, dynType],
          dartType: FakeDartType('Map<String, dynamic>', isDartCoreMap: true),
        );
        expect(mapType.isJson, isTrue);
      });

      test('returns false for Map<String, int>', () {
        final strType = makeResolvedType(
          'String',
          dartType: FakeDartType('String', isDartCoreString: true),
        );
        final intType = makeResolvedType(
          'int',
          dartType: FakeDartType('int', isDartCoreInt: true),
        );
        final mapType = makeResolvedType(
          'Map',
          typeArguments: [strType, intType],
          dartType: FakeDartType('Map<String, int>', isDartCoreMap: true),
        );
        expect(mapType.isJson, isFalse);
      });

      test('returns false for non-map types', () {
        final rt = makeResolvedType(
          'String',
          dartType: FakeDartType('String', isDartCoreString: true),
        );
        expect(rt.isJson, isFalse);
      });
    });

    group('listTypeArgument', () {
      test('returns first type argument for list', () {
        final inner = makeResolvedType(
          'int',
          dartType: FakeDartType('int', isDartCoreInt: true),
        );
        final listType = makeResolvedType(
          'List',
          typeArguments: [inner],
          dartType: FakeDartType('List<int>', isDartCoreList: true),
        );
        expect(listType.listTypeArgument, same(inner));
      });

      test('returns null for non-list', () {
        final rt = makeResolvedType(
          'String',
          dartType: FakeDartType('String', isDartCoreString: true),
        );
        expect(rt.listTypeArgument, isNull);
      });
    });

    group('identity', () {
      test('combines import and name', () {
        final rt = ResolvedType(
          name: 'MyType',
          dartType: FakeDartType('MyType'),
          import: 'package:my/types.dart',
        );
        expect(rt.identity, 'package:my/types.dart#MyType');
      });

      test('null import produces null#name', () {
        final rt = makeResolvedType('Foo');
        expect(rt.identity, 'null#Foo');
      });
    });

    group('equality', () {
      test('two ResolvedTypes with same identity are equal', () {
        final a = ResolvedType(
          name: 'Foo',
          dartType: FakeDartType('Foo'),
          import: 'package:a/a.dart',
        );
        final b = ResolvedType(
          name: 'Foo',
          dartType: FakeDartType('Foo'),
          import: 'package:a/a.dart',
        );
        expect(a, equals(b));
      });

      test('two ResolvedTypes with different name are not equal', () {
        final a = ResolvedType(
          name: 'Foo',
          dartType: FakeDartType('Foo'),
          import: 'package:a/a.dart',
        );
        final b = ResolvedType(
          name: 'Bar',
          dartType: FakeDartType('Bar'),
          import: 'package:a/a.dart',
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('returns name when no type arguments', () {
        final rt = makeResolvedType('String');
        expect(rt.toString(), 'String');
      });

      test('includes type arguments', () {
        final inner = makeResolvedType('int');
        final rt = makeResolvedType('List', typeArguments: [inner]);
        expect(rt.toString(), 'List<int>');
      });

      test('handles multiple type arguments', () {
        final k = makeResolvedType('String');
        final v = makeResolvedType('int');
        final rt = makeResolvedType('Map', typeArguments: [k, v]);
        expect(rt.toString(), 'Map<String,int>');
      });
    });

    group('copyWith', () {
      test('copies all fields by default', () {
        final original = ResolvedType(
          name: 'Foo',
          dartType: FakeDartType('Foo'),
          import: 'package:a/a.dart',
          isNullable: true,
          typeArguments: [makeResolvedType('int')],
        );
        final copy = original.copyWith();
        expect(copy.name, original.name);
        expect(copy.import, original.import);
        expect(copy.isNullable, original.isNullable);
        expect(copy.typeArguments, original.typeArguments);
      });

      test('overrides specified fields', () {
        final original = makeResolvedType('Foo');
        final copy = original.copyWith(name: 'Bar', isNullable: true);
        expect(copy.name, 'Bar');
        expect(copy.isNullable, isTrue);
      });
    });

    group('isPrimitiveList', () {
      test('returns true for List<int>', () {
        final intType = makeResolvedType(
          'int',
          dartType: FakeDartType('int', isDartCoreInt: true),
        );
        final listType = makeResolvedType(
          'List',
          typeArguments: [intType],
          dartType: FakeDartType('List<int>', isDartCoreList: true),
        );
        expect(listType.isPrimitiveList, isTrue);
      });

      test('returns false for List<MyModel>', () {
        final modelType = makeResolvedType(
          'MyModel',
          dartType: FakeDartType('MyModel'),
        );
        final listType = makeResolvedType(
          'List',
          typeArguments: [modelType],
          dartType: FakeDartType('List<MyModel>', isDartCoreList: true),
        );
        expect(listType.isPrimitiveList, isFalse);
      });

      test('returns false for non-list type', () {
        final rt = makeResolvedType(
          'int',
          dartType: FakeDartType('int', isDartCoreInt: true),
        );
        expect(rt.isPrimitiveList, isFalse);
      });
    });
  });

  // -------------------------------------------------------------------------
  // EnumConfig / EnumKeyConfig
  // -------------------------------------------------------------------------
  group('EnumConfig', () {
    test('stores values', () {
      const ec = EnumConfig(values: [
        EnumKeyConfig(fieldName: 'a', jsonName: 'A'),
        EnumKeyConfig(fieldName: 'b', jsonName: 'B'),
      ]);
      expect(ec.values, hasLength(2));
      expect(ec.values[0].fieldName, 'a');
      expect(ec.values[0].jsonName, 'A');
    });

    test('fallback defaults to null', () {
      const ec = EnumConfig(values: []);
      expect(ec.fallback, isNull);
    });

    test('stores fallback', () {
      const ec = EnumConfig(
        values: [],
        fallback: EnumKeyConfig(fieldName: 'x', jsonName: 'X'),
      );
      expect(ec.fallback, isNotNull);
      expect(ec.fallback!.fieldName, 'x');
    });
  });

  // -------------------------------------------------------------------------
  // UnionConfig
  // -------------------------------------------------------------------------
  group('UnionConfig', () {
    test('typeKey defaults to "type" when annotation has null typeKey', () {
      final uc = UnionConfig(
        values: [],
        annotation: const JUnion(),
        fallbackValue: null,
      );
      expect(uc.typeKey, 'type');
    });

    test('typeKey uses annotation typeKey when provided', () {
      final uc = UnionConfig(
        values: [],
        annotation: const JUnion(typeKey: 'kind'),
        fallbackValue: null,
      );
      expect(uc.typeKey, 'kind');
    });
  });

  // -------------------------------------------------------------------------
  // UnionSubTypeMeta
  // -------------------------------------------------------------------------
  group('UnionSubTypeMeta', () {
    test('typeKey defaults to "type" when annotation has null typeKey', () {
      const meta = UnionSubTypeMeta(
        typeJsonValue: 'myValue',
        unionAnnotation: JUnion(),
        unionValueAnnotation: JUnionValue(),
      );
      expect(meta.typeKey, 'type');
      expect(meta.typeJsonValue, 'myValue');
    });

    test('typeKey uses annotation typeKey when provided', () {
      const meta = UnionSubTypeMeta(
        typeJsonValue: 'val',
        unionAnnotation: JUnion(typeKey: 'discriminator'),
        unionValueAnnotation: JUnionValue(),
      );
      expect(meta.typeKey, 'discriminator');
    });
  });
}
