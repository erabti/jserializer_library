import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:exception_templates/exception_templates.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Mock annotation & generators
// ---------------------------------------------------------------------------

class MockAnnotation {
  const MockAnnotation();
}

/// Concrete MergingGenerator used to test base-class methods.
class TestMergingGenerator
    extends MergingGenerator<String, MockAnnotation> {
  @override
  String generateStreamItemForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return 'item';
  }

  @override
  FutureOr<String> generateMergedContent(Stream<String> stream) async {
    final items = <String>[];
    await for (final item in stream) {
      items.add(item);
    }
    return items.join('\n');
  }
}

/// A trivial Generator (not MergingGenerator) for StandaloneBuilder tests.
class TestGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return '// standalone output';
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // SyntheticInput.toString
  // -------------------------------------------------------------------------
  group('SyntheticInput.toString', () {
    test('LibDir.toString() returns its value', () {
      final lib = LibDir();
      expect(lib.toString(), lib.value);
      expect(lib.toString(), r'lib/$lib$');
    });

    test('PackageDir.toString() returns its value', () {
      final pkg = PackageDir();
      expect(pkg.toString(), pkg.value);
      expect(pkg.toString(), r'$package$');
    });
  });

  // -------------------------------------------------------------------------
  // SyntheticInput.isValidPath for PackageDir (always true, even outside lib)
  // -------------------------------------------------------------------------
  group('SyntheticInput.isValidPath<PackageDir>', () {
    test('returns true for lib path', () {
      expect(SyntheticInput.isValidPath<PackageDir>('lib/foo.dart'), isTrue);
    });

    test('returns true for test path', () {
      expect(SyntheticInput.isValidPath<PackageDir>('test/foo.dart'), isTrue);
    });

    test('returns true for web path', () {
      expect(SyntheticInput.isValidPath<PackageDir>('web/foo.dart'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // SyntheticInput.validatePath<PackageDir> does not throw
  // -------------------------------------------------------------------------
  group('SyntheticInput.validatePath<PackageDir>', () {
    test('does not throw for paths outside lib', () {
      expect(
        () => SyntheticInput.validatePath<PackageDir>('test/foo.dart'),
        returnsNormally,
      );
    });
  });

  // -------------------------------------------------------------------------
  // MergingGenerator static getters and generateForAnnotatedElement
  // -------------------------------------------------------------------------
  group('MergingGenerator', () {
    test('header returns empty string', () {
      expect(MergingGenerator.header, '');
    });

    test('footer returns empty string', () {
      expect(MergingGenerator.footer, '');
    });

    test('generateForAnnotatedElement returns empty string', () async {
      final gen = TestMergingGenerator();
      // The base-class implementation returns ''.
      // We pass nulls cast away because the default impl ignores them.
      final result = gen.generateForAnnotatedElement(
        // We cannot easily construct a real Element, but the base class
        // method ignores all parameters and returns ''.
        _FakeElement(),
        ConstantReader(null),
        _FakeBuildStep(),
      );
      // result is FutureOr<String>, await it in case it's a Future.
      expect(await result, '');
    });
  });

  // -------------------------------------------------------------------------
  // SyntheticBuilder.arrangeContent
  // -------------------------------------------------------------------------
  group('SyntheticBuilder.arrangeContent', () {
    test('includes header, source and footer', () {
      // Use a no-op formatter so we can inspect raw output.
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        inputFiles: 'lib/*.dart',
        outputFile: 'lib/output.dart',
        formatter: (input) => input,
      );

      final result = builder.arrangeContent('some source code');

      expect(result, contains('GENERATED CODE. DO NOT MODIFY.'));
      expect(result, contains('some source code'));
    });

    test('includes generatedBy when provided', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        inputFiles: 'lib/*.dart',
        outputFile: 'lib/output.dart',
        formatter: (input) => input,
      );

      final result = builder.arrangeContent(
        'body',
        generatedBy: 'Generated by Foo.',
      );

      expect(result, contains('Generated by Foo.'));
    });

    test('includes custom header text', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        inputFiles: 'lib/*.dart',
        outputFile: 'lib/output.dart',
        header: '// Custom header',
        formatter: (input) => input,
      );

      final result = builder.arrangeContent('body');
      expect(result, contains('// Custom header'));
    });

    test('includes custom footer text', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        inputFiles: 'lib/*.dart',
        outputFile: 'lib/output.dart',
        footer: '// Custom footer',
        formatter: (input) => input,
      );

      final result = builder.arrangeContent('body');
      expect(result, contains('// Custom footer'));
    });

    test('uses custom formatter', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        inputFiles: 'lib/*.dart',
        outputFile: 'lib/output.dart',
        formatter: (input) => 'FORMATTED: $input',
      );

      final result = builder.arrangeContent('body');
      expect(result, startsWith('FORMATTED: '));
    });

    test('uses default DartFormatter when no formatter provided', () {
      // The default DartFormatter will format valid dart code.
      // We just check that the constructor succeeds and arrangeContent works.
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        inputFiles: 'lib/*.dart',
        outputFile: 'lib/output.dart',
      );

      // Provide syntactically valid Dart so the formatter does not throw.
      final result = builder.arrangeContent('');
      expect(result, contains('GENERATED CODE'));
    });
  });

  // -------------------------------------------------------------------------
  // MergingBuilder constructor and properties
  // -------------------------------------------------------------------------
  group('MergingBuilder constructor', () {
    test('default sortAssets is false', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        formatter: (input) => input,
      );
      expect(builder.sortAssets, isFalse);
    });

    test('sortAssets can be set to true', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        sortAssets: true,
        formatter: (input) => input,
      );
      expect(builder.sortAssets, isTrue);
    });

    test('default outputFile', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        formatter: (input) => input,
      );
      expect(builder.outputFile, 'lib/merged_output.dart');
    });

    test('custom outputFile', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        outputFile: 'lib/custom.dart',
        formatter: (input) => input,
      );
      expect(builder.outputFile, 'lib/custom.dart');
    });

    test('stores generator', () {
      final gen = TestMergingGenerator();
      final builder = MergingBuilder<String, LibDir>(
        generator: gen,
        formatter: (input) => input,
      );
      expect(builder.generator, same(gen));
    });

    test('syntheticInput is LibDir for MergingBuilder<T, LibDir>', () {
      final builder = MergingBuilder<String, LibDir>(
        generator: TestMergingGenerator(),
        formatter: (input) => input,
      );
      expect(builder.syntheticInput, isA<LibDir>());
    });

    test('syntheticInput is PackageDir for MergingBuilder<T, PackageDir>', () {
      final builder = MergingBuilder<String, PackageDir>(
        generator: TestMergingGenerator(),
        formatter: (input) => input,
      );
      expect(builder.syntheticInput, isA<PackageDir>());
    });
  });

  // -------------------------------------------------------------------------
  // MergingBuilder.buildExtensions (already tested elsewhere, but with
  // PackageDir variant using non-lib paths)
  // -------------------------------------------------------------------------
  group('MergingBuilder.buildExtensions additional cases', () {
    test('buildExtensions for PackageDir with test paths', () {
      final builder = MergingBuilder<String, PackageDir>(
        generator: TestMergingGenerator(),
        inputFiles: 'test/*.dart',
        outputFile: 'test/merged.dart',
        formatter: (input) => input,
      );
      expect(builder.buildExtensions, {
        r'$package$': ['test/merged.dart'],
      });
    });
  });

  // -------------------------------------------------------------------------
  // StandaloneBuilder constructor and buildExtensions
  // -------------------------------------------------------------------------
  group('StandaloneBuilder', () {
    test('constructor stores generator', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        inputFiles: 'lib/*.dart',
        outputFiles: 'lib/generated_(*).dart',
        formatter: (input) => input,
      );
      expect(builder.generator, same(gen));
    });

    test('outputFiles default', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        formatter: (input) => input,
      );
      expect(builder.outputFiles, 'lib/standalone_(*).dart');
    });

    test('custom outputFiles', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        outputFiles: 'lib/gen_(*).dart',
        formatter: (input) => input,
      );
      expect(builder.outputFiles, 'lib/gen_(*).dart');
    });

    test('syntheticInput is LibDir', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        formatter: (input) => input,
      );
      expect(builder.syntheticInput, isA<LibDir>());
    });

    test('syntheticInput is PackageDir', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<PackageDir>(
        generator: gen,
        inputFiles: 'test/*.dart',
        outputFiles: 'test/gen_(*).dart',
        formatter: (input) => input,
      );
      expect(builder.syntheticInput, isA<PackageDir>());
    });

    test('root is trimmed', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        root: '  /some/path  ',
        formatter: (input) => input,
      );
      expect(builder.root, '/some/path');
    });

    test('default root is empty', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        formatter: (input) => input,
      );
      expect(builder.root, '');
    });

    test('header and footer passed through', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        header: '// header',
        footer: '// footer',
        formatter: (input) => input,
      );
      expect(builder.header, '// header');
      expect(builder.footer, '// footer');
    });

    test('arrangeContent works on StandaloneBuilder', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        formatter: (input) => input,
        header: '// MY HEADER',
        footer: '// MY FOOTER',
      );
      final result = builder.arrangeContent('code here');
      expect(result, contains('GENERATED CODE'));
      expect(result, contains('// MY HEADER'));
      expect(result, contains('code here'));
      expect(result, contains('// MY FOOTER'));
    });

    // buildExtensions for StandaloneBuilder resolves output files from the
    // filesystem. We test with the actual lib directory which contains at least
    // the library file.
    test('buildExtensions resolves output paths from filesystem', () {
      final gen = TestGenerator();
      // Use the actual merging_builder lib directory files.
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        inputFiles: 'lib/*.dart',
        outputFiles: 'lib/generated_(*).dart',
        formatter: (input) => input,
        root: '/Users/mohn93/Desktop/ls_projects/jserializer_library/merging_builder',
      );
      final extensions = builder.buildExtensions;
      // Should have the synthetic input as the key.
      expect(extensions.keys, contains(r'lib/$lib$'));
      // The outputs should contain at least the generated file for
      // merging_builder.dart.
      final outputs = extensions[r'lib/$lib$']!;
      expect(outputs, isNotEmpty);
      expect(
        outputs.any((o) => o.contains('generated_merging_builder.dart')),
        isTrue,
      );
    });

    test('buildExtensions throws when output clashes with input', () {
      final gen = TestGenerator();
      // outputFiles pattern that would produce a file with the same name
      // as the input (the (*) maps the basename, so "(*).dart" matches
      // the input file exactly).
      final builder = StandaloneBuilder<LibDir>(
        generator: gen,
        inputFiles: 'lib/*.dart',
        outputFiles: 'lib/(*).dart',
        formatter: (input) => input,
        root: '/Users/mohn93/Desktop/ls_projects/jserializer_library/merging_builder',
      );
      expect(
        () => builder.buildExtensions,
        throwsA(isA<ErrorOf<StandaloneBuilder>>()),
      );
    });

    test('StandaloneBuilder with PackageDir and test paths', () {
      final gen = TestGenerator();
      final builder = StandaloneBuilder<PackageDir>(
        generator: gen,
        inputFiles: 'test/*.dart',
        outputFiles: 'test/gen_(*).dart',
        formatter: (input) => input,
        root: '/Users/mohn93/Desktop/ls_projects/jserializer_library/merging_builder',
      );
      final extensions = builder.buildExtensions;
      expect(extensions.keys, contains(r'$package$'));
      final outputs = extensions[r'$package$']!;
      expect(outputs, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // MergingGenerator.generateMergedContent via concrete subclass
  // -------------------------------------------------------------------------
  group('MergingGenerator.generateMergedContent', () {
    test('collects stream items into merged output', () async {
      final gen = TestMergingGenerator();
      final stream = Stream<String>.fromIterable(['a', 'b', 'c']);
      final result = await gen.generateMergedContent(stream);
      expect(result, 'a\nb\nc');
    });

    test('returns empty string for empty stream', () async {
      final gen = TestMergingGenerator();
      final stream = Stream<String>.empty();
      final result = await gen.generateMergedContent(stream);
      expect(result, '');
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal fakes for testing generateForAnnotatedElement
// ---------------------------------------------------------------------------

/// Minimal fake Element for calling generateForAnnotatedElement.
/// The base-class implementation ignores all parameters, so this is fine.
class _FakeElement implements Element {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Minimal fake BuildStep for calling generateForAnnotatedElement.
class _FakeBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
