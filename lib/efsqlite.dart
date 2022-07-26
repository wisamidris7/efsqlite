// import 'dart:math';

// ignore_for_file: non_constant_identifier_names, overridden_fields, prefer_const_constructors, must_be_immutable, use_build_context_synchronously, constant_identifier_names, avoid_print, avoid_renaming_method_parameters

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

/// [SqliteQueryStorage] Class Is Just Add The Events In Place
///
/// Need To Call Commit Function In Provider
///
/// Need To Class To extends from [Provider] Class And Just Call Commit
class SqliteQueryStorage<T extends IModel> extends ISqliteQuery<T> {
  SqliteQueryStorage({required this.data, required this.table})
      : super(data: data, table: table) {
    query = SqliteQuery<T>(data: data, table: table);
  }

  /// [data] For Data Like Tables And Other
  @override
  SqliteData data;

  /// [table] For Current Table
  @override
  EFTable<T> table;
  late SqliteQuery<T> query;

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
    SqliteStorage.Actions.add(ActionModelStorage(action: () async {
      var database = await SqliteCommands(sqliteData: data).DBLoad();
      var items = await Get();
      var id = table.primrayKeyType == PrimaryKeyEnum.AutoIncrement
          ? (items.isEmpty ? 1 : table.primaryKeyGet(items.last) + 1)
          : table.primaryKeyGet(item);
      table.primaryKeySet(item, id);
      await database.insert(table.tableName, toMap(item));
      await EFPrinter.printing(
          database, "Added ${table.tableName} with primary key $id", data);
      return id;
    }, reverse: (id) async {
      await query.Delete(id);
    }));
  }

  /// [Update] Fuction For Update Item From Database
  @override
  Future<void> Update(T item) async {
    SqliteStorage.Actions.add(ActionModelStorage(action: () async {
      var res = await query.GetById(table.primaryKeyGet(item));
      await query.Update(item);
      return res;
    }, reverse: (e) async {
      await query.Update(e);
    }));
  }

  /// [Delete] Fuction For Delete Item From Database

  @override
  Future<void> Delete(dynamic id) async {
    SqliteStorage.Actions.add(ActionModelStorage(action: () async {
      var item = await query.GetById(id);
      await query.Delete(id);
      return item;
    }, reverse: (item) async {
      var database = await SqliteCommands(sqliteData: data).DBLoad();
      var items = await Get();
      int id = 0;
      if (table.primrayKeyType == PrimaryKeyEnum.AutoIncrement) {
        if (SqliteStorage.EndId == 0) {
          id = table.primrayKeyType == PrimaryKeyEnum.AutoIncrement
              ? (items.isEmpty ? 1 : table.primaryKeyGet(items.last) + 1)
              : table.primaryKeyGet(item);
          SqliteStorage.EndId = id;
        } else {
          SqliteStorage.EndId++;
          id = SqliteStorage.EndId;
        }
      } else {
        id = table.primrayKeyType == PrimaryKeyEnum.AutoIncrement
            ? (items.isEmpty ? 1 : table.primaryKeyGet(items.last) + 1)
            : table.primaryKeyGet(item);
      }
      table.primaryKeySet(item, id);
      await database.insert(table.tableName, toMap(item));
      await EFPrinter.printing(
          database, "Added ${table.tableName} with primary key $id", data);
    }));
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
  Future<void> Execute(String sql, {String? reverse}) async {
    SqliteStorage.Actions.add(ActionModelStorage(action: () async {
      await query.Execute(sql);
      return "success";
    }, reverse: (e) async {
      if (reverse != null) {
        await query.Execute(reverse);
      }
    }));
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

/// [SqliteQuery] Class Is For Any Action
class SqliteQuery<T extends IModel> extends ISqliteQuery<T> {
  SqliteQuery({required this.data, required this.table})
      : super(data: data, table: table) {
    sqliteCommands = SqliteCommands(sqliteData: data);
  }

  late SqliteCommands sqliteCommands;

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
    var items = await Get();
    var id = table.primrayKeyType == PrimaryKeyEnum.AutoIncrement
        ? (items.isEmpty ? 1 : table.primaryKeyGet(items.last) + 1)
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

class SqliteStorage {
  static List<ActionModelStorage> Actions = [];
  static int EndId = 0;
}

class ActionModelStorage {
  ActionModelStorage(
      {required this.action,
      required this.reverse,
      this.isDone = false,
      this.value});
  Future<dynamic> Function() action;
  Future<void> Function(dynamic) reverse;
  bool isDone;
  dynamic value;
}

/// [EfMaterialApp] For If You Want To Complate App With Drawer Or BottomNB
class EfMaterialApp extends StatefulWidget {
  EfMaterialApp(
      {Key? key,
      required this.pages,
      required this.data,
      this.navigatorKey,
      this.scaffoldMessengerKey,
      this.title = '',
      this.onGenerateTitle,
      this.color,
      this.theme,
      this.darkTheme,
      this.highContrastTheme,
      this.highContrastDarkTheme,
      this.themeMode = ThemeMode.system,
      this.isDrawer = true})
      : super(key: key) {
    tables = pages.map((e) => e.table).toList();
  }

  /// [tables] Tables Of What Gonna Showed
  late List<EFTable> tables;

  /// [pages] Is For Pages
  List<ModelPage> pages;

  /// [data] For The Class Who Has All Data
  SqliteData data;

  /// MaterialApp property
  final GlobalKey<NavigatorState>? navigatorKey;

  /// MaterialApp property
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// MaterialApp property
  final String title;

  /// MaterialApp property
  final GenerateAppTitle? onGenerateTitle;

  /// MaterialApp property
  final ThemeData? theme;

  /// MaterialApp property
  final ThemeData? darkTheme;

  /// MaterialApp property
  final ThemeData? highContrastTheme;

  /// MaterialApp property
  final ThemeData? highContrastDarkTheme;

  /// MaterialApp property
  final ThemeMode? themeMode;

  /// MaterialApp property
  final Color? color;

  /// [isDrawer] Ask You What Type Of Dashboard
  ///
  /// For : BottomNavigationBar : false
  ///
  /// For : Drawer : true
  bool isDrawer;
  @override
  State<EfMaterialApp> createState() => _EfMaterialAppState();
}

class _EfMaterialAppState extends State<EfMaterialApp> {
  List<ManagePage> pages = [];
  int currentIndex = 0;
  @override
  void initState() {
    update();
    super.initState();
  }

  void update() {
    if (widget.isDrawer) {
      var listDrawer = [];
      forEachIndexed(
        widget.pages,
        (e, index) => listDrawer.add(ListTile(
          leading: Icon(e.icon),
          title: Text(e.appBarName),
          onTap: () {
            currentIndex = index;
            update();
          },
        )),
      );
      var drwr = Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 180,
                color: Colors.blue,
              ),
              SizedBox(
                height: 10,
              ),
              ...listDrawer
            ],
          ),
        ),
      );
      pages = widget.pages
          .map(
            (e) => e.page(
              (b, f) => Scaffold(
                body: b,
                floatingActionButton: f,
                appBar: AppBar(
                  title: Text(e.appBarName),
                ),
                drawer: drwr,
              ),
              300,
            ),
          )
          .toList();
    } else {
      var listBottomNav = <BottomNavigationBarItem>[];
      forEachIndexed(
        widget.pages,
        (e, index) => listBottomNav.add(BottomNavigationBarItem(
          icon: Icon(e.icon),
          label: e.appBarName,
        )),
      );
      var bnb = BottomNavigationBar(
        items: [...listBottomNav],
        currentIndex: currentIndex,
        onTap: (index) {
          currentIndex = index;
          update();
        },
      );
      pages = widget.pages
          .map(
            (e) => e.page(
              (b, f) => Scaffold(
                body: b,
                floatingActionButton: f,
                appBar: AppBar(
                  title: Text(e.appBarName),
                ),
                bottomNavigationBar: bnb,
              ),
              300,
            ),
          )
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: pages[currentIndex],
      navigatorKey: widget.navigatorKey,
      scaffoldMessengerKey: widget.scaffoldMessengerKey,
      title: widget.title,
      onGenerateTitle: widget.onGenerateTitle,
      color: widget.color,
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      themeMode: widget.themeMode,
    );
  }

  void forEachIndexed(
      List list, void Function(ModelPage element, int index) action) {
    var index = 0;
    for (var element in list) {
      action(element!, index++);
    }
  }
}

