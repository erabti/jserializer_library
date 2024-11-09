import 'package:jserializer/jserializer.dart';
import 'package:type_plus/type_plus.dart';

abstract class Serializer<Model, Json> {
  const Serializer({
    JSerializerInterface? jSerializer,
  }) : _jSerializerInstance = jSerializer;

  final JSerializerInterface? _jSerializerInstance;

  JSerializerInterface get jSerializer => _jSerializerInstance ?? JSerializer.i;

  Type get modelType => Model;

  Type get jsonType => Json;

  String get modelTypeName => modelType.info.type;

  Function get decoder;

  Json toJson(Model model);

  String _getErrorMessage<T>(Object error, String? jsonName) {
    if (error is TypeError &&
        error.toString().contains("type 'Null' is not a subtype of type") &&
        jsonName != null) {
      return "Json missing the non-nullable key '$jsonName' of type '$T'. "
          "Please make sure that you include it in the passed json.";
    }

    return error.toString();
  }

  T safeLookup<T>({
    required T Function() call,
    String? jsonKey,
    String? fieldName,
    Type? modelType,
  }) {
    late final hideJsonKey = fieldName == null || jsonKey == fieldName;
    try {
      return call();
    } on FromJsonException catch (error, stack) {
      Error.throwWithStackTrace(
        FromJsonException<T>(
          fieldName: fieldName ?? jsonKey,
          jsonKey: hideJsonKey ? null : jsonKey,
          modelType: modelType ?? this.modelType,
          error: error,
        ),
        error.stackTrace ?? stack,
      );
    } catch (error, stacktrace) {
      Error.throwWithStackTrace(
        FromJsonException<T>(
          fieldName: fieldName ?? jsonKey,
          jsonKey: hideJsonKey ? null : jsonKey,
          modelType: modelType ?? this.modelType,
          message: '${_getErrorMessage<T>(error, jsonKey)}'
              '\nOriginal Error: $error',
          stackTrace: stacktrace,
        ),
        stacktrace,
      );
    }
  }

  T mapLookup<T>({
    json,
    required String jsonName,
    String? fieldName,
  }) {
    return safeLookup(
      call: () => json[jsonName],
      jsonKey: jsonName,
      fieldName: fieldName,
    );
  }
}

abstract class CustomModelSerializer<Model, Json>
    extends Serializer<Model, Json> {
  const CustomModelSerializer({super.jSerializer});

  @override
  Function get decoder => fromJson;

  Model fromJson(Json json);

  @override
  Json toJson(Model model);
}
