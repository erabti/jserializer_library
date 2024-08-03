import 'package:jserializer/jserializer.dart';
import 'package:jserializer/src/core/util/extension.dart';

class NameMocker extends JCustomMocker<String> implements JMockers {
  /// Generates a mock name
  const NameMocker({
    int? nameCount,
    String? language,
  })  : _nameCount = nameCount,
        _language = language;

  final int? _nameCount;

  int getNameCount(JMockerContext context) {
    return _nameCount ??
        context.options?['name']?['count'] ??
        context.options?['string']?['maxWords'] ??
        2;
  }

  final String? _language;

  String getLanguage(JMockerContext context) {
    return _language ??
        context.options?['name']?['language'] ??
        context.options?['string']?['language'] ??
        context.options?['language'] ??
        context.language;
  }

  @override
  String createMock([JMockerContext? context]) {
    final ctx = context ?? JMockerContext();
    final nameCount = getNameCount(ctx);
    final language = getLanguage(ctx);
    final randomize = ctx.randomize ?? false;
    final names = namesData[language] ?? namesData['en']!;
    if (!randomize) {
      return names.takeCircular(nameCount).join(' ');
    }

    final random = ctx.generateRandom();

    return List.generate(
      nameCount,
      (index) => names[random.nextInt(names.length)],
    ).join(' ');
  }

  static const namesData = {
    'ar': [
      'محمد',
      'أحمد',
      'علي',
      'عمر',
      'خالد',
      'حسن',
      'يوسف',
      'عبدالله',
      'إبراهيم',
      'مصطفى',
      'طه',
      'حسين',
      'محود',
      'عبد الرحيم',
      'عبد الغفور',
      'جمال',
      'حسني',
    ],
    'en': [
      'John',
      'Emma',
      'Michael',
      'Sophia',
      'William',
      'Olivia',
      'James',
      'Ava',
      'Robert',
      'Isabella',
      'David',
      'Mia',
      'Joseph',
      'Charlotte',
      'Daniel'
    ],
  };
}
