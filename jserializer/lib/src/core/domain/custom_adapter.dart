
mixin FromJsonAdapter<Model, Json> {
  Model fromJson(Json json);
}

mixin ToJsonAdapter<Model, Json> {
  Json toJson(Model model);
}

abstract class CustomAdapter<Model, Json>
    with FromJsonAdapter<Model, Json>, ToJsonAdapter<Model, Json> {
  const CustomAdapter();
}
