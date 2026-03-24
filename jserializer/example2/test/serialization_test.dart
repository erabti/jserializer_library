import 'package:example2/jserializer.dart';
import 'package:example2/model/complicated_model.dart';
import 'package:example2/model/model.dart';
import 'package:example2/model/product.dart';
import 'package:example2/model/product_customization.dart';
import 'package:example2/model/union.dart';
import 'package:jserializer/jserializer.dart';
import 'package:flutter_test/flutter_test.dart';

late JSerializerInterface js;

void main() {
  setUpAll(() {
    initializeJSerializer();
    js = JSerializer.i;
  });

  group('Price', () {
    test('fromJson', () {
      final json = {'amount': 9.99, 'currency': 'USD'};
      final price = js.fromJson<Price>(json);
      expect(price.amount, 9.99);
      expect(price.currency, 'USD');
    });

    test('toJson', () {
      const price = Price(amount: 9.99, currency: 'USD');
      final json = js.toJson(price) as Map<String, dynamic>;
      expect(json['amount'], 9.99);
      expect(json['currency'], 'USD');
    });

    test('round-trip', () {
      const original = Price(amount: 42.5, currency: 'EUR');
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<Price>(json);
      expect(restored.amount, original.amount);
      expect(restored.currency, original.currency);
    });

    test('nullable currency', () {
      final json = {'amount': 5.0};
      final price = js.fromJson<Price>(json);
      expect(price.amount, 5.0);
      expect(price.currency, isNull);
    });
  });

  group('Brand', () {
    test('fromJson', () {
      final json = {'name': 'Nike', 'logo': 'https://example.com/logo.png'};
      final brand = js.fromJson<Brand>(json);
      expect(brand.name, 'Nike');
      expect(brand.logo, 'https://example.com/logo.png');
    });

    test('toJson with nulls', () {
      const brand = Brand(name: 'Adidas');
      final json = js.toJson(brand) as Map<String, dynamic>;
      expect(json['name'], 'Adidas');
      expect(json.containsKey('logo'), true);
      expect(json['logo'], isNull);
    });

    test('round-trip', () {
      const original = Brand(name: 'Puma', logo: 'logo.png');
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<Brand>(json);
      expect(restored.name, original.name);
      expect(restored.logo, original.logo);
    });
  });

  group('Tag', () {
    test('fromJson full', () {
      final json = {
        'key': 'sale',
        'title': 'On Sale',
        'subTitle': '50% off',
        'featuredImage': 'sale.png',
      };
      final tag = js.fromJson<Tag>(json);
      expect(tag.key, 'sale');
      expect(tag.title, 'On Sale');
      expect(tag.subTitle, '50% off');
      expect(tag.featuredImage, 'sale.png');
    });

    test('fromJson minimal', () {
      final json = <String, dynamic>{};
      final tag = js.fromJson<Tag>(json);
      expect(tag.key, isNull);
      expect(tag.title, isNull);
    });
  });

  group('Category', () {
    test('round-trip', () {
      const original = Category(
        id: 'cat_1',
        name: 'Electronics',
        service: 'delivery',
        featuredImage: 'electronics.png',
        images: ['img1.png', 'img2.png'],
      );
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<Category>(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.service, original.service);
      expect(restored.images, original.images);
    });
  });

  group('ProductUserSpecific', () {
    test('round-trip', () {
      const original = ProductUserSpecific(isFavorite: true, cartQuantity: 3);
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<ProductUserSpecific>(json);
      expect(restored.isFavorite, true);
      expect(restored.cartQuantity, 3);
    });
  });

  group('ProductAttributeValue', () {
    test('round-trip', () {
      const original = ProductAttributeValue(
        id: 'attr_1',
        name: 'Red',
        color: '#FF0000',
        featuredImage: 'red.png',
      );
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<ProductAttributeValue>(json);
      expect(restored, original);
    });
  });

  group('ProductAttribute', () {
    test('round-trip with nested values', () {
      const original = ProductAttribute(
        id: 'color',
        name: 'Color',
        values: [
          ProductAttributeValue(id: 'red', name: 'Red', color: '#FF0000'),
          ProductAttributeValue(id: 'blue', name: 'Blue', color: '#0000FF'),
        ],
      );
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<ProductAttribute>(json);
      expect(restored, original);
      expect(restored.values!.length, 2);
      expect(restored.values![0].id, 'red');
    });
  });

  group('ProductCustomizationDecoration', () {
    test('round-trip', () {
      const original = ProductCustomizationDecoration(
        title: 'Engraving',
        preTitle: 'Personalize',
        subtitle: 'Add a custom message',
      );
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<ProductCustomizationDecoration>(json);
      expect(restored, original);
    });
  });

  group('ProductCustomizationValue', () {
    test('round-trip with nested Price', () {
      const original = ProductCustomizationValue(
        id: 'eng_1',
        name: 'Yes, add engraving',
        description: 'Up to 20 chars',
        price: Price(amount: 15.0, currency: 'USD'),
      );
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<ProductCustomizationValue>(json);
      expect(restored, original);
    });
  });

  group('ProductCustomization', () {
    test('round-trip with JKey renamed fields', () {
      const original = ProductCustomization(
        id: 'cust_1',
        decoration: ProductCustomizationDecoration(title: 'Size'),
        minSelection: 1,
        maxSelection: 3,
        values: [
          ProductCustomizationValue(id: 'v1', name: 'Small'),
          ProductCustomizationValue(id: 'v2', name: 'Large'),
        ],
      );
      final json = js.toJson(original) as Map<String, dynamic>;
      // JKey renames: minSelection -> 'min', maxSelection -> 'max'
      expect(json['min'], 1);
      expect(json['max'], 3);

      final restored = js.fromJson<ProductCustomization>(json);
      expect(restored, original);
    });
  });

  group('Vendor', () {
    test('round-trip with filterToJsonNulls', () {
      const original = Vendor(
        id: 'v1',
        name: 'TechShop',
        isOpen: true,
        service: 'delivery',
      );
      final json = js.toJson(original) as Map<String, dynamic>;
      // Vendor has @JSerializable(filterToJsonNulls: true)
      // so null fields should be excluded
      expect(json.containsKey('banner'), false);
      expect(json['id'], 'v1');
      expect(json['name'], 'TechShop');
      expect(json['isOpen'], true);

      final restored = js.fromJson<Vendor>(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.isOpen, original.isOpen);
    });

    test('JKey fallbackName for featuredImage', () {
      final json = {
        'id': 'v1',
        'image_url': 'vendor.png',
      };
      final vendor = js.fromJson<Vendor>(json);
      expect(vendor.featuredImage, 'vendor.png');
    });
  });

  group('Product (full model)', () {
    Map<String, dynamic> makeProductJson() => {
          'id': 'prod_1',
          'name': 'Wireless Headphones',
          'price': {'amount': 299.99, 'currency': 'USD'},
          'originalPrice': {'amount': 399.99, 'currency': 'USD'},
          'featuredImage': 'headphones.jpg',
          'images': ['front.jpg', 'side.jpg'],
          'vendor': {
            'id': 'vendor_1',
            'name': 'AudioCorp',
            'service': 'delivery',
            'isOpen': true,
          },
          'currency': 'USD',
          'maxPurchaseQuantity': 5,
          'service': 'delivery',
          'category': [
            {'id': 'cat_audio', 'name': 'Audio'},
          ],
          'discountRate': '25%',
          'isAvailable': true,
          'description': 'Great headphones',
          'tags': [
            {'key': 'sale', 'title': 'On Sale'},
            {'key': 'new', 'title': 'New'},
          ],
          'barcode': '1234567890',
          'quantity': 100,
          'variants': null,
          'shortUrl': 'https://shop.example.com/p/1',
          'brand': {'name': 'AudioPro', 'logo': 'logo.png'},
          'variantsAttributes': null,
          'attributes': [
            {'id': 'color_black', 'name': 'Black', 'color': '#000'},
          ],
          'groupReference': null,
          'vendorId': 'vendor_1',
          'userSpecifics': {'isFavorite': true, 'cartQuantity': 2},
          'customizations': [
            {
              'id': 'cust_1',
              'decoration': {'title': 'Warranty'},
              'min': 0,
              'max': 1,
              'values': [
                {
                  'id': 'w1',
                  'name': '1 Year',
                  'price': {'amount': 29.99, 'currency': 'USD'},
                },
              ],
            }
          ],
        };

    test('fromJson parses all fields', () {
      final json = makeProductJson();
      final product = js.fromJson<Product>(json);

      expect(product.id, 'prod_1');
      expect(product.name, 'Wireless Headphones');
      expect(product.price!.amount, 299.99);
      expect(product.price!.currency, 'USD');
      expect(product.originalPrice!.amount, 399.99);
      expect(product.featuredImage, 'headphones.jpg');
      expect(product.images, ['front.jpg', 'side.jpg']);
      expect(product.vendor!.id, 'vendor_1');
      expect(product.vendor!.name, 'AudioCorp');
      expect(product.currency, 'USD');
      expect(product.maxPurchaseQuantity, 5);
      expect(product.discountRate, '25%');
      expect(product.isAvailable, true);
      expect(product.description, 'Great headphones');
      expect(product.tags!.length, 2);
      expect(product.tags![0].key, 'sale');
      expect(product.barcode, '1234567890');
      expect(product.quantity, 100);
      expect(product.brand!.name, 'AudioPro');
      expect(product.attributes.length, 1);
      expect(product.attributes[0].id, 'color_black');
      expect(product.vendorId, 'vendor_1');
      expect(product.userSpecifics!.isFavorite, true);
      expect(product.userSpecifics!.cartQuantity, 2);
      expect(product.customizations.length, 1);
      expect(product.customizations[0].id, 'cust_1');
      expect(product.customizations[0].minSelection, 0);
      expect(product.customizations[0].maxSelection, 1);
      expect(product.customizations[0].values[0].price!.amount, 29.99);
    });

    test('round-trip preserves data', () {
      final json = makeProductJson();
      final product = js.fromJson<Product>(json);
      final outputJson = js.toJson(product) as Map<String, dynamic>;
      final restored = js.fromJson<Product>(outputJson);
      expect(restored.id, product.id);
      expect(restored.name, product.name);
      expect(restored.price!.amount, product.price!.amount);
      expect(restored.price!.currency, product.price!.currency);
      expect(restored.images, product.images);
      expect(restored.vendor!.id, product.vendor!.id);
      expect(restored.tags!.length, product.tags!.length);
      expect(restored.attributes.length, product.attributes.length);
      expect(restored.attributes[0], product.attributes[0]);
      expect(restored.customizations.length, product.customizations.length);
      expect(restored.customizations[0], product.customizations[0]);
      expect(restored.userSpecifics!.isFavorite, product.userSpecifics!.isFavorite);
    });

    test('fromJson with minimal fields', () {
      final json = {'id': 'prod_minimal'};
      final product = js.fromJson<Product>(json);
      expect(product.id, 'prod_minimal');
      expect(product.name, isNull);
      expect(product.price, isNull);
      expect(product.images, isEmpty);
      expect(product.attributes, isEmpty);
      expect(product.customizations, isEmpty);
    });

    test('category list parsing', () {
      final json = makeProductJson();
      final product = js.fromJson<Product>(json);
      expect(product.category.length, 1);
      expect(product.category[0].id, 'cat_audio');
    });
  });

  group('SomeModel', () {
    test('fromJson', () {
      final json = {
        'field1': 'hello',
        'field2': 'world',
        'field3': 3.14,
        'field4': 42,
      };
      final model = js.fromJson<SomeModel>(json);
      expect(model.field1, 'hello');
      expect(model.field2, 'world');
      expect(model.field3, 3.14);
      expect(model.field4, 42);
    });

    test('round-trip', () {
      final json = {
        'field1': 'test',
        'field2': 'value',
        'field3': 1.5,
        'field4': 10,
      };
      final model = js.fromJson<SomeModel>(json);
      final outputJson = js.toJson(model) as Map<String, dynamic>;
      final restored = js.fromJson<SomeModel>(outputJson);
      expect(restored.field1, model.field1);
      expect(restored.field2, model.field2);
      expect(restored.field3, model.field3);
      expect(restored.field4, model.field4);
    });

    test('extras field captures unknown keys', () {
      final json = {
        'field1': 'hi',
        'unknown_key': 'surprise',
        'another': 123,
      };
      final model = js.fromJson<SomeModel>(json);
      expect(model.field1, 'hi');
      expect(model.extras['unknown_key'], 'surprise');
      expect(model.extras['another'], 123);
    });
  });

  group('SomeEnum', () {
    test('fromJson', () {
      final value = js.fromJson<SomeEnum>('someValue1');
      expect(value, SomeEnum.someValue1);
    });

    test('toJson', () {
      final json = js.toJson(SomeEnum.someValue2);
      expect(json, 'someValue2');
    });

    test('round-trip', () {
      for (final e in SomeEnum.values) {
        final json = js.toJson(e);
        final restored = js.fromJson<SomeEnum>(json);
        expect(restored, e);
      }
    });
  });

  group('SomeCustomModel (custom serializer)', () {
    test('fromJson via custom serializer', () {
      final json = {'value': 'custom_value'};
      final model = js.fromJson<SomeCustomModel>(json);
      expect(model.value, 'custom_value');
    });

    test('toJson via custom serializer', () {
      const model = SomeCustomModel(value: 'test');
      final json = js.toJson(model) as Map<String, dynamic>;
      expect(json['value'], 'test');
    });

    test('round-trip', () {
      const original = SomeCustomModel(value: 'round_trip');
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<SomeCustomModel>(json);
      expect(restored.value, original.value);
    });
  });

  group('DynamicItemShape (enum)', () {
    test('round-trip all values', () {
      for (final shape in DynamicItemShape.values) {
        final json = js.toJson(shape);
        final restored = js.fromJson<DynamicItemShape>(json);
        expect(restored, shape);
      }
    });
  });

  group('SectionLayout (union type)', () {
    test('fromJson vList', () {
      final json = {'type': 'vList', 'shape': 'circle'};
      final layout = js.fromJson<SectionLayout>(json);
      expect(layout, isA<SectionLayoutVList>());
      expect(layout.shape, DynamicItemShape.circle);
    });

    test('fromJson hList', () {
      final json = {'type': 'hList'};
      final layout = js.fromJson<SectionLayout>(json);
      expect(layout, isA<SectionLayoutHList>());
    });

    test('fromJson gridView', () {
      final json = {'type': 'gridView'};
      final layout = js.fromJson<SectionLayout>(json);
      expect(layout, isA<SectionLayoutGridView>());
    });

    test('fromJson gridPattern with extra field', () {
      final json = {'type': 'gridPattern', 'pattern': 'zigzag'};
      final layout = js.fromJson<SectionLayout>(json);
      expect(layout, isA<SectionLayoutGridPattern>());
      expect((layout as SectionLayoutGridPattern).pattern, 'zigzag');
    });

    test('fromJson carousel', () {
      final json = {'type': 'carousel'};
      final layout = js.fromJson<SectionLayout>(json);
      expect(layout, isA<SectionLayoutCarousel>());
    });

    test('fromJson unknown type falls back', () {
      final json = {'type': 'unknown'};
      final layout = js.fromJson<SectionLayout>(json);
      expect(layout, isA<SectionLayoutUnknown>());
    });

    test('fromJson unrecognized type uses fallback', () {
      final json = {'type': 'some_new_type_from_backend'};
      final layout = js.fromJson<SectionLayout>(json);
      expect(layout, isA<SectionLayoutUnknown>());
    });

    test('round-trip vList', () {
      const original = SectionLayoutVList(shape: DynamicItemShape.circle);
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<SectionLayout>(json);
      expect(restored, isA<SectionLayoutVList>());
      expect(restored.shape, DynamicItemShape.circle);
    });

    test('round-trip gridPattern', () {
      const original =
          SectionLayoutGridPattern(shape: DynamicItemShape.circle, pattern: 'abc');
      final json = js.toJson(original) as Map<String, dynamic>;
      final restored = js.fromJson<SectionLayout>(json);
      expect(restored, isA<SectionLayoutGridPattern>());
      expect((restored as SectionLayoutGridPattern).pattern, 'abc');
    });
  });

  group('SomeGenericModel<T>', () {
    test('fromJson with String type', () {
      final json = {'value': 'hello'};
      final model = js.fromJson<SomeGenericModel<String>>(json);
      expect(model.value, 'hello');
    });

    test('fromJson with int type', () {
      final json = {'value': 42};
      final model = js.fromJson<SomeGenericModel<int>>(json);
      expect(model.value, 42);
    });

    test('round-trip with extras', () {
      final json = {
        'value': 'test',
        'unknown_field': 'extra_data',
      };
      final model = js.fromJson<SomeGenericModel<String>>(json);
      expect(model.value, 'test');
      expect(model.extras['unknown_field'], 'extra_data');

      final outputJson = js.toJson(model) as Map<String, dynamic>;
      final restored = js.fromJson<SomeGenericModel<String>>(outputJson);
      expect(restored.value, 'test');
      expect(restored.extras['unknown_field'], 'extra_data');
    });
  });

  group('SemiComplicatedModel<T>', () {
    Map<String, dynamic> makeSemiComplicatedJson() => {
          'value': 'root',
          'name': 'Test Model',
          'age': 30,
          'isAdult': true,
          'height': 1.75,
          'friends': ['Alice', 'Bob'],
          'map': {'key1': 'val1', 'nested': {'deep': true}},
          'values': ['v1', 'v2', 'v3'],
          'mapValues': {'k1': 'mv1', 'k2': 'mv2'},
          'nestedValues': [
            ['a1', 'a2'],
            ['b1'],
          ],
          'nestedMapValues': {
            'group1': ['x1', 'x2'],
            'group2': ['y1'],
          },
          'nestedValuesMap': [
            {'name': 'Alice'},
            {'name': 'Bob'},
          ],
          'nestedMapValuesMap': {
            'teams': [
              {'lead': 'Alice'},
            ],
          },
          'nestedValuesMapList': [
            [
              {'a': '1'},
            ],
          ],
          'nestedValuesMapListList': [
            [
              {'colors': ['red', 'blue']},
            ],
          ],
          'nestedMapValuesMapListList': {
            'section1': [
              {'opts': ['o1', 'o2']},
            ],
          },
        };

    test('fromJson parses all fields', () {
      final json = makeSemiComplicatedJson();
      final model = js.fromJson<SemiComplicatedModel<String>>(json);

      expect(model.value, 'root');
      expect(model.name, 'Test Model');
      expect(model.age, 30);
      expect(model.isAdult, true);
      expect(model.height, 1.75);
      expect(model.friends, ['Alice', 'Bob']);
      expect(model.values, ['v1', 'v2', 'v3']);
      expect(model.mapValues, {'k1': 'mv1', 'k2': 'mv2'});
      expect(model.nestedValues[0], ['a1', 'a2']);
      expect(model.nestedValues[1], ['b1']);
      expect(model.nestedMapValues['group1'], ['x1', 'x2']);
      expect(model.nestedValuesMap[0], {'name': 'Alice'});
    });

    test('toJson', () {
      final json = makeSemiComplicatedJson();
      final model = js.fromJson<SemiComplicatedModel<String>>(json);
      final outputJson = js.toJson(model) as Map<String, dynamic>;

      expect(outputJson['value'], 'root');
      expect(outputJson['name'], 'Test Model');
      expect(outputJson['age'], 30);
      expect(outputJson['isAdult'], true);
      expect(outputJson['friends'], ['Alice', 'Bob']);
      expect(outputJson['values'], ['v1', 'v2', 'v3']);
    });

    test('round-trip preserves nested collections', () {
      final json = makeSemiComplicatedJson();
      final model = js.fromJson<SemiComplicatedModel<String>>(json);
      final outputJson = js.toJson(model) as Map<String, dynamic>;
      final restored = js.fromJson<SemiComplicatedModel<String>>(outputJson);

      expect(restored.value, model.value);
      expect(restored.name, model.name);
      expect(restored.age, model.age);
      expect(restored.values, model.values);
      expect(restored.mapValues, model.mapValues);
      expect(restored.nestedValues, model.nestedValues);
      expect(restored.nestedMapValues, model.nestedMapValues);
      expect(restored.nestedValuesMap, model.nestedValuesMap);
      expect(restored.nestedValuesMapList, model.nestedValuesMapList);
      expect(restored.nestedValuesMapListList, model.nestedValuesMapListList);
      expect(restored.nestedMapValuesMapListList, model.nestedMapValuesMapListList);
    });
  });

  group('SuperComplicatedModel<T> (nested generic inheritance)', () {
    // Helper: creates a minimal ComplicatedModel<String> JSON
    Map<String, dynamic> minComplicatedJson(String value) => {
          'value': value,
          'name': 'n',
          'age': 1,
          'isAdult': true,
          'height': 1.0,
          'friends': [],
          'map': {},
          'values': [],
          'mapValues': {},
          'nestedValues': [],
          'nestedMapValues': {},
          'nestedValuesMap': [],
          'nestedMapValuesMap': {},
          'nestedValuesMapList': [],
          'nestedMapValuesMapList': {},
          'nestedValuesMapListList': [],
          'nestedMapValuesMapListList': {},
          'nestedValuesMapListListList': [],
          'nestedMapValuesMapListListList': {},
          'nestedValuesMapListListListList': [],
          'nestedMapValuesMapListListListList': {},
          'nestedValuesMapListListListListList': [],
          'nestedMapValuesMapListListListListList': {},
          'nestedValuesMapListListListListListList': [],
          'nestedMapValuesMapListListListListListList': {},
          'nestedValuesMapListListListListListListList': [],
          'nestedMapValuesMapListListListListListListList': {},
          'nestedValuesMapListListListListListListListList': [],
          'nestedMapValuesMapListListListListListListListList': {},
          'nestedValuesMapListListListListListListListListList': [],
        };

    // ComplicatedModel<ComplicatedModel<String>>
    Map<String, dynamic> complicatedOfComplicatedJson() =>
        minComplicatedJson('placeholder')
          ..['value'] = minComplicatedJson('inner_string');

    test('fromJson parses inherited fields with substituted generics', () {
      // SuperComplicatedModel<String> extends
      //   ComplicatedModel<ComplicatedModel<ComplicatedModel<String>>>
      // So the inherited `value` field has type ComplicatedModel<ComplicatedModel<String>>
      final json = {
        // `value` is ComplicatedModel<ComplicatedModel<String>>
        'value': complicatedOfComplicatedJson(),
        'name': 'Super',
        'age': 50,
        'isAdult': true,
        'height': 2.0,
        'friends': ['Eve'],
        'map': {'k': 'v'},
        'values': [],
        'mapValues': {},
        'nestedValues': [],
        'nestedMapValues': {},
        'nestedValuesMap': [],
        'nestedMapValuesMap': {},
        'nestedValuesMapList': [],
        'nestedMapValuesMapList': {},
        'nestedValuesMapListList': [],
        'nestedMapValuesMapListList': {},
        'nestedValuesMapListListList': [],
        'nestedMapValuesMapListListList': {},
        'nestedValuesMapListListListList': [],
        'nestedMapValuesMapListListListList': {},
        'nestedValuesMapListListListListList': [],
        'nestedMapValuesMapListListListListList': {},
        'nestedValuesMapListListListListListList': [],
        'nestedMapValuesMapListListListListListList': {},
        'nestedValuesMapListListListListListListList': [],
        'nestedMapValuesMapListListListListListListList': {},
        'nestedValuesMapListListListListListListListList': [],
        'nestedMapValuesMapListListListListListListListList': {},
        'nestedValuesMapListListListListListListListListList': [],
        // SuperComplicatedModel's own fields
        // theModel is ComplicatedModel<String>
        'theModel': minComplicatedJson('model1'),
        // theModel2 is ComplicatedModel<ComplicatedModel<String>>
        'theModel2': complicatedOfComplicatedJson(),
        // theModel3 is ComplicatedModel<ComplicatedModel<ComplicatedModel<String>>>
        'theModel3': minComplicatedJson('placeholder')
          ..['value'] = complicatedOfComplicatedJson(),
        // theModel4 is ComplicatedModel<ComplicatedModel<ComplicatedModel<ComplicatedModel<String>>>>
        'theModel4': minComplicatedJson('placeholder')
          ..['value'] = (minComplicatedJson('placeholder')
            ..['value'] = complicatedOfComplicatedJson()),
        // theModel5 is ComplicatedModel<ComplicatedModel<ComplicatedModel<ComplicatedModel<ComplicatedModel<String>>>>>
        'theModel5': minComplicatedJson('placeholder')
          ..['value'] = (minComplicatedJson('placeholder')
            ..['value'] = (minComplicatedJson('placeholder')
              ..['value'] = complicatedOfComplicatedJson())),
        'theModels': [],
      };

      final model = js.fromJson<SuperComplicatedModel<String>>(json);
      expect(model.name, 'Super');
      expect(model.age, 50);
      expect(model.friends, ['Eve']);
      expect(model.theModel.name, 'n');
      expect(model.theModels, isEmpty);
    });

    test('round-trip', () {
      final json = {
        'value': complicatedOfComplicatedJson(),
        'name': 'RoundTrip',
        'age': 25,
        'isAdult': true,
        'height': 1.8,
        'friends': ['A'],
        'map': {'x': 1},
        'values': [],
        'mapValues': {},
        'nestedValues': [],
        'nestedMapValues': {},
        'nestedValuesMap': [],
        'nestedMapValuesMap': {},
        'nestedValuesMapList': [],
        'nestedMapValuesMapList': {},
        'nestedValuesMapListList': [],
        'nestedMapValuesMapListList': {},
        'nestedValuesMapListListList': [],
        'nestedMapValuesMapListListList': {},
        'nestedValuesMapListListListList': [],
        'nestedMapValuesMapListListListList': {},
        'nestedValuesMapListListListListList': [],
        'nestedMapValuesMapListListListListList': {},
        'nestedValuesMapListListListListListList': [],
        'nestedMapValuesMapListListListListListList': {},
        'nestedValuesMapListListListListListListList': [],
        'nestedMapValuesMapListListListListListListList': {},
        'nestedValuesMapListListListListListListListList': [],
        'nestedMapValuesMapListListListListListListListList': {},
        'nestedValuesMapListListListListListListListListList': [],
        'theModel': minComplicatedJson('rt'),
        'theModel2': complicatedOfComplicatedJson(),
        'theModel3': minComplicatedJson('p')..['value'] = complicatedOfComplicatedJson(),
        'theModel4': minComplicatedJson('p')..['value'] = (minComplicatedJson('p')..['value'] = complicatedOfComplicatedJson()),
        'theModel5': minComplicatedJson('p')..['value'] = (minComplicatedJson('p')..['value'] = (minComplicatedJson('p')..['value'] = complicatedOfComplicatedJson())),
        'theModels': [],
      };
      final model = js.fromJson<SuperComplicatedModel<String>>(json);
      final output = js.toJson(model) as Map<String, dynamic>;
      final restored = js.fromJson<SuperComplicatedModel<String>>(output);
      expect(restored.name, model.name);
      expect(restored.age, model.age);
      expect(restored.friends, model.friends);
    });
  });

  group('ComplicatedModel<T>', () {
    Map<String, dynamic> makeComplicatedJson() => {
          'value': 'root_value',
          'name': 'Complicated',
          'age': 42,
          'isAdult': true,
          'height': 1.85,
          'friends': ['Alice', 'Bob', 'Charlie'],
          'map': {'key1': 'value1', 'key2': 42},
          'values': ['v1', 'v2'],
          'mapValues': {'k1': 'mv1'},
          'nestedValues': [
            ['a1', 'a2'],
          ],
          'nestedMapValues': {
            'group1': ['x1'],
          },
          'nestedValuesMap': [
            {'name': 'Alice'},
          ],
          'nestedMapValuesMap': {
            'teams': [
              {'lead': 'Alice'},
            ],
          },
          'nestedValuesMapList': [
            [
              {'a': '1'},
            ],
          ],
          'nestedMapValuesMapList': {
            'sec': [
              {'b': '2'},
            ],
          },
          'nestedValuesMapListList': [
            [
              {'colors': ['red']},
            ],
          ],
          'nestedMapValuesMapListList': {
            's1': [
              {'opts': ['o1']},
            ],
          },
          'nestedValuesMapListListList': [
            [
              {'c': ['c1']},
            ],
          ],
          'nestedMapValuesMapListListList': {
            's2': [
              {'d': ['d1']},
            ],
          },
          'nestedValuesMapListListListList': [
            [
              {'e': ['e1']},
            ],
          ],
          'nestedMapValuesMapListListListList': {
            's3': [
              {'f': ['f1']},
            ],
          },
          'nestedValuesMapListListListListList': [
            [
              {'g': ['g1']},
            ],
          ],
          'nestedMapValuesMapListListListListList': {
            's4': [
              {'h': ['h1']},
            ],
          },
          'nestedValuesMapListListListListListList': [
            [
              {'i': ['i1']},
            ],
          ],
          'nestedMapValuesMapListListListListListList': {
            's5': [
              {'j': ['j1']},
            ],
          },
          'nestedValuesMapListListListListListListList': [
            [
              {'k': ['k1']},
            ],
          ],
          'nestedMapValuesMapListListListListListListList': {
            's6': [
              {'l': ['l1']},
            ],
          },
          'nestedValuesMapListListListListListListListList': [
            [
              {'m': ['m1']},
            ],
          ],
          'nestedMapValuesMapListListListListListListListList': {
            's7': [
              {'n': ['n1']},
            ],
          },
          'nestedValuesMapListListListListListListListListList': [
            [
              {'o': ['o1']},
            ],
          ],
        };

    test('fromJson parses all fields', () {
      final json = makeComplicatedJson();
      final model = js.fromJson<ComplicatedModel<String>>(json);

      expect(model.value, 'root_value');
      expect(model.name, 'Complicated');
      expect(model.age, 42);
      expect(model.isAdult, true);
      expect(model.height, 1.85);
      expect(model.friends, ['Alice', 'Bob', 'Charlie']);
      expect(model.values, ['v1', 'v2']);
      expect(model.mapValues, {'k1': 'mv1'});
      expect(model.nestedValues[0], ['a1', 'a2']);
      expect(model.nestedMapValues['group1'], ['x1']);
    });

    test('round-trip preserves deeply nested collections', () {
      final json = makeComplicatedJson();
      final model = js.fromJson<ComplicatedModel<String>>(json);
      final outputJson = js.toJson(model) as Map<String, dynamic>;
      final restored = js.fromJson<ComplicatedModel<String>>(outputJson);

      expect(restored.value, model.value);
      expect(restored.name, model.name);
      expect(restored.age, model.age);
      expect(restored.values, model.values);
      expect(restored.mapValues, model.mapValues);
      expect(restored.nestedValues, model.nestedValues);
      expect(restored.nestedMapValues, model.nestedMapValues);
      expect(restored.nestedValuesMap, model.nestedValuesMap);
      expect(restored.nestedMapValuesMap, model.nestedMapValuesMap);
      expect(restored.nestedValuesMapList, model.nestedValuesMapList);
      expect(restored.nestedValuesMapListList, model.nestedValuesMapListList);
      expect(restored.nestedMapValuesMapListList, model.nestedMapValuesMapListList);
    });
  });
}
