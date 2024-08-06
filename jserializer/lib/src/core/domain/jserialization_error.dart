import 'package:jserializer/jserializer.dart';

sealed class JSerializationException implements Exception {}

class FromJsonException<ExpectedType> implements JSerializationException {
  Type get expectedType => ExpectedType;

  const FromJsonException({
    required this.modelType,
    this.fieldName,
    this.message,
    this.stackTrace,
    this.jsonKey,
    this.error,
  });

  final String? message;
  final StackTrace? stackTrace;
  final String? jsonKey;
  final String? fieldName;
  final Type modelType;
  final Object? error;

  FromJsonException? get child {
    final error = this.error;
    if (error is FromJsonException) return error;
    return null;
  }

  List<FromJsonException> get _flatChildren {
    if (child == null) return [this];

    return [this, ...child!._flatChildren];
  }

  String get modelTypeStr =>
      modelType.toString().replaceAll(RegExp('<.*?>'), '');

  String get path => '$modelTypeStr${fieldName == null ? '' : '.$fieldName'}';

  String get exactLocation {
    final children = _flatChildren;
    final last = children.last;
    final path = children.map((e) => e.path).join('->');

    final jsonName = last.jsonKey;
    final jsonPart = jsonName == null ? '' : '[key: $jsonName]';
    final expectedType = last.expectedType;

    return '$path$jsonPart(expectedType: $expectedType)';
  }

  @override
  String toString() {
    try {
      final children = _flatChildren;
      final last = children.last;
      final theMessage = last.message ?? last.error?.toString();
      final messagePart = theMessage ?? '';
      final colonPart = theMessage == null ? '' : ':\n';
      final location = exactLocation;

      return 'JSerializationFromJsonError:\n'
          '$location'
          '$colonPart$messagePart';
    } catch (e) {
      return '';
    }
  }

  String toStringWithStack() {
    try {
      final children = _flatChildren;
      final last = children.last;
      final theMessage = last.message ?? last.error?.toString();
      final messagePart = theMessage ?? '';
      final location = exactLocation;
      final stackTrace = last.stackTrace;
      final stacktracePart = stackTrace == null ? '' : '\n$stackTrace';
      final colonPart = (theMessage == null && stackTrace == null) ? '' : ':\n';

      return 'JSerializationFromJsonError:\n'
          '$location'
          '$colonPart$messagePart$stacktracePart';
    } catch (e) {
      return '';
    }
  }
}

class UnregisteredSerializableTypeException extends JSerializationException {
  UnregisteredSerializableTypeException(this.type);

  final Type type;

  @override
  String toString() {
    return 'UnregisteredTypeError:\n'
        'The type [$type] is not registered!\n'
        'Did you forget to annotate it with @JSerializable()?\n\n'
        'In case you do not have access to $type you can define a custom '
        'serializer for it and annotate it with @CustomJSerializer().';
  }
}

class UnregisteredMockerTypeException extends JSerializationException {
  UnregisteredMockerTypeException(this.type);

  final Type type;

  @override
  String toString() {
    return 'UnregisteredTypeError:\n'
        'The type [$type] has no registered mocker!\n'
        'Did you forget to annotate it with @JSerializable()?\n\n'
        'In case you do not have access to $type you can define a custom '
        'mocker for it and annotate it with @JCustomMocker().';
  }
}

class NonGenericSerializerMisuseException extends JSerializationException {
  NonGenericSerializerMisuseException({
    required this.lookupType,
    required this.serializer,
  });

  final Type lookupType;
  final Serializer serializer;

  @override
  String toString() {
    return 'NonGenericSerializerMisuseError:\n'
        'The type [$lookupType] is generic and the serializer [$serializer] is not!\n'
        'Please use either GenericModelSerializer or GenericSerializer '
        'for the serializer.';
  }
}

class LocationAwareJSerializerException extends JSerializationException {
  LocationAwareJSerializerException(
      {required this.location, required this.error});

  final String location;
  final dynamic error;

  @override
  String toString() => 'JSerializerError:\n'
      'Error-Location: $location\n'
      '$error';
}
