// ignore_for_file: must_be_immutable, prefer_const_constructors, use_function_type_syntax_for_parameters

import '../../efsqlite.dart';
import 'package:flutter/material.dart';

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

  void forEachIndexed(List list, void action(ModelPage element, int index)) {
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

  void forEachIndexed(List list, void action(ModelPage element, int index)) {
    var index = 0;
    for (var element in list) {
      action(element!, index++);
    }
  }
}
