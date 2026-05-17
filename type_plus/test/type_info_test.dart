import 'package:test/test.dart';
import 'package:type_plus/type_plus.dart';
import 'package:type_plus/src/type_info.dart';
import 'package:type_plus/src/resolved_type.dart';

void main() {
  // ─── TypeInfo.fromType ─────────────────────────────────────────────────
  group('TypeInfo.fromType', () {
    test('simple type', () {
      final info = TypeInfo.fromType<int>();
      expect(info.type, 'int');
      expect(info.args, isEmpty);
      expect(info.isNullable, false);
    });

    test('nullable type', () {
      final info = TypeInfo.fromType<int?>();
      expect(info.type, 'int');
      expect(info.isNullable, true);
    });

    test('generic type with one arg', () {
      final info = TypeInfo.fromType<List<int>>();
      expect(info.type, 'List');
      expect(info.args, hasLength(1));
      expect(info.args[0].type, 'int');
    });

    test('generic type with two args', () {
      final info = TypeInfo.fromType<Map<String, int>>();
      expect(info.type, 'Map');
      expect(info.args, hasLength(2));
      expect(info.args[0].type, 'String');
      expect(info.args[1].type, 'int');
    });

    test('nested generic type', () {
      final info = TypeInfo.fromType<List<Map<String, int>>>();
      expect(info.type, 'List');
      expect(info.args, hasLength(1));
      expect(info.args[0].type, 'Map');
      expect(info.args[0].args, hasLength(2));
      expect(info.args[0].args[0].type, 'String');
      expect(info.args[0].args[1].type, 'int');
    });

    test('nullable generic type', () {
      final info = TypeInfo.fromType<List<int>?>();
      expect(info.type, 'List');
      expect(info.isNullable, true);
      expect(info.args, hasLength(1));
    });

    test('generic with nullable arg', () {
      final info = TypeInfo.fromType<List<int?>>();
      expect(info.type, 'List');
      expect(info.isNullable, false);
      expect(info.args[0].type, 'int');
      expect(info.args[0].isNullable, true);
    });

    test('dynamic type', () {
      final info = TypeInfo.fromType<dynamic>();
      expect(info.type, 'dynamic');
      expect(info.isNullable, false);
    });

    test('String type', () {
      final info = TypeInfo.fromType<String>();
      expect(info.type, 'String');
    });

    test('caching works - same Type returns same instance', () {
      final info1 = TypeInfo.fromType<int>();
      final info2 = TypeInfo.fromType<int>();
      expect(identical(info1, info2), true);
    });
  });

  // ─── TypeInfo.fromString ───────────────────────────────────────────────
  group('TypeInfo.fromString', () {
    test('simple type', () {
      final info = TypeInfo.fromString('int');
      expect(info.type, 'int');
      expect(info.args, isEmpty);
      expect(info.isNullable, false);
    });

    test('nullable type', () {
      final info = TypeInfo.fromString('int?');
      expect(info.type, 'int');
      expect(info.isNullable, true);
    });

    test('generic with one arg', () {
      final info = TypeInfo.fromString('List<int>');
      expect(info.type, 'List');
      expect(info.args, hasLength(1));
      expect(info.args[0].type, 'int');
    });

    test('generic with two args', () {
      final info = TypeInfo.fromString('Map<String, int>');
      expect(info.type, 'Map');
      expect(info.args, hasLength(2));
      expect(info.args[0].type, 'String');
      expect(info.args[1].type, 'int');
    });

    test('nested generic', () {
      final info = TypeInfo.fromString('Map<String, List<int>>');
      expect(info.type, 'Map');
      expect(info.args[1].type, 'List');
      expect(info.args[1].args[0].type, 'int');
    });

    test('nullable nested generic', () {
      final info = TypeInfo.fromString('Map<String?, List<int>?>?');
      expect(info.isNullable, true);
      expect(info.args[0].isNullable, true);
      expect(info.args[1].isNullable, true);
    });
  });

  // ─── TypeInfo.toString ─────────────────────────────────────────────────
  group('TypeInfo.toString', () {
    test('simple type', () {
      final info = TypeInfo.fromString('int');
      expect(info.toString(), 'int');
    });

    test('nullable type', () {
      final info = TypeInfo.fromString('String?');
      expect(info.toString(), 'String?');
    });

    test('generic type', () {
      final info = TypeInfo.fromString('List<int>');
      expect(info.toString(), 'List<int>');
    });

    test('two-arg generic type', () {
      final info = TypeInfo.fromString('Map<String, int>');
      expect(info.toString(), 'Map<String, int>');
    });

    test('nested generic', () {
      final info = TypeInfo.fromString('List<Map<String, int>>');
      expect(info.toString(), 'List<Map<String, int>>');
    });
  });

  // ─── TypePlus extension ────────────────────────────────────────────────
  group('TypePlus extension', () {
    test('info returns TypeInfo', () {
      final Type t = int;
      final info = t.info;
      expect(info, isA<TypeInfo>());
      expect(info.type, 'int');
    });

    test('resolveWith returns ResolvedType', () {
      final reg = TypeRegistry.newInstance();
      final Type t = int;
      final resolved = t.resolveWith(reg);
      expect(resolved, isA<ResolvedType>());
      expect(resolved.base, int);
    });
  });

  // ─── TypeRegistry ──────────────────────────────────────────────────────
  group('TypeRegistry', () {
    test('singleton instance has SDK types', () {
      final reg = TypeRegistry.instance;
      expect(reg.idOf(int), isNotNull);
      expect(reg.idOf(String), isNotNull);
      expect(reg.idOf(bool), isNotNull);
      expect(reg.idOf(double), isNotNull);
      expect(reg.idOf(num), isNotNull);
      expect(reg.idOf(List), isNotNull);
      expect(reg.idOf(Map), isNotNull);
    });

    test('newInstance has SDK types', () {
      final reg = TypeRegistry.newInstance();
      expect(reg.idOf(int), 'int');
      expect(reg.idOf(String), 'String');
    });

    test('newInstance with parent inherits types', () {
      final parent = TypeRegistry.newInstance();
      parent.add((f) => f<DateTime>(), id: 'DateTime');

      final child = TypeRegistry.newInstance(parent: parent);
      expect(child.idOf(DateTime), 'DateTime');
    });

    test('add registers new type', () {
      final reg = TypeRegistry.newInstance();
      reg.add((f) => f<DateTime>(), id: 'DateTime');
      expect(reg.idOf(DateTime), 'DateTime');
    });

    test('add with duplicate id for same type does not throw', () {
      final reg = TypeRegistry.newInstance();
      reg.add((f) => f<DateTime>(), id: 'DateTime');
      reg.add((f) => f<DateTime>(), id: 'DateTime');
      expect(reg.idOf(DateTime), 'DateTime');
    });

    test('add with duplicate id for different type throws', () {
      final reg = TypeRegistry.newInstance();
      reg.add((f) => f<DateTime>(), id: 'myId');
      expect(
        () => reg.add((f) => f<Duration>(), id: 'myId'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('getFactoriesByName returns factories', () {
      final reg = TypeRegistry.newInstance();
      final factories = reg.getFactoriesByName('int');
      expect(factories, isNotEmpty);
    });

    test('getFactoriesByName returns empty for unknown', () {
      final reg = TypeRegistry.newInstance();
      final factories = reg.getFactoriesByName('UnknownTypeName');
      expect(factories, isEmpty);
    });

    test('idOf returns null for unregistered type', () {
      final reg = TypeRegistry.newInstance();
      // DateTime is registered as SDK type, use a custom class instead
      expect(reg.idOf(_TestClass), isNull);
    });

    test('fromId resolves type by id string', () {
      final reg = TypeRegistry.newInstance();
      final type = reg.fromId('int');
      expect(type, int);
    });

    test('fromId resolves generic type', () {
      final reg = TypeRegistry.newInstance();
      final type = reg.fromId('List<int>');
      expect(type, List<int>);
    });

    test('fromId resolves nested generic', () {
      final reg = TypeRegistry.newInstance();
      final type = reg.fromId('Map<String,List<int>>');
      expect(type, Map<String, List<int>>);
    });

    test('fromId returns UnresolvedType for unknown id', () {
      final reg = TypeRegistry.newInstance();
      final type = reg.fromId('SomeUnknownType');
      expect(type, UnresolvedType);
    });

    test('getSuperFactories returns factories for known type', () {
      final reg = TypeRegistry.newInstance();
      final intId = reg.idOf(int);
      expect(intId, isNotNull);
      final supers = reg.getSuperFactories(intId!);
      expect(supers, isNotEmpty);
    });

    test('getSuperFactories returns empty for unknown id', () {
      final reg = TypeRegistry.newInstance();
      expect(reg.getSuperFactories('nonexistent'), isEmpty);
    });
  });

  // ─── ResolvedType ──────────────────────────────────────────────────────
  group('ResolvedType', () {
    late TypeRegistry reg;

    setUp(() {
      reg = TypeRegistry.newInstance();
    });

    test('from resolves simple type', () {
      final resolved = ResolvedType.from<int>(reg);
      expect(resolved.base, int);
      expect(resolved.args, isEmpty);
      expect(resolved.isNullable, false);
    });

    test('from resolves generic type', () {
      final resolved = ResolvedType.from<List<int>>(reg);
      expect(resolved.base, List);
      expect(resolved.args, hasLength(1));
    });

    test('reversed returns the original type', () {
      final resolved = ResolvedType.from<int>(reg);
      expect(resolved.reversed, int);
    });

    test('reversed for generic type', () {
      final resolved = ResolvedType.from<List<int>>(reg);
      expect(resolved.reversed, List<int>);
    });

    test('argsAsTypes returns type list', () {
      final resolved = ResolvedType.from<Map<String, int>>(reg);
      expect(resolved.argsAsTypes, [String, int]);
    });

    test('provideTo calls function with resolved type', () {
      final resolved = ResolvedType.from<int>(reg);
      final type = resolved.provideTo(<T>() => T);
      expect(type, int);
    });

    test('id for simple type', () {
      final resolved = ResolvedType.from<int>(reg);
      expect(resolved.id, 'int');
    });

    test('id for nullable type', () {
      final resolved = ResolvedType.from<int?>(reg);
      expect(resolved.id, 'int?');
    });

    test('implements checks same type', () {
      final resolved = ResolvedType.from<int>(reg);
      expect(resolved.implements(int), true);
    });

    test('implements dynamic is always true', () {
      final resolved = ResolvedType.from<int>(reg);
      expect(resolved.implements(dynamic), true);
    });

    test('implements checks supertype', () {
      final resolved = ResolvedType.from<int>(reg);
      expect(resolved.implements(num), true);
    });

    test('unresolved creates unresolved type', () {
      final info = TypeInfo.fromString('UnknownType');
      final resolved = ResolvedType.unresolved(reg, info);
      expect(resolved.base, UnresolvedType);
    });

    test('nonNull returns non-nullable version', () {
      final resolved = ResolvedType.from<int?>(reg);
      final nonNull = resolved.nonNull;
      expect(nonNull.isNullable, false);
    });

    test('nonNull on non-nullable returns same instance', () {
      final resolved = ResolvedType.from<int>(reg);
      expect(identical(resolved.nonNull, resolved), true);
    });
  });

  // ─── FunctionPlus extension ────────────────────────────────────────────
  group('FunctionPlus', () {
    test('callWith invokes function with type arguments', () {
      final reg = TypeRegistry.newInstance();
      T identity<T>(T value) => value;

      final result = identity.callWith(
        typeRegistry: reg,
        parameters: [42],
        typeArguments: [int],
      );
      expect(result, 42);
    });

    test('callWith invokes generic function', () {
      final reg = TypeRegistry.newInstance();
      List<T> makeList<T>(T value) => [value];

      final result = makeList.callWith(
        typeRegistry: reg,
        parameters: ['hello'],
        typeArguments: [String],
      );
      expect(result, ['hello']);
    });
  });

  // ─── TypeSwitcher (via FunctionPlus.callWith) ───────────────────────────
  group('TypeSwitcher', () {
    late TypeRegistry reg;

    setUp(() {
      reg = TypeRegistry.newInstance();
    });

    test('0 type args, 0 params', () {
      int noArgs() => 42;
      final result = noArgs.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [],
      );
      expect(result, 42);
    });

    test('0 type args, 1 param', () {
      int addOne(int x) => x + 1;
      final result = addOne.callWith(
        typeRegistry: reg,
        parameters: [5],
        typeArguments: [],
      );
      expect(result, 6);
    });

    test('0 type args, 2 params', () {
      int add(int a, int b) => a + b;
      final result = add.callWith(
        typeRegistry: reg,
        parameters: [3, 4],
        typeArguments: [],
      );
      expect(result, 7);
    });

    test('0 type args, 3 params', () {
      int sum3(int a, int b, int c) => a + b + c;
      final result = sum3.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3],
        typeArguments: [],
      );
      expect(result, 6);
    });

    test('1 type arg, 0 params', () {
      Type getType<T>() => T;
      final result = getType.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int],
      );
      expect(result, int);
    });

    test('1 type arg, 1 param', () {
      T identity<T>(T value) => value;
      final result = identity.callWith(
        typeRegistry: reg,
        parameters: [42],
        typeArguments: [int],
      );
      expect(result, 42);
    });

    test('1 type arg, 2 params', () {
      List<T> makePair<T>(T a, T b) => [a, b];
      final result = makePair.callWith(
        typeRegistry: reg,
        parameters: [1, 2],
        typeArguments: [int],
      );
      expect(result, [1, 2]);
    });

    test('2 type args, 0 params', () {
      List<Type> getTypes<A, B>() => [A, B];
      final result = getTypes.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int, String],
      );
      expect(result, [int, String]);
    });

    test('2 type args, 1 param', () {
      MapEntry<K, V> makeEntry<K, V>(V value) => MapEntry<K, V>('' as K, value);
      final result = makeEntry.callWith(
        typeRegistry: reg,
        parameters: [42],
        typeArguments: [String, int],
      );
      expect(result, isA<MapEntry<String, int>>());
      expect((result as MapEntry).value, 42);
    });

    test('3 type args, 0 params', () {
      List<Type> getTypes<A, B, C>() => [A, B, C];
      final result = getTypes.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int, String, bool],
      );
      expect(result, [int, String, bool]);
    });

    test('callWith no type args uses empty list', () {
      int getValue() => 10;
      final result = getValue.callWith(
        typeRegistry: reg,
        parameters: [],
      );
      expect(result, 10);
    });

    test('callWith no params uses empty list', () {
      Type getType<T>() => T;
      final result = getType.callWith(
        typeRegistry: reg,
        typeArguments: [String],
      );
      expect(result, String);
    });

    // ── 0 type args with 3-5 params ──────────────────────────────────────

    test('0 type args, 4 params', () {
      int sum4(int a, int b, int c, int d) => a + b + c + d;
      final result = sum4.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4],
        typeArguments: [],
      );
      expect(result, 10);
    });

    test('0 type args, 5 params', () {
      int sum5(int a, int b, int c, int d, int e) => a + b + c + d + e;
      final result = sum5.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4, 5],
        typeArguments: [],
      );
      expect(result, 15);
    });

    // ── 1 type arg with 2-4 params ───────────────────────────────────────

    test('1 type arg, 3 params', () {
      List<T> makeTriple<T>(T a, T b, T c) => [a, b, c];
      final result = makeTriple.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3],
        typeArguments: [int],
      );
      expect(result, [1, 2, 3]);
    });

    test('1 type arg, 4 params', () {
      List<T> makeQuad<T>(T a, T b, T c, T d) => [a, b, c, d];
      final result = makeQuad.callWith(
        typeRegistry: reg,
        parameters: [10, 20, 30, 40],
        typeArguments: [int],
      );
      expect(result, [10, 20, 30, 40]);
    });

    // ── 2 type args with 2-3 params ──────────────────────────────────────

    test('2 type args, 2 params', () {
      MapEntry<A, B> makeEntry<A, B>(A a, B b) => MapEntry(a, b);
      final result = makeEntry.callWith(
        typeRegistry: reg,
        parameters: ['key', 42],
        typeArguments: [String, int],
      );
      expect(result, isA<MapEntry<String, int>>());
      expect((result as MapEntry).key, 'key');
      expect(result.value, 42);
    });

    test('2 type args, 3 params', () {
      List<dynamic> combine<A, B>(A a, B b, A c) => [a, b, c];
      final result = combine.callWith(
        typeRegistry: reg,
        parameters: ['x', 1, 'y'],
        typeArguments: [String, int],
      );
      expect(result, ['x', 1, 'y']);
    });

    // ── 3 type args with params ──────────────────────────────────────────

    test('3 type args, 1 param', () {
      List<dynamic> fn3<A, B, C>(A a) => [A, B, C, a];
      final result = fn3.callWith(
        typeRegistry: reg,
        parameters: [42],
        typeArguments: [int, String, bool],
      );
      expect(result, [int, String, bool, 42]);
    });

    test('3 type args, 2 params', () {
      List<dynamic> fn3<A, B, C>(A a, B b) => [A, B, C, a, b];
      final result = fn3.callWith(
        typeRegistry: reg,
        parameters: [42, 'hello'],
        typeArguments: [int, String, bool],
      );
      expect(result, [int, String, bool, 42, 'hello']);
    });

    test('3 type args, 3 params', () {
      List<dynamic> fn3<A, B, C>(A a, B b, C c) => [a, b, c];
      final result = fn3.callWith(
        typeRegistry: reg,
        parameters: [1, 'two', true],
        typeArguments: [int, String, bool],
      );
      expect(result, [1, 'two', true]);
    });

    // ── 4 type args ──────────────────────────────────────────────────────

    test('4 type args, 0 params', () {
      List<Type> getTypes<A, B, C, D>() => [A, B, C, D];
      final result = getTypes.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int, String, bool, double],
      );
      expect(result, [int, String, bool, double]);
    });

    test('4 type args, 1 param', () {
      List<dynamic> fn4<A, B, C, D>(A a) => [A, B, C, D, a];
      final result = fn4.callWith(
        typeRegistry: reg,
        parameters: [99],
        typeArguments: [int, String, bool, double],
      );
      expect(result, [int, String, bool, double, 99]);
    });

    test('4 type args, 2 params', () {
      List<dynamic> fn4<A, B, C, D>(A a, B b) => [A, B, C, D, a, b];
      final result = fn4.callWith(
        typeRegistry: reg,
        parameters: [1, 'hello'],
        typeArguments: [int, String, bool, double],
      );
      expect(result, [int, String, bool, double, 1, 'hello']);
    });

    // ── 5 type args ──────────────────────────────────────────────────────

    test('5 type args, 0 params', () {
      List<Type> getTypes<A, B, C, D, E>() => [A, B, C, D, E];
      final result = getTypes.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int, String, bool, double, num],
      );
      expect(result, [int, String, bool, double, num]);
    });

    test('5 type args, 1 param', () {
      List<dynamic> fn5<A, B, C, D, E>(A a) => [A, B, C, D, E, a];
      final result = fn5.callWith(
        typeRegistry: reg,
        parameters: [42],
        typeArguments: [int, String, bool, double, num],
      );
      expect(result, [int, String, bool, double, num, 42]);
    });

    // ── 6 type args ──────────────────────────────────────────────────────

    test('6 type args, 0 params', () {
      List<Type> getTypes<A, B, C, D, E, F>() => [A, B, C, D, E, F];
      final result = getTypes.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int, String, bool, double, num, List],
      );
      expect(result, [int, String, bool, double, num, List]);
    });

    // ── 7 type args ──────────────────────────────────────────────────────

    test('7 type args, 0 params', () {
      List<Type> getTypes<A, B, C, D, E, F, G>() => [A, B, C, D, E, F, G];
      final result = getTypes.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int, String, bool, double, num, List, Map],
      );
      expect(result, [int, String, bool, double, num, List, Map]);
    });

    // ── 8 type args ──────────────────────────────────────────────────────

    test('8 type args, 0 params', () {
      List<Type> getTypes<A, B, C, D, E, F, G, H>() =>
          [A, B, C, D, E, F, G, H];
      final result = getTypes.callWith(
        typeRegistry: reg,
        parameters: [],
        typeArguments: [int, String, bool, double, num, List, Map, Set],
      );
      expect(result, [int, String, bool, double, num, List, Map, Set]);
    });

    // ── 9 type args ──────────────────────────────────────────────────────

    test('9 type args, 0 params', () {
      List<Type> getTypes<A, B, C, D, E, F, G, H, I>() =>
          [A, B, C, D, E, F, G, H, I];
      final reg2 = TypeRegistry.newInstance();
      reg2.add((f) => f<Iterable>(), id: 'Iterable');
      final result = getTypes.callWith(
        typeRegistry: reg2,
        parameters: [],
        typeArguments: [
          int, String, bool, double, num, List, Map, Set, Iterable
        ],
      );
      expect(result,
          [int, String, bool, double, num, List, Map, Set, Iterable]);
    });

    // ── 10 type args ─────────────────────────────────────────────────────

    test('10 type args, 0 params', () {
      List<Type> getTypes<A, B, C, D, E, F, G, H, I, J>() =>
          [A, B, C, D, E, F, G, H, I, J];
      final reg2 = TypeRegistry.newInstance();
      reg2.add((f) => f<Iterable>(), id: 'Iterable');
      reg2.add((f) => f<Duration>(), id: 'Duration');
      final result = getTypes.callWith(
        typeRegistry: reg2,
        parameters: [],
        typeArguments: [
          int, String, bool, double, num, List, Map, Set, Iterable, Duration
        ],
      );
      expect(result, [
        int, String, bool, double, num, List, Map, Set, Iterable, Duration
      ]);
    });

    // ── Higher param counts with type args ────────────────────────────────

    test('0 type args, 6 params', () {
      int sum6(int a, int b, int c, int d, int e, int f) =>
          a + b + c + d + e + f;
      final result = sum6.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4, 5, 6],
        typeArguments: [],
      );
      expect(result, 21);
    });

    test('0 type args, 7 params', () {
      int sum7(int a, int b, int c, int d, int e, int f, int g) =>
          a + b + c + d + e + f + g;
      final result = sum7.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4, 5, 6, 7],
        typeArguments: [],
      );
      expect(result, 28);
    });

    test('0 type args, 8 params', () {
      int sum8(int a, int b, int c, int d, int e, int f, int g, int h) =>
          a + b + c + d + e + f + g + h;
      final result = sum8.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4, 5, 6, 7, 8],
        typeArguments: [],
      );
      expect(result, 36);
    });

    test('0 type args, 9 params', () {
      int sum9(
              int a, int b, int c, int d, int e, int f, int g, int h, int i) =>
          a + b + c + d + e + f + g + h + i;
      final result = sum9.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4, 5, 6, 7, 8, 9],
        typeArguments: [],
      );
      expect(result, 45);
    });

    test('0 type args, 10 params', () {
      int sum10(int a, int b, int c, int d, int e, int f, int g, int h, int i,
              int j) =>
          a + b + c + d + e + f + g + h + i + j;
      final result = sum10.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        typeArguments: [],
      );
      expect(result, 55);
    });

    // ── Cross-product: type args with higher param counts ─────────────────

    test('1 type arg, 5 params', () {
      List<T> make5<T>(T a, T b, T c, T d, T e) => [a, b, c, d, e];
      final result = make5.callWith(
        typeRegistry: reg,
        parameters: [1, 2, 3, 4, 5],
        typeArguments: [int],
      );
      expect(result, [1, 2, 3, 4, 5]);
    });

    test('2 type args, 4 params', () {
      List<dynamic> fn<A, B>(A a1, A a2, B b1, B b2) => [a1, a2, b1, b2];
      final result = fn.callWith(
        typeRegistry: reg,
        parameters: ['x', 'y', 1, 2],
        typeArguments: [String, int],
      );
      expect(result, ['x', 'y', 1, 2]);
    });

    test('2 type args, 5 params', () {
      List<dynamic> fn<A, B>(A a1, A a2, B b1, B b2, A a3) =>
          [a1, a2, b1, b2, a3];
      final result = fn.callWith(
        typeRegistry: reg,
        parameters: ['a', 'b', 1, 2, 'c'],
        typeArguments: [String, int],
      );
      expect(result, ['a', 'b', 1, 2, 'c']);
    });

    test('3 type args, 4 params', () {
      List<dynamic> fn<A, B, C>(A a, B b, C c, A d) => [a, b, c, d];
      final result = fn.callWith(
        typeRegistry: reg,
        parameters: [1, 'two', true, 4],
        typeArguments: [int, String, bool],
      );
      expect(result, [1, 'two', true, 4]);
    });

    test('3 type args, 5 params', () {
      List<dynamic> fn<A, B, C>(A a, B b, C c, A d, B e) => [a, b, c, d, e];
      final result = fn.callWith(
        typeRegistry: reg,
        parameters: [1, 'two', true, 4, 'five'],
        typeArguments: [int, String, bool],
      );
      expect(result, [1, 'two', true, 4, 'five']);
    });

    test('4 type args, 4 params', () {
      List<dynamic> fn<A, B, C, D>(A a, B b, C c, D d) => [a, b, c, d];
      final result = fn.callWith(
        typeRegistry: reg,
        parameters: [1, 'two', true, 3.14],
        typeArguments: [int, String, bool, double],
      );
      expect(result, [1, 'two', true, 3.14]);
    });

    test('5 type args, 2 params', () {
      List<dynamic> fn<A, B, C, D, E>(A a, B b) => [A, B, C, D, E, a, b];
      final result = fn.callWith(
        typeRegistry: reg,
        parameters: [42, 'hello'],
        typeArguments: [int, String, bool, double, num],
      );
      expect(result, [int, String, bool, double, num, 42, 'hello']);
    });

    // ── Assertion error paths (debug mode only) ──────────────────────────

    test('wrong number of type args throws in debug mode', () {
      Type getType<T>() => T;
      expect(
        () => getType.callWith(
          typeRegistry: reg,
          parameters: [],
          typeArguments: [int, String],
        ),
        throwsA(isA<Error>()),
      );
    });

    test('too many params throws in debug mode', () {
      int addOne(int x) => x + 1;
      expect(
        () => addOne.callWith(
          typeRegistry: reg,
          parameters: [1, 2],
          typeArguments: [],
        ),
        throwsA(isA<Error>()),
      );
    });

    test('too few params throws in debug mode', () {
      int add(int a, int b) => a + b;
      expect(
        () => add.callWith(
          typeRegistry: reg,
          parameters: [1],
          typeArguments: [],
        ),
        throwsA(isA<Error>()),
      );
    });
  });

  // ─── typeOf utility ────────────────────────────────────────────────────
  group('typeOf', () {
    test('returns Type for generic parameter', () {
      expect(typeOf<int>(), int);
      expect(typeOf<String>(), String);
      expect(typeOf<List<int>>(), List<int>);
    });

    test('nullable types', () {
      expect(typeOf<int?>(), isNot(equals(int)));
    });
  });

  // ─── UnresolvedType ────────────────────────────────────────────────────
  group('UnresolvedType', () {
    test('factory with 0 args', () {
      final f = UnresolvedType.factory(0);
      expect(f(typeOf), UnresolvedType);
    });

    test('factory with 1 arg', () {
      final f = UnresolvedType.factory(1);
      expect(f(typeOf), UnresolvedType);
    });

    test('factory throws for >10 args', () {
      expect(
        () => UnresolvedType.factory(11),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ─── FunctionInfo ─────────────────────────────────────────────────────
  group('FunctionInfo', () {
    test('parse simple function with one param', () {
      final info = TypeInfo.fromString('(int) => String');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, hasLength(1));
      expect(fn.params[0].type, 'int');
      expect(fn.returns.type, 'String');
      expect(fn.optionalParams, isEmpty);
      expect(fn.namedParams, isEmpty);
      expect(fn.args, isEmpty);
      expect(fn.isNullable, false);
    });

    test('parse function with two params', () {
      final info = TypeInfo.fromString('(int, String) => bool');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, hasLength(2));
      expect(fn.params[0].type, 'int');
      expect(fn.params[1].type, 'String');
      expect(fn.returns.type, 'bool');
    });

    test('parse function with no params', () {
      final info = TypeInfo.fromString('() => void');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, isEmpty);
      expect(fn.returns.type, 'void');
    });

    test('parse generic function', () {
      final info = TypeInfo.fromString('<T>(T) => List<T>');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.args, hasLength(1));
      expect(fn.args[0].type, 'T');
      expect(fn.params, hasLength(1));
      expect(fn.params[0].type, 'T');
      expect(fn.returns.type, 'List');
      expect(fn.returns.args, hasLength(1));
      expect(fn.returns.args[0].type, 'T');
    });

    test('parse function with optional positional params', () {
      final info = TypeInfo.fromString('(int, [String]) => void');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, hasLength(1));
      expect(fn.params[0].type, 'int');
      expect(fn.optionalParams, hasLength(1));
      expect(fn.optionalParams[0].type, 'String');
      expect(fn.returns.type, 'void');
    });

    test('parse function with named params', () {
      final info = TypeInfo.fromString('(int, {String name}) => void');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, hasLength(1));
      expect(fn.params[0].type, 'int');
      expect(fn.namedParams, hasLength(1));
      expect(fn.namedParams['name']?.type, 'String');
      expect(fn.returns.type, 'void');
    });

    test('parse nullable function wraps as record containing function', () {
      // When parsing '((int) => String)?', the outer parens create a
      // record wrapper. The inner '(int) => String' is parsed as a
      // FunctionInfo that becomes the single param of the outer record.
      final info = TypeInfo.fromString('((int) => String)?');
      expect(info, isA<RecordInfo>());
      final rec = info as RecordInfo;
      expect(rec.isNullable, true);
      expect(rec.params, hasLength(1));
      expect(rec.params[0], isA<FunctionInfo>());
      final fn = rec.params[0] as FunctionInfo;
      expect(fn.params, hasLength(1));
      expect(fn.params[0].type, 'int');
      expect(fn.returns.type, 'String');
    });

    test('toString round-trips for simple function', () {
      final input = '(int) => String';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for two-param function', () {
      final input = '(int, String) => bool';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for no-param function', () {
      final input = '() => void';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for generic function', () {
      final input = '<T>(T) => List<T>';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for function with optional params', () {
      final input = '(int, [String]) => void';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for function with named params', () {
      final input = '(int, {String name}) => void';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString for nullable function wrapping', () {
      // The parser wraps '((int) => String)?' as a nullable record
      // containing a FunctionInfo, so toString produces the record form.
      final info = TypeInfo.fromString('((int) => String)?');
      expect(info, isA<RecordInfo>());
      expect(info.toString(), '((int) => String)?');
    });

    test('FunctionInfo.toString with isNullable set wraps in parens', () {
      // Directly construct a nullable FunctionInfo to cover the
      // isNullable branch of FunctionInfo.toString().
      final fn = FunctionInfo()
        ..returns = (TypeInfo()..type = 'String')
        ..params = [TypeInfo()..type = 'int']
        ..isNullable = true;
      expect(fn.toString(), '((int) => String)?');
    });

    test('FunctionInfo.toString with optionalParams', () {
      final fn = FunctionInfo()
        ..returns = (TypeInfo()..type = 'void')
        ..params = [TypeInfo()..type = 'int']
        ..optionalParams = [TypeInfo()..type = 'String'];
      expect(fn.toString(), '(int, [String]) => void');
    });

    test('FunctionInfo.toString with namedParams', () {
      final fn = FunctionInfo()
        ..returns = (TypeInfo()..type = 'void')
        ..params = [TypeInfo()..type = 'int']
        ..namedParams = {'name': TypeInfo()..type = 'String'};
      expect(fn.toString(), '(int, {String name}) => void');
    });

    test('parse function with generic return type', () {
      final info = TypeInfo.fromString('(String) => Map<String, int>');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, hasLength(1));
      expect(fn.params[0].type, 'String');
      expect(fn.returns.type, 'Map');
      expect(fn.returns.args, hasLength(2));
      expect(fn.returns.args[0].type, 'String');
      expect(fn.returns.args[1].type, 'int');
    });

    test('parse function with multiple named params', () {
      final info = TypeInfo.fromString('({int age, String name}) => void');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, isEmpty);
      expect(fn.namedParams, hasLength(2));
      expect(fn.namedParams['age']?.type, 'int');
      expect(fn.namedParams['name']?.type, 'String');
    });

    test('parse function with multiple optional params', () {
      final info = TypeInfo.fromString('([int, String]) => void');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.params, isEmpty);
      expect(fn.optionalParams, hasLength(2));
      expect(fn.optionalParams[0].type, 'int');
      expect(fn.optionalParams[1].type, 'String');
    });

    test('parse function with multiple type params', () {
      final info = TypeInfo.fromString('<A, B>(A) => B');
      expect(info, isA<FunctionInfo>());
      final fn = info as FunctionInfo;
      expect(fn.args, hasLength(2));
      expect(fn.args[0].type, 'A');
      expect(fn.args[1].type, 'B');
      expect(fn.params, hasLength(1));
      expect(fn.params[0].type, 'A');
      expect(fn.returns.type, 'B');
    });
  });

  // ─── RecordInfo ───────────────────────────────────────────────────────
  group('RecordInfo', () {
    test('parse positional record', () {
      final info = TypeInfo.fromString('(int, String)');
      expect(info, isA<RecordInfo>());
      final rec = info as RecordInfo;
      expect(rec.params, hasLength(2));
      expect(rec.params[0].type, 'int');
      expect(rec.params[1].type, 'String');
      expect(rec.namedParams, isEmpty);
      expect(rec.isNullable, false);
    });

    test('parse record with named fields', () {
      final info = TypeInfo.fromString('(int, {String name})');
      expect(info, isA<RecordInfo>());
      final rec = info as RecordInfo;
      expect(rec.params, hasLength(1));
      expect(rec.params[0].type, 'int');
      expect(rec.namedParams, hasLength(1));
      expect(rec.namedParams['name']?.type, 'String');
    });

    test('parse record with only named fields', () {
      final info = TypeInfo.fromString('({int age, String name})');
      expect(info, isA<RecordInfo>());
      final rec = info as RecordInfo;
      expect(rec.params, isEmpty);
      expect(rec.namedParams, hasLength(2));
      expect(rec.namedParams['age']?.type, 'int');
      expect(rec.namedParams['name']?.type, 'String');
    });

    test('parse nullable record', () {
      final info = TypeInfo.fromString('(int, String)?');
      expect(info, isA<RecordInfo>());
      final rec = info as RecordInfo;
      expect(rec.isNullable, true);
      expect(rec.params, hasLength(2));
    });

    test('toString round-trips for positional record', () {
      final input = '(int, String)';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for record with named fields', () {
      final input = '(int, {String name})';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for nullable record', () {
      final input = '(int, String)?';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('toString round-trips for record with only named fields', () {
      final input = '({int age, String name})';
      final info = TypeInfo.fromString(input);
      expect(info.toString(), input);
    });

    test('type getter produces correct record type string', () {
      final info = TypeInfo.fromString('(int, String)');
      final rec = info as RecordInfo;
      // The type getter uses indexed positional fields like $0, $1
      expect(rec.type, contains('\$0'));
      expect(rec.type, contains('\$1'));
    });

    test('type getter includes named fields', () {
      final info = TypeInfo.fromString('(int, {String name})');
      final rec = info as RecordInfo;
      expect(rec.type, contains('\$0'));
      expect(rec.type, contains('name'));
    });

    test('args getter returns positional and named params', () {
      final info = TypeInfo.fromString('(int, {String name})');
      final rec = info as RecordInfo;
      expect(rec.args, hasLength(2));
      expect(rec.args[0].type, 'int');
      expect(rec.args[1].type, 'String');
    });

    test('args getter for positional-only record', () {
      final info = TypeInfo.fromString('(int, String, bool)');
      final rec = info as RecordInfo;
      expect(rec.args, hasLength(3));
      expect(rec.args[0].type, 'int');
      expect(rec.args[1].type, 'String');
      expect(rec.args[2].type, 'bool');
    });

    test('parse record with generic field types', () {
      final info = TypeInfo.fromString('(List<int>, Map<String, bool>)');
      expect(info, isA<RecordInfo>());
      final rec = info as RecordInfo;
      expect(rec.params, hasLength(2));
      expect(rec.params[0].type, 'List');
      expect(rec.params[0].args[0].type, 'int');
      expect(rec.params[1].type, 'Map');
      expect(rec.params[1].args, hasLength(2));
    });
  });

  // ─── TokenIterator edge cases ─────────────────────────────────────────
  group('TokenIterator', () {
    test('empty string produces null current after moveNext', () {
      final it = TokenIterator('');
      final hasNext = it.moveNext();
      expect(hasNext, false);
      expect(it.current, isNull);
    });

    test('whitespace-only string produces null current', () {
      final it = TokenIterator('   ');
      final hasNext = it.moveNext();
      expect(hasNext, false);
      expect(it.current, isNull);
    });

    test('recognizes => as a single token', () {
      final it = TokenIterator('=>');
      it.moveNext();
      expect(it.current, '=>');
    });

    test('tokenizes simple type name', () {
      final it = TokenIterator('int');
      it.moveNext();
      expect(it.current, 'int');
      final hasNext = it.moveNext();
      expect(hasNext, false);
      expect(it.current, isNull);
    });

    test('tokenizes type with angle brackets', () {
      final it = TokenIterator('List<int>');
      it.moveNext();
      expect(it.current, 'List');
      it.moveNext();
      expect(it.current, '<');
      it.moveNext();
      expect(it.current, 'int');
      it.moveNext();
      expect(it.current, '>');
      final hasNext = it.moveNext();
      expect(hasNext, false);
    });

    test('tokenizes function signature', () {
      final tokens = <String>[];
      final it = TokenIterator('(int) => String');
      while (it.moveNext()) {
        tokens.add(it.current!);
      }
      expect(tokens, ['(', 'int', ')', '=>', 'String']);
    });

    test('handles extra whitespace', () {
      final tokens = <String>[];
      final it = TokenIterator('  Map < String , int >  ');
      while (it.moveNext()) {
        tokens.add(it.current!);
      }
      expect(tokens, ['Map', '<', 'String', ',', 'int', '>']);
    });

    test('tokenizes nullable type', () {
      final tokens = <String>[];
      final it = TokenIterator('int?');
      while (it.moveNext()) {
        tokens.add(it.current!);
      }
      expect(tokens, ['int', '?']);
    });

    test('tokenizes record-like structure', () {
      final tokens = <String>[];
      final it = TokenIterator('(int, {String name})');
      while (it.moveNext()) {
        tokens.add(it.current!);
      }
      expect(tokens, ['(', 'int', ',', '{', 'String', 'name', '}', ')']);
    });

    test('tokenizes optional params syntax', () {
      final tokens = <String>[];
      final it = TokenIterator('(int, [String])');
      while (it.moveNext()) {
        tokens.add(it.current!);
      }
      expect(tokens, ['(', 'int', ',', '[', 'String', ']', ')']);
    });

    test('tokenizes extends keyword', () {
      final tokens = <String>[];
      final it = TokenIterator('T extends Comparable');
      while (it.moveNext()) {
        tokens.add(it.current!);
      }
      expect(tokens, ['T', 'extends', 'Comparable']);
    });
  });

  // ─── TypeInfo with bound (extends) ────────────────────────────────────
  group('TypeInfo with bound', () {
    test('parse type with simple bound', () {
      final info = TypeInfo.fromString('T extends Comparable');
      expect(info.type, 'T');
      expect(info.bound, isNotNull);
      expect(info.bound!.type, 'Comparable');
    });

    test('parse type with generic bound', () {
      final info = TypeInfo.fromString('T extends Comparable<T>');
      expect(info.type, 'T');
      expect(info.bound, isNotNull);
      expect(info.bound!.type, 'Comparable');
      expect(info.bound!.args, hasLength(1));
      expect(info.bound!.args[0].type, 'T');
    });

    test('toString includes extends clause', () {
      final info = TypeInfo.fromString('T extends Comparable');
      expect(info.toString(), 'T extends Comparable');
    });

    test('toString with generic bound', () {
      final info = TypeInfo.fromString('T extends Comparable<T>');
      expect(info.toString(), 'T extends Comparable<T>');
    });

    test('bound is null for regular types', () {
      final info = TypeInfo.fromString('int');
      expect(info.bound, isNull);
    });

    test('parse type with nested generic bound', () {
      final info = TypeInfo.fromString('T extends Map<String, int>');
      expect(info.type, 'T');
      expect(info.bound, isNotNull);
      expect(info.bound!.type, 'Map');
      expect(info.bound!.args, hasLength(2));
      expect(info.bound!.args[0].type, 'String');
      expect(info.bound!.args[1].type, 'int');
    });
  });
}

class _TestClass {}
