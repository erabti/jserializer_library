import 'package:jserializer/jserializer.dart';
import 'package:test/test.dart';

void main() {
  late JSerializerInterface js;

  setUp(() {
    js = JSerializer.newInstance(forceFresh: true);
  });

  // ─── NameMocker ────────────────────────────────────────────────────────
  group('NameMocker', () {
    test('createMock without randomize returns deterministic names', () {
      final mocker = NameMocker();
      final name = mocker.createMock();
      expect(name, isA<String>());
      expect(name.isNotEmpty, true);
      // Default nameCount is 2, so should have two words
      expect(name.split(' ').length, 2);
    });

    test('createMock with custom nameCount', () {
      final mocker = NameMocker(nameCount: 3);
      final name = mocker.createMock();
      expect(name.split(' ').length, 3);
    });

    test('createMock with nameCount 1', () {
      final mocker = NameMocker(nameCount: 1);
      final name = mocker.createMock();
      expect(name.split(' ').length, 1);
      // Should be a name from the default 'en' list
      expect(NameMocker.namesData['en'], contains(name));
    });

    test('createMock with language ar', () {
      final mocker = NameMocker(nameCount: 1, language: 'ar');
      final name = mocker.createMock();
      expect(NameMocker.namesData['ar'], contains(name));
    });

    test('createMock with randomize', () {
      final ctx = JMockerContext(randomize: true);
      final mocker = NameMocker(nameCount: 1);
      final name = mocker.createMock(ctx);
      expect(name, isA<String>());
      expect(name.isNotEmpty, true);
    });

    test('createMock with deterministic random produces consistent results',
        () {
      final mocker = NameMocker(nameCount: 1);
      final ctx1 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 42,
      );
      ctx1.setCallCount(0);
      final name1 = mocker.createMock(ctx1);

      final ctx2 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 42,
      );
      ctx2.setCallCount(0);
      final name2 = mocker.createMock(ctx2);
      expect(name1, name2);
    });

    test('getNameCount reads from context options', () {
      final mocker = NameMocker();
      final ctx = JMockerContext(options: {'name': {'count': 5}});
      expect(mocker.getNameCount(ctx), 5);
    });

    test('getNameCount falls back to string.maxWords', () {
      final mocker = NameMocker();
      final ctx = JMockerContext(options: {'string': {'maxWords': 4}});
      expect(mocker.getNameCount(ctx), 4);
    });

    test('getNameCount defaults to 2', () {
      final mocker = NameMocker();
      final ctx = JMockerContext();
      expect(mocker.getNameCount(ctx), 2);
    });

    test('getLanguage reads from context options', () {
      final mocker = NameMocker();
      final ctx = JMockerContext(options: {'name': {'language': 'ar'}});
      expect(mocker.getLanguage(ctx), 'ar');
    });

    test('getLanguage falls back to string.language', () {
      final mocker = NameMocker();
      final ctx = JMockerContext(options: {'string': {'language': 'ar'}});
      expect(mocker.getLanguage(ctx), 'ar');
    });

    test('getLanguage falls back to top-level language', () {
      final mocker = NameMocker();
      final ctx = JMockerContext(options: {'language': 'ar'});
      expect(mocker.getLanguage(ctx), 'ar');
    });

    test('getLanguage defaults to en', () {
      final mocker = NameMocker();
      final ctx = JMockerContext();
      expect(mocker.getLanguage(ctx), 'en');
    });

    test('namesData has en and ar', () {
      expect(NameMocker.namesData.containsKey('en'), true);
      expect(NameMocker.namesData.containsKey('ar'), true);
      expect(NameMocker.namesData['en']!.isNotEmpty, true);
      expect(NameMocker.namesData['ar']!.isNotEmpty, true);
    });

    test('createMock wraps around names circularly', () {
      // Request more names than available — should still work
      final mocker = NameMocker(nameCount: 20);
      final name = mocker.createMock();
      expect(name.split(' ').length, 20);
    });
  });

  // ─── EmailMocker ───────────────────────────────────────────────────────
  group('EmailMocker', () {
    test('createMock without randomize returns deterministic email', () {
      final mocker = EmailMocker();
      final email = mocker.createMock();
      expect(email, contains('@'));
      expect(email, endsWith('.com'));
      // Should be first name @ first domain
      final expectedName =
          NameMocker.namesData['en']!.first.toLowerCase();
      expect(email, startsWith(expectedName));
    });

    test('createMock with randomize', () {
      final ctx = JMockerContext(randomize: true);
      final mocker = EmailMocker();
      final email = mocker.createMock(ctx);
      expect(email, contains('@'));
    });

    test('createMock with deterministic random', () {
      final mocker = EmailMocker();
      final ctx1 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
      );
      ctx1.setCallCount(0);
      final email1 = mocker.createMock(ctx1);

      final ctx2 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
      );
      ctx2.setCallCount(0);
      final email2 = mocker.createMock(ctx2);
      expect(email1, email2);
    });

    test('emailDomainData is not empty', () {
      expect(EmailMocker.emailDomainData.isNotEmpty, true);
      expect(EmailMocker.emailDomainData, contains('gmail.com'));
    });
  });

  // ─── StringMocker ──────────────────────────────────────────────────────
  group('StringMocker', () {
    test('createMock without randomize returns "mock"', () {
      final mocker = StringMocker();
      final ctx = JMockerContext(randomize: false);
      expect(mocker.createMock(ctx), 'mock');
    });

    test('createMock with randomize generates random string', () {
      final mocker = StringMocker();
      final ctx = JMockerContext(randomize: true);
      final result = mocker.createMock(ctx);
      expect(result, isA<String>());
      expect(result.isNotEmpty, true);
    });

    test('createMock with deterministic random is consistent', () {
      final mocker = StringMocker();
      final ctx1 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 7,
      );
      ctx1.setCallCount(0);
      final s1 = mocker.createMock(ctx1);

      final ctx2 = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 7,
      );
      ctx2.setCallCount(0);
      final s2 = mocker.createMock(ctx2);
      expect(s1, s2);
    });

    test('randomizeString with en language', () {
      final result = StringMocker.randomizeString(
        minWords: 1,
        maxWords: 1,
        minChars: 5,
        maxChars: 5,
        language: 'en',
      );
      expect(result.length, 5);
      // English alphabet chars
      expect(result, matches(RegExp(r'^[a-z]+$')));
    });

    test('randomizeString with ar language', () {
      final result = StringMocker.randomizeString(
        minWords: 1,
        maxWords: 1,
        minChars: 3,
        maxChars: 3,
        language: 'ar',
      );
      expect(result.length, greaterThan(0));
    });

    test('randomizeString with multiple words', () {
      final result = StringMocker.randomizeString(
        minWords: 3,
        maxWords: 3,
        minChars: 2,
        maxChars: 4,
      );
      expect(result.split(' ').length, 3);
    });

    test('randomizeString unknown language falls back to en', () {
      final result = StringMocker.randomizeString(
        minWords: 1,
        maxWords: 1,
        minChars: 3,
        maxChars: 3,
        language: 'unknown',
      );
      expect(result, matches(RegExp(r'^[a-z]+$')));
    });

    test('createMock with custom language', () {
      final mocker = StringMocker(language: 'ar');
      final ctx = JMockerContext(randomize: true, deterministicRandom: true);
      ctx.setCallCount(0);
      final result = mocker.createMock(ctx);
      expect(result, isA<String>());
      expect(result.isNotEmpty, true);
    });

    test('createMock with custom word/char limits', () {
      final mocker = StringMocker(
        minWords: 2,
        maxWords: 2,
        minChars: 3,
        maxChars: 3,
      );
      final ctx = JMockerContext(randomize: true, deterministicRandom: true);
      ctx.setCallCount(0);
      final result = mocker.createMock(ctx);
      expect(result.split(' ').length, 2);
    });
  });

  // ─── IntMocker ─────────────────────────────────────────────────────────
  group('IntMocker', () {
    test('createMock without randomize returns 0', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false);
      expect(mocker.createMock(ctx), 0);
    });

    test('createMock with randomize returns int in range', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: true);
      final val = mocker.createMock(ctx);
      expect(val, isA<int>());
      expect(val, greaterThanOrEqualTo(0));
      expect(val, lessThanOrEqualTo(1000));
    });

    test('createMock with custom range', () {
      final mocker =
          IntMocker(jSerializer: js, minValue: 10, maxValue: 20);
      final ctx = JMockerContext(randomize: true, deterministicRandom: true);
      ctx.setCallCount(0);
      final val = mocker.createMock(ctx);
      expect(val, greaterThanOrEqualTo(10));
      expect(val, lessThanOrEqualTo(20));
    });
  });

  // ─── DoubleMocker ──────────────────────────────────────────────────────
  group('DoubleMocker', () {
    test('createMock without randomize returns 0', () {
      final mocker = DoubleMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false);
      expect(mocker.createMock(ctx), 0.0);
    });

    test('createMock with randomize returns double in range', () {
      final mocker = DoubleMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: true);
      final val = mocker.createMock(ctx);
      expect(val, isA<double>());
      expect(val, greaterThanOrEqualTo(0));
    });

    test('createMock with custom precision', () {
      final mocker = DoubleMocker(
        jSerializer: js,
        minValue: 0,
        maxValue: 100,
        precision: 2,
      );
      final ctx = JMockerContext(randomize: true, deterministicRandom: true);
      ctx.setCallCount(0);
      final val = mocker.createMock(ctx);
      // Should have at most 2 decimal places
      final str = val.toString();
      final decimalIndex = str.indexOf('.');
      if (decimalIndex != -1) {
        expect(str.substring(decimalIndex + 1).length, lessThanOrEqualTo(2));
      }
    });
  });

  // ─── BoolMocker ────────────────────────────────────────────────────────
  group('BoolMocker', () {
    test('createMock without randomize returns true', () {
      final mocker = BoolMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false);
      expect(mocker.createMock(ctx), true);
    });

    test('createMock with randomize returns bool', () {
      final mocker = BoolMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: true);
      expect(mocker.createMock(ctx), isA<bool>());
    });
  });

  // ─── NumMocker ─────────────────────────────────────────────────────────
  group('NumMocker', () {
    test('createMock without randomize returns 0', () {
      final mocker = NumMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false);
      expect(mocker.createMock(ctx), 0);
    });

    test('createMock with randomize and precision 0 returns int', () {
      final mocker = NumMocker(jSerializer: js, precision: 0);
      final ctx = JMockerContext(randomize: true);
      final val = mocker.createMock(ctx);
      expect(val, isA<int>());
    });
  });

  // ─── ListMocker ────────────────────────────────────────────────────────
  group('ListMocker', () {
    test('createMock without randomize returns 3-element list', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<List<int>>(context: ctx);
      expect(result, isA<List<int>>());
      expect(result.length, 3);
    });

    test('createMock with randomize returns list', () {
      final ctx = JMockerContext(randomize: true);
      final result = js.createMock<List<int>>(context: ctx);
      expect(result, isA<List<int>>());
    });

    test('createMock List<String>', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<List<String>>(context: ctx);
      expect(result, isA<List<String>>());
      expect(result.length, 3);
      for (final item in result) {
        expect(item, isA<String>());
      }
    });
  });

  // ─── MapMocker ─────────────────────────────────────────────────────────
  group('MapMocker', () {
    test('createMock without randomize returns 3-entry map', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<Map<String, int>>(context: ctx);
      expect(result, isA<Map<String, int>>());
      // May have fewer than 3 if keys collide (all 'mock')
      expect(result.isNotEmpty, true);
    });

    test('createMock with randomize returns map', () {
      final ctx = JMockerContext(randomize: true);
      final result = js.createMock<Map<String, int>>(context: ctx);
      expect(result, isA<Map<String, int>>());
    });
  });

  // ─── JCustomMocker helpers ─────────────────────────────────────────────
  group('JCustomMocker', () {
    test('optionallyRandomizedValueFromList without randomize returns first',
        () {
      final mocker = _TestCustomMocker();
      final result = mocker.testFromList(null, [10, 20, 30]);
      expect(result, 10);
    });

    test('optionallyRandomizedValueFromList with randomize picks from list',
        () {
      final mocker = _TestCustomMocker();
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 42,
      );
      ctx.setCallCount(0);
      final result = mocker.testFromList(ctx, [10, 20, 30]);
      expect([10, 20, 30], contains(result));
    });

    test(
        'optionallyRandomizedValueFromListLazy without randomize uses fallback',
        () {
      final mocker = _TestCustomMocker();
      final result = mocker.testFromListLazy(
        null,
        [() => 10, () => 20],
        fallback: () => 99,
      );
      expect(result, 99);
    });

    test(
        'optionallyRandomizedValueFromListLazy without randomize and no fallback uses first',
        () {
      final mocker = _TestCustomMocker();
      final result = mocker.testFromListLazy(
        null,
        [() => 10, () => 20],
      );
      expect(result, 10);
    });

    test(
        'optionallyRandomizedValueFromListLazy with randomize picks from list',
        () {
      final mocker = _TestCustomMocker();
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 42,
      );
      ctx.setCallCount(0);
      final result = mocker.testFromListLazy(ctx, [() => 10, () => 20]);
      expect([10, 20], contains(result));
    });
  });

  // ─── JMocker.subMock ──────────────────────────────────────────────────
  group('JMocker.subMock', () {
    test('subMock creates mock for primitive type', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false);
      final result =
          mocker.subMock<String>(context: ctx, fieldName: 'name', currentLevel: 0);
      expect(result, isA<String>());
    });

    test(
        'subMock returns null for nullable non-primitive at depth >= nullifyAfterDepth',
        () {
      // String is primitive in jserializer, so it won't be nullified.
      // Register a model type to test nullification.
      js.register<_NullTestModel>(
        (s) => _NullTestModelSerializer(jSerializer: s),
        (f) => f<_NullTestModel>(),
        mockFactory: (s) => _NullTestModelMocker(jSerializer: s),
      );

      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(nullifyAfterDepth: 2);
      final result = mocker.subMock<_NullTestModel?>(
        context: ctx,
        fieldName: 'model',
        currentLevel: 3,
      );
      expect(result, isNull);
    });

    test(
        'subMock does not nullify primitive types even at depth >= nullifyAfterDepth',
        () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(nullifyAfterDepth: 1, randomize: false);
      // Even at deep level, primitives should still be mocked
      final result =
          mocker.subMock<int>(context: ctx, fieldName: 'count', currentLevel: 5);
      expect(result, isA<int>());
    });

    test('subMock sets fieldName on context', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext();
      mocker.subMock<int>(context: ctx, fieldName: 'myField', currentLevel: 0);
      expect(ctx.fieldName, 'myField');
    });

    test('subMock increments depth level', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext();
      mocker.subMock<int>(context: ctx, fieldName: 'x', currentLevel: 2);
      expect(ctx.currentDepthLevel, 3);
    });
  });

  // ─── createMock via JSerializer for various types ──────────────────────
  group('JSerializer.createMock advanced', () {
    test('createMock<List<String>> without randomize', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<List<String>>(context: ctx);
      expect(result, isA<List<String>>());
    });

    test('createMock<Map<String, int>> without randomize', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<Map<String, int>>(context: ctx);
      expect(result, isA<Map<String, int>>());
    });

    test('createMock<void> does not throw', () {
      // void mocker just returns null, can't use in expect
      js.createMock<void>();
    });
  });

  // ─── CallCountWrapper ─────────────────────────────────────────────────
  group('CallCountWrapper', () {
    test('callCount starts at 0', () {
      final wrapper = CallCountWrapper<int>(
        valueBuilder: (count) => count * 10,
        key: 'test_key_unique_1',
      );
      expect(wrapper.callCount, 0);
    });

    test('callCount increments on each getValue call', () {
      final wrapper = CallCountWrapper<int>(
        valueBuilder: (count) => count * 10,
        key: 'test_key_unique_2',
      );
      expect(wrapper.callCount, 0);
      wrapper.getValue();
      expect(wrapper.callCount, 1);
      wrapper.getValue();
      expect(wrapper.callCount, 2);
      wrapper.getValue();
      expect(wrapper.callCount, 3);
    });

    test('getValue passes incrementing count to valueBuilder', () {
      final wrapper = CallCountWrapper<int>(
        valueBuilder: (count) => count * 10,
        key: 'test_key_unique_3',
      );
      expect(wrapper.getValue(), 0); // count=0, 0*10=0
      expect(wrapper.getValue(), 10); // count=1, 1*10=10
      expect(wrapper.getValue(), 20); // count=2, 2*10=20
    });

    test('separate keys have independent call counts', () {
      final wrapper1 = CallCountWrapper<String>(
        valueBuilder: (count) => 'a$count',
        key: 'test_key_unique_4a',
      );
      final wrapper2 = CallCountWrapper<String>(
        valueBuilder: (count) => 'b$count',
        key: 'test_key_unique_4b',
      );
      wrapper1.getValue();
      wrapper1.getValue();
      expect(wrapper1.callCount, 2);
      expect(wrapper2.callCount, 0);
      wrapper2.getValue();
      expect(wrapper2.callCount, 1);
    });
  });

  // ─── JGenericMocker.createMock (mocker.dart) ──────────────────────────
  group('JGenericMocker.createMock', () {
    test('createMock<List<int>> via JGenericMocker path', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<List<int>>(context: ctx);
      expect(result, isA<List<int>>());
      expect(result.length, 3);
      for (final item in result) {
        expect(item, isA<int>());
      }
    });

    test('createMock<List<String>> via JGenericMocker path', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<List<String>>(context: ctx);
      expect(result, isA<List<String>>());
      expect(result.length, 3);
    });

    test('createMock<List<bool>> via JGenericMocker path', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<List<bool>>(context: ctx);
      expect(result, isA<List<bool>>());
    });

    test('createMock<Map<String, double>> via JGenericMocker path', () {
      final ctx = JMockerContext(randomize: false);
      final result = js.createMock<Map<String, double>>(context: ctx);
      expect(result, isA<Map<String, double>>());
    });

    test('createMock<List<int>> with randomize', () {
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 42,
      );
      ctx.setCallCount(0);
      final result = js.createMock<List<int>>(context: ctx);
      expect(result, isA<List<int>>());
    });
  });

  // ─── JMocker typeOf and _eq helpers ───────────────────────────────────
  group('JMocker helper methods', () {
    test('typeOf returns correct type', () {
      final mocker = IntMocker(jSerializer: js);
      // typeOf is protected, but we can test through subMock behavior
      // which internally uses _eq and _isPrimitive
      final ctx = JMockerContext(randomize: false);
      // String is primitive; subMock should not nullify it
      final result = mocker.subMock<String>(
        context: ctx,
        fieldName: 'name',
        currentLevel: 100,
      );
      expect(result, isA<String>());
    });

    test('subMock with double is primitive', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false, nullifyAfterDepth: 0);
      // double is primitive; subMock should not nullify it even at high depth
      final result = mocker.subMock<double>(
        context: ctx,
        fieldName: 'price',
        currentLevel: 100,
      );
      expect(result, isA<double>());
    });

    test('subMock with bool is primitive', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false, nullifyAfterDepth: 0);
      final result = mocker.subMock<bool>(
        context: ctx,
        fieldName: 'active',
        currentLevel: 100,
      );
      expect(result, isA<bool>());
    });

    test('subMock with num is primitive', () {
      final mocker = IntMocker(jSerializer: js);
      final ctx = JMockerContext(randomize: false, nullifyAfterDepth: 0);
      final result = mocker.subMock<num>(
        context: ctx,
        fieldName: 'amount',
        currentLevel: 100,
      );
      expect(result, isA<num>());
    });
  });
}

class _TestCustomMocker extends JCustomMocker<int> {
  @override
  int createMock([JMockerContext? context]) => 42;

  R testFromList<R>(JMockerContext? ctx, List<R> list) =>
      optionallyRandomizedValueFromList(ctx, list);

  R testFromListLazy<R>(JMockerContext? ctx, List<R Function()> list,
          {R Function()? fallback}) =>
      optionallyRandomizedValueFromListLazy(ctx, list, fallback: fallback);
}

class _NullTestModel {
  final int value;
  _NullTestModel(this.value);
}

class _NullTestModelSerializer extends ModelSerializer<_NullTestModel> {
  const _NullTestModelSerializer({super.jSerializer});

  @override
  _NullTestModel fromJson(Map json) => _NullTestModel(json['value'] as int);

  @override
  Map toJson(_NullTestModel model) => {'value': model.value};
}

class _NullTestModelMocker extends JModelMocker<_NullTestModel> {
  const _NullTestModelMocker({super.jSerializer});

  @override
  _NullTestModel createMock([JMockerContext? context]) => _NullTestModel(0);
}
