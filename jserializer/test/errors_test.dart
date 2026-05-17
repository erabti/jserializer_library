import 'package:jserializer/jserializer.dart';
import 'package:test/test.dart';

void main() {
  // ─── FromJsonException ─────────────────────────────────────────────────
  group('FromJsonException', () {
    test('basic toString', () {
      final e = FromJsonException<int>(
        modelType: String,
        fieldName: 'age',
        message: 'Expected int',
      );
      final str = e.toString();
      expect(str, contains('JSerializationFromJsonError'));
      expect(str, contains('age'));
      expect(str, contains('Expected int'));
    });

    test('expectedType returns generic type', () {
      final e = FromJsonException<double>(modelType: String);
      expect(e.expectedType, double);
    });

    test('modelTypeStr strips generic args', () {
      final e = FromJsonException<int>(modelType: List<String>);
      expect(e.modelTypeStr, 'List');
    });

    test('path with fieldName', () {
      final e = FromJsonException<int>(
        modelType: String,
        fieldName: 'name',
      );
      expect(e.path, 'String.name');
    });

    test('path without fieldName', () {
      final e = FromJsonException<int>(modelType: String);
      expect(e.path, 'String');
    });

    test('child returns nested FromJsonException', () {
      final inner = FromJsonException<int>(
        modelType: int,
        fieldName: 'value',
        message: 'inner error',
      );
      final outer = FromJsonException<String>(
        modelType: String,
        fieldName: 'data',
        error: inner,
      );
      expect(outer.child, same(inner));
    });

    test('child returns null for non-FromJsonException error', () {
      final e = FromJsonException<int>(
        modelType: String,
        error: ArgumentError('bad'),
      );
      expect(e.child, isNull);
    });

    test('exactLocation traces full path', () {
      final inner = FromJsonException<int>(
        modelType: int,
        fieldName: 'id',
        jsonKey: 'user_id',
      );
      final outer = FromJsonException<Map>(
        modelType: String,
        fieldName: 'user',
        error: inner,
      );
      final location = outer.exactLocation;
      expect(location, contains('String.user'));
      expect(location, contains('int.id'));
      expect(location, contains('[key: user_id]'));
      expect(location, contains('expectedType: int'));
    });

    test('exactLocation includes jsonKey even when same as fieldName', () {
      // Note: jsonKey hiding logic is in Serializer.safeLookup, not FromJsonException
      final e = FromJsonException<int>(
        modelType: String,
        fieldName: 'name',
        jsonKey: 'name',
      );
      expect(e.exactLocation, contains('[key: name]'));
    });

    test('exactLocation omits jsonKey when null', () {
      final e = FromJsonException<int>(
        modelType: String,
        fieldName: 'name',
        jsonKey: null,
      );
      expect(e.exactLocation, isNot(contains('[key:')));
    });

    test('exactLocation shows jsonKey when different from fieldName', () {
      final e = FromJsonException<int>(
        modelType: String,
        fieldName: 'userName',
        jsonKey: 'user_name',
      );
      expect(e.exactLocation, contains('[key: user_name]'));
    });

    test('toString with nested errors', () {
      final inner = FromJsonException<int>(
        modelType: int,
        fieldName: 'count',
        message: 'Not a number',
      );
      final outer = FromJsonException<Map>(
        modelType: String,
        fieldName: 'data',
        error: inner,
      );
      final str = outer.toString();
      expect(str, contains('JSerializationFromJsonError'));
      expect(str, contains('Not a number'));
    });

    test('toStringWithStack includes stack trace', () {
      final stack = StackTrace.current;
      final e = FromJsonException<int>(
        modelType: String,
        fieldName: 'x',
        message: 'bad',
        stackTrace: stack,
      );
      expect(e.toStringWithStack(), contains('bad'));
    });

    test('toString with null message and null error', () {
      final e = FromJsonException<int>(modelType: String);
      // Should not throw
      final str = e.toString();
      expect(str, contains('JSerializationFromJsonError'));
    });
  });

  // ─── UnregisteredSerializableTypeException ──────────────────────────────
  group('UnregisteredSerializableTypeException', () {
    test('toString contains type name', () {
      final e = UnregisteredSerializableTypeException(DateTime);
      final str = e.toString();
      expect(str, contains('DateTime'));
      expect(str, contains('is not registered'));
      expect(str, contains('@JSerializable()'));
    });

    test('implements JSerializationException', () {
      final e = UnregisteredSerializableTypeException(String);
      expect(e, isA<JSerializationException>());
    });
  });

  // ─── UnregisteredMockerTypeException ────────────────────────────────────
  group('UnregisteredMockerTypeException', () {
    test('toString contains type name', () {
      final e = UnregisteredMockerTypeException(DateTime);
      final str = e.toString();
      expect(str, contains('DateTime'));
      expect(str, contains('has no registered mocker'));
    });

    test('implements JSerializationException', () {
      final e = UnregisteredMockerTypeException(String);
      expect(e, isA<JSerializationException>());
    });
  });

  // ─── LocationAwareJSerializerException ──────────────────────────────────
  group('LocationAwareJSerializerException', () {
    test('toString contains location and error', () {
      final e = LocationAwareJSerializerException(
        location: 'GenericSerializer: ListSerializer',
        error: 'cast failed',
      );
      final str = e.toString();
      expect(str, contains('GenericSerializer: ListSerializer'));
      expect(str, contains('cast failed'));
    });
  });

  // ─── JSerializerErrorHandler ────────────────────────────────────────────
  group('JSerializerErrorHandler', () {
    test('throwValue creates JSerializerErrorHandlerThrow', () {
      const handler = JSerializerErrorHandler<int>.throwValue(
        error: FormatException('bad'),
      );
      expect(handler, isA<JSerializerErrorHandlerThrow<int>>());
      expect(
        (handler as JSerializerErrorHandlerThrow).error,
        isA<FormatException>(),
      );
    });

    test('returnValue creates JSerializerErrorHandlerHandle', () {
      final handler = JSerializerErrorHandler<int>.returnValue(() => 42);
      expect(handler, isA<JSerializerErrorHandlerHandle<int>>());
      expect(
        (handler as JSerializerErrorHandlerHandle<int>).callback(),
        42,
      );
    });
  });
}
