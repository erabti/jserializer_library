import 'dart:convert';

import 'package:jserializer/jserializer.dart';

import 'models.dart';
import 'vanilla_serializers.dart' as vanilla;
import 'jserializer_serializers.dart' as js_ser;

// ============================================================================
// Realistic test data — matching the real Product model's scale
// ============================================================================

/// A fully populated Product JSON with all 26 fields, 2 variants (which are
/// themselves products), 3 categories, 4 tags, 2 customizations with 3 values
/// each, vendor with nested category & minimumOrderAmount, etc.
Map<String, dynamic> makeProductJson() => {
      'id': 'prod_xyz789',
      'name': 'Premium Wireless Headphones Pro Max',
      'price': {'amount': 299.99, 'currency': 'USD'},
      'originalPrice': {'amount': 399.99, 'currency': 'USD'},
      'featuredImage': 'https://cdn.example.com/products/headphones_pro.jpg',
      'images': [
        'https://cdn.example.com/products/hp_front.jpg',
        'https://cdn.example.com/products/hp_side.jpg',
        'https://cdn.example.com/products/hp_back.jpg',
        'https://cdn.example.com/products/hp_case.jpg',
      ],
      'vendor': {
        'id': 'vendor_abc',
        'name': 'TechAudio Corp',
        'banner': 'https://cdn.example.com/vendors/techaudio_banner.jpg',
        'featuredImage': 'https://cdn.example.com/vendors/techaudio_logo.jpg',
        'images': [
          'https://cdn.example.com/vendors/ta_1.jpg',
          'https://cdn.example.com/vendors/ta_2.jpg',
        ],
        'category': {
          'id': 'cat_electronics',
          'banner': 'https://cdn.example.com/cat/electronics_banner.jpg',
          'service': 'delivery',
          'featuredImage': 'https://cdn.example.com/cat/electronics.jpg',
          'images': ['https://cdn.example.com/cat/elec_1.jpg'],
          'name': 'Electronics',
        },
        'service': 'delivery',
        'isOpen': true,
        'partnerSupportNumber': '+1-800-555-0199',
        'minimumOrderAmount': {'amount': 25.00, 'currency': 'USD'},
      },
      'currency': 'USD',
      'maxPurchaseQuantity': 5,
      'service': 'delivery',
      'category': [
        {
          'id': 'cat_audio',
          'banner': null,
          'service': 'delivery',
          'featuredImage': 'https://cdn.example.com/cat/audio.jpg',
          'images': [],
          'name': 'Audio Equipment',
        },
        {
          'id': 'cat_wireless',
          'banner': null,
          'service': 'delivery',
          'featuredImage': null,
          'images': [],
          'name': 'Wireless Devices',
        },
        null, // nullable category
      ],
      'discountRate': '25%',
      'isAvailable': true,
      'description':
          'Experience unparalleled sound quality with our Premium Wireless Headphones Pro Max. '
              'Featuring active noise cancellation, 40-hour battery life, and premium comfort.',
      'tags': [
        {
          'key': 'bestseller',
          'title': 'Best Seller',
          'subTitle': 'Top rated product',
          'featuredImage': 'https://cdn.example.com/tags/bestseller.png'
        },
        {
          'key': 'new_arrival',
          'title': 'New Arrival',
          'subTitle': null,
          'featuredImage': null
        },
        {
          'key': 'sale',
          'title': 'On Sale',
          'subTitle': '25% off',
          'featuredImage': 'https://cdn.example.com/tags/sale.png'
        },
        {
          'key': 'premium',
          'title': 'Premium',
          'subTitle': 'High-end quality',
          'featuredImage': null
        },
      ],
      'barcode': '8901234567890',
      'quantity': 142,
      'variants': [
        {
          'id': 'prod_xyz789_black',
          'name': 'Premium Wireless Headphones Pro Max - Black',
          'price': {'amount': 299.99, 'currency': 'USD'},
          'originalPrice': {'amount': 399.99, 'currency': 'USD'},
          'featuredImage': 'https://cdn.example.com/products/hp_black.jpg',
          'images': ['https://cdn.example.com/products/hp_black_1.jpg'],
          'vendor': null,
          'currency': 'USD',
          'maxPurchaseQuantity': 5,
          'service': null,
          'category': null,
          'discountRate': '25%',
          'isAvailable': true,
          'description': null,
          'tags': null,
          'barcode': '8901234567891',
          'quantity': 80,
          'variants': null,
          'shortUrl': null,
          'brand': null,
          'variantsAttributes': null,
          'attributes': [
            {
              'id': 'attr_color_black',
              'name': 'Black',
              'color': '#000000',
              'featuredImage': null
            },
          ],
          'groupReference': 'prod_xyz789',
          'vendorId': 'vendor_abc',
          'userSpecifics': null,
          'customizations': [],
        },
        {
          'id': 'prod_xyz789_white',
          'name': 'Premium Wireless Headphones Pro Max - White',
          'price': {'amount': 309.99, 'currency': 'USD'},
          'originalPrice': {'amount': 399.99, 'currency': 'USD'},
          'featuredImage': 'https://cdn.example.com/products/hp_white.jpg',
          'images': [
            'https://cdn.example.com/products/hp_white_1.jpg',
            'https://cdn.example.com/products/hp_white_2.jpg',
          ],
          'vendor': null,
          'currency': 'USD',
          'maxPurchaseQuantity': 3,
          'service': null,
          'category': null,
          'discountRate': '22%',
          'isAvailable': true,
          'description': null,
          'tags': null,
          'barcode': '8901234567892',
          'quantity': 62,
          'variants': null,
          'shortUrl': null,
          'brand': null,
          'variantsAttributes': null,
          'attributes': [
            {
              'id': 'attr_color_white',
              'name': 'White',
              'color': '#FFFFFF',
              'featuredImage': null
            },
          ],
          'groupReference': 'prod_xyz789',
          'vendorId': 'vendor_abc',
          'userSpecifics': null,
          'customizations': [],
        },
      ],
      'shortUrl': 'https://shop.example.com/p/xyz789',
      'brand': {'name': 'AudioPro', 'logo': 'https://cdn.example.com/brands/audiopro.png'},
      'variantsAttributes': [
        {
          'id': 'attr_color',
          'name': 'Color',
          'values': [
            {'id': 'attr_color_black', 'name': 'Black', 'color': '#000000', 'featuredImage': null},
            {'id': 'attr_color_white', 'name': 'White', 'color': '#FFFFFF', 'featuredImage': null},
            {'id': 'attr_color_silver', 'name': 'Silver', 'color': '#C0C0C0', 'featuredImage': 'https://cdn.example.com/attrs/silver.jpg'},
          ],
        },
        {
          'id': 'attr_size',
          'name': 'Ear Cup Size',
          'values': [
            {'id': 'attr_size_standard', 'name': 'Standard', 'color': null, 'featuredImage': null},
            {'id': 'attr_size_large', 'name': 'Large', 'color': null, 'featuredImage': null},
          ],
        },
      ],
      'attributes': [
        {'id': 'attr_color_black', 'name': 'Black', 'color': '#000000', 'featuredImage': null},
        {'id': 'attr_size_standard', 'name': 'Standard', 'color': null, 'featuredImage': null},
      ],
      'groupReference': null,
      'vendorId': 'vendor_abc',
      'userSpecifics': {'isFavorite': true, 'cartQuantity': 1},
      'customizations': [
        {
          'id': 'cust_engraving',
          'decoration': {'title': 'Engraving', 'preTitle': 'Personalize', 'subtitle': 'Add a custom message'},
          'min': 0,
          'max': 1,
          'values': [
            {'id': 'cust_eng_yes', 'name': 'Yes, add engraving', 'featuredImage': null, 'description': 'Up to 20 characters', 'price': {'amount': 15.00, 'currency': 'USD'}},
            {'id': 'cust_eng_no', 'name': 'No thanks', 'featuredImage': null, 'description': null, 'price': null},
          ],
        },
        {
          'id': 'cust_warranty',
          'decoration': {'title': 'Extended Warranty', 'preTitle': 'Protection', 'subtitle': 'Extend your coverage'},
          'min': 0,
          'max': 1,
          'values': [
            {'id': 'cust_war_1yr', 'name': '1 Year Extended', 'featuredImage': null, 'description': 'Total 2 years coverage', 'price': {'amount': 29.99, 'currency': 'USD'}},
            {'id': 'cust_war_2yr', 'name': '2 Years Extended', 'featuredImage': null, 'description': 'Total 3 years coverage', 'price': {'amount': 49.99, 'currency': 'USD'}},
            {'id': 'cust_war_none', 'name': 'No thanks', 'featuredImage': null, 'description': null, 'price': null},
          ],
        },
      ],
    };

