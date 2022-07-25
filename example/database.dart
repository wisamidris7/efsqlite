// ignore_for_file: non_constant_identifier_names

import 'package:efsqlite/efsqlite.dart';

class Todo extends IModel {
  Todo({this.id, this.name, this.isDone});
  int? id;
  String? name;
  bool? isDone;
}

class TodoVaction extends IModel {
  TodoVaction({this.id, this.name, this.isDone});
  int? id;
  String? name;
  bool? isDone;
}

EFTable<Todo> tb_todos = EFTable(
  tableName: "todos",
  primrayKeyType: PrimaryKeyEnum.AutoIncrement,
  properties: [
    EFProperty(
      name: "name",
      type: TypeEnum.STRING,
      propertyGet: (e) => e.name,
      propertySet: (e, v) => e.name = v,
      isIndexed: true,
    ),
    EFProperty(
      name: "isDone",
      type: TypeEnum.BOOL,
      propertySet: (e, v) => e.isDone = v,
      propertyGet: (e) => e.isDone,
    ),
  ],
  primaryKeyGet: (e) => e.id,
  primaryKeySet: (e, v) => e.id = v,
  newEmptyObject: () => Todo(),
);
EFTable<TodoVaction> tb_todoVactions = EFTable(
  tableName: "todoVactions",
  primrayKeyType: PrimaryKeyEnum.AutoIncrement,
  properties: [
    EFProperty(
      name: "name",
      type: TypeEnum.STRING,
      propertyGet: (e) => e.name,
      propertySet: (e, v) => e.name = v,
      isIndexed: true,
    ),
    EFProperty(
      name: "isDone",
      type: TypeEnum.BOOL,
      propertySet: (e, v) => e.isDone = v,
      propertyGet: (e) => e.isDone,
    ),
  ],
  primaryKeyGet: (e) => e.id,
  primaryKeySet: (e, v) => e.id = v,
  newEmptyObject: () => TodoVaction(),
);
SqliteData data =
    SqliteData(tables: [tb_todos, tb_todoVactions], databaseName: "AppDb2");
SqliteQuery<Todo> TodosManager = SqliteQuery(data: data, table: tb_todos);
SqliteQuery<TodoVaction> TodoVactionsManager =
    SqliteQuery(data: data, table: tb_todoVactions);