/// [EfHomePage] For If You Want To Complate App With Drawer Or BottomNB
class EfHomePage extends StatefulWidget {
  EfHomePage(
      {Key? key,
      required this.pages,
      required this.data,
      required this.primaryColor,
      this.isDrawer = true})
      : super(key: key) {
    tables = pages.map((e) => e.table).toList();
  }

  /// [tables] Tables Of What Gonna Showed
  late List<EFTable> tables;

  /// [pages] Is For Pages
  List<ModelPage> pages;

  /// [data] For The Class Who Has All Data
  SqliteData data;

  /// [primaryColor] For Primary Color Of This Dashboard
  Color primaryColor;

  /// [isDrawer] Ask You What Type Of Dashboard
  ///
  /// For : BottomNavigationBar : false
  ///
  /// For : Drawer : true
  bool isDrawer;
  @override
  State<EfHomePage> createState() => _EfHomePageState();
}

/// [ModelPage] Has The Data Of Page
class ModelPage<T extends IModel> {
  ModelPage(
      {required this.page,
      required this.table,
      required this.appBarName,
      required this.icon});

  /// [table] Is For The Current Table
  EFTable<T> table;

  /// [appBarName] Is For The App Bar Name
  String appBarName;

  /// [icon] For The Icon In Drawer Or BottomNB
  IconData icon;

