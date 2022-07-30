// ignore_for_file: non_constant_identifier_names

import 'package:efsqlite/efsqlite.dart';

extension ModelExtensions<T extends IModel> on IModel {
  /// [toMap] Fuction For Convert From Item To Map

  Map<String, dynamic> toMap(T item, {SqliteQuery<T>? query}) {
    return (query ?? sqliteQuery!).toMap(item);
  }

  /// [fromMap] Fuction For Convert From Map To Item

  T fromMap(Map<String, dynamic> map, {SqliteQuery<T>? query}) {
    return (query ?? sqliteQuery!).fromMap(map) as T;
  }

  /// [Add] Fuction For Add Item To Database

  Future<void> Add(T item, {SqliteQuery<T>? query}) async {
    await (query ?? sqliteQuery!).Add(item) as T;
  }

  /// [Update] Fuction For Update Item From Database

  Future<void> Update(T item, {SqliteQuery<T>? query}) async {
    await (query ?? sqliteQuery!).Update(item);
  }

  /// [Delete] Fuction For Delete Item From Database

  Future<void> Delete(dynamic id, {SqliteQuery<T>? query}) async {
    await (query ?? sqliteQuery!).Delete(id);
  }

  /// [GetById] Get A Item From Database With Id

  Future<T> GetById(dynamic id, {SqliteQuery<T>? query}) async {
    return await (query ?? sqliteQuery!).GetById(id) as T;
  }

  /// [Where] For Get The Items From Database But With Where query

  Future<List<T>> Where(String queryTxt, {SqliteQuery<T>? query}) async {
    return await (query ?? sqliteQuery!).Where(queryTxt) as List<T>;
  }

  /// [FirstOrDefault] For Get The Item From Database But With Where query

  Future<T> FirstOrDefault(String queryTxt, {SqliteQuery<T>? query}) async {
    return await (query ?? sqliteQuery!).FirstOrDefault(queryTxt) as T;
  }

  /// [Get] For Get All Items

  Future<List<T>> Get({SqliteQuery<T>? query}) async {
    return await (query ?? sqliteQuery!).Get() as List<T>;
  }

  /// [Execute] For Execute A Query

  Future<void> Execute(String sql, {SqliteQuery<T>? query}) async {
    await (query ?? sqliteQuery!).Execute(sql);
  }
}
