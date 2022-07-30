// ignore_for_file: non_constant_identifier_names

import 'package:efsqlite/efsqlite.dart';

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
