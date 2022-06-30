import 'package:build/build.dart';
import 'package:jserializer/jserializer.dart';
import 'package:jserializer_generator/src/generator.dart';
import 'package:merging_builder/merging_builder.dart';

Builder jSerializerBuilder(BuilderOptions options) {
  BuilderOptions defaultOptions = BuilderOptions({
    'input_files': 'lib/**.dart',
    'output_file': 'lib/jserializer.dart',
    'header': '',
    'footer': '',
    'sort_assets': false,
  });

  options = defaultOptions.overrideWith(options);
  final config = _getJSerializable(options.config);

  final shouldAddAnalysisFile =
      options.config['export_models_analysis'] ?? false;

  return MergingBuilder<ModelConfig, LibDir>(
    generator: JSerializerGenerator(
      config,
      shouldAddAnalysisOptions: shouldAddAnalysisFile,
    ),
    inputFiles: options.config['input_files'],
    outputFile: options.config['output_file'],
    header: options.config['header'],
    footer: options.config['footer'],
    sortAssets: options.config['sort_assets'],
  );
}

JSerializable _getJSerializable(Map<String, dynamic> json) {
  final String fieldNameCaseString = json['fieldNameCase'] ?? 'none';
  final FieldNameCase fieldNameCase;
  if (fieldNameCaseString == 'camel') {
    fieldNameCase = FieldNameCase.camel;
  } else if (fieldNameCaseString == 'snake') {
    fieldNameCase = FieldNameCase.snake;
  } else if (fieldNameCaseString == 'pascal') {
    fieldNameCase = FieldNameCase.pascal;
  } else {
    fieldNameCase = FieldNameCase.none;
  }

  return JSerializable(
    deepToJson: json['deepToJson'] ?? true,
    filterToJsonNulls: json['filterToJsonNulls'] ?? false,
    fromJson: json['fromJson'] ?? true,
    toJson: json['toJson'] ?? true,
    guardedLookup: json['guardedLookup'] ?? true,
    fieldNameCase: fieldNameCase,
    ignoreAll: (json['ignoreAll'] as List).cast<String>(),
  );
}
