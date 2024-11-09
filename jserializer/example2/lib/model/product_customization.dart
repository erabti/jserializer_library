import 'package:equatable/equatable.dart';
import 'package:jserializer/jserializer.dart';

@jSerializable
class ProductCustomization with EquatableMixin {
  const ProductCustomization({
    required this.id,
    this.decoration,
    @JKey(name: 'min') this.minSelection,
    @JKey(name: 'max') this.maxSelection,
    List<ProductCustomizationValue>? values,
  }) : values = values ?? const [];

  factory ProductCustomization.mock() => const ProductCustomization(
        id: '1',
        decoration: ProductCustomizationDecoration(
          title: 'Sauce',
        ),
        values: [
          ProductCustomizationValue(
            id: '1',
            name: 'Ketchup',
            price: Price(amount: 100),
          ),
          ProductCustomizationValue(
            id: '2',
            name: 'Mayo',
            price: Price(amount: 100),
          ),
          ProductCustomizationValue(
            id: '3',
            name: 'Mustard',
            price: Price(amount: 100),
          ),
        ],
      );

  final String id;
  final ProductCustomizationDecoration? decoration;
  final int? minSelection;
  final int? maxSelection;
  final List<ProductCustomizationValue> values;

  bool get isRadio => maxSelection == 1;

  @override
  List<Object?> get props => [
        id,
        decoration,
        minSelection,
        maxSelection,
        values,
      ];

  ProductCustomization copyWith({
    String? id,
    ProductCustomizationDecoration? decoration,
    int? minSelection,
    int? maxSelection,
    List<ProductCustomizationValue>? values,
  }) {
    return ProductCustomization(
      id: id ?? this.id,
      decoration: decoration ?? this.decoration,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
      values: values ?? this.values,
    );
  }
}

typedef SelectedProductCustomizations = Map<String, List<String>>;

extension ProductCustomizationListX on List<ProductCustomization> {
  SelectedProductCustomizations toRawMap() {
    return Map.fromEntries(
      map(
        (e) => MapEntry(
          e.id,
          e.values.map((e) => e.id).toList(),
        ),
      ),
    );
  }
}

@jSerializable
class ProductCustomizationValue with EquatableMixin {
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

  @override
  List<Object?> get props => [id, name, featuredImage, description, price];
}

@jSerializable
class ProductCustomizationDecoration with EquatableMixin {
  const ProductCustomizationDecoration({
    this.title,
    this.preTitle,
    this.subtitle,
  });

  final String? title;
  final String? preTitle;
  final String? subtitle;

  @override
  List<Object?> get props => [title, preTitle, subtitle];
}

@jSerializable
class Price with EquatableMixin {
  const Price({
    required this.amount,
    this.currency,
  });

  final double amount;
  final String? currency;

  @override
  List<Object?> get props => [amount, currency];

  Price copyWith({
    double? amount,
    String? currency,
  }) {
    return Price(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }
}
