import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeJSerializerX on DartType {
  String getDisplayStringWithoutNullability() {
    final displayString = getDisplayString(withNullability: true);

    return displayString.replaceAll('?', '');
  }
}

extension InterfaceElementX on InterfaceElement {
  PropertyAccessorElement? safeLookupGetter({
    required String name,
    required LibraryElement library,
  }) {
    return lookUpGetter(name, library);
  }

  String getDisplayStringWithoutNullability() {
    final displayString = getDisplayString(withNullability: true);

    return displayString.replaceAll('?', '');
  }
}
