// GENERATED CODE. DO NOT MODIFY. Generated by JSerializerGenerator.

import 'package:jserializer/jserializer.dart' as js;
import 'package:example/branch.dart';

class Model2Serializer extends js.GenericModelSerializer2<Model2> {
  Model2Serializer(js.JSerializerInterface jSerializer) : super(jSerializer);

  Model2Serializer.from(
      {required js.Serializer serializer, required js.Serializer serializer2})
      : super.from(serializer: serializer, serializer2: serializer2);

  late final _Wrapper4_int_String_City_List_BranchSerializer =
      Wrapper4Serializer.from(
          serializer: _intSerializer,
          serializer2: _StringSerializer,
          serializer3: _CitySerializer,
          serializer4: _List_BranchSerializer);

  static const _intSerializer = js.PrimitiveSerializer<int>();

  static const _StringSerializer = js.PrimitiveSerializer<String>();

  static const _CitySerializer = CitySerializer();

  late final _List_BranchSerializer =
      js.ListSerializer<Branch>(_BranchSerializer);

  static const _BranchSerializer = BranchSerializer();

  late final _Wrapper2_T_numSerializer = Wrapper2Serializer.from(
      serializer: serializer!, serializer2: _numSerializer);

  static const _numSerializer = js.PrimitiveSerializer<num>();

  static const _LocationSerializer = LocationSerializer();

  late final _Wrapper_List_intSerializer =
      WrapperSerializer.from(serializer: _List_intSerializer);

  late final _List_intSerializer = js.ListSerializer<int>(_intSerializer);

  late final _Wrapper2_T_RSerializer = Wrapper2Serializer.from(
      serializer: serializer!, serializer2: serializer2!);

  static const _M2Serializer = M2Serializer();

  M fromJsonGeneric<M extends Model2, T, R>(json) {
    final value$Json = json['value'];
    final Wrapper4<int, String, City, List<Branch>> value$Value =
        _Wrapper4_int_String_City_List_BranchSerializer.fromJsonGeneric<
            Wrapper4<int, String, City, List<Branch>>,
            int,
            String,
            City,
            List<Branch>>(value$Json);
    final wrapper$Json = json['wrapper'];
    final Wrapper2<T, num> wrapper$Value = jSerializer == null
        ? getGenericValue2<Wrapper2<T, num>, T, num>(
            wrapper$Json, _Wrapper2_T_numSerializer)
        : (jSerializer!.serializerOf<Wrapper2>() as js.GenericModelSerializer2)
            .fromJsonGeneric<Wrapper2<T, num>, T, num>(wrapper$Json);
    final String name$Value = json['name'];
    final location$Json = json['location'];
    final Location location$Value = _LocationSerializer.fromJson(location$Json);
    final bool isRight$Value = json['is_right'];
    final city$Json = json['city'];
    final City city$Value = _CitySerializer.fromJson(city$Json);
    final value2$Json = json['value2'];
    final Wrapper<List<int>> value2$Value = _Wrapper_List_intSerializer
        .fromJsonGeneric<Wrapper<List<int>>, List<int>>(value2$Json);
    final hi$Json = json['hi'];
    final List<bool> hi$Value = List<bool>.from((hi$Json as List));
    final extras$Json = json['extras'];
    final Map<String, dynamic> extras$Value =
        Map<String, dynamic>.from((extras$Json as Map));
    final locations$Json = json['locations'];
    final List<M2> locations$Value = List<M2>.from(
        (locations$Json as List).map((e) => _M2Serializer.fromJson(e)));
    final v$Json = json['v'];
    final T v$Value = getGenericValue<T>(v$Json, serializer);
    final value3$Json = json['value3'];
    final Wrapper2<T, R> value3$Value = jSerializer == null
        ? getGenericValue2<Wrapper2<T, R>, T, R>(
            value3$Json, _Wrapper2_T_RSerializer)
        : (jSerializer!.serializerOf<Wrapper2>() as js.GenericModelSerializer2)
            .fromJsonGeneric<Wrapper2<T, R>, T, R>(value3$Json);
    return (Model2<T, R>(value$Value,
        wrapper: wrapper$Value,
        name: name$Value,
        location: location$Value,
        isRight: isRight$Value,
        city: city$Value,
        value2: value2$Value,
        hi: hi$Value,
        extras: extras$Value,
        locations: locations$Value,
        v: v$Value,
        value3: value3$Value) as M);
  }

