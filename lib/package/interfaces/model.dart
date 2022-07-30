import '../../efsqlite.dart';

/// [IModel] You Should To extends From Him To Model It's So Important
abstract class IModel {
  // If You Override So You Will Create New Instance From Object And You Will Find Add , Update And Other
  ISqliteQuery<IModel>? sqliteQuery;
}