/// Deeply nested collection model JSON (mirrors SemiComplicatedModel)
Map<String, dynamic> makeNestedCollectionJson() => {
      'value': 'root_value',
      'name': 'Nested Beast',
      'age': 42,
      'isAdult': true,
      'height': 1.85,
      'friends': ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve'],
      'map': {'key1': 'value1', 'key2': 42, 'key3': true, 'nested': {'deep': 'value'}},
      'values': ['v1', 'v2', 'v3', 'v4'],
      'mapValues': {'k1': 'mv1', 'k2': 'mv2', 'k3': 'mv3'},
      'nestedValues': [
        ['a1', 'a2', 'a3'],
        ['b1', 'b2'],
        ['c1', 'c2', 'c3', 'c4'],
      ],
      'nestedMapValues': {
        'group1': ['x1', 'x2', 'x3'],
        'group2': ['y1', 'y2'],
        'group3': ['z1'],
      },
      'nestedValuesMap': [
        {'name': 'Alice', 'role': 'admin'},
        {'name': 'Bob', 'role': 'user'},
        {'name': 'Charlie', 'role': 'moderator'},
      ],
      'nestedMapValuesMap': {
        'teams': [
          {'lead': 'Alice', 'member': 'Bob'},
          {'lead': 'Charlie', 'member': 'Diana'},
        ],
        'projects': [
          {'name': 'Alpha', 'status': 'active'},
          {'name': 'Beta', 'status': 'planning'},
          {'name': 'Gamma', 'status': 'completed'},
        ],
      },
      'nestedValuesMapList': [
        [
          {'a': '1', 'b': '2'},
          {'c': '3', 'd': '4'},
        ],
        [
          {'e': '5', 'f': '6'},
        ],
      ],
      'nestedValuesMapListList': [
        [
          {'colors': ['red', 'green', 'blue'], 'sizes': ['S', 'M', 'L']},
          {'tags': ['new', 'featured']},
        ],
        [
          {'items': ['item1', 'item2', 'item3', 'item4']},
          {'keys': ['k1', 'k2'], 'vals': ['v1', 'v2']},
        ],
      ],
      'nestedMapValuesMapListList': {
        'section1': [
          {'options': ['opt1', 'opt2'], 'defaults': ['def1']},
          {'labels': ['label1', 'label2', 'label3']},
        ],
        'section2': [
          {'ids': ['id1', 'id2']},
        ],
      },
    };