  Map<String, dynamic> toJson(Model2 model) => {
        'value':
            _Wrapper4_int_String_City_List_BranchSerializer.toJson(model.value),
        'wrapper': jSerializer == null
            ? getGenericValueToJson(model.wrapper, _Wrapper2_T_numSerializer)
            : (jSerializer!.serializerOf<Wrapper2>()
                    as js.GenericModelSerializer2)
                .toJson(model.wrapper),
        'name': model.name,
        'location': _LocationSerializer.toJson(model.location),
        'is_right': model.isRight,
        'city': _CitySerializer.toJson(model.city),
        'value2': _Wrapper_List_intSerializer.toJson(model.value2),
        'hi': model.hi,
        'extras': model.extras,
        'locations': model.locations.map((e) => _M2Serializer.toJson(e)),
        'v': getGenericValueToJson(model.v, serializer),
        'value3': jSerializer == null
            ? getGenericValueToJson(model.value3, _Wrapper2_T_RSerializer)
            : (jSerializer!.serializerOf<Wrapper2>()
                    as js.GenericModelSerializer2)
                .toJson(model.value3)
      };
}

class M2Serializer extends js.ModelSerializer<M2> {
  const M2Serializer();

  M2 fromJson(json) {
    final String something$Value = json['something'];
    return M2(something$Value);
  }

  Map<String, dynamic> toJson(M2 model) => {'something': model.something};
}

class Wrapper4Serializer extends js.GenericModelSerializer4<Wrapper4> {
  Wrapper4Serializer(js.JSerializerInterface jSerializer) : super(jSerializer);

  Wrapper4Serializer.from(
      {required js.Serializer serializer,
      required js.Serializer serializer2,
      required js.Serializer serializer3,
      required js.Serializer serializer4})
      : super.from(
            serializer: serializer,
            serializer2: serializer2,
            serializer3: serializer3,
            serializer4: serializer4);

  static const _LocationSerializer = LocationSerializer();

  static const _CitySerializer = CitySerializer();

  M fromJsonGeneric<M extends Wrapper4, A, B, C, D>(json) {
    final a$Json = json['a'];
    final List<A?> a$Value = List<A?>.from(
        (a$Json as List).map((e) => getGenericValue<A>(e, serializer)));
    final c$Json = json['c'];
    final Map<String, C> c$Value = Map<String, C>.from((c$Json as Map).map(
        (key, value) => MapEntry(key, getGenericValue<C>(value, serializer3))));
    final b$Json = json['b'];
    final B? b$Value =
        b$Json == null ? null : getGenericValue<B?>(b$Json, serializer2);
    final d$Json = json['d'];
    final D d$Value = getGenericValue<D>(d$Json, serializer4);
    final location$Json = json['location'];
    final Location location$Value = _LocationSerializer.fromJson(location$Json);
    final aaa$Json = json['aaa'];
    final Map<String, City> aaa$Value = Map<String, City>.from((aaa$Json as Map)
        .map((key, value) => MapEntry(key, _CitySerializer.fromJson(value))));
    return (Wrapper4<A, B, C, D>(
        a: a$Value,
        c: c$Value,
        b: b$Value,
        d: d$Value,
        location: location$Value,
        aaa: aaa$Value) as M);
  }