  /// For The ManagePage Has A Page
  ManagePage<T> Function(
    Scaffold Function(Widget body, Widget floatingActionButton) scaffold,
    double heightDialog,
  ) page;
}

class _EfHomePageState extends State<EfHomePage> {
  List<ManagePage> pages = [];
  int currentIndex = 0;
  @override
  void initState() {
    update();
    super.initState();
  }

  void update() {
    if (widget.isDrawer) {
      var listDrawer = [];
      forEachIndexed(
        widget.pages,
        (e, index) => listDrawer.add(ListTile(
          leading: Icon(e.icon),
          title: Text(e.appBarName),
          onTap: () {
            currentIndex = index;
            update();
          },
        )),
      );
      var drwr = Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 180,
                color: Colors.blue,
              ),
              SizedBox(
                height: 10,
              ),
              ...listDrawer
            ],
          ),
        ),
      );
      pages = widget.pages
          .map(
            (e) => e.page(
              (b, f) => Scaffold(
                body: b,
                floatingActionButton: f,
                appBar: AppBar(
                  title: Text(e.appBarName),
                ),
                drawer: drwr,
              ),
              300,
            ),
          )
          .toList();
    } else {
      var listBottomNav = <BottomNavigationBarItem>[];
      forEachIndexed(
        widget.pages,
        (e, index) => listBottomNav.add(BottomNavigationBarItem(
          icon: Icon(e.icon),
          label: e.appBarName,
        )),
      );
      var bnb = BottomNavigationBar(
        items: [...listBottomNav],
        currentIndex: currentIndex,
        onTap: (index) {
          currentIndex = index;
          update();
        },
      );
      pages = widget.pages
          .map(
            (e) => e.page(
              (b, f) => Scaffold(
                body: b,
                floatingActionButton: f,
                appBar: AppBar(
                  title: Text(e.appBarName),
                ),
                bottomNavigationBar: bnb,
              ),
              300,
            ),
          )
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return pages[currentIndex];
  }

  void forEachIndexed(
      List list, void Function(ModelPage element, int index) action) {
    var index = 0;
    for (var element in list) {
      action(element!, index++);
    }
  }
}

/// [ManagePage] Is For A One Page
class ManagePage<T extends IModel> extends StatefulWidget {
  ManagePage(
      {Key? key,
      required this.query,
      required this.scaffold,
      this.heightDialog = 0.5})
      : super(key: key);

  /// How To Create Scaffold The body to body and floatingActionButton to floatingActionButton
  Scaffold Function(Widget body, Widget floatingActionButton) scaffold;

  /// [query] This Is The Current Query
  SqliteQuery<T> query;

  /// [heightDialog] Is For Height For Add Edit Dialog Height
  double heightDialog;
  @override
  State<ManagePage<T>> createState() => _ManagePageState<T>();
}

class _ManagePageState<T extends IModel> extends State<ManagePage<T>> {
  List<T> itemsList = [];

  @override
  void initState() {
    Refresh();
    super.initState();
  }

  void update() {
    setState(() {});
  }

  Refresh() async {
    itemsList = await widget.query.Get();
    update();
  }

