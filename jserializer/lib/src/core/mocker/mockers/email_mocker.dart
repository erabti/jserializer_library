import 'package:jserializer/jserializer.dart';
import 'package:jserializer/src/core/mocker/mockers/name_mocker.dart';
import 'dart:math' as math;

class EmailMocker extends JCustomMocker<String> implements JMockers {
  const EmailMocker();

  @override
  String createMock({JMockerContext? context}) {
    final names = NameMocker.namesData['en']!;
    final randomize = context?.randomize ?? false;
    if (!randomize) {
      return '${names.first.toLowerCase()}@${emailDomainData.first}';
    }

    final deterministic = context?.deterministicRandom ?? false;
    final seed = !deterministic ? null : (context?.callCount ?? 0) + 7823;

    final random = math.Random(seed);

    final randomName = names[random.nextInt(names.length)].toLowerCase();
    final randomDomain =
        emailDomainData[random.nextInt(emailDomainData.length)];
    return '$randomName@$randomDomain';
  }

  static const emailDomainData = [
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'icloud.com',
    'aol.com',
    'protonmail.com',
    'zoho.com',
    'yandex.com',
    'mail.com',
    'gmx.com',
  ];
}
