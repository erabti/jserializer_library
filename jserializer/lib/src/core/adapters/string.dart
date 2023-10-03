import 'package:jserializer/jserializer.dart';

class JStringAdapter extends CustomAdapter<String, dynamic>
    implements JAdapters {
  const JStringAdapter();

  @override
  String fromJson(json) => json.toString();

  @override
  toJson(String? model) => model;
}

class JStringNullableAdapter extends CustomAdapter<String?, dynamic>
    implements JAdapters {
  const JStringNullableAdapter();

  @override
  String? fromJson(json) => json?.toString();

  @override
  toJson(String? model) => model;
}
