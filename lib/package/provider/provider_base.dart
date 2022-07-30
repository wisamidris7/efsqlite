// ignore_for_file: non_constant_identifier_names

import 'package:efsqlite/efsqlite.dart';

/// [ProviderBase] To Provider From One Model
abstract class ProviderBase<S extends ISqliteQuery<I>, I extends IModel> {
  /// You Need To query To Get Actions Form Him
  late S query;
  ProviderBase(Provider provider, String tableName) {
    var list = provider.sqliteQueries;
    query =
        list.firstWhere((element) => element.table.tableName == tableName) as S;
  }

  /// [toMap] Fuction For Convert From Item To Map
  Map<String, dynamic> toMap(I item) {
    return query.toMap(item);
  }

  /// [fromMap] Fuction For Convert From Map To Item

  I fromMap(Map<String, dynamic> map) {
    return query.fromMap(map);
  }

  /// [Add] Fuction For Add Item To Database

  Future<void> Add(I item) async {
    await query.Add(item);
  }

  /// [Update] Fuction For Update Item From Database

  Future<void> Update(I item) async {
    await query.Update(item);
  }

  /// [Delete] Fuction For Delete Item From Database

  Future<void> Delete(dynamic id) async {
    await query.Delete(id);
  }

  /// [GetById] Get A Item From Database With Id

  Future<I> GetById(dynamic id) async {
    return await query.GetById(id);
  }

  /// [Where] For Get The Items From Database But With Where query

  Future<List<I>> Where(String queryTxt) async {
    return await query.Where(queryTxt);
  }

  /// [FirstOrDefault] For Get The Item From Database But With Where query

  Future<I> FirstOrDefault(String queryTxt) async {
    return await query.FirstOrDefault(queryTxt);
  }

  /// [Get] For Get All Items

  Future<List<I>> Get() async {
    return await query.Get();
  }

  /// [Execute] For Execute A Query

  Future<void> Execute(String sql) async {
    await query.Execute(sql);
  }

  /// [GetPropByEnum] Get Property From Table With Details But With Enum

  EFProperty<I> GetPropByEnum(PropertyEnum prop) {
    return query.table.GetPropByEnum(prop);
  }

  /// [GetPropByName] Get Property From Table With Details But With Name Of Property

  EFProperty<I> GetPropByName(String name) {
    return query.table.GetPropByName(name);
  }
}
