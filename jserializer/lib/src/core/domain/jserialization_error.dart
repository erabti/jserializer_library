import 'package:jserializer/jserializer.dart';

sealed class JserializationError implements Exception {}

class LookupError<ExpectedType> implements JserializationError {
  Type get expectedType => ExpectedType;

  const LookupError({
    required this.fieldName,
    required this.modelType,
    this.message,
    this.stackTrace,
    this.jsonKey,
    this.child,
  });

  final String? message;
  final StackTrace? stackTrace;
  final String? jsonKey;
  final String fieldName;
  final Type modelType;

  final LookupError? child;

  List<LookupError> get _flatChildren {
    if (child == null) return [this];

    return [this, ...child!._flatChildren];
  }

  String get modelTypeStr =>
      modelType.toString().replaceAll(RegExp('<.*?>'), '');

  String get path => '$modelTypeStr.$fieldName';

  String get exactLocation {
    final children = _flatChildren;
    final last = children.last;
    final path = children.map((e) => e.path).join('->');

    final jsonName = last.jsonKey;
    final jsonPart = jsonName == null ? '' : '[key: $jsonName]';
    final expectedType = last.expectedType;

    return '$path$jsonPart(expectedType: $expectedType)';
  }

  String toStringWithoutStack() {
    try {
      final children = _flatChildren;
      final last = children.last;
      final theMessage = last.message;
      final messagePart = theMessage ?? '';
      final colonPart = theMessage == null ? '' : ':\n';
      final location = exactLocation;

      return 'JSerializationError:\n'
          '$location'
          '$colonPart$messagePart';
    } catch (e) {
      return '';
    }
  }

  @override
  String toString() {
    try {
      final children = _flatChildren;
      final last = children.last;
      final theMessage = last.message;
      final messagePart = theMessage ?? '';
      final location = exactLocation;
      final stackTrace = last.stackTrace;
      final stacktracePart = stackTrace == null ? '' : '\n$stackTrace';
      final colonPart = (theMessage == null && stackTrace == null) ? '' : ':\n';

      return 'JSerializationError:\n'
          '$location'
          '$colonPart$messagePart$stacktracePart';
    } catch (e) {
      return '';
    }
  }
}

class UnregisteredTypeError implements JserializationError {
  const UnregisteredTypeError(this.type);

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

class NonGenericSerializerMisuseError implements JserializationError {
  const NonGenericSerializerMisuseError({
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

class LocationAwareJSerializerError implements JserializationError {
  const LocationAwareJSerializerError({
    required this.location,
    required this.error,
  });

  final String location;
  final dynamic error;

  @override
  String toString() => 'JSerializerError:\n'
      'Error-Location: $location\n'
      '$error';
}