/// API response with 20 products
Map<String, dynamic> makeApiResponseJson() {
  final productTemplate = makeProductJson();
  return {
    'success': true,
    'data': List.generate(20, (i) {
      final p = Map<String, dynamic>.from(productTemplate);
      p['id'] = 'prod_page_$i';
      p['name'] = 'Product #$i - ${productTemplate['name']}';
      return p;
    }),
    'meta': {
      'currentPage': 1,
      'totalPages': 15,
      'totalItems': 294,
      'perPage': 20,
      'nextCursor': 'cursor_abc123',
      'prevCursor': null,
    },
    'errors': null,
    'timestamp': '2024-06-15T14:30:00Z',
  };
}

// ============================================================================
// Benchmark harness
// ============================================================================

class BenchmarkResult {
  BenchmarkResult(this.name, this.iterations, this.totalMicroseconds);
  final String name;
  final int iterations;
  final int totalMicroseconds;

  double get avgMicroseconds => totalMicroseconds / iterations;
  double get opsPerSecond => iterations / (totalMicroseconds / 1e6);
}

BenchmarkResult benchmark(String name, void Function() fn,
    {int warmup = 500, int iterations = 5000}) {
  for (var i = 0; i < warmup; i++) {
    fn();
  }
  final sw = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    fn();
  }
  sw.stop();
  return BenchmarkResult(name, iterations, sw.elapsedMicroseconds);
}

