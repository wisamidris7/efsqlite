// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, unused_local_variable

import 'package:sqflite/sqflite.dart';

import '../../efsqlite.dart';

typedef CreateNewInstance<S extends ISqliteQuery> = S Function(
    SqliteData data, EFTable table);

/// [Provider] Has All DB Things
abstract class Provider<S extends ISqliteQuery> {
  Provider(this.data, this.createInstance) {
    tables = data.tables;
  }

  /// [data] Has DB Data
  SqliteData data;

  /// [sqliteQueries] For Queries
  List<S> sqliteQueries = [];

  /// [tables] Has Tables
  List<EFTable> tables = [];

  /// [createInstance] How To Create ISqliteQuery
  ///
  /// Cause There Types And You Can Make Your Own
  CreateNewInstance<S> createInstance;

  /// [init] Init DB
  void init() {
    sqliteQueries = tables.map((e) => createInstance(data, e)).toList();
  }

  /// [removeDB] Removing DB File From App Data
  Future<void> removeDB() async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    await closeDB();
    await deleteDatabase(database.path);
  }

  /// [GetQueryByTableName] Get Query By Table Name
  S GetQueryByTableName(String tableName) {
    return sqliteQueries
        .firstWhere((element) => element.table.tableName == tableName);
  }

  /// [GetQueryByEFTable] Get Query By Table
  S GetQueryByEFTable(EFTable table) {
    return sqliteQueries
        .firstWhere((element) => element.table.tableName == table.tableName);
  }

  /// [openDB] Opening DB
  Future<Database> openDB() async {
    return await SqliteCommands(sqliteData: data).DBLoad();
  }

  /// [closeDB] Closing DB
  Future<void> closeDB() async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    if (database.isOpen) {
      await EFPrinter.printing(database, "Database Closed Successfully", data);
      await database.close();
    }
  }

  /// [getTables] Get All Tables
  ///
  /// ```
  /// return {
  ///   "id" : "tableName",
  ///   "id2" : "tableName2",
  /// };
  /// ```
  Future<Map<String, String>> getTables() async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var list = await database.query("EFTables");
    Map<String, String> res = {};
    list.forEach((element) {
      res.addAll({element["id"].toString(): element["tableName"].toString()});
    });
    return res;
  }

  /// To Apply Changes For All Databases
  Future<void> Commit() async {
    bool isError = false;
    for (var i = 0; i < SqliteStorage.Actions.length; i++) {
      try {
        SqliteStorage.Actions[i].isDone = true;
        SqliteStorage.Actions[i].value =
            await SqliteStorage.Actions[i].action();
      } catch (e) {
        isError = true;
        break;
      }
    }
    if (isError) {
      for (var i = 0; i < SqliteStorage.Actions.length; i++) {
        if (SqliteStorage.Actions[i].isDone == true) {
          SqliteStorage.Actions[i].isDone = false;
          await SqliteStorage.Actions[i]
              .reverse(SqliteStorage.Actions[i].value);
        }
      }
    }
    for (var item in SqliteStorage.Actions) {}
  }

  /// [Clear] For Clear All Steps
  Future<void> Clear(NumberUndo num, {int? count}) async {
    if (num == NumberUndo.All) {
      SqliteStorage.Actions.clear();
    } else {
      SqliteStorage.Actions.removeRange(
          SqliteStorage.Actions.length - count!, SqliteStorage.Actions.length);
    }
  }

  /// [Execute] For Execute An Action
  Future<void> Execute(String sql) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    await database.execute(sql);
    await EFPrinter.printing(database, "Executed Sql Command", data);
  }

  /// [DropTable]
  Future<void> DropTable(EFTable table) async {
    await Execute("DROP TABLE ${table.tableName}");
  }
}
