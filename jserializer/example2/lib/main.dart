import 'package:example2/jserializer.dart';

void main() {
  initializeJSerializer();

  // JSerializer.i.fromJsonErrorHandler = (arg) {
  //   if (arg.doesTypeAcceptNull) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => null,
  //     );
  //   }
  //
  //   final isInt = arg.doesTypeEqualsTypeOf<int>();
  //   final isNum = arg.doesTypeEqualsTypeOf<num>();
  //   final isDouble = arg.doesTypeEqualsTypeOf<double>() ||
  //       arg.doesTypeEqualsTypeOf<double?>();
  //
  //   if (isInt || isNum) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => 0,
  //     );
  //   }
  //   if (isDouble) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => 0.0,
  //     );
  //   }
  //
  //   final isStr = arg.doesTypeEqualsTypeOf<String>();
  //   if (isStr) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => '',
  //     );
  //   }
  //
  //   final isBool = arg.doesTypeEqualsTypeOf<bool>();
  //
  //   if (isBool) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => false,
  //     );
  //   }
  //
  //   final isList = arg.doesBaseTypeEqualsTypeOf<List>();
  //
  //   if (isList) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => arg.callWitTypeGenericArgs(
  //         <R>() => <R>[],
  //       ),
  //     );
  //   }
  //
  //   final isIterable = arg.doesBaseTypeEqualsTypeOf<List>();
  //
  //   if (isIterable) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => arg.callWitTypeGenericArgs(
  //         <R>() => <R>[],
  //       ),
  //     );
  //   }
  //
  //   final isMap = arg.doesBaseTypeEqualsTypeOf<Map>();
  //
  //   if (isMap) {
  //     return JSerializerErrorHandler.returnValue(
  //       () => arg.callWitTypeGenericArgs(
  //         <K, V>() => <K, V>{},
  //       ),
  //     );
  //   }
  //
  //   return const JSerializerErrorHandler.throwValue();
  // };
}
