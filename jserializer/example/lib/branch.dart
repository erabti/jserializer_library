import 'package:flutter/material.dart';
import 'package:jserializer/jserializer.dart';

@JSerializable(
  filterToJsonNulls: true,
  fieldNameCase: FieldNameCase.snake,
)
class Model2<T, R> {
  Model2(
    this.value, {
    required this.wrapper,
    required this.name,
    required this.location,
    required this.isRight,
    required this.city,
    required this.value2,
    required this.hi,
    required this.extras,
    required this.locations,
    required this.v,
    required this.value3,
    this.color,
  });

  final Color? color;
  final T v;
  final Location location;
  final City city;
  final String name;
  final bool isRight;
  final Wrapper<List<int>> value2;
  final Wrapper2<T, R> value3;
  final List<bool> hi;
  final List<M2> locations;
  final Wrapper2<T, num> wrapper;

  final Map<String, dynamic> extras;

  final Wrapper4<int, String, City, List<Branch>> value;
}

@JSerializable(filterToJsonNulls: true)
class M2 {
  M2(this.something);

  final String something;
}

@JSerializable(filterToJsonNulls: true)
class Wrapper4<A, B, C, D> {
  Wrapper4({
    required this.a,
    required this.c,
    this.b,
    required this.d,
    required this.location,
    required this.aaa,
  });

  final Location location;
  final List<A?> a;
  final B? b;
  final Map<String, C> c;
  final Map<String, City> aaa;

  final D d;
}

@JSerializable(filterToJsonNulls: true)
class Wrapper3<A, B, C> {
  Wrapper3({
    required this.a,
    required this.c,
    this.b,
  });

  final List<A> a;
  final B? b;
  final Map<String, C> c;
}

@JSerializable(filterToJsonNulls: true)
class Wrapper2<A, B> {
  Wrapper2({
    required this.a,
    this.b,
  });

  final List<A> a;
  final B? b;
}

@JSerializable(filterToJsonNulls: true)
class Wrapper<T> {
  Wrapper(this.value, this.somethingFunnyy);

  final int somethingFunnyy;

  final List<T> value;
}

@JSerializable(filterToJsonNulls: true)
class Branch {
  const Branch({
    this.id = -1,
    this.name = 'Ali',
    required this.description,
    this.location = const Location(longitude: 'sdf', latitude: 'sdfdsf'),
    this.city = const [],
    this.phones = const [],
    this.emails = const [],
  });

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

  final int? id;

  final String name;

  final String description;

  @JKey()
  final List<String>? phones;

  @JKey()
  final List<String>? emails;
  final List<City>? city;
  final Location? location;
}

@JSerializable()
class Model {
  const Model(this.value);

  final String value;
}

@JSerializable()
class Branch2<T> {
  const Branch2({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.city,
    this.phones,
    this.emails,
  });

  factory Branch2.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) =>
      _$Branch2FromJson(json, fromJsonT);

  final int id;

  final List<String>? phones;

  final List<String>? emails;

  final List<City>? city;
  final String name;

  final String description;

  final T location;
}

@JSerializable()
class Location {
  const Location({required this.longitude, required this.latitude});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  final String longitude;
  final String latitude;
}

@JSerializable()
class City {
  const City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  @IntAdapter2()
  @IntAdapter()
  @JKey()
  final int id;

  final String name;
}

class IntAdapter2 extends CustomAdapter<int, dynamic> {
  const IntAdapter2();

  @override
  dynamic toJson(dynamic json) => json;

  @override
  int fromJson(dynamic json) => (json as int) + 3;
}

class IntAdapter extends CustomAdapter<int, dynamic> {
  const IntAdapter();

  @override
  dynamic toJson(dynamic json) => json;

  @override
  int fromJson(dynamic json) => (json as int) + 3;
}

Branch2<T> _$Branch2FromJson<T>(
  Map<String, dynamic> json,
  T Function(dynamic json) fromJsonT,
) =>
    Branch2<T>(
      emails: (json['emails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      city: (json['city'] as List<dynamic>?)
              ?.map((e) => City.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      location: fromJsonT(json['location']),
    );

Branch _$BranchFromJson(Map<String, dynamic> json) => Branch(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      phones: (json['phones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      emails: (json['emails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      city: (json['city'] as List<dynamic>?)
              ?.map((e) => City.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
    );

City _$CityFromJson(Map<String, dynamic> json) => City(
      id: json['id'] as int,
      name: json['name'] as String,
    );

@jSerializable
class TheContainingModel<T> {
  const TheContainingModel({
    required this.key,
    required this.items,
  });

  final String key;
  final List<T> items;
}

@jSerializable
class TheModel {
  const TheModel({required this.values});

  final List<int> values;
}
