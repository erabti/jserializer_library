import 'package:jserializer/src/core/jserializer/essential_serializers.dart';
import 'package:jserializer/src/core/mocker/mockers/email_mocker.dart';
import 'package:jserializer/src/core/mocker/mockers/name_mocker.dart';

export 'name_mocker.dart';
export 'email_mocker.dart';

abstract interface class JMockers {
  /// Generates a mock name
  ///
  /// [nameCount]
  /// The number of names to generate.
  ///
  /// if not passed, will read from:
  /// 1. context.options.name.count
  /// 2. context.options.string.maxWords
  ///
  /// [language]
  /// The language of the names to generate.
  ///
  /// if not passed, will read from:
  /// 1. context.options.name.language
  /// 2. context.options.string.language
  /// 3. context.options.language
  const factory JMockers.name({
    int? nameCount,
    String? language,
  }) = NameMocker;

  const factory JMockers.email() = EmailMocker;

  const factory JMockers.string({
    String? language,
    int? maxWords,
    int? minWords,
    int? maxChars,
    int? minChars,
  }) = StringMocker;
}

void r() {
  JMockers.name(
    nameCount: 32,
  );
}
