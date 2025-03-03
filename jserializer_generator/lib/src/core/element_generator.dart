import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

abstract class ElementGenerator<T extends Spec> {
  T onGenerate();

  String generate() => DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      ).format(
        onGenerate().accept(DartEmitter()).toString(),
      );
}
