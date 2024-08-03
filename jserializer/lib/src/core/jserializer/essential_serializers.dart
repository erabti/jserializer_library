import 'package:jserializer/jserializer.dart';
import 'dart:math' as math;

class BoolSerializer extends Serializer<bool, dynamic> {
  const BoolSerializer({super.jSerializer});

  @override
  dynamic toJson(bool model) => model;

  @override
  Function get decoder => fromJson;

  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is num) return json != 0;
    if (json is String) return json != 'false' && json != '0';

    return json;
  }
}

class BoolMocker extends JMocker<bool> {
  const BoolMocker({super.jSerializer});

  @override
  Function get mocker => createMock;

  bool createMock({JMockerContext? context}) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<bool>(
      randomizer: (random) => random.nextBool(),
      fallback: () => true,
    );
  }
}

class NumSerializer extends Serializer<num, dynamic> {
  const NumSerializer({super.jSerializer});

  @override
  dynamic toJson(num model) => model;

  @override
  Function get decoder => fromJson;

  num fromJson(dynamic json) {
    if (json is num) return json;
    if (json is String) return num.parse(json);

    return json;
  }
}

class NumMocker extends JMocker<num> {
  const NumMocker({super.jSerializer});

  @override
  Function get mocker => createMock;

  num createMock({JMockerContext? context}) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<num>(
      randomizer: (random) => random.nextInt(ctx.numMaxValue),
      fallback: () => 0,
    );
  }
}

class StringSerializer extends Serializer<String, dynamic> {
  const StringSerializer({super.jSerializer});

  @override
  dynamic toJson(String model) => model;

  @override
  Function get decoder => fromJson;

  String fromJson(dynamic json) {
    if (json is String) return json;
    if (json is num) return json.toString();
    if (json is bool) return json.toString();

    return json;
  }
}

class StringMocker extends JMocker<String> implements JMockers {
  const StringMocker({
    super.jSerializer,
    this.language,
    this.maxWords,
    this.minWords,
    this.maxChars,
    this.minChars,
  });

  final String? language;
  final int? maxWords;
  final int? minWords;
  final int? maxChars;
  final int? minChars;

  @override
  Function get mocker => createMock;

  static String randomizeString({
    int? minWords,
    int? maxWords,
    int? maxChars,
    int? minChars,
    String? language,
    math.Random? randomInstance,
  }) {
    final alphabet = {
      'ar': 'ابجدهوزحطيكلمنسعفصقرشتثخذضظغ',
      'en': 'abcdefghijklmnopqrstuvwxyz',
    };

    // Set default values if not provided
    minWords ??= 1;
    maxWords ??= 5;
    minChars ??= 2;
    maxChars ??= 8;
    language ??= 'en';
    final chosenAlphabet = alphabet[language] ?? alphabet['en']!;

    final random = randomInstance ?? math.Random();

    // Generate a random number of words
    final wordCount = minWords + random.nextInt(maxWords - minWords + 1);

    // Generate random words
    final words = List.generate(
      wordCount,
      (_) {
        final charCount = minChars! + random.nextInt(maxChars! - minChars + 1);
        return List.generate(
          charCount,
          (_) => chosenAlphabet[random.nextInt(chosenAlphabet.length)],
        ).join();
      },
    );

    // Join words with spaces
    return words.join(' ');
  }

  String createMock({JMockerContext? context}) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<String>(
      randomizer: (random) => randomizeString(
        language: language ?? ctx.stringLanguage,
        maxChars: maxChars ?? ctx.stringMaxChars,
        minChars: minChars ?? ctx.stringMinChars,
        maxWords: maxWords ?? ctx.stringMaxWords,
        minWords: minWords ?? ctx.stringMinWords,
        randomInstance: random,
      ),
      fallback: () => 'mock',
    );
  }
}

class DoubleSerializer extends Serializer<double, dynamic> {
  const DoubleSerializer({super.jSerializer});

  @override
  dynamic toJson(double model) => model;

  @override
  Function get decoder => fromJson;

  double fromJson(dynamic json) {
    if (json is double) return json;
    if (json is num) return json.toDouble();
    if (json is String) return double.parse(json);

    return json;
  }
}

class DoubleMocker extends JMocker<double> {
  const DoubleMocker({super.jSerializer});

  @override
  Function get mocker => createMock;

  double createMock({JMockerContext? context}) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<double>(
      randomizer: (random) => random.nextDouble() * ctx.numMaxValue,
      fallback: () => 0,
    );
  }
}

class IntSerializer extends Serializer<int, dynamic> {
  const IntSerializer({super.jSerializer});

  @override
  dynamic toJson(int model) => model;

  @override
  Function get decoder => fromJson;

  int fromJson(dynamic json) {
    if (json is int) return json;
    if (json is num) return json.round();
    if (json is String) return int.parse(json);

    return json;
  }
}

class IntMocker extends JMocker<int> {
  const IntMocker({super.jSerializer});

  @override
  Function get mocker => createMock;

  int createMock({JMockerContext? context}) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<int>(
      randomizer: (random) => random.nextInt(ctx.numMaxValue),
      fallback: () => 0,
    );
  }
}