  @override
  Widget build(BuildContext context) {
    return widget.scaffold(
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 67,
                columns: widget.query.table.properties!
                    .map((e) => DataColumn(label: Text(e.name)))
                    .toList(),
                rows: itemsList.toList().map((e) {
                  var map = widget.query.toMap(e);
                  return DataRow(
                    onLongPress: () async {
                      var dialog =
                          AddEditDialog(context, isEdit: true, item: e);
                      await showDialog(
                          context: context, builder: (context) => dialog);
                      Refresh();
                    },
                    cells: widget.query.table.properties!
                        .map((ele) => DataCell(Text(map[ele.name].toString())))
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => AddEditDialog(
              context,
            ),
          );
          Refresh();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Dialog AddEditDialog(BuildContext context, {T? item, bool isEdit = false}) {
    var fields = widget.query.table.properties!;
    var list = fields.map((e) {
      // ignore: unnecessary_cast
      return {
        "controller": TextEditingController(
            text: isEdit ? e.propertyGet!(item!).toString() : ""),
        "label": e.name,
        "textField": (controller) => TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: e.name,
              ),
            ),
      } as Map<String, dynamic>;
    }).toList();
    var textFields = list
        .map((e) => ((e["textField"] as dynamic)(e["controller"]) as TextField))
        .toList();
    return Dialog(
      child: SizedBox(
        height: widget.heightDialog,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...(textFields).SelectMulti(() => SizedBox(
                      height: 10,
                    )),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isEdit == true) {
                      var resItem = fromControllerToModel(list);
                      widget.query.table.primaryKeySet(
                          resItem, widget.query.table.primaryKeyGet(item!));
                      await widget.query.Update(resItem);
                      Navigator.of(context).pop();

                      return;
                    }
                    await widget.query.Add(fromControllerToModel(list));
                    Navigator.of(context).pop();
                  },
                  child: Text(isEdit ? "Update" : "Add"),
                ),
                ...isEdit
                    ? [
                        ElevatedButton(
                          onPressed: () async {
                            await widget.query.Delete(
                                widget.query.table.primaryKeyGet(item!));
                            Navigator.of(context).pop();
                          },
                          child: Text("Delete"),
                        )
                      ]
                    : [],
              ],
            ),
          ),
        ),
      ),
    );
  }

  T fromControllerToModel(List<Map<String, dynamic>> list) {
    T item = widget.query.table.newEmptyObject();
    // ignore: prefer_function_declarations_over_variables
    var convert = (elem) {
      var element = widget.query.table.properties!
          .firstWhere((element) => element.name == elem['label'].toString());
      if (element.type == TypeEnum.BOOL) {
        return (elem['controller'] as TextEditingController).text == "true";
      } else if (element.type == TypeEnum.DOUBLE) {
        return double.parse((elem['controller'] as TextEditingController).text);
      } else if (element.type == TypeEnum.INT) {
        return int.parse((elem['controller'] as TextEditingController).text);
      } else {
        return (elem['controller'] as TextEditingController).text.toString();
      }
    };
    for (var e in list) {
      widget.query.table.properties!
          .firstWhere((element) => element.name == e['label'].toString())
          .propertySet!(item, convert(e));
    }
    return item;
  }
}

extension WidgetsList on List<Widget> {
  List<Widget> SelectMulti(Widget Function() seprator) {
    List<Widget> res = [];
    for (var i = 0; i < length; i++) {
      res.add(this[i]);
      res.add(seprator());
    }
    res.removeLast();
    return res;
  }
}

/// [NumberUndo] Is The Type Of Undo
enum NumberUndo {
  /// Num Will Undo With Number Of Steps
  Num,

  /// All Will Undo All Steps
  All,
}

/// [PrimaryKeyEnum] Is The Type Of Primary Key

enum PrimaryKeyEnum {
  /// This Will Make PK AutoIncrement
  AutoIncrement,

  /// This Will Male PK Text Type
  Text,

  /// This Will Make PK Maunlly Set
  Default,
}

/// [TypeEnum] Type Of Type Property
enum TypeEnum {
  INT,
  STRING,
  DOUBLE,
  BOOL,
}

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

class EFPrinter {
  /// Print The Text And Save It In Database
  static Future<void> printing(
      Database db, String text, SqliteData data) async {
    if (data.enableLog) {
      print("EFSqlite : $text , ${DateTime.now().toString()}");
      if (data.enableSaveLogs) {
        await db.insert("EFLogs", {
          "id": text.toUpperCase() +
              Random().nextInt(9999).toString() +
              Random().nextInt(9999).toString() +
              Random().nextInt(9999).toString(),
          "title": text,
          "date_log": DateTime.now().toString(),
        });
      }
    }
  }
}

/// [IModel] You Should To extends From Him To Model It's So Important
abstract class IModel {
  // If You Override So You Will Create New Instance From Object And You Will Find Add , Update And Other
  ISqliteQuery<IModel>? sqliteQuery;
}

