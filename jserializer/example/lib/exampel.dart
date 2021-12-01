import 'package:json_annotation/json_annotation.dart';

part 'exampel.g.dart';

@JsonSerializable()
class Model {
  Model({
    required this.list,
    required this.list2,
    required this.list3,
    required this.complex,
  });

  @JsonKey()
  final List<List<int>> list;
  final List<Map<String, List<int>>> list2;
  final Map<String, List<List<Map<String, dynamic>>>> list3;
  final Map<int, Model3> complex;
}

@JsonSerializable()
class Model3 {}

@JsonSerializable()
class Model2 {}
