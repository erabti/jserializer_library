import 'dart:math';

import 'package:jserializer/jserializer.dart';
import 'package:test/test.dart';

void main() {
  group('JMockerContext', () {
    test('default values', () {
      final ctx = JMockerContext();
      expect(ctx.randomize, isNull);
      expect(ctx.deterministicRandom, isNull);
      expect(ctx.nullifyAfterDepth, isNull);
      expect(ctx.callCount, isNull);
      expect(ctx.currentDepthLevel, 0);
      expect(ctx.fieldName, isNull);
      expect(ctx.deterministicSeedSalt, isNull);
      expect(ctx.options, isNull);
    });

    test('default option accessors', () {
      final ctx = JMockerContext();
      expect(ctx.language, 'en');
      expect(ctx.numMaxValue, 1000);
      expect(ctx.numMinValue, 0);
      expect(ctx.numMaxInclusive, true);
      expect(ctx.numPrecision, isNull);
      expect(ctx.stringMaxWords, 5);
      expect(ctx.stringMinWords, 1);
      expect(ctx.stringMaxChars, 10);
      expect(ctx.stringMinChars, 1);
      expect(ctx.stringLanguage, 'en');
      expect(ctx.listMaxCount, 8);
      expect(ctx.mapMaxCount, 8);
    });

    test('option accessors with custom options', () {
      final ctx = JMockerContext(
        options: {
          'language': 'ar',
          'num': {'maxValue': 500, 'minValue': 10, 'maxInclusive': false, 'precision': 2},
          'string': {
            'maxWords': 3,
            'minWords': 2,
            'maxChar': 5,
            'minChars': 3,
            'language': 'ar',
          },
          'list': {'maxCount': 4},
          'map': {'maxCount': 2},
        },
      );
      expect(ctx.language, 'ar');
      expect(ctx.numMaxValue, 500);
      expect(ctx.numMinValue, 10);
      expect(ctx.numMaxInclusive, false);
      expect(ctx.numPrecision, 2);
      expect(ctx.stringMaxWords, 3);
      expect(ctx.stringMinWords, 2);
      expect(ctx.stringMaxChars, 5);
      expect(ctx.stringMinChars, 3);
      expect(ctx.stringLanguage, 'ar');
      expect(ctx.listMaxCount, 4);
      expect(ctx.mapMaxCount, 2);
    });

    test('setCallCount and callCount', () {
      final ctx = JMockerContext();
      expect(ctx.callCount, isNull);
      ctx.setCallCount(5);
      expect(ctx.callCount, 5);
    });

    test('setCallCount ignores null', () {
      final ctx = JMockerContext();
      ctx.setCallCount(3);
      ctx.setCallCount(null);
      expect(ctx.callCount, 3);
    });

    test('callCountAsIndex', () {
      final ctx = JMockerContext();
      expect(ctx.callCountAsIndex, isNull);

      ctx.setCallCount(0);
      expect(ctx.callCountAsIndex, 0);

      ctx.setCallCount(1);
      expect(ctx.callCountAsIndex, 0);

      ctx.setCallCount(5);
      expect(ctx.callCountAsIndex, 4);
    });

    test('setDepthLevel and currentDepthLevel', () {
      final ctx = JMockerContext();
      expect(ctx.currentDepthLevel, 0);
      ctx.setDepthLevel(3);
      expect(ctx.currentDepthLevel, 3);
    });

    test('setFieldName and fieldName', () {
      final ctx = JMockerContext();
      expect(ctx.fieldName, isNull);
      ctx.setFieldName('myField');
      expect(ctx.fieldName, 'myField');
    });

    test('setFieldName ignores null', () {
      final ctx = JMockerContext();
      ctx.setFieldName('first');
      ctx.setFieldName(null);
      expect(ctx.fieldName, 'first');
    });

    test('generateSeed', () {
      final ctx = JMockerContext(deterministicSeedSalt: 10);
      ctx.setCallCount(5);
      expect(ctx.generateSeed(), 15); // callCount + deterministicSeedSalt
      expect(ctx.generateSeed(salt: 3), 8); // callCount + salt
    });

    test('generateSeed with no callCount', () {
      final ctx = JMockerContext();
      expect(ctx.generateSeed(), 0);
      expect(ctx.generateSeed(salt: 7), 7);
    });

    test('generateRandom returns deterministic Random when configured', () {
      final ctx = JMockerContext(deterministicRandom: true);
      ctx.setCallCount(42);
      final r1 = ctx.generateRandom();
      final r2 = ctx.generateRandom();
      // Same seed should produce same sequence
      expect(r1.nextInt(1000), r2.nextInt(1000));
    });

    test('generateRandom returns non-deterministic Random when not configured',
        () {
      final ctx = JMockerContext(deterministicRandom: false);
      // Just verify it doesn't throw
      final r = ctx.generateRandom();
      expect(r, isA<Random>());
    });

    test('getRandomValueFromList returns value from list', () {
      final ctx = JMockerContext(deterministicRandom: true);
      ctx.setCallCount(0);
      final list = [1, 2, 3, 4, 5];
      final value = ctx.getRandomValueFromList(list);
      expect(list, contains(value));
    });

    test('getValue with randomize true uses randomizer', () {
      final ctx = JMockerContext(randomize: true, deterministicRandom: true);
      ctx.setCallCount(0);

      final value = ctx.getValue<int>(
        randomizer: (random) => random.nextInt(100),
        fallback: () => -1,
      );
      expect(value, greaterThanOrEqualTo(0));
      expect(value, lessThan(100));
    });

    test('getValue with randomize false uses fallback', () {
      final ctx = JMockerContext(randomize: false);
      final value = ctx.getValue<int>(
        randomizer: (random) => random.nextInt(100),
        fallback: () => 42,
      );
      expect(value, 42);
    });

    test('getValue with randomize null uses fallback', () {
      final ctx = JMockerContext();
      final value = ctx.getValue<int>(
        randomizer: (random) => random.nextInt(100),
        fallback: () => 99,
      );
      expect(value, 99);
    });

    test('getValue with randomizer returning null uses fallback', () {
      final ctx = JMockerContext(randomize: true);
      final value = ctx.getValue<int>(
        randomizer: (random) => null,
        fallback: () => 7,
      );
      expect(value, 7);
    });

    test('copyWith preserves values', () {
      final ctx = JMockerContext(
        randomize: true,
        deterministicRandom: true,
        deterministicSeedSalt: 5,
        nullifyAfterDepth: 4,
        options: {'language': 'ar'},
      );
      ctx.setFieldName('myField');
      ctx.setDepthLevel(2);

      final copy = ctx.copyWith();
      expect(copy.randomize, true);
      expect(copy.deterministicRandom, true);
      expect(copy.deterministicSeedSalt, 5);
      expect(copy.nullifyAfterDepth, 4);
      expect(copy.fieldName, 'myField');
      expect(copy.currentDepthLevel, 2);
      expect(copy.language, 'ar');
    });

    test('copyWith overrides values', () {
      final ctx = JMockerContext(randomize: true, deterministicRandom: false);
      final copy = ctx.copyWith(randomize: false, deterministicRandom: true);
      expect(copy.randomize, false);
      expect(copy.deterministicRandom, true);
    });
  });
}
