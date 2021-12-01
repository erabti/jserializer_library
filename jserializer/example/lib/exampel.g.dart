// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exampel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
      list: (json['list'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
          .toList(),
      list2: (json['list2'] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as int).toList()),
              ))
          .toList(),
      list3: (json['list3'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => (e as List<dynamic>)
                    .map((e) => e as Map<String, dynamic>)
                    .toList())
                .toList()),
      ),
      complex: (json['complex'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(int.parse(k), Model3.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'list': instance.list,
      'list2': instance.list2,
      'list3': instance.list3,
      'complex': instance.complex.map((k, e) => MapEntry(k.toString(), e)),
    };

Model3 _$Model3FromJson(Map<String, dynamic> json) => Model3();

Map<String, dynamic> _$Model3ToJson(Model3 instance) => <String, dynamic>{};

Model2 _$Model2FromJson(Map<String, dynamic> json) => Model2();

Map<String, dynamic> _$Model2ToJson(Model2 instance) => <String, dynamic>{};
