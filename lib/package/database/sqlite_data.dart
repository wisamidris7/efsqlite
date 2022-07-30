import 'package:efsqlite/efsqlite.dart';

/// [SqliteData] has all data like tables
///
/// databaseName , version and other
class SqliteData {
  SqliteData(
      {required this.tables,
      required this.databaseName,
      this.version = 1,
      this.enableLog = true,
      this.enableSaveLogs = true});

  /// [tables] is a property has all tables
  /// ```
  /// tables: [todos_table],
  /// ```
  List<EFTable> tables;

  /// [databaseName] is a property for databaseName
  /// ```
  /// databaseName: "appDb",
  /// ```
  String databaseName;

  /// [version] is a property for version
  /// the default value is 1
  /// ```
  /// version: 2,
  /// ```
  int version;

  /// [enableLog] is a property for logs
  /// so this property to write all proccess in console
  /// the default value is true
  /// ```
  /// enableLog: false,
  /// enableLog: true,
  /// ```
  bool enableLog;

  /// [enableSaveLogs] is a property for logs
  ///
  /// so this property to write all proccess in db
  /// but this needs to [enableLog] to be true
  ///
  /// the default value is false
  /// ```
  /// enableSaveLogs: false,
  /// enableSaveLogs: true,
  /// ```
  bool enableSaveLogs;
}
