// ignore_for_file: non_constant_identifier_names

import '../../efsqlite.dart';

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
