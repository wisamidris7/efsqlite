// ignore_for_file: overridden_fields, non_constant_identifier_names

import 'package:efsqlite/efsqlite.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteBatch<T extends IModel> {
  SqfliteBatch({required this.data, required this.table}) {
    query = SqliteQuery<T>(data: data, table: table);
  }

  /// [query] is to base query
  late SqliteQuery<T> query;

  /// [batch] is the instace for batch
  late Batch batch;

  /// [data] is class have all data tables connection and other
  SqliteData data;

  /// [table] is the current table has name and propertieses and other
  EFTable<T> table;

  /// [OpenBatch] Function is for open or start batch
  ///
  /// If [OpenBatch] Function Didn't Called Nothing Gonna Load
  ///
  /// ```
  /// await batch.OpenBatch();
  /// ...
  /// await batch.Commit();
  /// ```
  Future<void> OpenBatch() async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    batch = database.batch();
  }

  /// [Add] Function For Add Any Item To Table
  ///
  /// [Add] Function will generate a Late Exception
  /// Because it's need to [OpenBatch] To called
  ///
  /// ```
  /// await batch.Add(Todo(...));
  /// ```
  Future<void> Add(T item) async {
    var items = await query.Get();
    var id = table.primrayKeyType == PrimaryKeyEnum.AutoIncrement
        ? (items.isEmpty ? 1 : table.primaryKeyGet(items.last) + 1)
        : table.primaryKeyGet(item);
    table.primaryKeySet(item, id);
    batch.insert(table.tableName, query.toMap(item));
  }

  /// [Update] Function For Update Any Item To Table
  ///
  /// [Update] Function will generate a Late Exception
  /// Because it's need to [OpenBatch] To called
  ///
  /// ```
  /// batch.Update(Todo(id: 1, ...));
  /// ```
  void Update(T item) {
    var updateId = ("${table.primaryKeyGet(item)}");
    var updateIdText = ("'${table.primaryKeyGet(item)}'");
    batch.update(table.tableName, query.toMap(item),
        where:
            "${table.primaryKeyName} = ${table.primrayKeyType == PrimaryKeyEnum.Text ? updateIdText : updateId}");
  }

  /// [Delete] Function For Delete Any Item From Table
  ///
  /// [Delete] Function will generate a Late Exception
  /// Because it's need to [OpenBatch] To called
  ///
  /// ```
  /// batch.Delete(1);
  /// ```
  void Delete(dynamic id) {
    var updateId = ("$id");
    var updateIdText = ("'$id'");
    batch.delete(table.tableName,
        where:
            "${table.primaryKeyName} = ${table.primrayKeyType == PrimaryKeyEnum.Text ? updateIdText : updateId}");
  }

  /// [Execute] Function For Execute Any Sql Command
  ///
  /// [Execute] Function will generate a Late Exception
  /// Because it's need to [OpenBatch] To called
  ///
  /// ```
  /// batch.Execute("INSERT INTO Todos VALUES (...)");
  /// ```
  Future<void> Execute(String sql) async {
    batch.execute(sql);
  }

  /// [Commit] After Write All Statements This Gonna Commit
  ///
  /// [Commit] Function will generate a Late Exception
  /// Because it's need to [OpenBatch] To called
  ///
  /// ```
  /// await batch.Commit();
  /// ```
  Future<void> Commit() async {
    await batch.commit();
  }
}
