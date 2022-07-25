import 'package:efsqlite/efsqlite.dart';
import 'package:flutter/material.dart';
import './database.dart';

void main() {
  runApp(EfMaterialApp(
    theme: ThemeData(primarySwatch: Colors.blue),
    data: data,
    pages: [
      ModelPage<Todo>(
        page: (scaffold, heightDialog) => ManagePage(
          scaffold: scaffold,
          query: TodosManager,
          heightDialog: heightDialog,
        ),
        table: tb_todos,
        appBarName: "Todos",
        icon: Icons.today_outlined,
      ),
      ModelPage<TodoVaction>(
        page: (scaffold, heightDialog) => ManagePage(
          scaffold: scaffold,
          query: TodoVactionsManager,
          heightDialog: heightDialog,
        ),
        table: tb_todoVactions,
        appBarName: "TodosVaction",
        icon: Icons.card_travel_rounded,
      ),
    ],
    // isDrawer: false, // ---------------------------------------------------------------------------------------
  ));
}
