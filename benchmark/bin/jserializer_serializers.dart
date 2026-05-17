/// JSerializer-based serializers — written in the same style the code generator produces.
/// This is what build_runner would auto-generate from @JSerializable() annotations.
import 'package:jserializer/jserializer.dart';
import 'models.dart';

// ============================================================================
// Price
// ============================================================================
class PriceSerializer extends ModelSerializer<Price> {
  const PriceSerializer({super.jSerializer});

  @override
  Price fromJson(json) => Price(
        amount: safeLookup<double>(
            call: () => (json['amount'] as num).toDouble(),
            jsonKey: 'amount'),
        currency: safeLookup<String?>(
            call: () => json['currency'] as String?,
            jsonKey: 'currency'),
      );

  @override
  Map<String, dynamic> toJson(Price model) => {
        'amount': model.amount,
        'currency': model.currency,
      };
}

// ============================================================================
// Brand
// ============================================================================
class BrandSerializer extends ModelSerializer<Brand> {
  const BrandSerializer({super.jSerializer});

  @override
  Brand fromJson(json) => Brand(
        name: safeLookup<String?>(
            call: () => json['name'] as String?,
            jsonKey: 'name'),
        logo: safeLookup<String?>(
            call: () => json['logo'] as String?,
            jsonKey: 'logo'),
      );

  @override
  Map<String, dynamic> toJson(Brand model) => {
        'name': model.name,
        'logo': model.logo,
      };
}

// ============================================================================
// Category (6 fields)
// ============================================================================
class CategorySerializer extends ModelSerializer<Category> {
  const CategorySerializer({super.jSerializer});

  @override
  Category fromJson(json) => Category(
        id: safeLookup<String?>(
            call: () => json['id'] as String?,
            jsonKey: 'id'),
        banner: safeLookup<String?>(
            call: () => json['banner'] as String?,
            jsonKey: 'banner'),
        service: safeLookup<String?>(
            call: () => json['service'] as String?,
            jsonKey: 'service'),
        featuredImage: safeLookup<String?>(
            call: () => json['featuredImage'] as String?,
            jsonKey: 'featuredImage'),
        images: safeLookup<List<String>?>(
            call: () => (json['images'] as List?)?.cast<String>(),
            jsonKey: 'images'),
        name: safeLookup<String?>(
            call: () => json['name'] as String?,
            jsonKey: 'name'),
      );

  @override
  Map<String, dynamic> toJson(Category model) => {
        'id': model.id,
        'banner': model.banner,
        'service': model.service,
        'featuredImage': model.featuredImage,
        'images': model.images,
        'name': model.name,
      };
}

// ============================================================================
// Tag (4 fields)
// ============================================================================
class TagSerializer extends ModelSerializer<Tag> {
  const TagSerializer({super.jSerializer});

  @override
  Tag fromJson(json) => Tag(
        key: safeLookup<String?>(
            call: () => json['key'] as String?,
            jsonKey: 'key'),
        title: safeLookup<String?>(
            call: () => json['title'] as String?,
            jsonKey: 'title'),
        subTitle: safeLookup<String?>(
            call: () => json['subTitle'] as String?,
            jsonKey: 'subTitle'),
        featuredImage: safeLookup<String?>(
            call: () => json['featuredImage'] as String?,
            jsonKey: 'featuredImage'),
      );

  @override
  Map<String, dynamic> toJson(Tag model) => {
        'key': model.key,
        'title': model.title,
        'subTitle': model.subTitle,
        'featuredImage': model.featuredImage,
      };
}

// ============================================================================
// Vendor (10 fields, nested Category + Price)
// ============================================================================
class VendorSerializer extends ModelSerializer<Vendor> {
  const VendorSerializer({super.jSerializer});

