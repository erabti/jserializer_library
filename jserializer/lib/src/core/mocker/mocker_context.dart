import 'dart:math';

class JMockerContext {
  const JMockerContext({
    this.callCount,
    this.fieldName,
    this.randomize,
    this.options,
    this.deterministicRandom,
    this.deterministicSeedSalt,
  });

  final bool? deterministicRandom;
  final bool? randomize;

  final int? callCount;
  final String? fieldName;
  final int? deterministicSeedSalt;
  final Map<String, dynamic>? options;

  int? get callCountAsIndex {
    final callCount = this.callCount;
    if (callCount == null) return null;
    if (callCount < 1) return 0;
    return callCount - 1;
  }

  String get language => options?['language'] ?? 'en';

  // Num
  int get numMaxValue => options?['num']?['maxRandomValue'] ?? 1000;

  // String
  int get stringMaxWords => options?['string']?['maxWords'] ?? 5;

  int get stringMinWords => options?['string']?['minWords'] ?? 1;

  int get stringMaxChars => options?['string']?['maxChar'] ?? 10;

  int get stringMinChars => options?['string']?['minChars'] ?? 1;

  String get stringLanguage =>
      options?['string']?['language'] ?? options?['language'] ?? 'en';

  // List
  int get listMaxCount => options?['list']?['maxCount'] ?? 8;

  // Map
  int get mapMaxCount => options?['map']?['maxCount'] ?? 8;

  int generateSeed({int? salt}) {
    return (callCount ?? 0) + (salt ?? deterministicSeedSalt ?? 0);
  }

  Random generateRandom({int? salt}) {
    final deterministic = deterministicRandom ?? false;
    late final seed = generateSeed(salt: salt);
    return Random(deterministic ? seed : null);
  }

  T getRandomValueFromList<T>(
    List<T> list, {
    int? salt,
  }) {
    final random = generateRandom(salt: salt);
    return list[random.nextInt(list.length)];
  }

  T getValue<T>({
    T? Function(Random random)? randomizer,
    required T Function() fallback,
    int? deterministicSeedSalt,
  }) {
    final randomize = this.randomize ?? false;

    if (randomize) {
      final seedSalt = deterministicSeedSalt;
      final random = generateRandom(salt: seedSalt);
      final randomValue = randomizer?.call(random);
      if (randomValue != null) return randomValue;
    }

    final fallbackValue = fallback();
    return fallbackValue;
  }

  JMockerContext copyWith({
    bool? deterministicRandom,
    bool? randomize,
    int? callCount,
    String? fieldName,
    int? deterministicSeedSalt,
    Map<String, dynamic>? options,
  }) {
    return JMockerContext(
      deterministicRandom: deterministicRandom ?? this.deterministicRandom,
      randomize: randomize ?? this.randomize,
      callCount: callCount ?? this.callCount,
      fieldName: fieldName ?? this.fieldName,
      deterministicSeedSalt:
          deterministicSeedSalt ?? this.deterministicSeedSalt,
      options: options ?? this.options,
    );
  }
}
