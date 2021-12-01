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

  return MergingBuilder<ModelConfig, LibDir>(
    generator: JSerializerGenerator(config),
    inputFiles: options.config['input_files'],
    outputFile: options.config['output_file'],
    header: options.config['header'],
    footer: options.config['footer'],
    sortAssets: options.config['sort_assets'],
  );
}

JSerializable _getJSerializable(Map<String, dynamic> json) => JSerializable();
