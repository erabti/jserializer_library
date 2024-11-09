import 'package:jserializer/jserializer.dart';

@jSerializable
class SuperComplicatedModel<T>
    extends ComplicatedModel<ComplicatedModel<ComplicatedModel<T>>> {
  SuperComplicatedModel({
    required super.value,
    required super.name,
    required super.age,
    required super.isAdult,
    required super.height,
    required super.friends,
    required super.map,
    required super.values,
    required super.mapValues,
    required super.nestedValues,
    required super.nestedMapValues,
    required super.nestedValuesMap,
    required super.nestedMapValuesMap,
    required super.nestedValuesMapList,
    required super.nestedMapValuesMapList,
    required super.nestedValuesMapListList,
    required super.nestedMapValuesMapListList,
    required super.nestedValuesMapListListList,
    required super.nestedMapValuesMapListListList,
    required super.nestedValuesMapListListListList,
    required super.nestedMapValuesMapListListListList,
    required super.nestedValuesMapListListListListList,
    required super.nestedMapValuesMapListListListListList,
    required super.nestedValuesMapListListListListListList,
    required super.nestedMapValuesMapListListListListListList,
    required super.nestedValuesMapListListListListListListList,
    required super.nestedMapValuesMapListListListListListListList,
    required super.nestedValuesMapListListListListListListListList,
    required super.nestedMapValuesMapListListListListListListListList,
    required super.nestedValuesMapListListListListListListListListList,
    required this.theModel,
    required this.theModel2,
    required this.theModel3,
    required this.theModel4,
    required this.theModel5,
    required this.theModels,
  });

  final ComplicatedModel<T> theModel;
  final ComplicatedModel<ComplicatedModel<T>> theModel2;
  final ComplicatedModel<ComplicatedModel<ComplicatedModel<T>>> theModel3;
  final ComplicatedModel<
      ComplicatedModel<ComplicatedModel<ComplicatedModel<T>>>> theModel4;
  final ComplicatedModel<
      ComplicatedModel<
          ComplicatedModel<ComplicatedModel<ComplicatedModel<T>>>>> theModel5;
  final List<ComplicatedModel<T>> theModels;
}

@jSerializable
class ComplicatedModel<T> {
  const ComplicatedModel({
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
    required this.nestedMapValuesMapList,
    required this.nestedValuesMapListList,
    required this.nestedMapValuesMapListList,
    required this.nestedValuesMapListListList,
    required this.nestedMapValuesMapListListList,
    required this.nestedValuesMapListListListList,
    required this.nestedMapValuesMapListListListList,
    required this.nestedValuesMapListListListListList,
    required this.nestedMapValuesMapListListListListList,
    required this.nestedValuesMapListListListListListList,
    required this.nestedMapValuesMapListListListListListList,
    required this.nestedValuesMapListListListListListListList,
    required this.nestedMapValuesMapListListListListListListList,
    required this.nestedValuesMapListListListListListListListList,
    required this.nestedMapValuesMapListListListListListListListList,
    required this.nestedValuesMapListListListListListListListListList,
  });

  final T value;
  final String name;
  final int age;
  final bool isAdult;
  final double height;
  final List<String> friends;
  final Map<String, dynamic> map;
  final List<T> values;
  final Map<String, T> mapValues;
  final List<List<T>> nestedValues;
  final Map<String, List<T>> nestedMapValues;
  final List<Map<String, T>> nestedValuesMap;
  final Map<String, List<Map<String, T>>> nestedMapValuesMap;
  final List<List<Map<String, T>>> nestedValuesMapList;
  final Map<String, List<Map<String, T>>> nestedMapValuesMapList;
  final List<List<Map<String, List<T>>>> nestedValuesMapListList;
  final Map<String, List<Map<String, List<T>>>> nestedMapValuesMapListList;
  final List<List<Map<String, List<T>>>> nestedValuesMapListListList;
  final Map<String, List<Map<String, List<T>>>> nestedMapValuesMapListListList;
  final List<List<Map<String, List<T>>>> nestedValuesMapListListListList;
  final Map<String, List<Map<String, List<T>>>>
      nestedMapValuesMapListListListList;
  final List<List<Map<String, List<T>>>> nestedValuesMapListListListListList;
  final Map<String, List<Map<String, List<T>>>>
      nestedMapValuesMapListListListListList;
  final List<List<Map<String, List<T>>>>
      nestedValuesMapListListListListListList;
  final Map<String, List<Map<String, List<T>>>>
      nestedMapValuesMapListListListListListList;
  final List<List<Map<String, List<T>>>>
      nestedValuesMapListListListListListListList;
  final Map<String, List<Map<String, List<T>>>>
      nestedMapValuesMapListListListListListListList;
  final List<List<Map<String, List<T>>>>
      nestedValuesMapListListListListListListListList;
  final Map<String, List<Map<String, List<T>>>>
      nestedMapValuesMapListListListListListListListList;
  final List<List<Map<String, List<T>>>>
      nestedValuesMapListListListListListListListListList;
}

@jSerializable
class SemiComplicatedModel<T> {
  const SemiComplicatedModel({
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

  final T value;
  final String name;
  final int age;
  final bool isAdult;
  final double height;
  final List<String> friends;
  final Map<String, dynamic> map;
  final List<T> values;
  final Map<String, T> mapValues;
  final List<List<T>> nestedValues;
  final Map<String, List<T>> nestedMapValues;
  final List<Map<String, T>> nestedValuesMap;
  final Map<String, List<Map<String, T>>> nestedMapValuesMap;
  final List<List<Map<String, T>>> nestedValuesMapList;
  final List<List<Map<String, List<T>>>> nestedValuesMapListList;
  final Map<String, List<Map<String, List<T>>>> nestedMapValuesMapListList;
}
