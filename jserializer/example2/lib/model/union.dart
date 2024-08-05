import 'package:jserializer/jserializer.dart';

@jEnum
enum DynamicItemShape {
  circle,
  undefined,
}

@JUnion(fallbackName: 'unknown')
sealed class SectionLayout {
  @JUnionValue.ignore()
  const SectionLayout({
    DynamicItemShape? shape,
  }) : shape = shape ?? DynamicItemShape.undefined;

  const factory SectionLayout.vList({
    DynamicItemShape? shape,
  }) = SectionLayoutVList;

  const factory SectionLayout.hList({
    DynamicItemShape? shape,
  }) = SectionLayoutHList;

  const factory SectionLayout.gridView({
    DynamicItemShape? shape,
  }) = SectionLayoutGridView;

  const factory SectionLayout.gridPattern({
    DynamicItemShape? shape,
    String? pattern,
  }) = SectionLayoutGridPattern;

  const factory SectionLayout.carousel({
    DynamicItemShape? shape,
  }) = SectionLayoutCarousel;

  const factory SectionLayout.unknown() = SectionLayoutUnknown;

  final DynamicItemShape shape;
}

class SectionLayoutVList extends SectionLayout {
  const SectionLayoutVList({super.shape});
}

class SectionLayoutHList extends SectionLayout {
  const SectionLayoutHList({super.shape});
}

class SectionLayoutGridView extends SectionLayout {
  const SectionLayoutGridView({super.shape});
}

class SectionLayoutGridPattern extends SectionLayout {
  const SectionLayoutGridPattern({
    super.shape,
    this.pattern,
  });

  final String? pattern;
}

class SectionLayoutCarousel extends SectionLayout {
  const SectionLayoutCarousel({super.shape});
}

class SectionLayoutUnknown extends SectionLayout {
  const SectionLayoutUnknown();
}
