import '../../efsqlite.dart';

abstract class PropertyEnum {
  const PropertyEnum(this.name, this.type, {this.isIndexed = false});
  final bool isIndexed;
  final String name;
  final TypeEnum type;
}
