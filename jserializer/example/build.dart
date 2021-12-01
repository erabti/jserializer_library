// ignore_for_file: directives_ordering
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:dart_json_mapper/builder_factory.dart' as _i2;
import 'package:build_config/build_config.dart' as _i3;
import 'package:build/build.dart' as _i4;
import 'package:jserializer_generator/builder.dart' as _i5;
import 'package:reflectable/reflectable_builder.dart' as _i6;
import 'package:json_serializable/builder.dart' as _i7;
import 'package:source_gen/builder.dart' as _i8;
import 'package:build_modules/builders.dart' as _i9;
import 'package:build_web_compilers/builders.dart' as _i10;
import 'dart:isolate' as _i11;
import 'package:build_runner/build_runner.dart' as _i12;
import 'dart:io' as _i13;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(r'dart_json_mapper:dart_json_mapper', [_i2.dartJsonMapperBuilder],
      _i1.toRoot(),
      hideOutput: false,
      defaultGenerateFor: const _i3.InputSet(include: [
        r'benchmark/**.dart',
        r'bin/**.dart',
        r'test/_*.dart',
        r'example/**.dart',
        r'lib/main.dart',
        r'tool/**.dart',
        r'web/**.dart'
      ], exclude: [
        r'lib/**.dart'
      ]),
      defaultOptions: const _i4.BuilderOptions({
        r'iterables': r'List, Set',
        r'extension': r'.mapper.g.dart',
        r'formatted': false
      })),
  _i1.apply(r'jserializer_generator:jserializer', [_i5.jSerializerBuilder],
      _i1.toRoot(),
      hideOutput: false),
  _i1.apply(r'reflectable:reflectable', [_i6.reflectableBuilder], _i1.toRoot(),
      hideOutput: false,
      defaultGenerateFor: const _i3.InputSet(include: [
        r'benchmark/**.dart',
        r'bin/**.dart',
        r'example/**.dart',
        r'lib/main.dart',
        r'test/**.dart',
        r'tool/**.dart',
        r'web/**.dart'
      ])),
  _i1.apply(r'json_serializable:json_serializable', [_i7.jsonSerializable],
      _i1.toDependentsOf(r'json_serializable'),
      hideOutput: true,
      appliesBuilders: const [r'source_gen:combining_builder']),
  _i1.apply(r'source_gen:combining_builder', [_i8.combiningBuilder],
      _i1.toNoneByDefault(),
      hideOutput: false, appliesBuilders: const [r'source_gen:part_cleanup']),
  _i1.apply(r'build_modules:module_library', [_i9.moduleLibraryBuilder],
      _i1.toAllPackages(),
      isOptional: true,
      hideOutput: true,
      appliesBuilders: const [r'build_modules:module_cleanup']),
  _i1.apply(
      r'build_web_compilers:dart2js_modules',
      [
        _i10.dart2jsMetaModuleBuilder,
        _i10.dart2jsMetaModuleCleanBuilder,
        _i10.dart2jsModuleBuilder
      ],
      _i1.toNoneByDefault(),
      isOptional: true,
      hideOutput: true,
      appliesBuilders: const [r'build_modules:module_cleanup']),
  _i1.apply(
      r'build_web_compilers:ddc_modules',
      [
        _i10.ddcMetaModuleBuilder,
        _i10.ddcMetaModuleCleanBuilder,
        _i10.ddcModuleBuilder
      ],
      _i1.toNoneByDefault(),
      isOptional: true,
      hideOutput: true,
      appliesBuilders: const [r'build_modules:module_cleanup']),
  _i1.apply(
      r'build_web_compilers:ddc',
      [
        _i10.ddcKernelBuilderUnsound,
        _i10.ddcBuilderUnsound,
        _i10.ddcKernelBuilderSound,
        _i10.ddcBuilderSound
      ],
      _i1.toAllPackages(),
      isOptional: true,
      hideOutput: true,
      appliesBuilders: const [
        r'build_web_compilers:ddc_modules',
        r'build_web_compilers:dart2js_modules',
        r'build_web_compilers:dart_source_cleanup'
      ]),
  _i1.apply(
      r'build_web_compilers:sdk_js',
      [
        _i10.sdkJsCompileUnsound,
        _i10.sdkJsCompileSound,
        _i10.sdkJsCopyRequirejs
      ],
      _i1.toNoneByDefault(),
      isOptional: true,
      hideOutput: true),
  _i1.apply(r'build_web_compilers:entrypoint', [_i10.webEntrypointBuilder],
      _i1.toRoot(),
      hideOutput: true,
      defaultGenerateFor: const _i3.InputSet(include: [
        r'web/**',
        r'test/**.dart.browser_test.dart',
        r'example/**',
        r'benchmark/**'
      ], exclude: [
        r'test/**.node_test.dart',
        r'test/**.vm_test.dart'
      ]),
      defaultOptions: const _i4.BuilderOptions({
        r'dart2js_args': [r'--minify']
      }),
      defaultDevOptions: const _i4.BuilderOptions({
        r'dart2js_args': [r'--enable-asserts']
      }),
      defaultReleaseOptions:
          const _i4.BuilderOptions({r'compiler': r'dart2js'}),
      appliesBuilders: const [
        r'build_web_compilers:dart2js_archive_extractor'
      ]),
  _i1.applyPostProcess(r'build_modules:module_cleanup', _i9.moduleCleanup),
  _i1.applyPostProcess(r'build_web_compilers:dart2js_archive_extractor',
      _i10.dart2jsArchiveExtractor,
      defaultReleaseOptions:
          const _i4.BuilderOptions({r'filter_outputs': true})),
  _i1.applyPostProcess(
      r'build_web_compilers:dart_source_cleanup', _i10.dartSourceCleanup,
      defaultReleaseOptions: const _i4.BuilderOptions({r'enabled': true})),
  _i1.applyPostProcess(r'source_gen:part_cleanup', _i8.partCleanup)
];
void main(List<String> args, [_i11.SendPort? sendPort]) async {
  var result = await _i12.run(args, _builders);
  sendPort?.send(result);
  _i13.exitCode = result;
}