  @override
  Vendor fromJson(json) => Vendor(
        id: safeLookup<String?>(
            call: () => json['id'] as String?,
            jsonKey: 'id'),
        name: safeLookup<String?>(
            call: () => json['name'] as String?,
            jsonKey: 'name'),
        banner: safeLookup<String?>(
            call: () => json['banner'] as String?,
            jsonKey: 'banner'),
        featuredImage: safeLookup<String?>(
            call: () => json['featuredImage'] as String?,
            jsonKey: 'featuredImage'),
        images: safeLookup<List<String>?>(
            call: () => (json['images'] as List?)?.cast<String>(),
            jsonKey: 'images'),
        category: safeLookup<Category?>(
            call: () => jSerializer.fromJson<Category?>(json['category']),
            jsonKey: 'category'),
        service: safeLookup<String?>(
            call: () => json['service'] as String?,
            jsonKey: 'service'),
        isOpen: safeLookup<bool?>(
            call: () => json['isOpen'] as bool?,
            jsonKey: 'isOpen'),
        partnerSupportNumber: safeLookup<String?>(
            call: () => json['partnerSupportNumber'] as String?,
            jsonKey: 'partnerSupportNumber'),
        minimumOrderAmount: safeLookup<Price?>(
            call: () => jSerializer.fromJson<Price?>(json['minimumOrderAmount']),
            jsonKey: 'minimumOrderAmount'),
      );

  @override
  Map<String, dynamic> toJson(Vendor model) => {
        'id': model.id,
        'name': model.name,
        'banner': model.banner,
        'featuredImage': model.featuredImage,
        'images': model.images,
        'category': jSerializer.toJson(model.category),
        'service': model.service,
        'isOpen': model.isOpen,
        'partnerSupportNumber': model.partnerSupportNumber,
        'minimumOrderAmount': jSerializer.toJson(model.minimumOrderAmount),
      };
}

// ============================================================================
// ProductUserSpecific
// ============================================================================
class ProductUserSpecificSerializer extends ModelSerializer<ProductUserSpecific> {
  const ProductUserSpecificSerializer({super.jSerializer});

  @override
  ProductUserSpecific fromJson(json) => ProductUserSpecific(
        isFavorite: safeLookup<bool?>(
            call: () => json['isFavorite'] as bool?,
            jsonKey: 'isFavorite'),
        cartQuantity: safeLookup<int?>(
            call: () => (json['cartQuantity'] as num?)?.toInt(),
            jsonKey: 'cartQuantity'),
      );

  @override
  Map<String, dynamic> toJson(ProductUserSpecific model) => {
        'isFavorite': model.isFavorite,
        'cartQuantity': model.cartQuantity,
      };
}

// ============================================================================
// ProductAttributeValue (4 fields)
// ============================================================================
class ProductAttributeValueSerializer extends ModelSerializer<ProductAttributeValue> {
  const ProductAttributeValueSerializer({super.jSerializer});

  @override
  ProductAttributeValue fromJson(json) => ProductAttributeValue(
        id: safeLookup<String>(
            call: () => json['id'] as String,
            jsonKey: 'id'),
        name: safeLookup<String?>(
            call: () => json['name'] as String?,
            jsonKey: 'name'),
        color: safeLookup<String?>(
            call: () => json['color'] as String?,
            jsonKey: 'color'),
        featuredImage: safeLookup<String?>(
            call: () => json['featuredImage'] as String?,
            jsonKey: 'featuredImage'),
      );

  @override
  Map<String, dynamic> toJson(ProductAttributeValue model) => {
        'id': model.id,
        'name': model.name,
        'color': model.color,
        'featuredImage': model.featuredImage,
      };
}

// ============================================================================
// ProductAttribute (nested list of values)
// ============================================================================
class ProductAttributeSerializer extends ModelSerializer<ProductAttribute> {
  const ProductAttributeSerializer({super.jSerializer});

  @override
  ProductAttribute fromJson(json) => ProductAttribute(
        id: safeLookup<String>(
            call: () => json['id'] as String,
            jsonKey: 'id'),
        name: safeLookup<String?>(
            call: () => json['name'] as String?,
            jsonKey: 'name'),
        values: safeLookup<List<ProductAttributeValue>?>(
            call: () => (json['values'] as List?)
                ?.map((e) => jSerializer.fromJson<ProductAttributeValue>(e))
                .toList(),
            jsonKey: 'values'),
      );

  @override
  Map<String, dynamic> toJson(ProductAttribute model) => {
        'id': model.id,
        'name': model.name,
        'values': jSerializer.toJson(model.values),
      };
}

// ============================================================================
// ProductCustomizationDecoration
// ============================================================================
class ProductCustomizationDecorationSerializer
    extends ModelSerializer<ProductCustomizationDecoration> {
  const ProductCustomizationDecorationSerializer({super.jSerializer});

  @override
  ProductCustomizationDecoration fromJson(json) => ProductCustomizationDecoration(
        title: safeLookup<String?>(
            call: () => json['title'] as String?,
            jsonKey: 'title'),
        preTitle: safeLookup<String?>(
            call: () => json['preTitle'] as String?,
            jsonKey: 'preTitle'),
        subtitle: safeLookup<String?>(
            call: () => json['subtitle'] as String?,
            jsonKey: 'subtitle'),
      );

  @override
  Map<String, dynamic> toJson(ProductCustomizationDecoration model) => {
        'title': model.title,
        'preTitle': model.preTitle,
        'subtitle': model.subtitle,
      };
}

