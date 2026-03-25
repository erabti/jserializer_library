// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart' show TypeReference;
import 'package:jserializer_generator/src/resolved_type.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeDartType implements DartType {
  final String displayString;
  @override
  final bool isDartCoreMap;
  @override
  final bool isDartCoreList;
  @override
  final bool isDartCoreBool;
  @override
  final bool isDartCoreString;
  @override
  final bool isDartCoreInt;
  @override
  final bool isDartCoreDouble;
  @override
  final bool isDartCoreNum;
  @override
  final NullabilitySuffix nullabilitySuffix;
  @override
  final Element? element;

  FakeDartType(
    this.displayString, {
    this.isDartCoreMap = false,
    this.isDartCoreList = false,
    this.isDartCoreBool = false,
    this.isDartCoreString = false,
    this.isDartCoreInt = false,
    this.isDartCoreDouble = false,
    this.isDartCoreNum = false,
    this.nullabilitySuffix = NullabilitySuffix.none,
    this.element,
  });

  @override
  String getDisplayString({bool withNullability = true}) => displayString;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not implemented');
}

class FakeDynamicType extends FakeDartType implements DynamicType {
  FakeDynamicType() : super('dynamic');

  @override
  Element? get element => null;
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

ResolvedType rt(
  String name, {
  DartType? dartType,
  String? import,
  bool isNullable = false,
  List<ResolvedType> typeArguments = const [],
}) {
  return ResolvedType(
    name: name,
    dartType: dartType ?? FakeDartType(name),
    import: import,
    isNullable: isNullable,
    typeArguments: typeArguments,
  );
}

// Convenience factories for common primitive dart types.
FakeDartType fakeBool() =>
    FakeDartType('bool', isDartCoreBool: true);
FakeDartType fakeString() =>
    FakeDartType('String', isDartCoreString: true);
FakeDartType fakeInt() =>
    FakeDartType('int', isDartCoreInt: true);
FakeDartType fakeDouble() =>
    FakeDartType('double', isDartCoreDouble: true);
FakeDartType fakeNum() =>
    FakeDartType('num', isDartCoreNum: true);
FakeDartType fakeList(String displayString) =>
    FakeDartType(displayString, isDartCoreList: true);
FakeDartType fakeMap(String displayString) =>
    FakeDartType(displayString, isDartCoreMap: true);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // 1. Constructor & basic properties
  // -------------------------------------------------------------------------
  group('Constructor & basic properties', () {
    test('stores name, import, isNullable, typeArguments, dartType', () {
      final dt = FakeDartType('Foo');
      final type = ResolvedType(
        name: 'Foo',
        dartType: dt,
        import: 'package:a/a.dart',
        isNullable: true,
        typeArguments: [rt('Bar')],
      );

      expect(type.name, 'Foo');
      expect(type.import, 'package:a/a.dart');
      expect(type.isNullable, isTrue);
      expect(type.typeArguments, hasLength(1));
      expect(type.typeArguments.first.name, 'Bar');
      expect(type.dartType, same(dt));
    });

    test('defaults: isNullable=false, typeArguments=const[], import=null', () {
      final type = rt('Simple');
      expect(type.isNullable, isFalse);
      expect(type.typeArguments, isEmpty);
      expect(type.import, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // 2. toString
  // -------------------------------------------------------------------------
  group('toString', () {
    test('without type arguments returns name', () {
      expect(rt('Foo').toString(), 'Foo');
    });

    test('with type arguments returns name<A,B>', () {
      final type = rt('Map', typeArguments: [rt('String'), rt('int')]);
      expect(type.toString(), 'Map<String,int>');
    });

    test('nested type arguments', () {
      final inner = rt('List', typeArguments: [rt('int')]);
      final outer = rt('Map', typeArguments: [rt('String'), inner]);
      expect(outer.toString(), 'Map<String,List<int>>');
    });
  });

  // -------------------------------------------------------------------------
  // 3. == and hashCode
  // -------------------------------------------------------------------------
  group('== and hashCode', () {
    test('equal when identity matches', () {
      final a = rt('Foo', import: 'pkg:a');
      final b = rt('Foo', import: 'pkg:a');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when name differs', () {
      final a = rt('Foo', import: 'pkg:a');
      final b = rt('Bar', import: 'pkg:a');
      expect(a, isNot(equals(b)));
    });

    test('not equal when import differs', () {
      final a = rt('Foo', import: 'pkg:a');
      final b = rt('Foo', import: 'pkg:b');
      expect(a, isNot(equals(b)));
    });

    test('identical object is equal', () {
      final a = rt('Foo');
      expect(a, equals(a));
    });

    test('not equal to non-ResolvedType', () {
      // ignore: unrelated_type_equality_checks
      expect(rt('Foo') == 'Foo', isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 4. identity
  // -------------------------------------------------------------------------
  group('identity', () {
    test('with import', () {
      expect(rt('Foo', import: 'pkg:a').identity, 'pkg:a#Foo');
    });

    test('without import (null)', () {
      expect(rt('Foo').identity, 'null#Foo');
    });
  });

  // -------------------------------------------------------------------------
  // 5. copyWith
  // -------------------------------------------------------------------------
  group('copyWith', () {
    test('override each field individually', () {
      final original = ResolvedType(
        name: 'Foo',
        dartType: FakeDartType('Foo'),
        import: 'pkg:a',
        isNullable: false,
        typeArguments: [rt('int')],
      );

      final newDt = FakeDartType('Bar');
      final copy = original.copyWith(
        name: 'Bar',
        dartType: newDt,
        import: 'pkg:b',
        isNullable: true,
        typeArguments: [],
      );

      expect(copy.name, 'Bar');
      expect(copy.dartType, same(newDt));
      expect(copy.import, 'pkg:b');
      expect(copy.isNullable, isTrue);
      expect(copy.typeArguments, isEmpty);
    });

    test('keeps defaults when no arguments provided', () {
      final original = ResolvedType(
        name: 'Foo',
        dartType: FakeDartType('Foo'),
        import: 'pkg:a',
        isNullable: true,
        typeArguments: [rt('int')],
      );

      final copy = original.copyWith();

      expect(copy.name, original.name);
      expect(copy.import, original.import);
      expect(copy.isNullable, original.isNullable);
      expect(copy.typeArguments, original.typeArguments);
      expect(copy.dartType, original.dartType);
    });
  });

  // -------------------------------------------------------------------------
  // 6. fullName
  // -------------------------------------------------------------------------
  group('fullName', () {
    test('simple type', () {
      expect(rt('Foo', dartType: FakeDartType('Foo')).fullName, 'Foo');
    });

    test('generic with commas, angles, and spaces', () {
      // e.g. "Map<String, int>" -> spaces and > removed, commas and < replaced with _
      final type = rt('Map',
          dartType: FakeDartType('Map<String, int>'),
          typeArguments: [rt('String'), rt('int')]);
      // "Map<String, int>" -> remove spaces and '>' -> "Map<String,int"
      // then replace '<' and ',' with '_' -> "Map_String_int"
      expect(type.fullName, 'Map_String_int');
    });

    test('nullable display string has ? removed', () {
      // The extension strips '?' from the display string
      final type = rt('Foo', dartType: FakeDartType('Foo?'));
      expect(type.fullName, 'Foo');
    });
  });

  // -------------------------------------------------------------------------
  // 7. fullNameAsSerializer
  // -------------------------------------------------------------------------
  group('fullNameAsSerializer', () {
    test('prefixes fullName with underscore and Serializer suffix', () {
      final type = rt('Foo', dartType: FakeDartType('Foo'));
      expect(type.fullNameAsSerializer, '_FooSerializer');
    });

    test('with generic type', () {
      final type = rt('List',
          dartType: FakeDartType('List<int>'),
          typeArguments: [rt('int')]);
      expect(type.fullNameAsSerializer, '_List_intSerializer');
    });
  });

  // -------------------------------------------------------------------------
  // 8. isMap, isList, isListOrMap
  // -------------------------------------------------------------------------
  group('isMap, isList, isListOrMap', () {
    test('isMap true when dartType.isDartCoreMap', () {
      final type = rt('Map', dartType: fakeMap('Map'));
      expect(type.isMap, isTrue);
      expect(type.isList, isFalse);
      expect(type.isListOrMap, isTrue);
    });

    test('isList true when dartType.isDartCoreList', () {
      final type = rt('List', dartType: fakeList('List'));
      expect(type.isList, isTrue);
      expect(type.isMap, isFalse);
      expect(type.isListOrMap, isTrue);
    });

    test('isListOrMap false for non-list/non-map', () {
      final type = rt('Foo');
      expect(type.isListOrMap, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 9. isJson
  // -------------------------------------------------------------------------
  group('isJson', () {
    test('true when Map<String, dynamic>', () {
      final stringArg = rt('String', dartType: fakeString());
      final dynamicArg = rt('dynamic', dartType: FakeDynamicType());
      final type = rt('Map',
          dartType: fakeMap('Map<String, dynamic>'),
          typeArguments: [stringArg, dynamicArg]);
      expect(type.isJson, isTrue);
    });

    test('false when first arg is not String', () {
      final intArg = rt('int', dartType: fakeInt());
      final dynamicArg = rt('dynamic', dartType: FakeDynamicType());
      final type = rt('Map',
          dartType: fakeMap('Map<int, dynamic>'),
          typeArguments: [intArg, dynamicArg]);
      expect(type.isJson, isFalse);
    });

    test('false when second arg is not dynamic', () {
      final stringArg = rt('String', dartType: fakeString());
      final intArg = rt('int', dartType: fakeInt());
      final type = rt('Map',
          dartType: fakeMap('Map<String, int>'),
          typeArguments: [stringArg, intArg]);
      expect(type.isJson, isFalse);
    });

    test('false when not a map', () {
      final type = rt('Foo');
      expect(type.isJson, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 10. isPrimitive
  // -------------------------------------------------------------------------
  group('isPrimitive', () {
    test('bool is primitive', () {
      expect(rt('bool', dartType: fakeBool()).isPrimitive, isTrue);
    });

    test('String is primitive', () {
      expect(rt('String', dartType: fakeString()).isPrimitive, isTrue);
    });

    test('int is primitive', () {
      expect(rt('int', dartType: fakeInt()).isPrimitive, isTrue);
    });

    test('double is primitive', () {
      expect(rt('double', dartType: fakeDouble()).isPrimitive, isTrue);
    });

    test('num is primitive', () {
      expect(rt('num', dartType: fakeNum()).isPrimitive, isTrue);
    });

    test('dynamic is primitive', () {
      expect(rt('dynamic', dartType: FakeDynamicType()).isPrimitive, isTrue);
    });

    test('custom type is not primitive', () {
      expect(rt('MyClass').isPrimitive, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 11. isPrimitiveList
  // -------------------------------------------------------------------------
  group('isPrimitiveList', () {
    test('List<int> is primitive list', () {
      final intArg = rt('int', dartType: fakeInt());
      final type = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);
      expect(type.isPrimitiveList, isTrue);
    });

    test('List<CustomType> is not primitive list', () {
      final customArg = rt('CustomType');
      final type = rt('List',
          dartType: fakeList('List<CustomType>'), typeArguments: [customArg]);
      expect(type.isPrimitiveList, isFalse);
    });

    test('non-list is not primitive list', () {
      expect(rt('Foo').isPrimitiveList, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 12. isPrimitiveNestedList
  // -------------------------------------------------------------------------
  group('isPrimitiveNestedList', () {
    test('List<List<int>> is primitive nested list', () {
      final intArg = rt('int', dartType: fakeInt());
      final innerList = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);
      final outerList = rt('List',
          dartType: fakeList('List<List<int>>'), typeArguments: [innerList]);
      expect(outerList.isPrimitiveNestedList, isTrue);
    });

    test('List<List<CustomType>> is not primitive nested list', () {
      final customArg = rt('CustomType');
      final innerList = rt('List',
          dartType: fakeList('List<CustomType>'),
          typeArguments: [customArg]);
      final outerList = rt('List',
          dartType: fakeList('List<List<CustomType>>'),
          typeArguments: [innerList]);
      expect(outerList.isPrimitiveNestedList, isFalse);
    });

    test('non-list returns false', () {
      expect(rt('Foo').isPrimitiveNestedList, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 13. isPrimitiveNestedMapOrList
  // -------------------------------------------------------------------------
  group('isPrimitiveNestedMapOrList', () {
    test('Map<String, List<int>> with primitives returns true', () {
      final intArg = rt('int', dartType: fakeInt());
      final innerList = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);
      final stringArg = rt('String', dartType: fakeString());
      final type = rt('Map',
          dartType: fakeMap('Map<String, List<int>>'),
          typeArguments: [stringArg, innerList]);
      expect(type.isPrimitiveNestedMapOrList, isTrue);
    });

    test('Map<String, CustomType> returns false', () {
      final stringArg = rt('String', dartType: fakeString());
      final customArg = rt('CustomType');
      final type = rt('Map',
          dartType: fakeMap('Map<String, CustomType>'),
          typeArguments: [stringArg, customArg]);
      expect(type.isPrimitiveNestedMapOrList, isFalse);
    });

    test('non-map/non-list returns false', () {
      expect(rt('Foo').isPrimitiveNestedMapOrList, isFalse);
    });

    test('List<Map<String, int>> returns true', () {
      final stringArg = rt('String', dartType: fakeString());
      final intArg = rt('int', dartType: fakeInt());
      final innerMap = rt('Map',
          dartType: fakeMap('Map<String, int>'),
          typeArguments: [stringArg, intArg]);
      final outerList = rt('List',
          dartType: fakeList('List<Map<String, int>>'),
          typeArguments: [innerMap]);
      expect(outerList.isPrimitiveNestedMapOrList, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // 14. isPrimitiveOrListOrMap
  // -------------------------------------------------------------------------
  group('isPrimitiveOrListOrMap', () {
    test('primitive type returns true', () {
      expect(rt('int', dartType: fakeInt()).isPrimitiveOrListOrMap(), isTrue);
    });

    test('list of primitives returns true', () {
      final intArg = rt('int', dartType: fakeInt());
      final type = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);
      expect(type.isPrimitiveOrListOrMap(), isTrue);
    });

    test('custom type returns false', () {
      expect(rt('MyClass').isPrimitiveOrListOrMap(), isFalse);
    });

    test('with skip function skips matching types', () {
      // A list containing a custom type, but we skip the custom type
      final customArg = rt('CustomType');
      final type = rt('List',
          dartType: fakeList('List<CustomType>'),
          typeArguments: [customArg]);
      // Without skip: the custom type makes this false
      expect(type.isPrimitiveOrListOrMap(), isFalse);
      // With skip that skips the custom type: the remaining flat types
      // (just the List itself) are all list/map/primitive
      expect(
        type.isPrimitiveOrListOrMap(
          skip: (t) => t.name == 'CustomType',
        ),
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------------------
  // 15. listTypeArgument
  // -------------------------------------------------------------------------
  group('listTypeArgument', () {
    test('on list type returns first type argument', () {
      final intArg = rt('int', dartType: fakeInt());
      final type = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);
      expect(type.listTypeArgument, same(intArg));
    });

    test('on non-list type returns null', () {
      expect(rt('Foo').listTypeArgument, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // 16. flatTypes
  // -------------------------------------------------------------------------
  group('flatTypes', () {
    test('simple type returns itself', () {
      final type = rt('Foo');
      final flat = type.flatTypes();
      expect(flat.map((e) => e.name), ['Foo']);
    });

    test('nested generics flattens all types', () {
      final intArg = rt('int', dartType: fakeInt());
      final stringArg = rt('String', dartType: fakeString());
      final innerList = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);
      final outerMap = rt('Map',
          dartType: fakeMap('Map<String, List<int>>'),
          typeArguments: [stringArg, innerList]);

      final flat = outerMap.flatTypes();
      final names = flat.map((e) => e.name).toList();
      // outerMap, String (leaf), innerList, innerList (also added as parent in recursion), int (leaf)
      // Let's see: theFlatTypes(outerMap) -> [outerMap] then for String (leaf, empty args) -> add String, theFlatTypes(String) -> [String] -> add [String]
      // then for innerList (non-empty args) -> theFlatTypes(innerList) -> [innerList] then for int (leaf) -> add int, theFlatTypes(int) -> [int] -> result [innerList, int, int]
      // So total: [outerMap, String, String, innerList, int, int]
      // Wait, let me re-read the code more carefully...
      expect(names, contains('Map'));
      expect(names, contains('String'));
      expect(names, contains('List'));
      expect(names, contains('int'));
    });

    test('with skip function excludes matching types', () {
      final intArg = rt('int', dartType: fakeInt());
      final type = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);

      final flat = type.flatTypes(skip: (t) => t.name == 'int');
      final names = flat.map((e) => e.name).toList();
      expect(names, contains('List'));
      expect(names, isNot(contains('int')));
    });
  });

  // -------------------------------------------------------------------------
  // 17. distinctFlatTypes
  // -------------------------------------------------------------------------
  group('distinctFlatTypes', () {
    test('removes duplicates by display name', () {
      final intArg1 = rt('int', dartType: fakeInt());
      final intArg2 = rt('int', dartType: fakeInt());
      final type = rt('Pair',
          dartType: FakeDartType('Pair<int, int>'),
          typeArguments: [intArg1, intArg2]);

      final distinct = type.distinctFlatTypes();
      // There should be only one 'int' in the result
      final intCount =
          distinct.where((e) => e.name == 'int').length;
      expect(intCount, 1);
    });
  });

  // -------------------------------------------------------------------------
  // 18. hasDeepGenericOf
  // -------------------------------------------------------------------------
  group('hasDeepGenericOf', () {
    test('match at top level type argument', () {
      final intArg = rt('int', dartType: fakeInt());
      final type = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);

      expect(type.hasDeepGenericOf(fakeInt()), isTrue);
    });

    test('nested match', () {
      final intArg = rt('int', dartType: fakeInt());
      final innerList = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);
      final outerList = rt('List',
          dartType: fakeList('List<List<int>>'),
          typeArguments: [innerList]);

      expect(outerList.hasDeepGenericOf(fakeInt()), isTrue);
    });

    test('no match', () {
      final intArg = rt('int', dartType: fakeInt());
      final type = rt('List',
          dartType: fakeList('List<int>'), typeArguments: [intArg]);

      expect(type.hasDeepGenericOf(fakeString()), isFalse);
    });

    test('empty type arguments returns false', () {
      final type = rt('Foo');
      expect(type.hasDeepGenericOf(fakeInt()), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 19. refer, referAsNullable, baseRefer
  // -------------------------------------------------------------------------
  group('refer, referAsNullable, baseRefer', () {
    test('refer returns TypeReference with correct properties', () {
      final type = rt('Foo', import: 'pkg:a', isNullable: true,
          typeArguments: [rt('Bar')]);
      final ref = type.refer;

      expect(ref, isA<TypeReference>());
      expect(ref.symbol, 'Foo');
      expect(ref.url, 'pkg:a');
      expect(ref.isNullable, isTrue);
      expect(ref.types, hasLength(1));
    });

    test('refer with no type arguments has empty types', () {
      final type = rt('Foo');
      final ref = type.refer;
      expect(ref.types, isEmpty);
    });

    test('referAsNullable uses dartType displayString as symbol', () {
      final dt = FakeDartType('FooBar');
      final type = ResolvedType(
        name: 'Foo',
        dartType: dt,
        import: 'pkg:a',
        isNullable: true,
      );
      final ref = type.referAsNullable;
      // referAsNullable uses dartType.getDisplayStringWithoutNullability() as symbol
      expect(ref.symbol, 'FooBar');
      expect(ref.isNullable, isTrue);
    });

    test('referAsNullable strips ? from nullable display string', () {
      final dt = FakeDartType('Foo?');
      final type = ResolvedType(
        name: 'Foo',
        dartType: dt,
        import: 'pkg:a',
        isNullable: true,
      );
      final ref = type.referAsNullable;
      expect(ref.symbol, 'Foo');
    });

    test('baseRefer has no type arguments', () {
      final type = rt('Foo', import: 'pkg:a', isNullable: false,
          typeArguments: [rt('Bar')]);
      final ref = type.baseRefer;

      expect(ref.symbol, 'Foo');
      expect(ref.url, 'pkg:a');
      expect(ref.isNullable, isFalse);
      expect(ref.types, isEmpty);
    });
  });
}