void printHeader(String title) {
  print('\n--- $title ---');
  print('${'  Benchmark'.padRight(50)} ${'avg'.padLeft(12)}   ${'throughput'.padLeft(12)}');
  print('  ${'-' * 76}');
}

void printResult(BenchmarkResult r) {
  final avg = r.avgMicroseconds.toStringAsFixed(2);
  final ops = r.opsPerSecond.toStringAsFixed(0);
  print('  ${r.name.padRight(48)} ${avg.padLeft(10)} µs/op ${ops.padLeft(10)} ops/s');
}

void printComparison(BenchmarkResult vanilla, BenchmarkResult jser) {
  final ratio = jser.avgMicroseconds / vanilla.avgMicroseconds;
  final symbol = ratio > 1 ? 'slower' : 'faster';
  final absRatio = ratio > 1 ? ratio : (1 / ratio);
  print('  ${'>> Ratio (JSerializer / Vanilla)'.padRight(48)} ${absRatio.toStringAsFixed(2).padLeft(10)}x $symbol');
}

// ============================================================================
// Main
// ============================================================================

void main() {
  js_ser.initializeJSerializer();
  final jSerializer = JSerializer.i;

  print('=' * 80);
  print('  JSerializer Benchmark — Realistic Models');
  print('=' * 80);
  print('');
  print('  Model Complexity:');
  print('    Product:         26 fields, 12 model types, depth 4, self-ref variants');
  print('    NestedCollection: 16 fields, List<List<Map<String,List<String>>>> depth');
  print('    ApiResponse:     wraps 20 Products = ~600 nested objects total');

  // --------------------------------------------------
  // 1. PRODUCT (26 fields, 4 depth levels, full real-world model)
  // --------------------------------------------------
  printHeader('Product (26 fields, 4 levels deep, 2 variants, full data)');

  final productJson = makeProductJson();
  Product? productObj;

  final vPd = benchmark('Vanilla fromJson', () {
    productObj = vanilla.productFromJson(productJson);
  });
  printResult(vPd);

  final jPd = benchmark('JSerializer fromJson', () {
    productObj = jSerializer.fromJson<Product>(productJson);
  });
  printResult(jPd);
  printComparison(vPd, jPd);

  print('');
  final productModel = vanilla.productFromJson(productJson);

  final vPs = benchmark('Vanilla toJson', () {
    vanilla.productToJson(productModel);
  });
  printResult(vPs);

  final jPs = benchmark('JSerializer toJson', () {
    jSerializer.toJson(productModel);
  });
  printResult(jPs);
  printComparison(vPs, jPs);

  // --------------------------------------------------
  // 2. NESTED COLLECTION MODEL (deeply nested generics)
  // --------------------------------------------------
  printHeader('NestedCollectionModel (16 fields, 4-deep nested collections)');

  final nestedJson = makeNestedCollectionJson();
  NestedCollectionModel? nestedObj;

  final vNd = benchmark('Vanilla fromJson', () {
    nestedObj = vanilla.nestedCollectionModelFromJson(nestedJson);
  });
  printResult(vNd);

  final jNd = benchmark('JSerializer fromJson', () {
    nestedObj = jSerializer.fromJson<NestedCollectionModel>(nestedJson);
  });
  printResult(jNd);
  printComparison(vNd, jNd);

  print('');
  final nestedModel = vanilla.nestedCollectionModelFromJson(nestedJson);

  final vNs = benchmark('Vanilla toJson', () {
    vanilla.nestedCollectionModelToJson(nestedModel);
  });
  printResult(vNs);

  final jNs = benchmark('JSerializer toJson', () {
    jSerializer.toJson(nestedModel);
  });
  printResult(jNs);
  printComparison(vNs, jNs);

  // --------------------------------------------------
  // 3. API RESPONSE (20 products = massive nested payload)
  // --------------------------------------------------
  printHeader('ApiResponse (20 fully-populated Products, ~600 nested objects)');

  final apiJson = makeApiResponseJson();
  ApiResponse? apiObj;

  final vAd = benchmark('Vanilla fromJson', () {
    apiObj = vanilla.apiResponseFromJson(apiJson);
  }, warmup: 100, iterations: 1000);
  printResult(vAd);

  final jAd = benchmark('JSerializer fromJson', () {
    apiObj = jSerializer.fromJson<ApiResponse>(apiJson);
  }, warmup: 100, iterations: 1000);
  printResult(jAd);
  printComparison(vAd, jAd);

  print('');
  final apiModel = vanilla.apiResponseFromJson(apiJson);

  final vAs = benchmark('Vanilla toJson', () {
    vanilla.apiResponseToJson(apiModel);
  }, warmup: 100, iterations: 1000);
  printResult(vAs);

  final jAs = benchmark('JSerializer toJson', () {
    jSerializer.toJson(apiModel);
  }, warmup: 100, iterations: 1000);
  printResult(jAs);
  printComparison(vAs, jAs);

  // --------------------------------------------------
  // 4. Full round-trip with JSON string encoding/decoding
  // --------------------------------------------------
  printHeader('Full Round-Trip: jsonDecode → fromJson → toJson → jsonEncode');

  final productJsonString = jsonEncode(makeProductJson());

  final vRT = benchmark('Vanilla (single Product)', () {
    final decoded = jsonDecode(productJsonString) as Map<String, dynamic>;
    final model = vanilla.productFromJson(decoded);
    final encoded = vanilla.productToJson(model);
    jsonEncode(encoded);
  });
  printResult(vRT);

  final jRT = benchmark('JSerializer (single Product)', () {
    final decoded = jsonDecode(productJsonString) as Map<String, dynamic>;
    final model = jSerializer.fromJson<Product>(decoded);
    final encoded = jSerializer.toJson(model);
    jsonEncode(encoded);
  });
  printResult(jRT);
  printComparison(vRT, jRT);

  final apiJsonString = jsonEncode(makeApiResponseJson());

  print('');
  final vRTA = benchmark('Vanilla (20 Products API)', () {
    final decoded = jsonDecode(apiJsonString) as Map<String, dynamic>;
    final model = vanilla.apiResponseFromJson(decoded);
    final encoded = vanilla.apiResponseToJson(model);
    jsonEncode(encoded);
  }, warmup: 50, iterations: 500);
  printResult(vRTA);

  final jRTA = benchmark('JSerializer (20 Products API)', () {
    final decoded = jsonDecode(apiJsonString) as Map<String, dynamic>;
    final model = jSerializer.fromJson<ApiResponse>(decoded);
    final encoded = jSerializer.toJson(model);
    jsonEncode(encoded);
  }, warmup: 50, iterations: 500);
  printResult(jRTA);
  printComparison(vRTA, jRTA);

  // --------------------------------------------------
  // Summary
  // --------------------------------------------------
  print('\n${'=' * 80}');
  print('  SUMMARY');
  print('${'=' * 80}');
  print('');
  print('  ${'Scenario'.padRight(40)} ${'Vanilla'.padLeft(12)} ${'JSerializer'.padLeft(12)} ${'Ratio'.padLeft(10)}');
  print('  ${'-' * 76}');

  void summaryRow(String label, BenchmarkResult v, BenchmarkResult j) {
    final ratio = j.avgMicroseconds / v.avgMicroseconds;
    print(
        '  ${label.padRight(40)} ${v.avgMicroseconds.toStringAsFixed(1).padLeft(10)}µs ${j.avgMicroseconds.toStringAsFixed(1).padLeft(10)}µs ${ratio.toStringAsFixed(1).padLeft(8)}x');
  }

  summaryRow('Product fromJson', vPd, jPd);
  summaryRow('Product toJson', vPs, jPs);
  summaryRow('NestedCollection fromJson', vNd, jNd);
  summaryRow('NestedCollection toJson', vNs, jNs);
  summaryRow('ApiResponse(20) fromJson', vAd, jAd);
  summaryRow('ApiResponse(20) toJson', vAs, jAs);
  summaryRow('Round-trip Product', vRT, jRT);
  summaryRow('Round-trip API(20)', vRTA, jRTA);

  print('');
  print('  Boilerplate comparison:');
  print('    vanilla_serializers.dart : 440 lines of hand-written code');
  print('    jserializer_serializers.dart : 0 lines (auto-generated by build_runner)');
  print('');
  print('${'=' * 80}');

  // Prevent dead-code elimination
  productObj.hashCode;
  nestedObj.hashCode;
  apiObj.hashCode;
}