  Map<String, dynamic> toJson(Wrapper4 model) => {
        'a': model.a.map((e) => getGenericValueToJson(e, serializer)),
        'c': model.c.map((key, value) =>
            MapEntry(key, getGenericValueToJson(value, serializer3))),
        if (model.b != null) 'b': getGenericValueToJson(model.b!, serializer2),
        'd': getGenericValueToJson(model.d, serializer4),
        'location': _LocationSerializer.toJson(model.location),
        'aaa': model.aaa
            .map((key, value) => MapEntry(key, _CitySerializer.toJson(value)))
      };
}

class Wrapper3Serializer extends js.GenericModelSerializer3<Wrapper3> {
  Wrapper3Serializer(js.JSerializerInterface jSerializer) : super(jSerializer);

  Wrapper3Serializer.from(
      {required js.Serializer serializer,
      required js.Serializer serializer2,
      required js.Serializer serializer3})
      : super.from(
            serializer: serializer,
            serializer2: serializer2,
            serializer3: serializer3);

  M fromJsonGeneric<M extends Wrapper3, A, B, C>(json) {
    final a$Json = json['a'];
    final List<A> a$Value = List<A>.from(
        (a$Json as List).map((e) => getGenericValue<A>(e, serializer)));
    final c$Json = json['c'];
    final Map<String, C> c$Value = Map<String, C>.from((c$Json as Map).map(
        (key, value) => MapEntry(key, getGenericValue<C>(value, serializer3))));
    final b$Json = json['b'];
    final B? b$Value =
        b$Json == null ? null : getGenericValue<B?>(b$Json, serializer2);
    return (Wrapper3<A, B, C>(a: a$Value, c: c$Value, b: b$Value) as M);
  }

  Map<String, dynamic> toJson(Wrapper3 model) => {
        'a': model.a.map((e) => getGenericValueToJson(e, serializer)),
        'c': model.c.map((key, value) =>
            MapEntry(key, getGenericValueToJson(value, serializer3))),
        if (model.b != null) 'b': getGenericValueToJson(model.b!, serializer2)
      };
}

class Wrapper2Serializer extends js.GenericModelSerializer2<Wrapper2> {
  Wrapper2Serializer(js.JSerializerInterface jSerializer) : super(jSerializer);

  Wrapper2Serializer.from(
      {required js.Serializer serializer, required js.Serializer serializer2})
      : super.from(serializer: serializer, serializer2: serializer2);

  M fromJsonGeneric<M extends Wrapper2, A, B>(json) {
    final a$Json = json['a'];
    final List<A> a$Value = List<A>.from(
        (a$Json as List).map((e) => getGenericValue<A>(e, serializer)));
    final b$Json = json['b'];
    final B? b$Value =
        b$Json == null ? null : getGenericValue<B?>(b$Json, serializer2);
    return (Wrapper2<A, B>(a: a$Value, b: b$Value) as M);
  }

  Map<String, dynamic> toJson(Wrapper2 model) => {
        'a': model.a.map((e) => getGenericValueToJson(e, serializer)),
        if (model.b != null) 'b': getGenericValueToJson(model.b!, serializer2)
      };
}

class WrapperSerializer extends js.GenericModelSerializer<Wrapper> {
  WrapperSerializer(js.JSerializerInterface jSerializer) : super(jSerializer);

  WrapperSerializer.from({required js.Serializer serializer})
      : super.from(serializer: serializer);

  M fromJsonGeneric<M extends Wrapper, T>(json) {
    final value$Json = json['value'];
    final List<T> value$Value = List<T>.from(
        (value$Json as List).map((e) => getGenericValue<T>(e, serializer)));
    final int somethingFunnyy$Value = json['somethingFunnyy'];
    return (Wrapper<T>(value$Value, somethingFunnyy$Value) as M);
  }

  Map<String, dynamic> toJson(Wrapper model) => {
        'value': model.value.map((e) => getGenericValueToJson(e, serializer)),
        'somethingFunnyy': model.somethingFunnyy
      };
}

class BranchSerializer extends js.ModelSerializer<Branch> {
  const BranchSerializer();

  static const _LocationSerializer = LocationSerializer();

