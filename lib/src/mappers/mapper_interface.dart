interface class Mapper<Entity, Model> {
  List<Model> toModelList(List<Entity> entities) => throw UnimplementedError();

  Model toModel(Entity entity) => throw UnimplementedError();
}
