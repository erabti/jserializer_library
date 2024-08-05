import 'package:jserializer/jserializer.dart';
import 'package:type_plus/type_plus.dart';
export 'mocker_context.dart';
export 'call_count_wrapper.dart';
export 'mockers/j_mockers.dart';

abstract class JMocker<T> {
  const JMocker({JSerializerInterface? jSerializer})
      : _jSerializerInstance = jSerializer;

  final JSerializerInterface? _jSerializerInstance;

  JSerializerInterface get jSerializer => _jSerializerInstance ?? JSerializer.i;

  Function get mocker;
}

abstract class JCustomMocker<T> extends JMocker<T> {
  const JCustomMocker({super.jSerializer});

  T createMock([JMockerContext? context]);

  @override
  Function get mocker => createMock;

  R optionallyRandomizedValueFromList<R>(
    JMockerContext? context,
    List<R> list, {
    int? salt,
  }) {
    final ctx = context ?? JMockerContext();
    final randomized = ctx.randomize ?? false;
    if (!randomized) {
      return list.first;
    }

    return ctx.getRandomValueFromList(
      list,
      salt: salt ?? ctx.deterministicSeedSalt,
    );
  }

  R optionallyRandomizedValueFromListLazy<R>(
    JMockerContext? context,
    List<R Function()> list, {
    R Function()? fallback,
    int? salt,
  }) {
    final ctx = context ?? JMockerContext();
    final randomized = ctx.randomize ?? false;
    if (!randomized) {
      return fallback?.call() ?? list.first();
    }

    final itemBuilder = ctx.getRandomValueFromList(
      list,
      salt: salt ?? ctx.deterministicSeedSalt,
    );

    return itemBuilder();
  }
}

abstract class JModelMocker<T> extends JMocker<T> {
  const JModelMocker({super.jSerializer});

  T createMock([JMockerContext? context]);

  @override
  Function get mocker => createMock;
}

abstract class JGenericMocker<T> extends JMocker<T> {
  const JGenericMocker({super.jSerializer});

  M createMock<M extends T?>([JMockerContext? context]) {
    final result = mocker.callWith(
      typeArguments: M.args,
      parameters: [context],
    );

    try {
      return result as M;
    } catch (error) {
      throw LocationAwareJSerializerError(
        location: 'MockGenericSerializer: $this',
        error: error,
      );
    }
  }
}