// ============================================================================
// ProductCustomizationValue (5 fields, nested Price)
// ============================================================================
class ProductCustomizationValueSerializer
    extends ModelSerializer<ProductCustomizationValue> {
  const ProductCustomizationValueSerializer({super.jSerializer});

  @override
  ProductCustomizationValue fromJson(json) => ProductCustomizationValue(
        id: safeLookup<String>(
            call: () => json['id'] as String,
            jsonKey: 'id'),
        name: safeLookup<String?>(
            call: () => json['name'] as String?,
            jsonKey: 'name'),
        featuredImage: safeLookup<String?>(
            call: () => json['featuredImage'] as String?,
            jsonKey: 'featuredImage'),
        description: safeLookup<String?>(
            call: () => json['description'] as String?,
            jsonKey: 'description'),
        price: safeLookup<Price?>(
            call: () => jSerializer.fromJson<Price?>(json['price']),
            jsonKey: 'price'),
      );

  @override
  Map<String, dynamic> toJson(ProductCustomizationValue model) => {
        'id': model.id,
        'name': model.name,
        'featuredImage': model.featuredImage,
        'description': model.description,
        'price': jSerializer.toJson(model.price),
      };
}

// ============================================================================
// ProductCustomization (5 fields, nested decoration + list of values)
// ============================================================================
class ProductCustomizationSerializer
    extends ModelSerializer<ProductCustomization> {
  const ProductCustomizationSerializer({super.jSerializer});

  @override
  ProductCustomization fromJson(json) => ProductCustomization(
        id: safeLookup<String>(
            call: () => json['id'] as String,
            jsonKey: 'id'),
        decoration: safeLookup<ProductCustomizationDecoration?>(
            call: () => jSerializer
                .fromJson<ProductCustomizationDecoration?>(json['decoration']),
            jsonKey: 'decoration'),
        minSelection: safeLookup<int?>(
            call: () => (json['min'] as num?)?.toInt(),
            jsonKey: 'min'),
        maxSelection: safeLookup<int?>(
            call: () => (json['max'] as num?)?.toInt(),
            jsonKey: 'max'),
        values: safeLookup<List<ProductCustomizationValue>?>(
            call: () => (json['values'] as List?)
                ?.map((e) => jSerializer.fromJson<ProductCustomizationValue>(e))
                .toList(),
            jsonKey: 'values'),
      );

  @override
  Map<String, dynamic> toJson(ProductCustomization model) => {
        'id': model.id,
        'decoration': jSerializer.toJson(model.decoration),
        'min': model.minSelection,
        'max': model.maxSelection,
        'values': jSerializer.toJson(model.values),
      };
}

// ============================================================================
// Product (26 fields! The big one.)
// ============================================================================
class ProductSerializer extends ModelSerializer<Product> {
  const ProductSerializer({super.jSerializer});

