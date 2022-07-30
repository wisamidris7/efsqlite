// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:efsqlite/efsqlite.dart';

class EFPrinter {
  /// Print The Text And Save It In Database
  static Future<void> printing(
      Database db, String text, SqliteData data) async {
    if (data.enableLog) {
      print("EFSqlite : $text , ${DateTime.now().toString()}");
      if (data.enableSaveLogs) {
        await db.insert("EFLogs", {
          "id": text.toUpperCase() +
              Random().nextInt(9).toString() +
              Random().nextInt(9).toString() +
              Random().nextInt(9).toString(),
          "title": text,
          "date_log": DateTime.now().toString(),
        });
      }
    }
  }
}