  static const _CitySerializer = CitySerializer();

  Branch fromJson(json) {
    final int id$Value = json['id'] ?? -1;
    final String name$Value = json['name'] ?? 'Ali';
    final String description$Value = json['description'];
    final location$Json = json['location'];
    final Location? location$Value = location$Json == null
        ? const Location(longitude: 'sdf', latitude: 'sdfdsf')
        : _LocationSerializer.fromJson(location$Json);
    final city$Json = json['city'];
    final List<City>? city$Value = city$Json == null
        ? const []
        : List<City>.from(
            (city$Json as List).map((e) => _CitySerializer.fromJson(e)));
    final phones$Json = json['phones'];
    final List<String>? phones$Value = phones$Json == null
        ? const []
        : List<String>.from((phones$Json as List));
    final emails$Json = json['emails'];
    final List<String>? emails$Value = emails$Json == null
        ? const []
        : List<String>.from((emails$Json as List));
    return Branch(
        id: id$Value,
        name: name$Value,
        description: description$Value,
        location: location$Value,
        city: city$Value,
        phones: phones$Value,
        emails: emails$Value);
  }

  Map<String, dynamic> toJson(Branch model) => {
        if (model.id != null) 'id': model.id,
        'name': model.name,
        'description': model.description,
        if (model.location != null)
          'location': _LocationSerializer.toJson(model.location!),
        if (model.city != null)
          'city': model.city!.map((e) => _CitySerializer.toJson(e)),
        if (model.phones != null) 'phones': model.phones,
        if (model.emails != null) 'emails': model.emails
      };
}

class ModelSerializer extends js.ModelSerializer<Model> {
  const ModelSerializer();

  Model fromJson(json) {
    final String value$Value = json['value'];
    return Model(value$Value);
  }

  Map<String, dynamic> toJson(Model model) => {'value': model.value};
}

class LocationSerializer extends js.ModelSerializer<Location> {
  const LocationSerializer();

  Location fromJson(json) {
    final String longitude$Value = json['longitude'];
    final String latitude$Value = json['latitude'];
    return Location(longitude: longitude$Value, latitude: latitude$Value);
  }

  Map<String, dynamic> toJson(Location model) =>
      {'longitude': model.longitude, 'latitude': model.latitude};
}

class CitySerializer extends js.ModelSerializer<City> {
  const CitySerializer();

  City fromJson(json) {
    final int id$Value = json['id'];
    final String name$Value = json['name'];
    return City(id: id$Value, name: name$Value);
  }

  Map<String, dynamic> toJson(City model) =>
      {'id': model.id, 'name': model.name};
}

void initializeJSerializer() {
  js.JSerializer.register<Model2>(
      (s) => Model2Serializer(s), <T, R>(f) => f<Model2<T, R>>());
  js.JSerializer.register<M2>((_) => const M2Serializer(), (f) => f<M2>());
  js.JSerializer.register<Wrapper4>((s) => Wrapper4Serializer(s),
      <A, B, C, D>(f) => f<Wrapper4<A, B, C, D>>());
  js.JSerializer.register<Wrapper3>(
      (s) => Wrapper3Serializer(s), <A, B, C>(f) => f<Wrapper3<A, B, C>>());
  js.JSerializer.register<Wrapper2>(
      (s) => Wrapper2Serializer(s), <A, B>(f) => f<Wrapper2<A, B>>());
  js.JSerializer.register<Wrapper>(
      (s) => WrapperSerializer(s), <T>(f) => f<Wrapper<T>>());
  js.JSerializer.register<Branch>(
      (_) => const BranchSerializer(), (f) => f<Branch>());
  js.JSerializer.register<Model>(
      (_) => const ModelSerializer(), (f) => f<Model>());
  js.JSerializer.register<Location>(
      (_) => const LocationSerializer(), (f) => f<Location>());
  js.JSerializer.register<City>(
      (_) => const CitySerializer(), (f) => f<City>());
}
