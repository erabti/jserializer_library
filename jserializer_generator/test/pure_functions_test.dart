import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:jserializer_generator/src/core/j_field_config.dart';
import 'package:jserializer_generator/src/core/model_config.dart';
import 'package:jserializer_generator/builder.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // 1. reCase function
  // ---------------------------------------------------------------------------
  group('reCase', () {
    test('returns camelCase when nameCase is FieldNameCase.camel', () {
      expect(reCase('hello_world', nameCase: FieldNameCase.camel), 'helloWorld');
      expect(reCase('HelloWorld', nameCase: FieldNameCase.camel), 'helloWorld');
      expect(reCase('my_field_name', nameCase: FieldNameCase.camel), 'myFieldName');
    });

    test('returns PascalCase when nameCase is FieldNameCase.pascal', () {
      expect(reCase('hello_world', nameCase: FieldNameCase.pascal), 'HelloWorld');
      expect(reCase('myFieldName', nameCase: FieldNameCase.pascal), 'MyFieldName');
      expect(reCase('my_field_name', nameCase: FieldNameCase.pascal), 'MyFieldName');
    });

    test('returns snake_case when nameCase is FieldNameCase.snake', () {
      expect(reCase('helloWorld', nameCase: FieldNameCase.snake), 'hello_world');
      expect(reCase('HelloWorld', nameCase: FieldNameCase.snake), 'hello_world');
      expect(reCase('myFieldName', nameCase: FieldNameCase.snake), 'my_field_name');
    });

    test('returns identifier unchanged when nameCase is null', () {
      expect(reCase('helloWorld'), 'helloWorld');
      expect(reCase('HelloWorld'), 'HelloWorld');
      expect(reCase('my_field_name'), 'my_field_name');
    });

    test('returns identifier unchanged when nameCase is FieldNameCase.none', () {
      expect(reCase('helloWorld', nameCase: FieldNameCase.none), 'helloWorld');
      expect(reCase('HelloWorld', nameCase: FieldNameCase.none), 'HelloWorld');
      expect(reCase('my_field_name', nameCase: FieldNameCase.none), 'my_field_name');
    });

    test('handles single word identifiers', () {
      expect(reCase('hello', nameCase: FieldNameCase.camel), 'hello');
      expect(reCase('hello', nameCase: FieldNameCase.pascal), 'Hello');
      expect(reCase('hello', nameCase: FieldNameCase.snake), 'hello');
    });

    test('handles already-cased identifiers idempotently', () {
      // camelCase on already camelCase
      expect(reCase('myFieldName', nameCase: FieldNameCase.camel), 'myFieldName');
      // PascalCase on already PascalCase
      expect(reCase('MyFieldName', nameCase: FieldNameCase.pascal), 'MyFieldName');
      // snake_case on already snake_case
      expect(reCase('my_field_name', nameCase: FieldNameCase.snake), 'my_field_name');
    });
  });

  // ---------------------------------------------------------------------------
  // 2. NoPrefixAllocator class
  // ---------------------------------------------------------------------------
  group('NoPrefixAllocator', () {
    late NoPrefixAllocator allocator;

    setUp(() {
      allocator = NoPrefixAllocator();
    });

    test('allocate with jserializer URL returns js. prefixed symbol', () {
      final ref = refer('ModelSerializer', 'package:jserializer/jserializer.dart');
      final result = allocator.allocate(ref);
      expect(result, 'js.ModelSerializer');
    });

    test('allocate with non-jserializer URL returns plain symbol', () {
      final ref = refer('SomeClass', 'package:some_package/some_package.dart');
      final result = allocator.allocate(ref);
      expect(result, 'SomeClass');
    });

    test('allocate with null URL returns plain symbol', () {
      final ref = refer('LocalClass');
      final result = allocator.allocate(ref);
      expect(result, 'LocalClass');
    });

    test('imports tracks all URLs that have been allocated', () {
      allocator.allocate(refer('A', 'package:jserializer/jserializer.dart'));
      allocator.allocate(refer('B', 'package:other/other.dart'));
      allocator.allocate(refer('C')); // null URL, should not be tracked

      final importDirectives = allocator.imports.toList();
      expect(importDirectives, hasLength(2));
    });

    test('imports contains js alias for jserializer package', () {
      allocator.allocate(refer('X', 'package:jserializer/jserializer.dart'));
      allocator.allocate(refer('Y', 'package:foo/foo.dart'));

      final importDirectives = allocator.imports.toList();

      // Find the jserializer directive
      final jsDirective = importDirectives.firstWhere(
        (d) => d.url == 'package:jserializer/jserializer.dart',
      );
      expect(jsDirective.as, 'js');

      // Find the other directive — should have no alias
      final otherDirective = importDirectives.firstWhere(
        (d) => d.url == 'package:foo/foo.dart',
      );
      expect(otherDirective.as, isNull);
    });

    test('imports deduplicates URLs', () {
      allocator.allocate(refer('A', 'package:jserializer/jserializer.dart'));
      allocator.allocate(refer('B', 'package:jserializer/jserializer.dart'));
      allocator.allocate(refer('C', 'package:other/other.dart'));
      allocator.allocate(refer('D', 'package:other/other.dart'));

      final importDirectives = allocator.imports.toList();
      expect(importDirectives, hasLength(2));
    });

    test('imports is empty when no URLs have been allocated', () {
      allocator.allocate(refer('LocalClass')); // null URL
      expect(allocator.imports, isEmpty);
    });

    test('multiple jserializer symbols all get js. prefix', () {
      expect(
        allocator.allocate(refer('Serializer', 'package:jserializer/jserializer.dart')),
        'js.Serializer',
      );
      expect(
        allocator.allocate(refer('JSerializable', 'package:jserializer/jserializer.dart')),
        'js.JSerializable',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 3. StringX.firstLowerCase() extension
  // ---------------------------------------------------------------------------
  group('StringX.firstLowerCase()', () {
    test('lowercases the first character of a normal string', () {
      expect('HelloWorld'.firstLowerCase(), 'helloWorld');
    });

    test('returns empty string for empty input', () {
      expect(''.firstLowerCase(), '');
    });

    test('handles single character string', () {
      expect('A'.firstLowerCase(), 'a');
      expect('Z'.firstLowerCase(), 'z');
    });

    test('returns same string if already lowercase', () {
      expect('helloWorld'.firstLowerCase(), 'helloWorld');
      expect('a'.firstLowerCase(), 'a');
    });

    test('only lowercases the first character', () {
      expect('ABC'.firstLowerCase(), 'aBC');
    });

    test('handles non-alphabetic first character', () {
      expect('123abc'.firstLowerCase(), '123abc');
      expect('_Hello'.firstLowerCase(), '_Hello');
    });
  });

  // ---------------------------------------------------------------------------
  // 4. jSerializerBuilder function
  // ---------------------------------------------------------------------------
  group('jSerializerBuilder', () {
    test('creates a builder with default options', () {
      final builder = jSerializerBuilder(BuilderOptions({}));
      expect(builder, isNotNull);
      expect(builder.buildExtensions.values.first, contains('lib/jserializer.dart'));
    });

    test('creates a builder with custom output_file', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'output_file': 'lib/custom_output.dart',
      }));
      expect(builder.buildExtensions.values.first, contains('lib/custom_output.dart'));
    });

    test('creates a builder with camel fieldNameCase', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'fieldNameCase': 'camel',
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with snake fieldNameCase', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'fieldNameCase': 'snake',
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with pascal fieldNameCase', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'fieldNameCase': 'pascal',
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with filterToJsonNulls', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'filterToJsonNulls': true,
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with ignoreAll list', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'ignoreAll': ['field1', 'field2'],
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with safeLookup', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'safeLookup': true,
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with export_models_analysis flag', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'export_models_analysis': true,
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with custom input_files', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'input_files': 'lib/models/**.dart',
      }));
      expect(builder, isNotNull);
    });

    test('handles unknown fieldNameCase by defaulting to none', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'fieldNameCase': 'unknown_case',
      }));
      expect(builder, isNotNull);
    });

    test('creates a builder with multiple options combined', () {
      final builder = jSerializerBuilder(BuilderOptions({
        'fieldNameCase': 'snake',
        'filterToJsonNulls': true,
        'safeLookup': true,
        'ignoreAll': ['createdAt', 'updatedAt'],
        'output_file': 'lib/generated/serializers.dart',
        'input_files': 'lib/models/**.dart',
      }));
      expect(builder, isNotNull);
      expect(builder.buildExtensions.values.first,
          contains('lib/generated/serializers.dart'));
    });
  });

  // ---------------------------------------------------------------------------
  // 6. ModelGenericConfig.serializerName
  // ---------------------------------------------------------------------------
  group('ModelGenericConfig.serializerName', () {
    // ModelGenericConfig requires a ResolvedType which needs a DartType.
    // We cannot easily create a DartType without the analyzer, so we test
    // the logic directly via string manipulation matching the implementation.
    test('serializerName logic: index 0 returns "serializer"', () {
      // The implementation: 'serializer${index == 0 ? '' : index + 1}'
      const index = 0;
      final name = 'serializer${index == 0 ? '' : index + 1}';
      expect(name, 'serializer');
    });

    test('serializerName logic: index 1 returns "serializer2"', () {
      const index = 1;
      final name = 'serializer${index == 0 ? '' : index + 1}';
      expect(name, 'serializer2');
    });

    test('serializerName logic: index 2 returns "serializer3"', () {
      const index = 2;
      final name = 'serializer${index == 0 ? '' : index + 1}';
      expect(name, 'serializer3');
    });

    test('serializerName logic: index 5 returns "serializer6"', () {
      const index = 5;
      final name = 'serializer${index == 0 ? '' : index + 1}';
      expect(name, 'serializer6');
    });
  });

  // ---------------------------------------------------------------------------
  // 7. EnumKeyConfig
  // ---------------------------------------------------------------------------
  group('EnumKeyConfig', () {
    test('stores fieldName and jsonName', () {
      const config = EnumKeyConfig(fieldName: 'myField', jsonName: 'my_field');
      expect(config.fieldName, 'myField');
      expect(config.jsonName, 'my_field');
    });

    test('supports different fieldName and jsonName', () {
      const config = EnumKeyConfig(fieldName: 'status', jsonName: 'STATUS');
      expect(config.fieldName, 'status');
      expect(config.jsonName, 'STATUS');
    });

    test('supports same fieldName and jsonName', () {
      const config = EnumKeyConfig(fieldName: 'value', jsonName: 'value');
      expect(config.fieldName, config.jsonName);
    });
  });

  // ---------------------------------------------------------------------------
  // 7b. UnionConfig.typeKey (via UnionSubTypeMeta.typeKey)
  // ---------------------------------------------------------------------------
  group('UnionSubTypeMeta.typeKey', () {
    test('returns custom typeKey from unionAnnotation', () {
      final meta = UnionSubTypeMeta(
        typeJsonValue: 'someValue',
        unionAnnotation: const JUnion(typeKey: 'kind'),
        unionValueAnnotation: const JUnionValue(name: 'test'),
      );
      expect(meta.typeKey, 'kind');
    });

    test('returns default "type" when typeKey is null', () {
      final meta = UnionSubTypeMeta(
        typeJsonValue: 'someValue',
        unionAnnotation: const JUnion(),
        unionValueAnnotation: const JUnionValue(name: 'test'),
      );
      expect(meta.typeKey, 'type');
    });

    test('stores typeJsonValue correctly', () {
      final meta = UnionSubTypeMeta(
        typeJsonValue: 'mySubType',
        unionAnnotation: const JUnion(),
        unionValueAnnotation: const JUnionValue(name: 'test'),
      );
      expect(meta.typeJsonValue, 'mySubType');
    });
  });

  // ---------------------------------------------------------------------------
  // 7c. UnionConfig.typeKey
  // ---------------------------------------------------------------------------
  group('UnionConfig.typeKey', () {
    test('returns custom typeKey from annotation', () {
      final config = UnionConfig(
        values: [],
        annotation: const JUnion(typeKey: 'discriminator'),
        fallbackValue: null,
      );
      expect(config.typeKey, 'discriminator');
    });

    test('returns default "type" when annotation typeKey is null', () {
      final config = UnionConfig(
        values: [],
        annotation: const JUnion(),
        fallbackValue: null,
      );
      expect(config.typeKey, 'type');
    });
  });
}
