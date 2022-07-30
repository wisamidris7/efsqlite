import 'package:efsqlite/efsqlite.dart';

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
