import 'package:jserializer/src/core/util/extension.dart';
import 'package:test/test.dart';

void main() {
  // ─── CircularTakeExtension ─────────────────────────────────────────────
  group('CircularTakeExtension', () {
    test('takeCircular with count less than length', () {
      final result = [1, 2, 3, 4, 5].takeCircular(3).toList();
      expect(result, [1, 2, 3]);
    });

    test('takeCircular with count equal to length', () {
      final result = [1, 2, 3].takeCircular(3).toList();
      expect(result, [1, 2, 3]);
    });

    test('takeCircular with count greater than length wraps around', () {
      final result = [1, 2, 3].takeCircular(5).toList();
      expect(result, [1, 2, 3, 1, 2]);
    });

    test('takeCircular with count 0', () {
      final result = [1, 2, 3].takeCircular(0).toList();
      expect(result, isEmpty);
    });

    test('takeCircular on empty iterable', () {
      final result = <int>[].takeCircular(3).toList();
      expect(result, isEmpty);
    });

    test('takeCircular with startIndex', () {
      final result = [1, 2, 3, 4, 5].takeCircular(3, startIndex: 2).toList();
      expect(result, [3, 4, 5]);
    });

    test('takeCircular with startIndex wraps around', () {
      final result = [1, 2, 3].takeCircular(4, startIndex: 1).toList();
      expect(result, [2, 3, 1, 2]);
    });

    test('takeCircular with negative startIndex', () {
      final result = [1, 2, 3, 4].takeCircular(2, startIndex: -1).toList();
      expect(result, [4, 1]);
    });

    test('takeCircular with large startIndex normalizes', () {
      final result = [1, 2, 3].takeCircular(2, startIndex: 10).toList();
      // 10 % 3 = 1
      expect(result, [2, 3]);
    });

    test('takeCircular with count 1', () {
      final result = [10, 20, 30].takeCircular(1).toList();
      expect(result, [10]);
    });
  });

  // ─── CircularIndexExtension ────────────────────────────────────────────
  group('CircularIndexExtension', () {
    test('circularAt with valid index', () {
      expect([10, 20, 30].circularAt(0), 10);
      expect([10, 20, 30].circularAt(1), 20);
      expect([10, 20, 30].circularAt(2), 30);
    });

    test('circularAt wraps around', () {
      expect([10, 20, 30].circularAt(3), 10);
      expect([10, 20, 30].circularAt(4), 20);
      expect([10, 20, 30].circularAt(6), 10);
    });

    test('circularAt with negative index', () {
      expect([10, 20, 30].circularAt(-1), 30);
      expect([10, 20, 30].circularAt(-2), 20);
      expect([10, 20, 30].circularAt(-3), 10);
    });

    test('circularAt on empty list returns null', () {
      expect(<int>[].circularAt(0), isNull);
      expect(<int>[].circularAt(5), isNull);
    });

    test('circularAt with large index', () {
      expect([1, 2].circularAt(100), 1);
      expect([1, 2].circularAt(101), 2);
    });
  });
}
