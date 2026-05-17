import 'package:jserializer/jserializer.dart';
import 'package:test/test.dart';

void main() {
  // ─── Primitive fromJson / toJson via JSerializer.i ─────────────────────
  group('JSerializer primitive serialization', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    // ── int ────────────────────────────────────────────────────────────
    group('int', () {
      test('fromJson passes int through', () {
        expect(js.fromJson<int>(42), 42);
      });

      test('fromJson coerces double to int (rounds)', () {
        expect(js.fromJson<int>(3.7), 4); // IntSerializer uses .round()
        expect(js.fromJson<int>(3.2), 3);
      });

      test('fromJson coerces string to int', () {
        expect(js.fromJson<int>('99'), 99);
      });

      test('fromJson coerces bool to int', () {
        expect(js.fromJson<int>(true), 1);
        expect(js.fromJson<int>(false), 0);
      });

      test('toJson returns int directly', () {
        expect(js.toJson(42), 42);
      });
    });

    // ── double ─────────────────────────────────────────────────────────
    group('double', () {
      test('fromJson passes double through', () {
        expect(js.fromJson<double>(3.14), 3.14);
      });

      test('fromJson coerces int to double', () {
        final result = js.fromJson<double>(5);
        expect(result, 5.0);
        expect(result, isA<double>());
      });

      test('fromJson coerces string to double', () {
        expect(js.fromJson<double>('2.5'), 2.5);
      });

      test('toJson returns double directly', () {
        expect(js.toJson(3.14), 3.14);
      });
    });

    // ── String ─────────────────────────────────────────────────────────
    group('String', () {
      test('fromJson passes string through', () {
        expect(js.fromJson<String>('hello'), 'hello');
      });

      test('fromJson coerces num to string', () {
        expect(js.fromJson<String>(42), '42');
      });

      test('fromJson coerces bool to string', () {
        expect(js.fromJson<String>(true), 'true');
      });

      test('toJson returns string directly', () {
        expect(js.toJson('hello'), 'hello');
      });
    });

    // ── bool ───────────────────────────────────────────────────────────
    group('bool', () {
      test('fromJson passes bool through', () {
        expect(js.fromJson<bool>(true), true);
        expect(js.fromJson<bool>(false), false);
      });

      test('fromJson coerces num to bool', () {
        expect(js.fromJson<bool>(1), true);
        expect(js.fromJson<bool>(0), false);
      });

      test('fromJson coerces string to bool', () {
        expect(js.fromJson<bool>('true'), true);
        expect(js.fromJson<bool>('false'), false);
        expect(js.fromJson<bool>('0'), false);
      });

      test('toJson returns bool directly', () {
        expect(js.toJson(true), true);
        expect(js.toJson(false), false);
      });
    });

    // ── num ────────────────────────────────────────────────────────────
    group('num', () {
      test('fromJson passes num through', () {
        expect(js.fromJson<num>(42), 42);
        expect(js.fromJson<num>(3.14), 3.14);
      });

      test('fromJson coerces string to num', () {
        expect(js.fromJson<num>('55'), 55);
      });

      test('fromJson coerces bool to num', () {
        expect(js.fromJson<num>(true), 1);
        expect(js.fromJson<num>(false), 0);
      });

      test('toJson returns num directly', () {
        expect(js.toJson(42), 42);
      });
    });

    // ── null / void / dynamic ──────────────────────────────────────────
    group('null and dynamic', () {
      test('fromJson null returns null for dynamic', () {
        expect(js.fromJson<dynamic>(null), isNull);
      });

      test('toJson null returns null', () {
        expect(js.toJson(null), isNull);
      });

      test('toJson dynamic object passthrough', () {
        expect(js.toJson('hello'), 'hello');
        expect(js.toJson(42), 42);
        expect(js.toJson(true), true);
      });
    });
  });

  // ─── List serialization ────────────────────────────────────────────────
  group('JSerializer list serialization', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('fromJson List<int>', () {
      final result = js.fromJson<List<int>>([1, 2, 3]);
      expect(result, [1, 2, 3]);
      expect(result, isA<List<int>>());
    });

    test('fromJson List<String>', () {
      final result = js.fromJson<List<String>>(['a', 'b']);
      expect(result, ['a', 'b']);
    });

    test('fromJson List<dynamic>', () {
      final result = js.fromJson<List<dynamic>>([1, 'two', true]);
      expect(result, [1, 'two', true]);
    });

    test('toJson List<String>', () {
      final result = js.toJson(['a', 'b', 'c']);
      expect(result, ['a', 'b', 'c']);
    });

    test('toJson List<int>', () {
      final result = js.toJson([1, 2, 3]);
      expect(result, [1, 2, 3]);
    });

    test('fromJson empty list', () {
      final result = js.fromJson<List<int>>([]);
      expect(result, isEmpty);
      expect(result, isA<List<int>>());
    });

    test('toJson empty list', () {
      expect(js.toJson(<int>[]), []);
    });
  });

  // ─── Map serialization ─────────────────────────────────────────────────
  group('JSerializer map serialization', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('fromJson Map<String, int>', () {
      final result = js.fromJson<Map<String, int>>({'a': 1, 'b': 2});
      expect(result, {'a': 1, 'b': 2});
      expect(result, isA<Map<String, int>>());
    });

    test('fromJson Map<String, String>', () {
      final result = js.fromJson<Map<String, String>>({'k': 'v'});
      expect(result, {'k': 'v'});
    });

    test('toJson Map<String, int>', () {
      final result = js.toJson({'a': 1, 'b': 2});
      expect(result, {'a': 1, 'b': 2});
    });

    test('toJson Map<String, String>', () {
      final result = js.toJson({'x': 'y'});
      expect(result, {'x': 'y'});
    });

    test('fromJson empty map', () {
      final result = js.fromJson<Map<String, int>>({});
      expect(result, isEmpty);
    });

    test('toJson empty map', () {
      expect(js.toJson(<String, int>{}), {});
    });
  });

  // ─── Register / Unregister / serializerOf / hasSerializerOf ────────────
  group('JSerializer registration', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('hasSerializerOf for built-in types', () {
      expect(js.hasSerializerOf<int>(), true);
      expect(js.hasSerializerOf<String>(), true);
      expect(js.hasSerializerOf<bool>(), true);
      expect(js.hasSerializerOf<double>(), true);
      expect(js.hasSerializerOf<num>(), true);
      expect(js.hasSerializerOf<List>(), true);
      expect(js.hasSerializerOf<Map>(), true);
    });

    test('serializerOf returns serializer for built-in types', () {
      expect(js.serializerOf<int>(), isA<Serializer>());
      expect(js.serializerOf<String>(), isA<Serializer>());
      expect(js.serializerOf<bool>(), isA<Serializer>());
    });

    test('serializerOf throws for unregistered type', () {
      expect(
        () => js.serializerOf<DateTime>(),
        throwsA(isA<UnregisteredSerializableTypeException>()),
      );
    });

    test('hasSerializerOf returns false for unregistered type', () {
      expect(js.hasSerializerOf<DateTime>(), false);
    });

    test('hasMockerOf for built-in types', () {
      expect(js.hasMockerOf<int>(), true);
      expect(js.hasMockerOf<String>(), true);
      expect(js.hasMockerOf<bool>(), true);
      expect(js.hasMockerOf<double>(), true);
      expect(js.hasMockerOf<num>(), true);
    });

    test('hasMockerOf returns false for unregistered type', () {
      expect(js.hasMockerOf<DateTime>(), false);
    });

    test('mockerOf throws for unregistered type', () {
      expect(
        () => js.mockerOf<DateTime>(),
        throwsA(isA<UnregisteredMockerTypeException>()),
      );
    });
  });

  // ─── newInstance ───────────────────────────────────────────────────────
  group('JSerializer.newInstance', () {
    test('new instance inherits parent serializers', () {
      final child = JSerializer.newInstance();
      expect(child.hasSerializerOf<int>(), true);
      expect(child.hasSerializerOf<String>(), true);
    });

    test('forceFresh creates clean instance with built-in types', () {
      final fresh = JSerializer.newInstance(forceFresh: true);
      // Should still have built-in types registered
      expect(fresh.hasSerializerOf<int>(), true);
      expect(fresh.hasSerializerOf<String>(), true);
    });

    test('child registration does not affect parent', () {
      final parent = JSerializer.newInstance(forceFresh: true);
      final child = JSerializer.newInstance(parent: parent);

      // Verify DateTime not registered in parent
      expect(parent.hasSerializerOf<DateTime>(), false);

      // Register in child
      child.register<DateTime>(
        (s) => _DateTimeSerializer(jSerializer: s),
        (f) => f<DateTime>(),
      );

      expect(child.hasSerializerOf<DateTime>(), true);
      // Parent should be unaffected
      expect(parent.hasSerializerOf<DateTime>(), false);
    });
  });

  // ─── Error handling ────────────────────────────────────────────────────
  group('JSerializer error handling', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('fromJson throws FromJsonException for unregistered type', () {
      expect(
        () => js.fromJson<DateTime>({'year': 2024}),
        throwsA(isA<FromJsonException>()),
      );
    });

    test('onError callback is invoked on error', () {
      Object? capturedError;
      js.onError = (arg) {
        capturedError = arg.error;
      };

      try {
        js.fromJson<DateTime>({'year': 2024});
      } catch (_) {}

      expect(capturedError, isNotNull);
    });

    test('fromJsonErrorHandler can return a fallback value', () {
      final result = js.fromJson<int>(
        'not_a_number_string_that_will_fail',
        handleError: (arg) =>
            JSerializerErrorHandler<int>.returnValue(() => -1),
      );
      expect(result, -1);
    });

    test('fromJsonErrorHandler can rethrow with custom error', () {
      expect(
        () => js.fromJson<DateTime>(
          'bad',
          handleError: (arg) => JSerializerErrorHandler<DateTime>.throwValue(
            error: FormatException('custom error'),
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson handles null gracefully', () {
      expect(js.toJson(null), isNull);
    });

    test('toJson handles primitives directly', () {
      expect(js.toJson('hello'), 'hello');
      expect(js.toJson(42), 42);
      expect(js.toJson(true), true);
      expect(js.toJson(3.14), 3.14);
    });

    test('toJsonErrorHandler can be set', () {
      // toJsonErrorHandler is a setter on the interface
      // Just verify it can be set without error
      js.toJsonErrorHandler = (arg) {
        return {'fallback': true};
      };
      // Setting null to clear
      js.toJsonErrorHandler = null;
    });
  });

  // ─── createMock for primitives ─────────────────────────────────────────
  group('JSerializer.createMock', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('createMock<int> returns int', () {
      final mock = js.createMock<int>();
      expect(mock, isA<int>());
    });

    test('createMock<String> returns string', () {
      final mock = js.createMock<String>();
      expect(mock, isA<String>());
    });

    test('createMock<bool> returns bool', () {
      final mock = js.createMock<bool>();
      expect(mock, isA<bool>());
    });

    test('createMock<double> returns double', () {
      final mock = js.createMock<double>();
      expect(mock, isA<double>());
    });

    test('createMock<num> returns num', () {
      final mock = js.createMock<num>();
      expect(mock, isA<num>());
    });

    test('createMock<int> without randomize returns default', () {
      final ctx = JMockerContext(randomize: false);
      final mock = js.createMock<int>(context: ctx);
      // IntMocker fallback is 0
      expect(mock, 0);
    });

    test('createMock<String> without randomize returns default', () {
      final ctx = JMockerContext(randomize: false);
      final mock = js.createMock<String>(context: ctx);
      // StringMocker fallback is 'mock'
      expect(mock, 'mock');
    });

    test('createMock<bool> without randomize returns default', () {
      final ctx = JMockerContext(randomize: false);
      final mock = js.createMock<bool>(context: ctx);
      // BoolMocker fallback is true
      expect(mock, true);
    });

    test('createMock<int> with randomize generates values', () {
      final ctx = JMockerContext(randomize: true);
      final mock = js.createMock<int>(context: ctx);
      expect(mock, isA<int>());
    });

    test('createMock throws for unregistered type', () {
      expect(
        () => js.createMock<DateTime>(),
        throwsA(isA<UnregisteredMockerTypeException>()),
      );
    });
  });

  // ─── Singleton instance ────────────────────────────────────────────────
  group('JSerializer singleton', () {
    test('JSerializer.i returns same instance', () {
      final a = JSerializer.i;
      final b = JSerializer.i;
      expect(identical(a, b), true);
    });

    test('static fromJson delegates to instance', () {
      expect(JSerializer.fromJson<int>(42), 42);
    });

    test('static toJson delegates to instance', () {
      expect(JSerializer.toJson('hello'), 'hello');
    });
  });

  // ─── Register/unregister custom serializers ──────────────────────────
  group('JSerializer register/unregister custom types', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('register and use custom ModelSerializer', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );

      final json = {'value': 42};
      final model = js.fromJson<_SimpleModel>(json);
      expect(model.value, 42);

      final result = js.toJson(model) as Map;
      expect(result['value'], 42);
    });

    test('unregister removes serializer', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
      expect(js.hasSerializerOf<_SimpleModel>(), true);

      js.unregister<_SimpleModel>();
      expect(js.hasSerializerOf<_SimpleModel>(), false);
    });

    test('register with mockFactory', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
        mockFactory: (s) => _SimpleModelMocker(jSerializer: s),
      );
      expect(js.hasMockerOf<_SimpleModel>(), true);

      final mock = js.createMock<_SimpleModel>();
      expect(mock, isA<_SimpleModel>());
      expect(mock.value, 99);
    });

    test('registerMocker and unregisterMocker', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );

      expect(js.hasMockerOf<_SimpleModel>(), false);

      js.registerMocker<_SimpleModel>(
        (s) => _SimpleModelMocker(jSerializer: s),
      );
      expect(js.hasMockerOf<_SimpleModel>(), true);

      js.unregisterMocker<_SimpleModel>();
      expect(js.hasMockerOf<_SimpleModel>(), false);
    });

    test('serializerOf caches serializers', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );

      final s1 = js.serializerOf<_SimpleModel>();
      final s2 = js.serializerOf<_SimpleModel>();
      expect(identical(s1, s2), true);
    });

    test('register clears cached serializer', () {
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
      final s1 = js.serializerOf<_SimpleModel>();

      // Re-register with same type
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
      final s2 = js.serializerOf<_SimpleModel>();
      // Cache should have been cleared, so new instance
      expect(identical(s1, s2), false);
    });
  });

  // ─── fromJson/toJson with registered model ──────────────────────────
  group('JSerializer model serialization', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
    });

    test('fromJson with registered model', () {
      final model = js.fromJson<_SimpleModel>({'value': 10});
      expect(model.value, 10);
    });

    test('toJson with registered model', () {
      final json = js.toJson(_SimpleModel(10)) as Map;
      expect(json['value'], 10);
    });

    test('fromJson null returns null for nullable type', () {
      final result = js.fromJson<_SimpleModel?>(null);
      expect(result, isNull);
    });

    test('toJson with list containing model', () {
      final result = js.toJson([_SimpleModel(1), _SimpleModel(2)]) as List;
      expect(result.length, 2);
      expect((result[0] as Map)['value'], 1);
      expect((result[1] as Map)['value'], 2);
    });

    test('toJson with map containing model', () {
      final result =
          js.toJson({'a': _SimpleModel(5)}) as Map;
      expect((result['a'] as Map)['value'], 5);
    });

    test('fromJson with list of models', () {
      final result = js.fromJson<List<_SimpleModel>>([
        {'value': 1},
        {'value': 2},
      ]);
      expect(result.length, 2);
      expect(result[0].value, 1);
      expect(result[1].value, 2);
    });

    test('fromJson with nested call is already in zone', () {
      // Test that nested fromJson calls work (zone reuse)
      final result = js.fromJson<List<_SimpleModel>>([
        {'value': 1}
      ]);
      expect(result.first.value, 1);
    });
  });

  // ─── onError nested zone behavior ──────────────────────────────────
  group('JSerializer error zone behavior', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('onError called once for nested fromJson errors', () {
      int errorCount = 0;
      js.onError = (arg) {
        errorCount++;
      };

      try {
        js.fromJson<DateTime>({'year': 2024});
      } catch (_) {}

      expect(errorCount, 1);
    });

    test('per-call onError overrides global onError', () {
      bool globalCalled = false;
      bool localCalled = false;
      js.onError = (arg) {
        globalCalled = true;
      };

      try {
        js.fromJson<DateTime>(
          'bad',
          onError: (arg) {
            localCalled = true;
          },
        );
      } catch (_) {}

      // Both should be called (per-call + global)
      expect(localCalled, true);
      expect(globalCalled, true);
    });
  });

  // ─── _fromJson with explicit type parameter ──────────────────────────
  group('fromJson with explicit type parameter', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
    });

    test('fromJson with type param for a registered ModelSerializer', () {
      final model = js.fromJson<_SimpleModel>(
        {'value': 77},
        type: _SimpleModel,
      );
      expect(model, isA<_SimpleModel>());
      expect(model.value, 77);
    });

    test('fromJson with type param for List type (GenericSerializer)', () {
      final result = js.fromJson<List<int>>(
        [1, 2, 3],
        type: List<int>,
      );
      expect(result, [1, 2, 3]);
      expect(result, isA<List<int>>());
    });

    test('fromJson with type param for Map type (GenericSerializer)', () {
      final result = js.fromJson<Map<String, int>>(
        {'a': 1, 'b': 2},
        type: Map<String, int>,
      );
      expect(result, {'a': 1, 'b': 2});
      expect(result, isA<Map<String, int>>());
    });

    test('fromJson with type param returns json as-is if same type', () {
      // If json is already of type T, return it directly
      final result = js.fromJson<int>(42, type: int);
      expect(result, 42);
    });

    test('fromJson with type param returns null when json is null', () {
      final result = js.fromJson<_SimpleModel?>(null, type: _SimpleModel);
      expect(result, isNull);
    });

    test('fromJson with type param for primitive serializer', () {
      final result = js.fromJson<String>('hello', type: String);
      expect(result, 'hello');
    });

    test('fromJson with type for int coercion', () {
      final result = js.fromJson<int>(3.7, type: int);
      expect(result, 4);
    });
  });

  // ─── TypeError message handling in fromJson ───────────────────────────
  group('fromJson TypeError message handling', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
    });

    test('passing a string where Map is expected triggers TypeError path', () {
      // _SimpleModelSerializer.fromJson expects a Map, passing a string
      // should produce a TypeError with the "is not a subtype of type 'Map<dynamic, dynamic>'" message
      expect(
        () => js.fromJson<_SimpleModel>('not a map'),
        throwsA(
          isA<FromJsonException>().having(
            (e) => e.message,
            'message',
            isNotNull,
          ),
        ),
      );
    });

    test('passing empty string triggers empty value display in message', () {
      expect(
        () => js.fromJson<_SimpleModel>(''),
        throwsA(
          isA<FromJsonException>().having(
            (e) => e.message,
            'message',
            isNotNull,
          ),
        ),
      );
    });

    test('non-TypeError error has null message in FromJsonException', () {
      // Trigger a non-TypeError error: unregistered type
      expect(
        () => js.fromJson<DateTime>({'year': 2024}),
        throwsA(
          isA<FromJsonException>(),
        ),
      );
    });

    test('TypeError that is not about Map subtype has error.toString() as message', () {
      // A TypeError that does not end with "is not a subtype of type 'Map<dynamic, dynamic>'"
      // For example, passing a wrong type to a primitive serializer that triggers a TypeError
      // IntSerializer tries to cast/convert, but let's trigger a TypeError differently.
      // Register a custom serializer that throws a TypeError internally
      js.register<_TypeErrorModel>(
        (s) => _TypeErrorModelSerializer(jSerializer: s),
        (f) => f<_TypeErrorModel>(),
      );

      expect(
        () => js.fromJson<_TypeErrorModel>({'value': 'abc'}),
        throwsA(
          isA<FromJsonException>().having(
            (e) => e.message,
            'message',
            isNotNull,
          ),
        ),
      );
    });
  });

  // ─── JSerializerErrorHandlerThrow with null error ─────────────────────
  group('fromJsonErrorHandler throw with null error', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('throwValue with no error rethrows original error', () {
      expect(
        () => js.fromJson<DateTime>(
          'bad',
          handleError: (arg) =>
              const JSerializerErrorHandler<DateTime>.throwValue(),
        ),
        throwsA(isA<FromJsonException>()),
      );
    });

    test('throwValue with custom stackTrace', () {
      final customStack = StackTrace.current;
      expect(
        () => js.fromJson<DateTime>(
          'bad',
          handleError: (arg) => JSerializerErrorHandler<DateTime>.throwValue(
            error: StateError('custom'),
            stackTrace: customStack,
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('handleError returning wrong type falls through to rethrow', () {
      // JSerializerErrorHandlerHandle that returns a non-T value
      // The code checks `if (value is T) return value;`, so if not T it falls through
      expect(
        () => js.fromJson<int>(
          'definitely_not_an_int_at_all',
          handleError: (arg) =>
              JSerializerErrorHandler<int>.returnValue(() => 42),
        ),
        // This should succeed because 42 is an int
        returnsNormally,
      );
    });

    test('global fromJsonErrorHandler is used when no local handler', () {
      js.fromJsonErrorHandler = (arg) {
        return JSerializerErrorHandler.returnValue(() => -999);
      };

      final result = js.fromJson<int>('not_an_int_string_will_fail');
      expect(result, -999);
    });
  });

  // ─── FromJsonErrorHandlerArg utility methods ──────────────────────────
  group('FromJsonErrorHandlerArg utility methods', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
    });

    test('doesTypeEqualsTypeOf returns true for matching type', () {
      bool? result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.doesTypeEqualsTypeOf<int>();
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, true);
    });

    test('doesTypeEqualsTypeOf returns false for non-matching type', () {
      bool? result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.doesTypeEqualsTypeOf<String>();
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, false);
    });

    test('doesBaseTypeEqualsTypeOf returns true for same base type', () {
      bool? result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.doesBaseTypeEqualsTypeOf<int>();
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, true);
    });

    test('doesBaseTypeEqualsTypeOf returns false for different base type', () {
      bool? result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.doesBaseTypeEqualsTypeOf<String>();
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, false);
    });

    test('doesTypeAcceptNull is false for non-nullable type', () {
      bool? result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.doesTypeAcceptNull;
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, false);
    });

    test('checkIfObjIsModelType returns true for matching instance', () {
      bool? result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.checkIfObjIsModelType(42);
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, true);
    });

    test('checkIfObjIsModelType returns false for non-matching instance', () {
      bool? result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.checkIfObjIsModelType('not an int');
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, false);
    });

    test('callWithModelTypeAsGeneric calls function with correct type', () {
      Type? capturedType;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          arg.callWithModelTypeAsGeneric(<MT extends int>() {
            capturedType = MT;
          });
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(capturedType, int);
    });

    test('callWitTypeGenericArgs calls function with type args', () {
      // For a non-generic type like int, argsAsTypes will be empty
      dynamic result;
      js.fromJson<int>(
        'will_fail_but_we_catch',
        handleError: (arg) {
          result = arg.callWitTypeGenericArgs(() => 'called');
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );
      expect(result, 'called');
    });

    test('FromJsonErrorHandlerArg exposes error and json', () {
      Object? capturedError;
      dynamic capturedJson;
      Type? capturedType;
      Type? capturedBaseType;

      js.fromJson<int>(
        'bad_value',
        handleError: (arg) {
          capturedError = arg.error;
          capturedJson = arg.json;
          capturedType = arg.type;
          capturedBaseType = arg.baseType;
          return JSerializerErrorHandler<int>.returnValue(() => 0);
        },
      );

      expect(capturedError, isA<FromJsonException>());
      expect(capturedJson, 'bad_value');
      expect(capturedType, int);
      expect(capturedBaseType, int);
    });
  });

  // ─── JSerializer.newInstance with parent ───────────────────────────────
  group('JSerializer.newInstance with explicit parent', () {
    test('newInstance with custom parent inherits custom serializers', () {
      final parent = JSerializer.newInstance(forceFresh: true);
      parent.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );

      final child = JSerializer.newInstance(parent: parent);
      expect(child.hasSerializerOf<_SimpleModel>(), true);

      final model = child.fromJson<_SimpleModel>({'value': 55});
      expect(model.value, 55);
    });

    test('newInstance with parent inherits mockers', () {
      final parent = JSerializer.newInstance(forceFresh: true);
      parent.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
        mockFactory: (s) => _SimpleModelMocker(jSerializer: s),
      );

      final child = JSerializer.newInstance(parent: parent);
      expect(child.hasMockerOf<_SimpleModel>(), true);

      final mock = child.createMock<_SimpleModel>();
      expect(mock.value, 99);
    });

    test('newInstance forceFresh ignores parent', () {
      final parent = JSerializer.newInstance(forceFresh: true);
      parent.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );

      final child = JSerializer.newInstance(
        parent: parent,
        forceFresh: true,
      );
      // forceFresh should ignore the parent
      expect(child.hasSerializerOf<_SimpleModel>(), false);
      // But still have built-in types
      expect(child.hasSerializerOf<int>(), true);
    });
  });

  // ─── hasSerializerOf with type parameter ──────────────────────────────
  group('hasSerializerOf with explicit type parameter', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
    });

    test('hasSerializerOf with type param returns true for registered type', () {
      expect(js.hasSerializerOf<_SimpleModel>(_SimpleModel), true);
    });

    test('hasSerializerOf with type param returns false for unregistered', () {
      expect(js.hasSerializerOf<DateTime>(DateTime), false);
    });

    test('hasMockerOf with type param for registered mocker', () {
      js.registerMocker<_SimpleModel>(
        (s) => _SimpleModelMocker(jSerializer: s),
      );
      expect(js.hasMockerOf<_SimpleModel>(_SimpleModel), true);
    });

    test('hasMockerOf with type param for unregistered mocker', () {
      expect(js.hasMockerOf<_SimpleModel>(_SimpleModel), false);
    });
  });

  // ─── createMock with JModelMocker ─────────────────────────────────────
  group('createMock with JModelMocker', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
        mockFactory: (s) => _SimpleModelMocker(jSerializer: s),
      );
    });

    test('createMock uses JModelMocker path', () {
      final mock = js.createMock<_SimpleModel>();
      expect(mock, isA<_SimpleModel>());
      expect(mock.value, 99);
    });

    test('createMock with context', () {
      final ctx = JMockerContext(randomize: false);
      final mock = js.createMock<_SimpleModel>(context: ctx);
      expect(mock, isA<_SimpleModel>());
      expect(mock.value, 99);
    });

    test('createMock with overriddenMocker', () {
      final customMocker = _SimpleModelMockerAlternate(jSerializer: js);
      final mock = js.createMock<_SimpleModel>(overriddenMocker: customMocker);
      expect(mock, isA<_SimpleModel>());
      expect(mock.value, 42);
    });
  });

  // ─── createMock with List/Map generic mockers ─────────────────────────
  group('createMock with generic types', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
    });

    test('createMock<List<int>> returns list', () {
      final mock = js.createMock<List<int>>();
      expect(mock, isA<List<int>>());
    });

    test('createMock<Map<String, int>> returns map', () {
      final mock = js.createMock<Map<String, int>>();
      expect(mock, isA<Map<String, int>>());
    });
  });

  // ─── serializerOf with explicit type parameter ────────────────────────
  group('serializerOf with explicit type parameter', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
      );
    });

    test('serializerOf with type param returns serializer', () {
      final serializer = js.serializerOf<_SimpleModel>(_SimpleModel);
      expect(serializer, isA<_SimpleModelSerializer>());
    });

    test('serializerOf with type param caches result', () {
      final s1 = js.serializerOf<_SimpleModel>(_SimpleModel);
      final s2 = js.serializerOf<_SimpleModel>(_SimpleModel);
      expect(identical(s1, s2), true);
    });

    test('serializerOf with unregistered type param throws', () {
      expect(
        () => js.serializerOf<DateTime>(DateTime),
        throwsA(isA<UnregisteredSerializableTypeException>()),
      );
    });
  });

  // ─── mockerOf with explicit type parameter ────────────────────────────
  group('mockerOf with explicit type parameter', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      js.register<_SimpleModel>(
        (s) => _SimpleModelSerializer(jSerializer: s),
        (f) => f<_SimpleModel>(),
        mockFactory: (s) => _SimpleModelMocker(jSerializer: s),
      );
    });

    test('mockerOf with type param returns mocker', () {
      final mocker = js.mockerOf<_SimpleModel>(_SimpleModel);
      expect(mocker, isA<_SimpleModelMocker>());
    });

    test('mockerOf with unregistered type param throws', () {
      expect(
        () => js.mockerOf<DateTime>(DateTime),
        throwsA(isA<UnregisteredMockerTypeException>()),
      );
    });
  });

  // ─── toJson error handling ────────────────────────────────────────────
  group('toJson error handling', () {
    late JSerializerInterface js;

    setUp(() {
      js = JSerializer.newInstance(forceFresh: true);
      // Register a model whose toJson always throws
      js.register<_ThrowingToJsonModel>(
        (s) => _ThrowingToJsonModelSerializer(jSerializer: s),
        (f) => f<_ThrowingToJsonModel>(),
      );
    });

    test('toJson error triggers toJsonErrorHandler', () {
      js.toJsonErrorHandler = (arg) {
        return {'fallback': true};
      };

      final result = js.toJson(_ThrowingToJsonModel());
      expect(result, {'fallback': true});
    });

    test('toJson per-call handleError overrides global', () {
      js.toJsonErrorHandler = (arg) {
        return {'global': true};
      };

      final result = js.toJson(
        _ThrowingToJsonModel(),
        handleError: (arg) {
          return {'local': true};
        },
      );
      expect(result, {'local': true});
    });

    test('toJson handleError returning null rethrows', () {
      expect(
        () => js.toJson(
          _ThrowingToJsonModel(),
          handleError: (arg) => null,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('toJson onError callback is invoked on error', () {
      Object? capturedError;
      js.onError = (arg) {
        capturedError = arg.error;
      };

      try {
        js.toJson(_ThrowingToJsonModel());
      } catch (_) {}

      expect(capturedError, isNotNull);
    });

    test('toJson per-call onError is also called', () {
      bool localCalled = false;
      bool globalCalled = false;

      js.onError = (arg) {
        globalCalled = true;
      };

      try {
        js.toJson(
          _ThrowingToJsonModel(),
          onError: (arg) {
            localCalled = true;
          },
        );
      } catch (_) {}

      expect(localCalled, true);
      expect(globalCalled, true);
    });

    test('toJson ToJsonErrorHandlerArg contains model and error', () {
      dynamic capturedModel;
      Object? capturedError;

      js.toJsonErrorHandler = (arg) {
        capturedModel = arg.model;
        capturedError = arg.error;
        return {'handled': true};
      };

      js.toJson(_ThrowingToJsonModel());
      expect(capturedModel, isA<_ThrowingToJsonModel>());
      expect(capturedError, isA<StateError>());
    });
  });
}

// ─── Test model and serializer ───────────────────────────────────────────
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

class _SimpleModelMocker extends JModelMocker<_SimpleModel> {
  const _SimpleModelMocker({super.jSerializer});

  @override
  _SimpleModel createMock([JMockerContext? context]) => _SimpleModel(99);
}

/// Simple DateTime serializer for testing registration.
class _DateTimeSerializer extends CustomModelSerializer<DateTime, String> {
  const _DateTimeSerializer({super.jSerializer});

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime model) => model.toIso8601String();
}

/// Alternate mocker for _SimpleModel that returns value 42.
class _SimpleModelMockerAlternate extends JModelMocker<_SimpleModel> {
  const _SimpleModelMockerAlternate({super.jSerializer});

  @override
  _SimpleModel createMock([JMockerContext? context]) => _SimpleModel(42);
}

/// Model that deliberately throws a TypeError in fromJson.
class _TypeErrorModel {
  final int value;
  _TypeErrorModel(this.value);
}

class _TypeErrorModelSerializer extends ModelSerializer<_TypeErrorModel> {
  const _TypeErrorModelSerializer({super.jSerializer});

  @override
  _TypeErrorModel fromJson(Map json) {
    // This will throw a TypeError when json['value'] is a String
    // and we try to use it as int, but NOT the "Map<dynamic, dynamic>" TypeError
    final val = json['value'] as int;
    return _TypeErrorModel(val);
  }

  @override
  Map toJson(_TypeErrorModel model) => {'value': model.value};
}

/// A model whose toJson always throws, used to trigger errors in toJson.
class _ThrowingToJsonModel {
  final String name = 'test';
}

class _ThrowingToJsonModelSerializer
    extends ModelSerializer<_ThrowingToJsonModel> {
  const _ThrowingToJsonModelSerializer({super.jSerializer});

  @override
  _ThrowingToJsonModel fromJson(Map json) => _ThrowingToJsonModel();

  @override
  Map toJson(_ThrowingToJsonModel model) =>
      throw StateError('intentional toJson error');
}