  @override
  Product fromJson(json) => Product(
        id: safeLookup<String>(
            call: () => json['id'] as String,
            jsonKey: 'id'),
        name: safeLookup<String?>(
            call: () => json['name'] as String?,
            jsonKey: 'name'),
        price: safeLookup<Price?>(
            call: () => jSerializer.fromJson<Price?>(json['price']),
            jsonKey: 'price'),
        originalPrice: safeLookup<Price?>(
            call: () => jSerializer.fromJson<Price?>(json['originalPrice']),
            jsonKey: 'originalPrice'),
        featuredImage: safeLookup<String?>(
            call: () => json['featuredImage'] as String?,
            jsonKey: 'featuredImage'),
        images: safeLookup<List<String>?>(
            call: () => (json['images'] as List?)?.cast<String>(),
            jsonKey: 'images'),
        vendor: safeLookup<Vendor?>(
            call: () => jSerializer.fromJson<Vendor?>(json['vendor']),
            jsonKey: 'vendor'),
        currency: safeLookup<String?>(
            call: () => json['currency'] as String?,
            jsonKey: 'currency'),
        maxPurchaseQuantity: safeLookup<int?>(
            call: () => (json['maxPurchaseQuantity'] as num?)?.toInt(),
            jsonKey: 'maxPurchaseQuantity'),
        service: safeLookup<String?>(
            call: () => json['service'] as String?,
            jsonKey: 'service'),
        category: safeLookup<List<Category?>?>(
            call: () => (json['category'] as List?)
                ?.map((e) => jSerializer.fromJson<Category?>(e))
                .toList(),
            jsonKey: 'category'),
        discountRate: safeLookup<String?>(
            call: () => json['discountRate'] as String?,
            jsonKey: 'discountRate'),
        isAvailable: safeLookup<bool?>(
            call: () => json['isAvailable'] as bool?,
            jsonKey: 'isAvailable'),
        description: safeLookup<String?>(
            call: () => json['description'] as String?,
            jsonKey: 'description'),
        tags: safeLookup<List<Tag>?>(
            call: () => (json['tags'] as List?)
                ?.map((e) => jSerializer.fromJson<Tag>(e))
                .toList(),
            jsonKey: 'tags'),
        barcode: safeLookup<String?>(
            call: () => json['barcode'] as String?,
            jsonKey: 'barcode'),
        quantity: safeLookup<int?>(
            call: () => (json['quantity'] as num?)?.toInt(),
            jsonKey: 'quantity'),
        variants: safeLookup<List<Product>?>(
            call: () => (json['variants'] as List?)
                ?.map((e) => jSerializer.fromJson<Product>(e))
                .toList(),
            jsonKey: 'variants'),
        shortUrl: safeLookup<String?>(
            call: () => json['shortUrl'] as String?,
            jsonKey: 'shortUrl'),
        brand: safeLookup<Brand?>(
            call: () => jSerializer.fromJson<Brand?>(json['brand']),
            jsonKey: 'brand'),
        variantsAttributes: safeLookup<List<ProductAttribute>?>(
            call: () => (json['variantsAttributes'] as List?)
                ?.map((e) => jSerializer.fromJson<ProductAttribute>(e))
                .toList(),
            jsonKey: 'variantsAttributes'),
        attributes: safeLookup<List<ProductAttributeValue>?>(
            call: () => (json['attributes'] as List?)
                ?.map((e) => jSerializer.fromJson<ProductAttributeValue>(e))
                .toList(),
            jsonKey: 'attributes'),
        groupReference: safeLookup<String?>(
            call: () => json['groupReference'] as String?,
            jsonKey: 'groupReference'),
        vendorId: safeLookup<String?>(
            call: () => json['vendorId'] as String?,
            jsonKey: 'vendorId'),
        userSpecifics: safeLookup<ProductUserSpecific?>(
            call: () => jSerializer.fromJson<ProductUserSpecific?>(json['userSpecifics']),
            jsonKey: 'userSpecifics'),
        customizations: safeLookup<List<ProductCustomization>?>(
            call: () => (json['customizations'] as List?)
                ?.map((e) => jSerializer.fromJson<ProductCustomization>(e))
                .toList(),
            jsonKey: 'customizations'),
      );

  @override
  Map<String, dynamic> toJson(Product model) => {
        'id': model.id,
        'name': model.name,
        'price': jSerializer.toJson(model.price),
        'originalPrice': jSerializer.toJson(model.originalPrice),
        'featuredImage': model.featuredImage,
        'images': model.images,
        'vendor': jSerializer.toJson(model.vendor),
        'currency': model.currency,
        'maxPurchaseQuantity': model.maxPurchaseQuantity,
        'service': model.service,
        'category': jSerializer.toJson(model.category),
        'discountRate': model.discountRate,
        'isAvailable': model.isAvailable,
        'description': model.description,
        'tags': jSerializer.toJson(model.tags),
        'barcode': model.barcode,
        'quantity': model.quantity,
        'variants': jSerializer.toJson(model.variants),
        'shortUrl': model.shortUrl,
        'brand': jSerializer.toJson(model.brand),
        'variantsAttributes': jSerializer.toJson(model.variantsAttributes),
        'attributes': jSerializer.toJson(model.attributes),
        'groupReference': model.groupReference,
        'vendorId': model.vendorId,
        'userSpecifics': jSerializer.toJson(model.userSpecifics),
        'customizations': jSerializer.toJson(model.customizations),
      };
}

