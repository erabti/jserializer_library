import 'package:jserializer/jserializer.dart';

class ListSerializer extends GenericSerializer<List, Iterable> {
  const ListSerializer({super.jSerializer});

  List<T> _decoder<T>(Iterable json) {
    if (json is List<T>) return json;
    if (json is! List) json = json.toList();

    return json.asMap().entries.map((e) {
      final index = e.key;
      final value = e.value;

      return safeLookup(
        call: () => jSerializer.fromJson<T>(value),
        jsonKey: 'index-of:[$index]',
      );
    }).toList();
  }

  @override
  Function get decoder => _decoder;

  @override
  List toJson(model) => model.map((e) => jSerializer.toJson(e)).toList();
}

class ListMocker extends JGenericMocker<List> {
  const ListMocker({super.jSerializer});

  @override
  Function get mocker => _mock;

  List<T> _mock<T>([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<List<T>>(
      randomizer: (random) => List.generate(
        random.nextInt(ctx.listMaxCount),
        (index) => jSerializer.createMock<T>(context: ctx),
      ),
      fallback: () => [
        jSerializer.createMock<T>(context: ctx),
        jSerializer.createMock<T>(context: ctx),
        jSerializer.createMock<T>(context: ctx),
      ],
    );
  }
}
