/// Benchmark models — mirrors the actual project models at realistic complexity.
///
/// Tier 1: Product-like (26 fields, 4 levels deep, nullable, lists, inheritance)
/// Tier 2: SemiComplicatedModel-like (deeply nested generic collections)
/// Tier 3: API response wrapping a list of Tier 1 models

// ============================================================================
// Tier 1: Product ecosystem (mirrors product.dart + product_customization.dart)
// 12 model classes, max depth 4, 26+ fields on root model
// ============================================================================

class Price {
  const Price({required this.amount, this.currency});
  final double amount;
  final String? currency;
}

class Brand {
  const Brand({this.name, this.logo});
  final String? name;
  final String? logo;
}

class Category {
  const Category({
    this.id,
    this.banner,
    this.service,
    this.featuredImage,
    List<String>? images,
    this.name,
  }) : images = images ?? const [];
  final String? service;
  final String? banner;
  final String? featuredImage;
  final String? id;
  final List<String> images;
  final String? name;
}

class Tag {
  const Tag({this.key, this.title, this.subTitle, this.featuredImage});
  final String? key;
  final String? title;
  final String? subTitle;
  final String? featuredImage;
}

class Vendor {
  const Vendor({
    this.id,
    this.name,
    this.banner,
    this.featuredImage,
    List<String>? images,
    this.category,
    this.service,
    this.isOpen,
    this.partnerSupportNumber,
    this.minimumOrderAmount,
  }) : images = images ?? const [];
  final String? banner;
  final Category? category;
  final String? featuredImage;
  final String? id;
  final List<String> images;
  final String? name;
  final String? service;
  final bool? isOpen;
  final Price? minimumOrderAmount;
  final String? partnerSupportNumber;
}

class ProductUserSpecific {
  const ProductUserSpecific({this.isFavorite, this.cartQuantity});
  final bool? isFavorite;
  final int? cartQuantity;
}

class ProductAttributeValue {
  const ProductAttributeValue({
    required this.id,
    this.name,
    this.color,
    this.featuredImage,
  });
  final String id;
  final String? name;
  final String? color;
  final String? featuredImage;
}

class ProductAttribute {
  const ProductAttribute({required this.id, this.name, this.values});
  final String id;
  final String? name;
  final List<ProductAttributeValue>? values;
}

class ProductCustomizationDecoration {
  const ProductCustomizationDecoration({this.title, this.preTitle, this.subtitle});
  final String? title;
  final String? preTitle;
  final String? subtitle;
}

class ProductCustomizationValue {
  const ProductCustomizationValue({
    required this.id,
    this.name,
    this.featuredImage,
    this.description,
    this.price,
  });
  final String id;
  final String? name;
  final String? featuredImage;
  final String? description;
  final Price? price;
}

class ProductCustomization {
  const ProductCustomization({
    required this.id,
    this.decoration,
    this.minSelection,
    this.maxSelection,
    List<ProductCustomizationValue>? values,
  }) : values = values ?? const [];
  final String id;
  final ProductCustomizationDecoration? decoration;
  final int? minSelection;
  final int? maxSelection;
  final List<ProductCustomizationValue> values;
}

/// The big one: 26 fields, mirrors the real Product model.
class Product {
  const Product({
    required this.id,
    this.name,
    this.price,
    this.originalPrice,
    this.featuredImage,
    List<String>? images,
    this.vendor,
    this.currency,
    this.maxPurchaseQuantity,
    this.service,
    this.category,
    this.discountRate,
    this.isAvailable,
    this.description,
    this.tags,
    this.barcode,
    this.quantity,
    this.variants,
    this.shortUrl,
    this.brand,
    this.variantsAttributes,
    List<ProductAttributeValue>? attributes,
    this.groupReference,
    this.vendorId,
    this.userSpecifics,
    List<ProductCustomization>? customizations,
  })  : images = images ?? const [],
        attributes = attributes ?? const [],
        customizations = customizations ?? const [];

  final String id;
  final String? name;
  final Price? price;
  final Price? originalPrice;
  final String? featuredImage;
  final List<String> images;
  final Vendor? vendor;
  final String? currency;
  final int? maxPurchaseQuantity;
  final String? service;
  final List<Category?>? category;
  final String? discountRate;
  final bool? isAvailable;
  final String? description;
  final List<Tag>? tags;
  final String? barcode;
  final int? quantity;
  final List<Product>? variants; // self-referencing variants
  final String? shortUrl;
  final Brand? brand;
  final List<ProductAttribute>? variantsAttributes;
  final List<ProductAttributeValue> attributes;
  final String? groupReference;
  final String? vendorId;
  final ProductUserSpecific? userSpecifics;
  final List<ProductCustomization> customizations;
}

// ============================================================================
// Tier 2: Deeply nested collections (mirrors SemiComplicatedModel)
// ============================================================================

class NestedCollectionModel {
  const NestedCollectionModel({
    required this.value,
    required this.name,
    required this.age,
    required this.isAdult,
    required this.height,
    required this.friends,
    required this.map,
    required this.values,
    required this.mapValues,
    required this.nestedValues,
    required this.nestedMapValues,
    required this.nestedValuesMap,
    required this.nestedMapValuesMap,
    required this.nestedValuesMapList,
    required this.nestedValuesMapListList,
    required this.nestedMapValuesMapListList,
  });

  final String value;
  final String name;
  final int age;
  final bool isAdult;
  final double height;
  final List<String> friends;
  final Map<String, dynamic> map;
  final List<String> values;
  final Map<String, String> mapValues;
  final List<List<String>> nestedValues;                              // depth 2
  final Map<String, List<String>> nestedMapValues;                    // depth 2
  final List<Map<String, String>> nestedValuesMap;                    // depth 2
  final Map<String, List<Map<String, String>>> nestedMapValuesMap;    // depth 3
  final List<List<Map<String, String>>> nestedValuesMapList;          // depth 3
  final List<List<Map<String, List<String>>>> nestedValuesMapListList;           // depth 4
  final Map<String, List<Map<String, List<String>>>> nestedMapValuesMapListList; // depth 4
}

// ============================================================================
// Tier 3: API paginated response wrapping products
// ============================================================================

class PaginationMeta {
  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    this.nextCursor,
    this.prevCursor,
  });
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final String? nextCursor;
  final String? prevCursor;
}

class ApiResponse {
  const ApiResponse({
    required this.success,
    required this.data,
    required this.meta,
    this.errors,
    required this.timestamp,
  });
  final bool success;
  final List<Product> data;
  final PaginationMeta meta;
  final List<String>? errors;
  final String timestamp;
}
