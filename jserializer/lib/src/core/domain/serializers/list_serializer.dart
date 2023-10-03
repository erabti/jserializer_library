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