abstract class PropertyEnum {
  const PropertyEnum(this.name, this.type, {this.isIndexed = false});
  final bool isIndexed;
  final String name;
  final TypeEnum type;
}

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

typedef PropertyGetDelegate<V, T extends IModel> = V Function(T item);
typedef PropertySetDelegate<I extends IModel, T> = void Function(
    I item, T value);

/// [EFProperty] For The Property
class EFProperty<T extends IModel> {
  EFProperty(
      {this.propertyGet,
      this.propertySet,
      required this.name,
      required this.type,
      this.isIndexed = true});

  /// [name] For Prop Name
  String name;

  /// [type] For The Type
  TypeEnum type;

  /// [isIndexed] This Will Make This Field Indexed
  bool isIndexed;

  /// How to get
  PropertyGetDelegate<dynamic, T>? propertyGet;

  /// How to set
  PropertySetDelegate<T, dynamic>? propertySet;
}

typedef PrimaryKeyGetDelegate<T> = dynamic Function(T item);
typedef PrimaryKeySetDelegate<T> = void Function(T item, dynamic id);
typedef ToMapFunc<T> = Map<String, dynamic> Function(T item);
typedef FromMapFunc<T> = T Function(Map<String, dynamic> map);
typedef NewEmptyObjectDelegate<T> = T Function();

/// [EFTable] For If It Will Be A Table
class EFTable<T extends IModel> {
  EFTable(
      {required this.tableName,
      this.enumProperties,
      this.properties,
      required this.primaryKeyGet,
      required this.primaryKeySet,
      required this.newEmptyObject,
      this.primrayKeyType = PrimaryKeyEnum.Default,
      this.fromMap,
      this.toMap,
      this.isAutoMap = true,
      this.isUseEnum = false,
      this.primaryKeyName = "id",
      this.defaultValues}) {
    if (isUseEnum) {
      isAutoMap = false;
      properties = enumProperties!
          .map((e) => EFProperty<T>(name: e.name, type: e.type))
          .toList();
    }
  }

  /// [tableName] For The TableName
  String tableName;

  /// [isAuto] For If It Will Be Auto Map
  bool isAutoMap;

  /// [isUseEnum] For If You Some Times Use Enum
  bool isUseEnum;

  /// [primaryKeyName] The PrimaryKeyName You Can Just But Him Null For 'id' Name
  String primaryKeyName;

  /// [toMap] If You Turn [IsAutoMap] false So You Need To Assign
  ToMapFunc<T>? toMap;

  /// [fromMap] If You Turn [IsAutoMap] false So You Need To Assign
  FromMapFunc<T>? fromMap;

  /// [properties] For Properties
  List<EFProperty<T>>? properties;

  /// [enumProperties] If You Turn [isUseEnum] So You Need To It
  List<PropertyEnum>? enumProperties = [];

  /// [primaryKeyGet] For How To Get PrimaryKey
  PrimaryKeyGetDelegate<T> primaryKeyGet;

  /// [primaryKeyGet] For How To Set PrimaryKey
  PrimaryKeySetDelegate<T> primaryKeySet;

  /// [newEmptyObject] For How Create New Instace From Object
  NewEmptyObjectDelegate<T> newEmptyObject;

  /// [primrayKeyType] For Type Of PK
  PrimaryKeyEnum primrayKeyType;

  /// [defaultValues] For Default Values Will Generate Just When First Time In DB
  List<T>? defaultValues;

  /// To Get Prop By Enum
  EFProperty<T> GetPropByEnum(PropertyEnum prop) {
    return properties!.firstWhere(
        (element) => element.name == prop.name && element.type == prop.type);
  }

  /// To Get Prop By Name
  EFProperty<T> GetPropByName(String name) {
    return properties!.firstWhere((element) => element.name == name);
  }

  Map<String, dynamic> ToMap(T item) {
    if (isAutoMap) {
      Map<String, dynamic> map = {};
      for (var property in properties!) {
        map.addEntries([
          MapEntry(
              property.name,
              property.type == TypeEnum.BOOL
                  ? (property.propertyGet!(item) == true ? 1 : 0)
                  : property.propertyGet!(item))
        ]);
      }
      map.addEntries([MapEntry(primaryKeyName, primaryKeyGet(item))]);
      return map;
    }
    return toMap!(item);
  }
}

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
    for (var element in list) {
      res.addAll({element["id"].toString(): element["tableName"].toString()});
    }
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
    SqliteStorage.Actions.clear();
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
