import 'package:jserializer/jserializer.dart';

class ListSerializer extends GenericSerializer<List, Iterable> {
  const ListSerializer({super.jSerializer});

  List<T> _decoder<T>(Iterable json) {
    if (json is List<T>) return json;
    final list = json is List ? json : json.toList();

    if (T == String ||
        T == int ||
        T == double ||
        T == num ||
        T == bool ||
        T == dynamic) {
      return list.cast<T>();
    }

    return List<T>.generate(
        list.length, (i) => jSerializer.fromJson<T>(list[i]));
  }

  @override
  Function get decoder => _decoder;

  @override
  List toJson(model) {
    if (model is List<String> || model is List<num> || model is List<bool>) {
      return model;
    }
    return model.map((e) => jSerializer.toJson(e)).toList();
  }
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
