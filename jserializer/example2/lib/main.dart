import 'dart:async';

import 'package:example2/jserializer.dart';
import 'package:example2/model/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jserializer/jserializer.dart';

typedef TestType = Map<Vendor, List<Product>>;

final instance = JSerializer.i;

void main() async {
  initializeJSerializer();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;
  Timer? _secondTimer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        // runTest(instance);
        compute((message) => runTest(message), instance);
      },
    );

    _secondTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JSerializer Example'),
        ),
        body: ListView(
          children: [
            ...List.generate(
              500,
              (index) => index.isOdd
                  ? const SizedBox(
                      height: 100,
                      child: FlutterLogo(),
                    )
                  : IntrinsicHeight(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          'https://picsum.photos/500/500?random=$index',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

void runTest(JSerializerInterface instance) {
  final sw1 = Stopwatch()..start();
  final mock = instance.createMock<TestType>(
    context: JMockerContext(
      randomize: true,
      options: {
        'list': {
          'maxCount': 20,
        },
      },
    ),
  );

  debugPrint('Mock Elapsed: ${sw1.elapsedMilliseconds}ms\n');
  sw1.stop();

  final sw2 = Stopwatch()..start();
  final json = instance.toJson(mock);
  debugPrint('toJson Elapsed: ${sw2.elapsedMilliseconds}ms\n');
  sw2.stop();

  final sw3 = Stopwatch()..start();
  instance.fromJson<TestType>(json);

  debugPrint('fromJson Elapsed: ${sw3.elapsedMilliseconds}ms\n');
  sw3.stop();
}
