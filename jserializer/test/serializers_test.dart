import 'dart:math' as math;

import 'package:jserializer/jserializer.dart';
import 'package:test/test.dart';

void main() {
  late JSerializerInterface js;

  setUp(() {
    js = JSerializer.newInstance(forceFresh: true);
  });

  // ─── PrimitiveSerializer ───────────────────────────────────────────────
  group('PrimitiveSerializer', () {
    test('void serializer exists', () {
      final s = PrimitiveSerializer<void>(jSerializer: js);
      expect(s.modelType, isNotNull);
    });

    test('dynamic serializer passes through', () {
      final s = PrimitiveSerializer<dynamic>(jSerializer: js);
      expect(s.toJson('hello'), 'hello');
      expect(s.toJson(42), 42);
      expect(s.toJson(null), isNull);
    });

    test('modelType returns correct type', () {
      final s = PrimitiveSerializer<int>(jSerializer: js);
      expect(s.modelType, int);
    });

    test('jsonType returns correct type', () {
      final s = PrimitiveSerializer<int>(jSerializer: js);
      expect(s.jsonType, int);
    });
  });

  // ─── IntSerializer ─────────────────────────────────────────────────────
  group('IntSerializer', () {
    late IntSerializer s;

    setUp(() {
      s = IntSerializer(jSerializer: js);
    });

    test('fromJson int passthrough', () {
      expect(s.fromJson(42), 42);
    });

    test('fromJson double rounds', () {
      expect(s.fromJson(3.7), 4);
      expect(s.fromJson(3.2), 3);
    });

    test('fromJson string parses', () {
      expect(s.fromJson('123'), 123);
    });

    test('fromJson string with decimal parses', () {
      expect(s.fromJson('9.8'), 10);
    });

    test('fromJson bool converts', () {
      expect(s.fromJson(true), 1);
      expect(s.fromJson(false), 0);
    });

    test('toJson returns int', () {
      expect(s.toJson(42), 42);
    });

    test('modelType is int', () {
      expect(s.modelType, int);
    });
  });

  // ─── DoubleSerializer ──────────────────────────────────────────────────
  group('DoubleSerializer', () {
    late DoubleSerializer s;

    setUp(() {
      s = DoubleSerializer(jSerializer: js);
    });

    test('fromJson double passthrough', () {
      expect(s.fromJson(3.14), 3.14);
    });

    test('fromJson int converts to double', () {
      final result = s.fromJson(5);
      expect(result, 5.0);
      expect(result, isA<double>());
    });

    test('fromJson string parses', () {
      expect(s.fromJson('2.5'), 2.5);
    });

    test('fromJson bool converts', () {
      expect(s.fromJson(true), 1);
      expect(s.fromJson(false), 0);
    });

    test('toJson returns double', () {
      expect(s.toJson(3.14), 3.14);
    });
  });

  // ─── StringSerializer ──────────────────────────────────────────────────
  group('StringSerializer', () {
    late StringSerializer s;

    setUp(() {
      s = StringSerializer(jSerializer: js);
    });

    test('fromJson string passthrough', () {
      expect(s.fromJson('hello'), 'hello');
    });

    test('fromJson num converts to string', () {
      expect(s.fromJson(42), '42');
      expect(s.fromJson(3.14), '3.14');
    });

    test('fromJson bool converts to string', () {
      expect(s.fromJson(true), 'true');
      expect(s.fromJson(false), 'false');
    });

    test('toJson returns string', () {
      expect(s.toJson('abc'), 'abc');
    });
  });

  // ─── BoolSerializer ────────────────────────────────────────────────────
  group('BoolSerializer', () {
    late BoolSerializer s;

    setUp(() {
      s = BoolSerializer(jSerializer: js);
    });

    test('fromJson bool passthrough', () {
      expect(s.fromJson(true), true);
      expect(s.fromJson(false), false);
    });

    test('fromJson num converts (0 = false)', () {
      expect(s.fromJson(0), false);
      expect(s.fromJson(1), true);
      expect(s.fromJson(-1), true);
    });

    test('fromJson string converts', () {
      expect(s.fromJson('false'), false);
      expect(s.fromJson('0'), false);
      expect(s.fromJson('true'), true);
      expect(s.fromJson('anything'), true);
    });

    test('toJson returns bool', () {
      expect(s.toJson(true), true);
      expect(s.toJson(false), false);
    });
  });

  // ─── NumSerializer ─────────────────────────────────────────────────────
  group('NumSerializer', () {
    late NumSerializer s;

    setUp(() {
      s = NumSerializer(jSerializer: js);
    });

    test('fromJson num passthrough', () {
      expect(s.fromJson(42), 42);
      expect(s.fromJson(3.14), 3.14);
    });

    test('fromJson bool converts', () {
      expect(s.fromJson(true), 1);
      expect(s.fromJson(false), 0);
    });

    test('fromJson string parses', () {
      expect(s.fromJson('55'), 55);
      expect(s.fromJson('3.14'), 3.14);
    });

    test('toJson returns num', () {
      expect(s.toJson(42), 42);
    });
  });

  // ─── ListSerializer ────────────────────────────────────────────────────
  group('ListSerializer', () {
    late ListSerializer s;

    setUp(() {
      s = ListSerializer(jSerializer: js);
    });

    test('toJson with primitive list returns as-is', () {
      expect(s.toJson([1, 2, 3]), [1, 2, 3]);
      expect(s.toJson(['a', 'b']), ['a', 'b']);
      expect(s.toJson([true, false]), [true, false]);
    });

    test('toJson with mixed list calls toJson on each', () {
      final result = s.toJson([1, 'two', true]);
      expect(result, [1, 'two', true]);
    });

    test('toJson with empty list', () {
      expect(s.toJson([]), []);
    });

    test('toJson with nested lists', () {
      final result = s.toJson([
        [1, 2],
        [3, 4]
      ]);
      expect(result, [
        [1, 2],
        [3, 4]
      ]);
    });
  });

  // ─── MapSerializer ─────────────────────────────────────────────────────
  group('MapSerializer', () {
    late MapSerializer s;

    setUp(() {
      s = MapSerializer(jSerializer: js);
    });

    test('toJson with string-string map returns as-is', () {
      expect(s.toJson({'a': 'b'}), {'a': 'b'});
    });

    test('toJson with string-num map returns as-is', () {
      expect(s.toJson({'a': 1}), {'a': 1});
    });

    test('toJson with string-bool map returns as-is', () {
      expect(s.toJson({'a': true}), {'a': true});
    });

    test('toJson with mixed value map serializes values', () {
      final input = <String, dynamic>{'a': 1, 'b': 'two', 'c': true};
      final result = s.toJson(input);
      expect(result, {'a': 1, 'b': 'two', 'c': true});
    });

    test('toJson with empty map', () {
      expect(s.toJson({}), {});
    });

    test('toJson with nested maps', () {
      final input = {
        'outer': {'inner': 1}
      };
      final result = s.toJson(input);
      expect(result, {
        'outer': {'inner': 1}
      });
    });
  });

  // ─── Serializer base class ─────────────────────────────────────────────
  group('Serializer base', () {
    test('jSerializer falls back to JSerializer.i', () {
      final s = IntSerializer();
      expect(s.jSerializer, same(JSerializer.i));
    });

    test('jSerializer uses provided instance', () {
      final s = IntSerializer(jSerializer: js);
      expect(s.jSerializer, same(js));
    });

    test('modelTypeName strips generics', () {
      final s = ListSerializer(jSerializer: js);
      expect(s.modelTypeName, 'List');
    });

    test('safeLookup wraps errors in FromJsonException', () {
      final s = IntSerializer(jSerializer: js);
      expect(
        () => s.safeLookup<int>(
          call: () => throw FormatException('bad'),
          jsonKey: 'count',
          fieldName: 'count',
        ),
        throwsA(isA<FromJsonException<int>>()),
      );
    });

    test('safeLookup preserves nested FromJsonException', () {
      final s = IntSerializer(jSerializer: js);
      final inner = FromJsonException<String>(
        modelType: String,
        fieldName: 'name',
        message: 'inner',
      );
      expect(
        () => s.safeLookup<int>(
          call: () => throw inner,
          jsonKey: 'val',
          fieldName: 'value',
        ),
        throwsA(
          isA<FromJsonException<int>>().having(
            (e) => e.child,
            'child',
            isNotNull,
          ),
        ),
      );
    });

    test('mapLookup reads value from json map', () {
      final s = IntSerializer(jSerializer: js);
      final result = s.mapLookup<int>(
        json: {'count': 42},
        jsonName: 'count',
      );
      expect(result, 42);
    });

    test('mapLookup returns null for missing key', () {
      final s = IntSerializer(jSerializer: js);
      final result = s.mapLookup<int?>(
        json: {'other': 42},
        jsonName: 'count',
      );
      expect(result, isNull);
    });
  });

  // ─── ListSerializer generic fromJson paths ──────────────────────────────
  group('ListSerializer fromJson via JSerializer', () {
    test('fromJson List<int> already typed returns as-is', () {
      final input = <int>[1, 2, 3];
      final result = js.fromJson<List<int>>(input);
      expect(result, [1, 2, 3]);
    });

    test('fromJson List<String> already typed returns as-is', () {
      final input = <String>['a', 'b'];
      final result = js.fromJson<List<String>>(input);
      expect(result, ['a', 'b']);
    });

    test('fromJson List<bool> primitive fast path', () {
      final result = js.fromJson<List<bool>>([true, false, true]);
      expect(result, [true, false, true]);
    });

    test('fromJson List<dynamic> cast path', () {
      final result = js.fromJson<List<dynamic>>([1, 'two', true]);
      expect(result, [1, 'two', true]);
    });

    test('fromJson List from Iterable (non-List)', () {
      // Passing a Set which is an Iterable but not a List
      final input = {1, 2, 3};
      final result = js.fromJson<List<int>>(input);
      expect(result, [1, 2, 3]);
    });

    test('toJson List with nested lists', () {
      final result = js.toJson([
        [1, 2],
        [3, 4]
      ]);
      expect(result, [
        [1, 2],
        [3, 4]
      ]);
    });

    test('toJson List<num> returns as-is', () {
      final result = js.toJson(<num>[1, 2.0, 3]);
      expect(result, [1, 2.0, 3]);
    });
  });

  // ─── MapSerializer generic fromJson paths ──────────────────────────────
  group('MapSerializer fromJson via JSerializer', () {
    test('fromJson Map<String, dynamic> already typed', () {
      final input = <String, dynamic>{'a': 1, 'b': 'two'};
      final result = js.fromJson<Map<String, dynamic>>(input);
      expect(result, {'a': 1, 'b': 'two'});
    });

    test('fromJson Map<String, int> primitive value fast path', () {
      final result = js.fromJson<Map<String, int>>({'x': 1, 'y': 2});
      expect(result, {'x': 1, 'y': 2});
    });

    test('fromJson Map<String, bool> primitive value fast path', () {
      final result = js.fromJson<Map<String, bool>>({'a': true, 'b': false});
      expect(result, {'a': true, 'b': false});
    });

    test('fromJson Map<dynamic, dynamic> already typed', () {
      final result = js.fromJson<Map<dynamic, dynamic>>({'a': 1});
      expect(result, {'a': 1});
    });

    test('toJson Map<String, bool> returns as-is', () {
      final result = js.toJson({'a': true, 'b': false});
      expect(result, {'a': true, 'b': false});
    });

    test('toJson Map with nested map values', () {
      final input = <String, dynamic>{
        'outer': <String, dynamic>{'inner': 42}
      };
      final result = js.toJson(input) as Map;
      expect(result['outer'], {'inner': 42});
    });
  });

  // ─── ModelSerializer ──────────────────────────────────────────────────
  group('ModelSerializer', () {
    test('decoder returns fromJson function', () {
      final s = _TestModelSerializer();
      expect(s.decoder, isA<Function>());
    });

    test('fromJson and toJson work', () {
      final s = _TestModelSerializer();
      final person = s.fromJson({'name': 'Alice', 'age': 30});
      expect(person.name, 'Alice');
      expect(person.age, 30);

      final json = s.toJson(person);
      expect(json['name'], 'Alice');
      expect(json['age'], 30);
    });
  });

  // ─── CustomModelSerializer ─────────────────────────────────────────────
  group('CustomModelSerializer', () {
    test('decoder returns fromJson function', () {
      final s = _TestCustomSerializer();
      expect(s.decoder, isA<Function>());
    });

    test('fromJson and toJson work', () {
      final s = _TestCustomSerializer();
      final point = s.fromJson({'x': 1, 'y': 2});
      expect(point.x, 1);
      expect(point.y, 2);

      final json = s.toJson(point);
      expect(json, {'x': 1, 'y': 2});
    });
  });

  // ─── MapSerializer slow path (non-primitive values) ───────────────────
  group('MapSerializer slow path (non-primitive values)', () {
    test('fromJson Map<String, _SimpleModel> decodes via jSerializer', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
      final input = <String, dynamic>{
        'a': {'value': 10},
        'b': {'value': 20},
      };
      final result = js.fromJson<Map<String, _SimpleModel>>(input);
      expect(result, isA<Map<String, _SimpleModel>>());
      expect(result['a']!.value, 10);
      expect(result['b']!.value, 20);
    });

    test('toJson Map with registered model values serializes each', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
      final input = <String, dynamic>{
        'x': _SimpleModel(42),
      };
      final s = MapSerializer(jSerializer: js);
      final result = s.toJson(input);
      expect(result['x'], isA<Map>());
      expect((result['x'] as Map)['value'], 42);
    });
  });

  // ─── PrimitiveMocker ─────────────────────────────────────────────────
  group('PrimitiveMocker', () {
    test('createMock calls the provided mockBuilder', () {
      final mocker = PrimitiveMocker<int>(
        mockBuilder: ([context]) => 99,
        jSerializer: js,
      );
      expect(mocker.createMock(), 99);
    });

    test('createMock passes context to mockBuilder', () {
      final ctx = JMockerContext(randomize: true);
      JMockerContext? receivedCtx;
      final mocker = PrimitiveMocker<String>(
        mockBuilder: ([context]) {
          receivedCtx = context;
          return 'hello';
        },
        jSerializer: js,
      );
      final result = mocker.createMock(ctx);
      expect(result, 'hello');
      expect(receivedCtx, same(ctx));
    });

    test('mocker getter returns createMock function', () {
      final mocker = PrimitiveMocker<int>(
        mockBuilder: ([context]) => 0,
        jSerializer: js,
      );
      expect(mocker.mocker, isA<Function>());
    });
  });

  // ─── JMockRandomObjX ────────────────────────────────────────────────
  group('JMockRandomObjX (nextIntInRange / nextDoubleInRange)', () {
    test('nextIntInRange returns value within non-inclusive range', () {
      final random = math.Random(42);
      for (var i = 0; i < 50; i++) {
        final val = random.nextIntInRange(5, 10);
        expect(val, greaterThanOrEqualTo(5));
        expect(val, lessThan(10));
      }
    });

    test('nextIntInRange with inclusive=true allows max value', () {
      // With inclusive, range is [min, max] so max is possible
      final random = math.Random(42);
      final values = <int>{};
      for (var i = 0; i < 200; i++) {
        values.add(random.nextIntInRange(0, 2, inclusive: true));
      }
      // Should include 0, 1, and 2
      expect(values, contains(0));
      expect(values, contains(1));
      expect(values, contains(2));
    });

    test('nextIntInRange with min == max - 1 returns min', () {
      final random = math.Random(42);
      // Range [5, 6) exclusive => always 5
      for (var i = 0; i < 10; i++) {
        final val = random.nextIntInRange(5, 6);
        expect(val, 5);
      }
    });

    test('nextDoubleInRange returns value within range', () {
      final random = math.Random(42);
      for (var i = 0; i < 50; i++) {
        final val = random.nextDoubleInRange(1.0, 5.0);
        expect(val, greaterThanOrEqualTo(1.0));
        expect(val, lessThan(5.1)); // small tolerance
      }
    });

    test('nextDoubleInRange with precision truncates decimals', () {
      final random = math.Random(42);
      final val = random.nextDoubleInRange(0.0, 10.0, precision: 2);
      final str = val.toString();
      final decimalIndex = str.indexOf('.');
      if (decimalIndex != -1) {
        expect(str.substring(decimalIndex + 1).length, lessThanOrEqualTo(2));
      }
    });

    test('nextDoubleInRange with inclusive=true', () {
      final random = math.Random(42);
      final val = random.nextDoubleInRange(0.0, 10.0, inclusive: true);
      expect(val, greaterThanOrEqualTo(0.0));
    });

    test('nextDoubleInRange returns min when min >= max (after assert)', () {
      // The method asserts min < max, but after assert (in release mode),
      // if min >= max it returns min.
      // We test the assertion fires in debug mode.
      final random = math.Random(42);
      expect(
        () => random.nextDoubleInRange(5.0, 5.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('nextDoubleInRange with precision 0 returns whole number', () {
      final random = math.Random(42);
      final val = random.nextDoubleInRange(0.0, 100.0, precision: 0);
      expect(val, equals(val.roundToDouble()));
    });
  });

  // ─── BoolMocker additional paths ─────────────────────────────────────
  group('BoolMocker additional', () {
    test('createMock without context defaults to fallback (true)', () {
      final mocker = BoolMocker(jSerializer: js);
      // Without context, a new JMockerContext() is created with randomize=null
      // which is treated as false, so fallback is used
      final val = mocker.createMock();
      expect(val, true);
    });

    test('createMock with deterministic random returns consistent result', () {
      final mocker = BoolMocker(jSerializer: js);
      final ctx1 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 7,
      );
      ctx1.setCallCount(0);
      final val1 = mocker.createMock(ctx1);

      final ctx2 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 7,
      );
      ctx2.setCallCount(0);
      final val2 = mocker.createMock(ctx2);
      expect(val1, val2);
    });
  });

  // ─── IntMocker additional paths ──────────────────────────────────────
  group('IntMocker additional', () {
    test('createMock without context returns fallback (0)', () {
      final mocker = IntMocker(jSerializer: js);
      final val = mocker.createMock();
      expect(val, 0);
    });

    test('createMock with maxInclusive=true includes max value boundary', () {
      final mocker = IntMocker(
        jSerializer: js,
        minValue: 0,
        maxValue: 1,
        maxInclusive: true,
      );
      final values = <int>{};
      for (var i = 0; i < 100; i++) {
        final ctx = JMockerContext(randomize: true);
        values.add(mocker.createMock(ctx));
      }
      // With inclusive, should include 0 and 1
      expect(values, contains(0));
      expect(values, contains(1));
    });

    test('createMock reads range from context options', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        options: {
          'num': {'minValue': 50, 'maxValue': 60, 'maxInclusive': true},
        },
      );
      ctx.setCallCount(0);
      final val = mocker.createMock(ctx);
      expect(val, greaterThanOrEqualTo(50));
      expect(val, lessThanOrEqualTo(60));
    });
  });

  // ─── NumMocker additional paths ──────────────────────────────────────
  group('NumMocker additional', () {
    test('createMock without context returns fallback (0)', () {
      final mocker = NumMocker(jSerializer: js);
      final val = mocker.createMock();
      expect(val, 0);
    });

    test('createMock with randomize and no precision can return int or double',
        () {
      final mocker = NumMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: true);
      final val = mocker.createMock(ctx);
      expect(val, isA<num>());
    });

    test('createMock with precision 0 delegates to int mocker', () {
      // NumMocker with precision: 0 delegates to jSerializer.createMock<int>
      // which uses the IntMocker with context defaults (0-1000 range)
      final mocker = NumMocker(
        jSerializer: js,
        precision: 0,
      );
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
      );
      ctx.setCallCount(0);
      final val = mocker.createMock(ctx);
      expect(val, isA<int>());
      expect(val, greaterThanOrEqualTo(0));
      expect(val, lessThanOrEqualTo(1000));
    });

    test('createMock with maxInclusive parameter', () {
      final mocker = NumMocker(
        jSerializer: js,
        maxInclusive: true,
        precision: 0,
      );
      final ctx = JMockerContext(randomize: true);
      final val = mocker.createMock(ctx);
      expect(val, isA<num>());
    });
  });

  // ─── MapMocker with randomize context ────────────────────────────────
  group('MapMocker with randomize', () {
    test('createMock Map<String, int> with randomize=true', () {
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 42,
      );
      ctx.setCallCount(0);
      final result = js.createMock<Map<String, int>>(context: ctx);
      expect(result, isA<Map<String, int>>());
    });

    test('createMock Map<String, bool> with randomize=true', () {
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 99,
      );
      ctx.setCallCount(0);
      final result = js.createMock<Map<String, bool>>(context: ctx);
      expect(result, isA<Map<String, bool>>());
    });

    test('createMock Map<int, String> with randomize=true', () {
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 5,
      );
      ctx.setCallCount(0);
      final result = js.createMock<Map<int, String>>(context: ctx);
      expect(result, isA<Map<int, String>>());
    });
  });

  // ─── Annotations constructors ────────────────────────────────────────
  group('Annotations constructors', () {
    group('JKey', () {
      test('default constructor with all parameters', () {
        const key = JKey(
          name: 'user_name',
          ignore: true,
          fallbackName: 'name',
          mockValue: 'mock_name',
        );
        expect(key.name, 'user_name');
        expect(key.ignore, true);
        expect(key.fallbackName, 'name');
        expect(key.mockValue, 'mock_name');
        expect(key.isExtras, false);
        expect(key.overridesToJsonModelFields, false);
      });

      test('default constructor with defaults', () {
        const key = JKey();
        expect(key.name, isNull);
        expect(key.ignore, false);
        expect(key.fallbackName, isNull);
        expect(key.mockValue, isNull);
        expect(key.isExtras, false);
        expect(key.overridesToJsonModelFields, false);
      });

      test('JKey.extras constructor', () {
        const key = JKey.extras();
        expect(key.isExtras, true);
        expect(key.ignore, true);
        expect(key.name, isNull);
        expect(key.fallbackName, isNull);
        expect(key.mockValue, isNull);
        expect(key.overridesToJsonModelFields, false);
      });

      test('JKey.extras with overridesToJsonModelFields', () {
        const key = JKey.extras(overridesToJsonModelFields: true);
        expect(key.isExtras, true);
        expect(key.overridesToJsonModelFields, true);
      });
    });

    group('JUnion / JUnionValue', () {
      test('JUnion default constructor', () {
        const u = JUnion();
        expect(u.typeKey, isNull);
        expect(u.fallbackName, isNull);
      });

      test('JUnion with typeKey and fallbackName', () {
        const u = JUnion(typeKey: 'type', fallbackName: 'unknown');
        expect(u.typeKey, 'type');
        expect(u.fallbackName, 'unknown');
      });

      test('jUnion constant', () {
        expect(jUnion, isA<JUnion>());
        expect(jUnion.typeKey, isNull);
      });

      test('JUnionValue default constructor', () {
        const v = JUnionValue(name: 'foo');
        expect(v.name, 'foo');
        expect(v.ignore, false);
      });

      test('JUnionValue with ignore', () {
        const v = JUnionValue(name: 'bar', ignore: true);
        expect(v.name, 'bar');
        expect(v.ignore, true);
      });

      test('JUnionValue.ignore constructor', () {
        const v = JUnionValue.ignore();
        expect(v.ignore, true);
        expect(v.name, isNull);
      });
    });

    group('JEnum / JEnumKey / JEnumIdentifier', () {
      test('JEnum constructor', () {
        const e = JEnum();
        expect(e, isA<JEnum>());
      });

      test('jEnum constant', () {
        expect(jEnum, isA<JEnum>());
      });

      test('JEnumKey default constructor', () {
        const k = JEnumKey();
        expect(k.isFallback, false);
      });

      test('JEnumKey with isFallback true', () {
        const k = JEnumKey(isFallback: true);
        expect(k.isFallback, true);
      });

      test('JEnumKey.fallback constructor', () {
        const k = JEnumKey.fallback();
        expect(k.isFallback, true);
      });

      test('JEnumIdentifier constructor', () {
        const id = JEnumIdentifier();
        expect(id, isA<JEnumIdentifier>());
      });

      test('jEnumId constant', () {
        expect(jEnumId, isA<JEnumIdentifier>());
      });
    });

    group('CustomJSerializer / CustomJMocker', () {
      test('CustomJSerializer constructor', () {
        const s = CustomJSerializer();
        expect(s, isA<CustomJSerializer>());
      });

      test('customJSerializer constant', () {
        expect(customJSerializer, isA<CustomJSerializer>());
      });

      test('CustomJMocker default constructor', () {
        const m = CustomJMocker();
        expect(m.applyOnlyToFieldNames, isNull);
      });

      test('CustomJMocker with applyOnlyToFieldNames', () {
        const m = CustomJMocker(applyOnlyToFieldNames: ['name', 'email']);
        expect(m.applyOnlyToFieldNames, ['name', 'email']);
      });

      test('customJMocker constant', () {
        expect(customJMocker, isA<CustomJMocker>());
        expect(customJMocker.applyOnlyToFieldNames, isNull);
      });
    });
  });
}

class _Point {
  final int x;
  final int y;
  _Point(this.x, this.y);
}

class _TestCustomSerializer
    extends CustomModelSerializer<_Point, Map<String, dynamic>> {
  @override
  _Point fromJson(Map<String, dynamic> json) =>
      _Point(json['x'] as int, json['y'] as int);

  @override
  Map<String, dynamic> toJson(_Point model) => {'x': model.x, 'y': model.y};
}

class _Person {
  final String name;
  final int age;
  _Person(this.name, this.age);
}

class _TestModelSerializer extends ModelSerializer<_Person> {
  @override
  _Person fromJson(Map json) =>
      _Person(json['name'] as String, json['age'] as int);

  @override
  Map toJson(_Person model) => {'name': model.name, 'age': model.age};
}

class _SimpleModel {
  final int value;
  _SimpleModel(this.value);
}

class _SimpleModelSerializer extends ModelSerializer<_SimpleModel> {
  const _SimpleModelSerializer({super.jSerializer});

  @override
  _SimpleModel fromJson(Map json) => _SimpleModel(json['value'] as int);

  @override
  Map toJson(_SimpleModel model) => {'value': model.value};
}