// ============================================================================
// NestedCollectionModel (16 fields, deeply nested collections)
// ============================================================================
class NestedCollectionModelSerializer
    extends ModelSerializer<NestedCollectionModel> {
  const NestedCollectionModelSerializer({super.jSerializer});

  @override
  NestedCollectionModel fromJson(json) => NestedCollectionModel(
        value: safeLookup<String>(
            call: () => json['value'] as String,
            jsonKey: 'value'),
        name: safeLookup<String>(
            call: () => json['name'] as String,
            jsonKey: 'name'),
        age: safeLookup<int>(
            call: () => (json['age'] as num).toInt(),
            jsonKey: 'age'),
        isAdult: safeLookup<bool>(
            call: () => json['isAdult'] as bool,
            jsonKey: 'isAdult'),
        height: safeLookup<double>(
            call: () => (json['height'] as num).toDouble(),
            jsonKey: 'height'),
        friends: safeLookup<List<String>>(
            call: () => (json['friends'] as List).cast<String>(),
            jsonKey: 'friends'),
        map: safeLookup<Map<String, dynamic>>(
            call: () => jSerializer.fromJson<Map<String, dynamic>>(json['map']),
            jsonKey: 'map'),
        values: safeLookup<List<String>>(
            call: () => (json['values'] as List).cast<String>(),
            jsonKey: 'values'),
        mapValues: safeLookup<Map<String, String>>(
            call: () => jSerializer.fromJson<Map<String, String>>(json['mapValues']),
            jsonKey: 'mapValues'),
        nestedValues: safeLookup<List<List<String>>>(
            call: () => jSerializer.fromJson<List<List<String>>>(json['nestedValues']),
            jsonKey: 'nestedValues'),
        nestedMapValues: safeLookup<Map<String, List<String>>>(
            call: () => jSerializer.fromJson<Map<String, List<String>>>(json['nestedMapValues']),
            jsonKey: 'nestedMapValues'),
        nestedValuesMap: safeLookup<List<Map<String, String>>>(
            call: () => jSerializer.fromJson<List<Map<String, String>>>(json['nestedValuesMap']),
            jsonKey: 'nestedValuesMap'),
        nestedMapValuesMap: safeLookup<Map<String, List<Map<String, String>>>>(
            call: () => jSerializer.fromJson<Map<String, List<Map<String, String>>>>(json['nestedMapValuesMap']),
            jsonKey: 'nestedMapValuesMap'),
        nestedValuesMapList: safeLookup<List<List<Map<String, String>>>>(
            call: () => jSerializer.fromJson<List<List<Map<String, String>>>>(json['nestedValuesMapList']),
            jsonKey: 'nestedValuesMapList'),
        nestedValuesMapListList: safeLookup<List<List<Map<String, List<String>>>>>(
            call: () => jSerializer.fromJson<List<List<Map<String, List<String>>>>>(json['nestedValuesMapListList']),
            jsonKey: 'nestedValuesMapListList'),
        nestedMapValuesMapListList: safeLookup<Map<String, List<Map<String, List<String>>>>>(
            call: () => jSerializer.fromJson<Map<String, List<Map<String, List<String>>>>>(json['nestedMapValuesMapListList']),
            jsonKey: 'nestedMapValuesMapListList'),
      );

  @override
  Map<String, dynamic> toJson(NestedCollectionModel model) => {
        'value': model.value,
        'name': model.name,
        'age': model.age,
        'isAdult': model.isAdult,
        'height': model.height,
        'friends': model.friends,
        'map': model.map,
        'values': model.values,
        'mapValues': model.mapValues,
        'nestedValues': model.nestedValues,
        'nestedMapValues': model.nestedMapValues,
        'nestedValuesMap': model.nestedValuesMap,
        'nestedMapValuesMap': model.nestedMapValuesMap,
        'nestedValuesMapList': model.nestedValuesMapList,
        'nestedValuesMapListList': model.nestedValuesMapListList,
        'nestedMapValuesMapListList': model.nestedMapValuesMapListList,
      };
}

// ============================================================================
// PaginationMeta
// ============================================================================
class PaginationMetaSerializer extends ModelSerializer<PaginationMeta> {
  const PaginationMetaSerializer({super.jSerializer});

