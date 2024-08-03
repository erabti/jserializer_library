import 'package:analyzer/dart/constant/value.dart';
import 'package:jserializer_generator/src/generator.dart';

class JKeyConfig {
  const JKeyConfig({
    this.ignore = false,
    this.isExtras = false,
    this.name,
    this.overridesToJsonModelFields = false,
    this.fallbackName,
    this.mockValueCode,
  });

  factory JKeyConfig.fromDartObj(DartObject obj) {
    return JKeyConfig(
      ignore: obj.getField('ignore')?.toBoolValue() ?? false,
      name: obj.getField('name')?.toStringValue(),
      isExtras: obj.getField('isExtras')?.toBoolValue() ?? false,
      overridesToJsonModelFields:
          obj.getField('overridesToJsonModelFields')?.toBoolValue() ?? false,
      fallbackName: obj.getField('fallbackName')?.toStringValue(),
      mockValueCode: getMockValueCode(obj),
    );
  }

  static String? getMockValueCode(DartObject obj) {
    final field = obj.getField('mockValue');
    if (field == null) return null;
    if (field.isNull) return null;
    return field.toCodeString();
  }

  final bool ignore;
  final bool isExtras;
  final String? name;
  final bool overridesToJsonModelFields;
  final String? fallbackName;
  final String? mockValueCode;
}
