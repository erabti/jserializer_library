/// Vanilla manual fromJson / toJson — the way you'd do it without any library.
/// This is the boilerplate you'd have to write and maintain by hand.
import 'models.dart';

// ---------------------------------------------------------------------------
// Price
// ---------------------------------------------------------------------------
Price priceFromJson(Map<String, dynamic> json) => Price(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> priceToJson(Price m) => {
      'amount': m.amount,
      'currency': m.currency,
    };

// ---------------------------------------------------------------------------
// Brand
// ---------------------------------------------------------------------------
Brand brandFromJson(Map<String, dynamic> json) => Brand(
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );

Map<String, dynamic> brandToJson(Brand m) => {
      'name': m.name,
      'logo': m.logo,
    };

// ---------------------------------------------------------------------------
// Category
// ---------------------------------------------------------------------------
Category categoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as String?,
      banner: json['banner'] as String?,
      service: json['service'] as String?,
      featuredImage: json['featuredImage'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      name: json['name'] as String?,
    );

Map<String, dynamic> categoryToJson(Category m) => {
      'id': m.id,
      'banner': m.banner,
      'service': m.service,
      'featuredImage': m.featuredImage,
      'images': m.images,
      'name': m.name,
    };

// ---------------------------------------------------------------------------
// Tag
// ---------------------------------------------------------------------------
Tag tagFromJson(Map<String, dynamic> json) => Tag(
      key: json['key'] as String?,
      title: json['title'] as String?,
      subTitle: json['subTitle'] as String?,
      featuredImage: json['featuredImage'] as String?,
    );

Map<String, dynamic> tagToJson(Tag m) => {
      'key': m.key,
      'title': m.title,
      'subTitle': m.subTitle,
      'featuredImage': m.featuredImage,
    };

// ---------------------------------------------------------------------------
// Vendor (10 fields, nested Category + Price)
// ---------------------------------------------------------------------------
Vendor vendorFromJson(Map<String, dynamic> json) => Vendor(
      id: json['id'] as String?,
      name: json['name'] as String?,
      banner: json['banner'] as String?,
      featuredImage: json['featuredImage'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      category: json['category'] != null
          ? categoryFromJson(json['category'] as Map<String, dynamic>)
          : null,
      service: json['service'] as String?,
      isOpen: json['isOpen'] as bool?,
      partnerSupportNumber: json['partnerSupportNumber'] as String?,
      minimumOrderAmount: json['minimumOrderAmount'] != null
          ? priceFromJson(json['minimumOrderAmount'] as Map<String, dynamic>)
          : null,
    );

Map<String, dynamic> vendorToJson(Vendor m) => {
      'id': m.id,
      'name': m.name,
      'banner': m.banner,
      'featuredImage': m.featuredImage,
      'images': m.images,
      'category': m.category != null ? categoryToJson(m.category!) : null,
      'service': m.service,
      'isOpen': m.isOpen,
      'partnerSupportNumber': m.partnerSupportNumber,
      'minimumOrderAmount':
          m.minimumOrderAmount != null ? priceToJson(m.minimumOrderAmount!) : null,
    };

// ---------------------------------------------------------------------------
// ProductUserSpecific
// ---------------------------------------------------------------------------
ProductUserSpecific productUserSpecificFromJson(Map<String, dynamic> json) =>
    ProductUserSpecific(
      isFavorite: json['isFavorite'] as bool?,
      cartQuantity: json['cartQuantity'] as int?,
    );

Map<String, dynamic> productUserSpecificToJson(ProductUserSpecific m) => {
      'isFavorite': m.isFavorite,
      'cartQuantity': m.cartQuantity,
    };

// ---------------------------------------------------------------------------
// ProductAttributeValue
// ---------------------------------------------------------------------------
ProductAttributeValue productAttributeValueFromJson(Map<String, dynamic> json) =>
    ProductAttributeValue(
      id: json['id'] as String,
      name: json['name'] as String?,
      color: json['color'] as String?,
      featuredImage: json['featuredImage'] as String?,
    );

Map<String, dynamic> productAttributeValueToJson(ProductAttributeValue m) => {
      'id': m.id,
      'name': m.name,
      'color': m.color,
      'featuredImage': m.featuredImage,
    };

// ---------------------------------------------------------------------------
// ProductAttribute (nested list of ProductAttributeValue)
// ---------------------------------------------------------------------------
ProductAttribute productAttributeFromJson(Map<String, dynamic> json) =>
    ProductAttribute(
      id: json['id'] as String,
      name: json['name'] as String?,
      values: (json['values'] as List?)
          ?.map((e) => productAttributeValueFromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> productAttributeToJson(ProductAttribute m) => {
      'id': m.id,
      'name': m.name,
      'values': m.values?.map(productAttributeValueToJson).toList(),
    };

// ---------------------------------------------------------------------------
// ProductCustomizationDecoration
// ---------------------------------------------------------------------------
ProductCustomizationDecoration productCustomizationDecorationFromJson(
        Map<String, dynamic> json) =>
    ProductCustomizationDecoration(
      title: json['title'] as String?,
      preTitle: json['preTitle'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> productCustomizationDecorationToJson(
        ProductCustomizationDecoration m) =>
    {
      'title': m.title,
      'preTitle': m.preTitle,
      'subtitle': m.subtitle,
    };

// ---------------------------------------------------------------------------
// ProductCustomizationValue (nested Price)
// ---------------------------------------------------------------------------
ProductCustomizationValue productCustomizationValueFromJson(
        Map<String, dynamic> json) =>
    ProductCustomizationValue(
      id: json['id'] as String,
      name: json['name'] as String?,
      featuredImage: json['featuredImage'] as String?,
      description: json['description'] as String?,
      price: json['price'] != null
          ? priceFromJson(json['price'] as Map<String, dynamic>)
          : null,
    );

Map<String, dynamic> productCustomizationValueToJson(
        ProductCustomizationValue m) =>
    {
      'id': m.id,
      'name': m.name,
      'featuredImage': m.featuredImage,
      'description': m.description,
      'price': m.price != null ? priceToJson(m.price!) : null,
    };

// ---------------------------------------------------------------------------
// ProductCustomization (nested decoration + list of values)
// ---------------------------------------------------------------------------
ProductCustomization productCustomizationFromJson(Map<String, dynamic> json) =>
    ProductCustomization(
      id: json['id'] as String,
      decoration: json['decoration'] != null
          ? productCustomizationDecorationFromJson(
              json['decoration'] as Map<String, dynamic>)
          : null,
      minSelection: json['min'] as int?,
      maxSelection: json['max'] as int?,
      values: (json['values'] as List?)
              ?.map((e) =>
                  productCustomizationValueFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> productCustomizationToJson(ProductCustomization m) => {
      'id': m.id,
      'decoration': m.decoration != null
          ? productCustomizationDecorationToJson(m.decoration!)
          : null,
      'min': m.minSelection,
      'max': m.maxSelection,
      'values': m.values.map(productCustomizationValueToJson).toList(),
    };

// ---------------------------------------------------------------------------
// Product (26 fields! The big one. Self-referencing variants.)
// ---------------------------------------------------------------------------
Product productFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String?,
      price: json['price'] != null
          ? priceFromJson(json['price'] as Map<String, dynamic>)
          : null,
      originalPrice: json['originalPrice'] != null
          ? priceFromJson(json['originalPrice'] as Map<String, dynamic>)
          : null,
      featuredImage: json['featuredImage'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      vendor: json['vendor'] != null
          ? vendorFromJson(json['vendor'] as Map<String, dynamic>)
          : null,
      currency: json['currency'] as String?,
      maxPurchaseQuantity: json['maxPurchaseQuantity'] as int?,
      service: json['service'] as String?,
      category: (json['category'] as List?)
          ?.map((e) =>
              e != null ? categoryFromJson(e as Map<String, dynamic>) : null)
          .toList(),
      discountRate: json['discountRate'] as String?,
      isAvailable: json['isAvailable'] as bool?,
      description: json['description'] as String?,
      tags: (json['tags'] as List?)
          ?.map((e) => tagFromJson(e as Map<String, dynamic>))
          .toList(),
      barcode: json['barcode'] as String?,
      quantity: json['quantity'] as int?,
      variants: (json['variants'] as List?)
          ?.map((e) => productFromJson(e as Map<String, dynamic>))
          .toList(),
      shortUrl: json['shortUrl'] as String?,
      brand: json['brand'] != null
          ? brandFromJson(json['brand'] as Map<String, dynamic>)
          : null,
      variantsAttributes: (json['variantsAttributes'] as List?)
          ?.map((e) => productAttributeFromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: (json['attributes'] as List?)
              ?.map((e) =>
                  productAttributeValueFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      groupReference: json['groupReference'] as String?,
      vendorId: json['vendorId'] as String?,
      userSpecifics: json['userSpecifics'] != null
          ? productUserSpecificFromJson(
              json['userSpecifics'] as Map<String, dynamic>)
          : null,
      customizations: (json['customizations'] as List?)
              ?.map((e) =>
                  productCustomizationFromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> productToJson(Product m) => {
      'id': m.id,
      'name': m.name,
      'price': m.price != null ? priceToJson(m.price!) : null,
      'originalPrice':
          m.originalPrice != null ? priceToJson(m.originalPrice!) : null,
      'featuredImage': m.featuredImage,
      'images': m.images,
      'vendor': m.vendor != null ? vendorToJson(m.vendor!) : null,
      'currency': m.currency,
      'maxPurchaseQuantity': m.maxPurchaseQuantity,
      'service': m.service,
      'category': m.category
          ?.map((e) => e != null ? categoryToJson(e) : null)
          .toList(),
      'discountRate': m.discountRate,
      'isAvailable': m.isAvailable,
      'description': m.description,
      'tags': m.tags?.map(tagToJson).toList(),
      'barcode': m.barcode,
      'quantity': m.quantity,
      'variants': m.variants?.map(productToJson).toList(),
      'shortUrl': m.shortUrl,
      'brand': m.brand != null ? brandToJson(m.brand!) : null,
      'variantsAttributes':
          m.variantsAttributes?.map(productAttributeToJson).toList(),
      'attributes': m.attributes.map(productAttributeValueToJson).toList(),
      'groupReference': m.groupReference,
      'vendorId': m.vendorId,
      'userSpecifics': m.userSpecifics != null
          ? productUserSpecificToJson(m.userSpecifics!)
          : null,
      'customizations':
          m.customizations.map(productCustomizationToJson).toList(),
    };

// ---------------------------------------------------------------------------
// NestedCollectionModel (deeply nested List/Map combos)
// ---------------------------------------------------------------------------
NestedCollectionModel nestedCollectionModelFromJson(Map<String, dynamic> json) =>
    NestedCollectionModel(
      value: json['value'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      isAdult: json['isAdult'] as bool,
      height: (json['height'] as num).toDouble(),
      friends: (json['friends'] as List).cast<String>(),
      map: Map<String, dynamic>.from(json['map'] as Map),
      values: (json['values'] as List).cast<String>(),
      mapValues: Map<String, String>.from(json['mapValues'] as Map),
      nestedValues: (json['nestedValues'] as List)
          .map((e) => (e as List).cast<String>())
          .toList(),
      nestedMapValues: (json['nestedMapValues'] as Map).map(
        (k, v) => MapEntry(k as String, (v as List).cast<String>()),
      ),
      nestedValuesMap: (json['nestedValuesMap'] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      nestedMapValuesMap: (json['nestedMapValuesMap'] as Map).map(
        (k, v) => MapEntry(
          k as String,
          (v as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList(),
        ),
      ),
      nestedValuesMapList: (json['nestedValuesMapList'] as List)
          .map((e) => (e as List)
              .map((e2) => Map<String, String>.from(e2 as Map))
              .toList())
          .toList(),
      nestedValuesMapListList: (json['nestedValuesMapListList'] as List)
          .map((e) => (e as List)
              .map((e2) => (e2 as Map).map(
                    (k, v) => MapEntry(k as String, (v as List).cast<String>()),
                  ))
              .toList())
          .toList(),
      nestedMapValuesMapListList:
          (json['nestedMapValuesMapListList'] as Map).map(
        (k, v) => MapEntry(
          k as String,
          (v as List)
              .map((e) => (e as Map).map(
                    (k2, v2) =>
                        MapEntry(k2 as String, (v2 as List).cast<String>()),
                  ))
              .toList(),
        ),
      ),
    );

Map<String, dynamic> nestedCollectionModelToJson(NestedCollectionModel m) => {
      'value': m.value,
      'name': m.name,
      'age': m.age,
      'isAdult': m.isAdult,
      'height': m.height,
      'friends': m.friends,
      'map': m.map,
      'values': m.values,
      'mapValues': m.mapValues,
      'nestedValues': m.nestedValues,
      'nestedMapValues': m.nestedMapValues,
      'nestedValuesMap': m.nestedValuesMap,
      'nestedMapValuesMap': m.nestedMapValuesMap,
      'nestedValuesMapList': m.nestedValuesMapList,
      'nestedValuesMapListList': m.nestedValuesMapListList,
      'nestedMapValuesMapListList': m.nestedMapValuesMapListList,
    };

// ---------------------------------------------------------------------------
// PaginationMeta
// ---------------------------------------------------------------------------
PaginationMeta paginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalItems: json['totalItems'] as int,
      perPage: json['perPage'] as int,
      nextCursor: json['nextCursor'] as String?,
      prevCursor: json['prevCursor'] as String?,
    );

Map<String, dynamic> paginationMetaToJson(PaginationMeta m) => {
      'currentPage': m.currentPage,
      'totalPages': m.totalPages,
      'totalItems': m.totalItems,
      'perPage': m.perPage,
      'nextCursor': m.nextCursor,
      'prevCursor': m.prevCursor,
    };

// ---------------------------------------------------------------------------
// ApiResponse (wraps List<Product>)
// ---------------------------------------------------------------------------
ApiResponse apiResponseFromJson(Map<String, dynamic> json) => ApiResponse(
      success: json['success'] as bool,
      data: (json['data'] as List)
          .map((e) => productFromJson(e as Map<String, dynamic>))
          .toList(),
      meta: paginationMetaFromJson(json['meta'] as Map<String, dynamic>),
      errors: (json['errors'] as List?)?.cast<String>(),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> apiResponseToJson(ApiResponse m) => {
      'success': m.success,
      'data': m.data.map(productToJson).toList(),
      'meta': paginationMetaToJson(m.meta),
      'errors': m.errors,
      'timestamp': m.timestamp,
    };
