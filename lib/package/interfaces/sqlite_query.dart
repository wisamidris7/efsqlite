// ignore_for_file: non_constant_identifier_names, avoid_renaming_method_parameters

import '../../efsqlite.dart';

abstract class ISqliteQuery<T extends IModel> {
  ISqliteQuery({required this.data, required this.table});
  SqliteData data;
  EFTable<T> table;

  Map<String, dynamic> toMap(T item);

  T fromMap(Map<String, dynamic> map);

  Future<void> Add(T item);

  Future<void> Update(T item);

  Future<void> Delete(int id);

  Future<T> GetById(int id);

  Future<List<T>> Where(String query);

  Future<T> FirstOrDefault(String query);

  Future<List<T>> Get();
  Future<void> Execute(String sql);
}

abstract class ISqliteQueryWithBase<T extends IModel> extends ISqliteQuery<T> {
  ISqliteQueryWithBase(
      {required super.data, required super.table, required this.query});
  ISqliteQuery<T> query;
  @override
  Map<String, dynamic> toMap(T item) {
    return query.toMap(item);
  }

  @override
  T fromMap(Map<String, dynamic> map) {
    return query.fromMap(map);
  }

  @override
  Future<void> Add(T item) async {
    await query.Add(item);
  }

  @override
  Future<void> Update(T item) async => await query.Update(item);

  @override
  Future<void> Delete(dynamic id) async => await query.Delete(id);

  @override
  Future<T> GetById(dynamic id) async => await query.GetById(id);

  @override
  Future<List<T>> Where(String queryTxt) async => await query.Where(queryTxt);

  @override
  Future<T> FirstOrDefault(String queryTxt) async =>
      await query.FirstOrDefault(queryTxt);

  @override
  Future<List<T>> Get() async => await query.Get();

  @override
  Future<void> Execute(String sql) async => await query.Execute(sql);
}
