import 'package:jserializer/jserializer.dart';
import 'package:test/test.dart';

void main() {
  // ─── JIntAdapter ───────────────────────────────────────────────────────
  group('JIntAdapter', () {
    const adapter = JIntAdapter();

    test('fromJson returns int directly', () {
      expect(adapter.fromJson(42, {}), 42);
    });

    test('fromJson converts double to int', () {
      expect(adapter.fromJson(3.7, {}), 3);
    });

    test('fromJson parses string to int', () {
      expect(adapter.fromJson('123', {}), 123);
    });

    test('fromJson throws on string with decimal (int.tryParse fails)', () {
      // JIntAdapter uses int.tryParse which can't parse '9.8'
      expect(() => adapter.fromJson('9.8', {}), throwsA(isA<TypeError>()));
    });

    test('fromJson throws on null without fallback', () {
      expect(() => adapter.fromJson(null, {}), throwsA(isA<TypeError>()));
    });

    test('fromJson returns fallback on null', () {
      const adapterFb = JIntAdapter(fallback: 99);
      expect(adapterFb.fromJson(null, {}), 99);
    });

    test('fromJson returns fallback on unparseable string', () {
      const adapterFb = JIntAdapter(fallback: -1);
      expect(adapterFb.fromJson('abc', {}), -1);
    });

    test('fromJson throws on unparseable string without fallback', () {
      expect(() => adapter.fromJson('abc', {}), throwsA(isA<TypeError>()));
    });

    test('fromJson with handleBool converts true to 1', () {
      const adapterBool = JIntAdapter(handleBool: true);
      expect(adapterBool.fromJson(true, {}), 1);
    });

    test('fromJson with handleBool converts false to 0', () {
      const adapterBool = JIntAdapter(handleBool: true);
      expect(adapterBool.fromJson(false, {}), 0);
    });

    test('fromJson without handleBool throws on bool', () {
      // handleBool defaults to false; bool falls through to string parsing
      // which can't parse 'true' as int, so it throws
      expect(() => adapter.fromJson(true, {}), throwsA(isA<TypeError>()));
    });

    test('toJson returns the value unchanged', () {
      expect(adapter.toJson(42), 42);
      expect(adapter.toJson(null), isNull);
    });
  });

  // ─── JIntNullableAdapter ───────────────────────────────────────────────
  group('JIntNullableAdapter', () {
    const adapter = JIntNullableAdapter();

    test('fromJson returns int directly', () {
      expect(adapter.fromJson(10, {}), 10);
    });

    test('fromJson converts double to int', () {
      expect(adapter.fromJson(5.9, {}), 5);
    });

    test('fromJson returns null for null input', () {
      // Without fallback, null input on nullable adapter should throw
      // because _throwError is called, but nullable T means fallback path
      // Actually, for nullable adapter: if json is T (int?) then null is int?,
      // so it should return null
      expect(adapter.fromJson(null, {}), isNull);
    });

    test('fromJson with fallback returns fallback for null', () {
      const adapterFb = JIntNullableAdapter(fallback: 0);
      expect(adapterFb.fromJson(null, {}), 0);
    });

    test('fromJson parses string', () {
      expect(adapter.fromJson('7', {}), 7);
    });

    test('toJson returns value unchanged', () {
      expect(adapter.toJson(5), 5);
      expect(adapter.toJson(null), isNull);
    });
  });

  // ─── JDoubleAdapter ────────────────────────────────────────────────────
  group('JDoubleAdapter', () {
    const adapter = JDoubleAdapter();

    test('fromJson returns double directly', () {
      expect(adapter.fromJson(3.14, {}), 3.14);
    });

    test('fromJson converts int to double', () {
      expect(adapter.fromJson(5, {}), 5.0);
      expect(adapter.fromJson(5, {}), isA<double>());
    });

    test('fromJson parses string to double', () {
      expect(adapter.fromJson('2.5', {}), 2.5);
    });

    test('fromJson throws on null without fallback', () {
      expect(() => adapter.fromJson(null, {}), throwsA(isA<TypeError>()));
    });

    test('fromJson returns fallback on null', () {
      const adapterFb = JDoubleAdapter(fallback: 0.0);
      expect(adapterFb.fromJson(null, {}), 0.0);
    });

    test('fromJson returns fallback on unparseable string', () {
      const adapterFb = JDoubleAdapter(fallback: -1.0);
      expect(adapterFb.fromJson('xyz', {}), -1.0);
    });

    test('fromJson throws on unparseable string without fallback', () {
      expect(() => adapter.fromJson('xyz', {}), throwsA(isA<TypeError>()));
    });

    test('fromJson with handleBool converts true to 1.0', () {
      const adapterBool = JDoubleAdapter(handleBool: true);
      expect(adapterBool.fromJson(true, {}), 1.0);
    });

    test('fromJson with handleBool converts false to 0.0', () {
      const adapterBool = JDoubleAdapter(handleBool: true);
      expect(adapterBool.fromJson(false, {}), 0.0);
    });

    test('toJson returns value unchanged', () {
      expect(adapter.toJson(3.14), 3.14);
    });
  });

  // ─── JDoubleNullableAdapter ────────────────────────────────────────────
  group('JDoubleNullableAdapter', () {
    const adapter = JDoubleNullableAdapter();

    test('fromJson returns double', () {
      expect(adapter.fromJson(1.5, {}), 1.5);
    });

    test('fromJson returns null for null input', () {
      expect(adapter.fromJson(null, {}), isNull);
    });

    test('fromJson with fallback returns fallback for null', () {
      const adapterFb = JDoubleNullableAdapter(fallback: 0.0);
      expect(adapterFb.fromJson(null, {}), 0.0);
    });

    test('fromJson converts int to double', () {
      expect(adapter.fromJson(7, {}), 7.0);
    });

    test('toJson returns value unchanged', () {
      expect(adapter.toJson(2.0), 2.0);
      expect(adapter.toJson(null), isNull);
    });
  });

  // ─── JNumAdapter ───────────────────────────────────────────────────────
  group('JNumAdapter', () {
    const adapter = JNumAdapter();

    test('fromJson returns int directly', () {
      expect(adapter.fromJson(42, {}), 42);
    });

    test('fromJson returns double directly', () {
      expect(adapter.fromJson(3.14, {}), 3.14);
    });

    test('fromJson parses string to int', () {
      expect(adapter.fromJson('55', {}), 55);
    });

    test('fromJson throws on null without fallback', () {
      expect(() => adapter.fromJson(null, {}), throwsA(isA<TypeError>()));
    });

    test('fromJson returns fallback on null', () {
      const adapterFb = JNumAdapter(fallback: 0);
      expect(adapterFb.fromJson(null, {}), 0);
    });

    test('fromJson with handleBool converts true to 1', () {
      const adapterBool = JNumAdapter(handleBool: true);
      expect(adapterBool.fromJson(true, {}), 1);
    });

    test('fromJson with handleBool converts false to 0', () {
      const adapterBool = JNumAdapter(handleBool: true);
      expect(adapterBool.fromJson(false, {}), 0);
    });

    test('toJson returns value unchanged', () {
      expect(adapter.toJson(42), 42);
      expect(adapter.toJson(3.14), 3.14);
    });
  });

  // ─── JNumNullableAdapter ───────────────────────────────────────────────
  group('JNumNullableAdapter', () {
    const adapter = JNumNullableAdapter();

    test('fromJson returns num directly', () {
      expect(adapter.fromJson(42, {}), 42);
      expect(adapter.fromJson(3.14, {}), 3.14);
    });

    test('fromJson returns null for null input', () {
      expect(adapter.fromJson(null, {}), isNull);
    });

    test('fromJson with fallback', () {
      const adapterFb = JNumNullableAdapter(fallback: -1);
      expect(adapterFb.fromJson(null, {}), -1);
    });

    test('toJson returns value unchanged', () {
      expect(adapter.toJson(42), 42);
      expect(adapter.toJson(null), isNull);
    });
  });

  // ─── JStringAdapter ────────────────────────────────────────────────────
  group('JStringAdapter', () {
    const adapter = JStringAdapter();

    test('fromJson returns string directly', () {
      expect(adapter.fromJson('hello', {}), 'hello');
    });

    test('fromJson converts int to string', () {
      expect(adapter.fromJson(42, {}), '42');
    });

    test('fromJson converts double to string', () {
      expect(adapter.fromJson(3.14, {}), '3.14');
    });

    test('fromJson converts bool to string', () {
      expect(adapter.fromJson(true, {}), 'true');
      expect(adapter.fromJson(false, {}), 'false');
    });

    test('fromJson converts null to string', () {
      expect(adapter.fromJson(null, {}), 'null');
    });

    test('toJson returns string unchanged', () {
      expect(adapter.toJson('hello'), 'hello');
      expect(adapter.toJson(null), isNull);
    });
  });

  // ─── JStringNullableAdapter ────────────────────────────────────────────
  group('JStringNullableAdapter', () {
    const adapter = JStringNullableAdapter();

    test('fromJson returns string directly', () {
      expect(adapter.fromJson('hello', {}), 'hello');
    });

    test('fromJson converts int to string', () {
      expect(adapter.fromJson(42, {}), '42');
    });

    test('fromJson returns null for null input', () {
      expect(adapter.fromJson(null, {}), isNull);
    });

    test('toJson returns value unchanged', () {
      expect(adapter.toJson('abc'), 'abc');
      expect(adapter.toJson(null), isNull);
    });
  });

  // ─── JNumToBoolAdapter ─────────────────────────────────────────────────
  group('JNumToBoolAdapter', () {
    const adapter = JNumToBoolAdapter();

    test('fromJson converts 0 to false', () {
      expect(adapter.fromJson(0, {}), false);
    });

    test('fromJson converts 1 to true', () {
      expect(adapter.fromJson(1, {}), true);
    });

    test('fromJson converts 0.0 to false', () {
      expect(adapter.fromJson(0.0, {}), false);
    });

    test('fromJson converts 1.0 to true', () {
      expect(adapter.fromJson(1.0, {}), true);
    });

    test('fromJson throws on other values without fallback', () {
      expect(
        () => adapter.fromJson(2, {}),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson returns fallback on other values', () {
      const adapterFb = JNumToBoolAdapter(fallback: false);
      expect(adapterFb.fromJson(99, {}), false);
    });

    test('fromJson returns fallback for null', () {
      const adapterFb = JNumToBoolAdapter(fallback: true);
      // null.toDouble() => n is null => not 0.0, not 1.0 => fallback
      expect(adapterFb.fromJson(null, {}), true);
    });

    test('toJson converts true to 1', () {
      expect(adapter.toJson(true), 1);
    });

    test('toJson converts false to 0', () {
      expect(adapter.toJson(false), 0);
    });

    test('toJson returns null for null input', () {
      expect(adapter.toJson(null), isNull);
    });
  });

  // ─── JNumNullableAdapter _isEqual path ─────────────────────────────────
  group('JNumNullableAdapter _isEqual with double input', () {
    const adapter = JNumNullableAdapter();

    test('fromJson with double value returns the double as num?', () {
      final result = adapter.fromJson(3.14, {});
      expect(result, 3.14);
      expect(result, isA<double>());
    });

    test('fromJson with int value returns the int as num?', () {
      final result = adapter.fromJson(42, {});
      expect(result, 42);
      expect(result, isA<int>());
    });

    test('fromJson parses string to num', () {
      expect(adapter.fromJson('99', {}), 99);
    });

    test('fromJson with handleBool on nullable num', () {
      const adapterBool = JNumNullableAdapter(handleBool: true);
      expect(adapterBool.fromJson(true, {}), 1);
      expect(adapterBool.fromJson(false, {}), 0);
    });
  });

  // ─── JIntNullableAdapter _isEqual path with double ───────────────────
  group('JIntNullableAdapter _isEqual with double input', () {
    const adapter = JIntNullableAdapter();

    test('fromJson converts double to int', () {
      final result = adapter.fromJson(7.9, {});
      expect(result, 7);
      expect(result, isA<int>());
    });

    test('fromJson with handleBool on nullable int', () {
      const adapterBool = JIntNullableAdapter(handleBool: true);
      expect(adapterBool.fromJson(true, {}), 1);
      expect(adapterBool.fromJson(false, {}), 0);
    });
  });

  // ─── JDoubleNullableAdapter _isEqual path with int ───────────────────
  group('JDoubleNullableAdapter _isEqual with int input', () {
    const adapter = JDoubleNullableAdapter();

    test('fromJson converts int to double', () {
      final result = adapter.fromJson(5, {});
      expect(result, 5.0);
      expect(result, isA<double>());
    });

    test('fromJson with handleBool on nullable double', () {
      const adapterBool = JDoubleNullableAdapter(handleBool: true);
      expect(adapterBool.fromJson(true, {}), 1.0);
      expect(adapterBool.fromJson(false, {}), 0.0);
    });

    test('fromJson parses string', () {
      expect(adapter.fromJson('3.14', {}), 3.14);
    });
  });

  // ─── Number adapter handleBool edge cases ────────────────────────────
  group('Number adapter handleBool edge cases', () {
    test('JNumAdapter handleBool with false returns 0 (isNum path)', () {
      const adapter = JNumAdapter(handleBool: true);
      expect(adapter.fromJson(false, {}), 0);
    });

    test('JDoubleAdapter handleBool true returns 1.0 (isDouble path)', () {
      const adapter = JDoubleAdapter(handleBool: true);
      expect(adapter.fromJson(true, {}), 1.0);
    });

    test('JDoubleAdapter handleBool false returns 0.0', () {
      const adapter = JDoubleAdapter(handleBool: true);
      expect(adapter.fromJson(false, {}), 0.0);
    });

    test('JIntAdapter handleBool hits isInt path (not isNum)', () {
      const adapter = JIntAdapter(handleBool: true);
      expect(adapter.fromJson(true, {}), 1);
      expect(adapter.fromJson(false, {}), 0);
    });
  });

  // ─── JNumToBoolNullableAdapter ─────────────────────────────────────────
  group('JNumToBoolNullableAdapter', () {
    const adapter = JNumToBoolNullableAdapter();

    test('fromJson converts 0 to false', () {
      expect(adapter.fromJson(0, {}), false);
    });

    test('fromJson converts 1 to true', () {
      expect(adapter.fromJson(1, {}), true);
    });

    test('fromJson returns null for other values without fallback', () {
      expect(adapter.fromJson(5, {}), isNull);
    });

    test('fromJson returns null for null without fallback', () {
      expect(adapter.fromJson(null, {}), isNull);
    });

    test('fromJson returns fallback for other values', () {
      const adapterFb = JNumToBoolNullableAdapter(fallback: false);
      expect(adapterFb.fromJson(99, {}), false);
    });

    test('toJson converts true to 1', () {
      expect(adapter.toJson(true), 1);
    });

    test('toJson converts false to 0', () {
      expect(adapter.toJson(false), 0);
    });

    test('toJson returns null for null', () {
      expect(adapter.toJson(null), isNull);
    });
  });
}
