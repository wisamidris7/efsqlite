// ignore_for_file: overridden_fields, non_constant_identifier_names

import '../../efsqlite.dart';

/// [SqliteQuery] Class Is For Any Action
class SqliteQuery<T extends IModel> extends ISqliteQuery<T> {
  SqliteQuery({required this.data, required this.table})
      : super(data: data, table: table);

  /// [data] For Data Like Tables And Other

  @override
  SqliteData data;

  /// [table] For Current Table

  @override
  EFTable<T> table;

  /// [toMap] Fuction For Convert From Item To Map

  @override
  Map<String, dynamic> toMap(T item) {
    if (table.isAutoMap) {
      Map<String, dynamic> map = {};
      for (var property in table.properties!) {
        map.addEntries([
          MapEntry(
              property.name,
              property.type == TypeEnum.BOOL
                  ? (property.propertyGet!(item) == true ? 1 : 0)
                  : property.propertyGet!(item))
        ]);
      }
      map.addEntries(
          [MapEntry(table.primaryKeyName, table.primaryKeyGet(item))]);
      return map;
    }
    return table.toMap!(item);
  }

  /// [fromMap] Fuction For Convert From Map To Item

  @override
  T fromMap(Map<String, dynamic> map) {
    if (table.isAutoMap) {
      T newItem = table.newEmptyObject();
      table.primaryKeySet(newItem, map[table.primaryKeyName]);
      for (var propertyItem in table.properties!) {
        propertyItem.propertySet!(
            newItem,
            propertyItem.type == TypeEnum.BOOL
                ? (map[propertyItem.name] == 1)
                : map[propertyItem.name]);
      }
      return newItem;
    }
    return table.fromMap!(map);
  }

  /// [Add] Fuction For Add Item To Database

  @override
  Future<void> Add(T item) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var items = await database.rawQuery(
        "SELECT MAX(${table.primaryKeyName}) as ${table.primaryKeyName} FROM ${table.tableName}");
    var id = table.primrayKeyType == PrimaryKeyEnum.AutoIncrement
        ? ((items.isEmpty
                ? 0
                : int.parse(items.first[table.primaryKeyName].toString())) +
            1)
        : table.primaryKeyGet(item);
    table.primaryKeySet(item, id);
    await database.insert(table.tableName, toMap(item));
    await EFPrinter.printing(
        database, "Added ${table.tableName} with primary key $id", data);
  }

  /// [Update] Fuction For Update Item From Database

  @override
  Future<void> Update(T item) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var updateId = ("${table.primaryKeyGet(item)}");
    var updateIdText = ("'${table.primaryKeyGet(item)}'");
    await database.update(table.tableName, toMap(item),
        where:
            "${table.primaryKeyName} = ${table.primrayKeyType == PrimaryKeyEnum.Text ? updateIdText : updateId}");
    await EFPrinter.printing(database,
        "Updated ${table.tableName} with primary key $updateId", data);
  }

  /// [Delete] Fuction For Delete Item From Database

  @override
  Future<void> Delete(dynamic id) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var updateId = ("$id");
    var updateIdText = ("'$id'");
    await database.delete(table.tableName,
        where:
            "${table.primaryKeyName} = ${table.primrayKeyType == PrimaryKeyEnum.Text ? updateIdText : updateId}");
    await EFPrinter.printing(
        database, "Deleted ${table.tableName} with primary key $id", data);
  }

  /// [GetById] Get A Item From Database With Id

  @override
  Future<T> GetById(dynamic id) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var updateId = ("$id");
    var updateIdText = ("'$id'");
    var value = await database.query(table.tableName,
        where:
            "${table.primaryKeyName} = ${table.primrayKeyType == PrimaryKeyEnum.Text ? updateIdText : updateId}");
    return fromMap(value.first);
  }

  /// [Where] For Get The Items From Database But With Where query

  @override
  Future<List<T>> Where(String query) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var value = await database.query(table.tableName, where: query);
    return value.map((e) => fromMap(e)).toList();
  }

  /// [FirstOrDefault] For Get The Item From Database But With Where query

  @override
  Future<T> FirstOrDefault(String query) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var value = await database.query(table.tableName, where: query);
    return fromMap(value.first);
  }

  /// [Get] For Get All Items

  @override
  Future<List<T>> Get() async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    var value = await database.query(table.tableName);
    var res = <T>[];
    for (var item in value) {
      res.add(fromMap(item));
    }
    return res;
  }

  /// [Execute] For Execute A Query

  @override
  Future<void> Execute(String sql) async {
    var database = await SqliteCommands(sqliteData: data).DBLoad();
    await database.execute(sql);
    await EFPrinter.printing(database, "Executed Sql Command", data);
  }

  /// [GetPropByEnum] Get Property From Table With Details But With Enum

  EFProperty<T> GetPropByEnum(PropertyEnum prop) {
    return table.GetPropByEnum(prop);
  }

  /// [GetPropByName] Get Property From Table With Details But With Name Of Property

  EFProperty<T> GetPropByName(String name) {
    return table.GetPropByName(name);
  }
}