  @override
  PaginationMeta fromJson(json) => PaginationMeta(
        currentPage: safeLookup<int>(
            call: () => (json['currentPage'] as num).toInt(),
            jsonKey: 'currentPage'),
        totalPages: safeLookup<int>(
            call: () => (json['totalPages'] as num).toInt(),
            jsonKey: 'totalPages'),
        totalItems: safeLookup<int>(
            call: () => (json['totalItems'] as num).toInt(),
            jsonKey: 'totalItems'),
        perPage: safeLookup<int>(
            call: () => (json['perPage'] as num).toInt(),
            jsonKey: 'perPage'),
        nextCursor: safeLookup<String?>(
            call: () => json['nextCursor'] as String?,
            jsonKey: 'nextCursor'),
        prevCursor: safeLookup<String?>(
            call: () => json['prevCursor'] as String?,
            jsonKey: 'prevCursor'),
      );

  @override
  Map<String, dynamic> toJson(PaginationMeta model) => {
        'currentPage': model.currentPage,
        'totalPages': model.totalPages,
        'totalItems': model.totalItems,
        'perPage': model.perPage,
        'nextCursor': model.nextCursor,
        'prevCursor': model.prevCursor,
      };
}

// ============================================================================
// ApiResponse
// ============================================================================
class ApiResponseSerializer extends ModelSerializer<ApiResponse> {
  const ApiResponseSerializer({super.jSerializer});

  @override
  ApiResponse fromJson(json) => ApiResponse(
        success: safeLookup<bool>(
            call: () => json['success'] as bool,
            jsonKey: 'success'),
        data: safeLookup<List<Product>>(
            call: () => (json['data'] as List)
                .map((e) => jSerializer.fromJson<Product>(e))
                .toList(),
            jsonKey: 'data'),
        meta: safeLookup<PaginationMeta>(
            call: () => jSerializer.fromJson<PaginationMeta>(json['meta']),
            jsonKey: 'meta'),
        errors: safeLookup<List<String>?>(
            call: () => (json['errors'] as List?)?.cast<String>(),
            jsonKey: 'errors'),
        timestamp: safeLookup<String>(
            call: () => json['timestamp'] as String,
            jsonKey: 'timestamp'),
      );

  @override
  Map<String, dynamic> toJson(ApiResponse model) => {
        'success': model.success,
        'data': jSerializer.toJson(model.data),
        'meta': jSerializer.toJson(model.meta),
        'errors': model.errors,
        'timestamp': model.timestamp,
      };
}

// ============================================================================
// Registration — what initializeJSerializer() does in real projects
// ============================================================================
void initializeJSerializer() {
  final js = JSerializer.i;

  js.register<Price>(
      (s) => PriceSerializer(jSerializer: s), (Function f) => f<Price>());
  js.register<Brand>(
      (s) => BrandSerializer(jSerializer: s), (Function f) => f<Brand>());
  js.register<Category>(
      (s) => CategorySerializer(jSerializer: s), (Function f) => f<Category>());
  js.register<Tag>(
      (s) => TagSerializer(jSerializer: s), (Function f) => f<Tag>());
  js.register<Vendor>(
      (s) => VendorSerializer(jSerializer: s), (Function f) => f<Vendor>());
  js.register<ProductUserSpecific>(
      (s) => ProductUserSpecificSerializer(jSerializer: s),
      (Function f) => f<ProductUserSpecific>());
  js.register<ProductAttributeValue>(
      (s) => ProductAttributeValueSerializer(jSerializer: s),
      (Function f) => f<ProductAttributeValue>());
  js.register<ProductAttribute>(
      (s) => ProductAttributeSerializer(jSerializer: s),
      (Function f) => f<ProductAttribute>());
  js.register<ProductCustomizationDecoration>(
      (s) => ProductCustomizationDecorationSerializer(jSerializer: s),
      (Function f) => f<ProductCustomizationDecoration>());
  js.register<ProductCustomizationValue>(
      (s) => ProductCustomizationValueSerializer(jSerializer: s),
      (Function f) => f<ProductCustomizationValue>());
  js.register<ProductCustomization>(
      (s) => ProductCustomizationSerializer(jSerializer: s),
      (Function f) => f<ProductCustomization>());
  js.register<Product>(
      (s) => ProductSerializer(jSerializer: s), (Function f) => f<Product>());
  js.register<NestedCollectionModel>(
      (s) => NestedCollectionModelSerializer(jSerializer: s),
      (Function f) => f<NestedCollectionModel>());
  js.register<PaginationMeta>(
      (s) => PaginationMetaSerializer(jSerializer: s),
      (Function f) => f<PaginationMeta>());
  js.register<ApiResponse>(
      (s) => ApiResponseSerializer(jSerializer: s),
      (Function f) => f<ApiResponse>());
}
