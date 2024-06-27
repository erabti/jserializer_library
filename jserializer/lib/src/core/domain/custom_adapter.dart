abstract class CustomAdapter<ModelT, JsonT> {
  const CustomAdapter();

  ModelT fromJson(JsonT json, Map fullJson);

  JsonT toJson(ModelT model);
}
