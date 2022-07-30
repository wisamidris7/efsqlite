// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names

import 'dart:math';

import 'package:path/path.dart';
import 'package:efsqlite/efsqlite.dart';
import 'package:sqflite/sqflite.dart';

/// [SqliteCommands] Is Class Is Backend Work So Don't Worry It's Auto Using
class SqliteCommands {
  SqliteCommands({required this.sqliteData});

  /// [SqliteData] Has Tables And Data Of Database
  SqliteData sqliteData;

  /// [GetProperties] Function For Get The Properties
  ///
  /// ```
  /// var properties = commands.GetProperties(table);
  /// ```
  String GetProperties(EFTable table) {
    StringBuffer res = StringBuffer();
    for (var property in table.properties!) {
      switch (property.type) {
        case TypeEnum.BOOL:
          res.writeAll([property.name, "INTEGER", ","], " ");
          break;
        case TypeEnum.INT:
          res.writeAll([property.name, "INTEGER", ","], " ");
          break;
        case TypeEnum.STRING:
          res.writeAll([property.name, "TEXT", ","], " ");
          break;
        case TypeEnum.DOUBLE:
          res.writeAll([property.name, "REAL", ","], " ");
          break;
        default:
          break;
      }
    }
    return res.toString().substring(0, res.toString().length - 2);
  }

  /// [DBLoad] Function For Load Db
  ///
  /// [DBLoad] Function will generate the database doesn't exisit
  ///
  /// ```
  /// var db = commands.DBLoad();
  /// ```
  Future<Database> DBLoad() async {
    return openDatabase(
      join(await getDatabasesPath(), "${sqliteData.databaseName}.db"),
      onCreate: (db, version) async {
        if (sqliteData.enableLog && sqliteData.enableSaveLogs) {
          await db.execute(
              "CREATE TABLE EFLogs (id TEXT PRIMARY KEY ,title TEXT , date_log TEXT)");
        }
        await EFPrinter.printing(
            db, "Creating Database ${sqliteData.databaseName}", sqliteData);
        for (var table in sqliteData.tables) {
          await db.execute(
              "CREATE TABLE ${table.tableName} (${table.primaryKeyName} ${table.primrayKeyType == PrimaryKeyEnum.Text ? "TEXT" : "INTEGER"} PRIMARY KEY, ${GetProperties(table)})");

          await EFPrinter.printing(
              db, "Created Table ${table.tableName}", sqliteData);
          for (var property
              in table.properties!.where((element) => element.isIndexed)) {
            int num = Random().nextInt(2000);
            await db.execute(
                "CREATE INDEX ${property.name.toUpperCase()}_${table.tableName}_IX ON ${table.tableName}(${property.name})");
            await EFPrinter.printing(
                db,
                "Created Index ${property.name.toUpperCase()}_${table.tableName}_IX For Table ${table.tableName} Property ${property.name}",
                sqliteData);
          }
          int counter = 0;
          if (table.defaultValues != null) {
            for (var element in table.defaultValues!) {
              counter++;
              var id = counter;
              var map = table.ToMap(element);
              map[table.primaryKeyName] = id;
              await db.insert(table.tableName, map);
            }
            await EFPrinter.printing(
                db,
                "Created Default Data For Table ${table.tableName} Successfully Length : ${table.defaultValues!.length}",
                sqliteData);
          }
        }
        await db.execute(
            "CREATE TABLE EFTables (id TEXT PRIMARY KEY ,tableName TEXT)");
        for (var table in sqliteData.tables) {
          await db.insert("EFTables", {"id": "ID-${table.tableName}"});
        }
        await EFPrinter.printing(
            db,
            "Created Database ${sqliteData.databaseName} Successfully",
            sqliteData);
      },
      version: sqliteData.version,
    );
  }
}
