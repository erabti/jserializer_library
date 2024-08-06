import 'dart:math';

import 'package:jserializer/jserializer.dart';

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

class StringMocker extends JModelMocker<String> implements JMockers {
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

  static String randomizeString({
    int? minWords,
    int? maxWords,
    int? maxChars,
    int? minChars,
    String? language,
    Random? randomInstance,
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

    final random = randomInstance ?? Random();

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

  @override
  String createMock([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();

    return ctx.getValue<String>(
      randomizer: (random) {
        return randomizeString(
          language: language ?? ctx.stringLanguage,
          maxChars: maxChars ?? ctx.stringMaxChars,
          minChars: minChars ?? ctx.stringMinChars,
          maxWords: maxWords ?? ctx.stringMaxWords,
          minWords: minWords ?? ctx.stringMinWords,
          randomInstance: random,
        );
      },
      fallback: () => 'mock',
    );
  }
}
