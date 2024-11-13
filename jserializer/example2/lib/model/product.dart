import 'package:equatable/equatable.dart';
import 'package:example2/model/product_customization.dart';
import 'package:jserializer/jserializer.dart';

@jSerializable
class Product with EquatableMixin {
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
    String? service,
    List<Category?>? category,
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
        _service = service,
        attributes = attributes ?? const [],
        _category = category,
        customizations = customizations ?? const [];

  final String id;
  final String? name;
  final Price? price;
  final String? _service;

  String? get service => _service ?? vendor?.service;
  final String? featuredImage;
  final List<String> images;
  final String? shortUrl;
  final int? maxPurchaseQuantity;
  final String? currency;

  List<Category> get category =>
      _category?.whereType<Category>().toList() ?? [];

  final List<Category?>? _category;

  final Price? originalPrice;
  final String? groupReference;

  // might be deprecated by tags
  final String? discountRate;

  // Might be deprecated in favor of vendorId
  final Vendor? vendor;
  final String? vendorId;
  final bool? isAvailable;
  final String? description;
  final List<Tag>? tags;
  final int? quantity;
  final String? barcode;

  final List<ProductCustomization> customizations;
  final Brand? brand;
  final List<ProductAttribute>? variantsAttributes;
  final List<ProductVariant>? variants;
  final List<ProductAttributeValue> attributes;
  final ProductUserSpecific? userSpecifics;

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        originalPrice,
        featuredImage,
        images,
        vendor,
        currency,
        maxPurchaseQuantity,
        service,
        category,
        discountRate,
        isAvailable,
        description,
        tags,
        barcode,
        quantity,
        variants,
        shortUrl,
        brand,
        variantsAttributes,
        attributes,
        groupReference,
        vendorId,
        userSpecifics,
        customizations,
      ];
}

@jSerializable
class Tag {
  const Tag({
    this.key,
    this.title,
    this.subTitle,
    this.featuredImage,
  });

  final String? key;
  final String? title;
  final String? subTitle;
  final String? featuredImage;
}

@JSerializable(filterToJsonNulls: true)
class Vendor {
  const Vendor({
    this.id,
    this.name,
    this.banner,
    @JKey(fallbackName: 'image_url') this.featuredImage,
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

  String get uniqueId => '$id-$service';

  final bool? isOpen;
  final Price? minimumOrderAmount;
  final String? partnerSupportNumber;
}

@jSerializable
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

@jSerializable
class ProductUserSpecific {
  const ProductUserSpecific({
    this.isFavorite,
    this.cartQuantity,
  });

  final bool? isFavorite;
  final int? cartQuantity;
}

@jSerializable
class ProductAttribute with EquatableMixin {
  const ProductAttribute({required this.id, this.name, this.values});

  final String id;
  final String? name;
  final List<ProductAttributeValue>? values;

  ProductAttribute copyWith({
    String? id,
    String? name,
    List<ProductAttributeValue>? values,
  }) {
    return ProductAttribute(
      id: id ?? this.id,
      name: name ?? this.name,
      values: values ?? this.values,
    );
  }

  @override
  List<Object?> get props => [id];
}

@jSerializable
class ProductAttributeValue with EquatableMixin {
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

  ProductAttributeValue copyWith({
    String? id,
    String? name,
    String? color,
    String? featuredImage,
  }) {
    return ProductAttributeValue(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      featuredImage: featuredImage ?? this.featuredImage,
    );
  }

  @override
  String toString() {
    return 'ProductAttributeValue{id: $id, name: $name}';
  }

  @override
  List<Object?> get props => [id];
}

@jSerializable
class Brand {
  const Brand({
    this.name,
    this.logo,
  });

  final String? name;
  final String? logo;
}

@jSerializable
class ProductVariant extends Product {
  ProductVariant({
    required super.id,
    super.name,
    super.price,
    super.featuredImage,
    super.images,
    super.vendor,
    super.currency,
    super.maxPurchaseQuantity,
    super.service,
    super.category,
    super.originalPrice,
    super.discountRate,
    super.isAvailable,
    super.description,
    super.tags,
    super.barcode,
    super.quantity,
    super.shortUrl,
    super.brand,
    super.variantsAttributes,
    super.attributes,
    super.userSpecifics,
    super.vendorId,
  });

}
