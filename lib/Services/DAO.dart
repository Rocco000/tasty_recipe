abstract class DAO<T> {
  Future<String> save(T newItem);

  Future<void> delete(T item);

  Future<T> retrieve(T item);

  Future<String> getId(T item);

  Future<List<T>> getAll();
}
