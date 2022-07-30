// ignore_for_file: non_constant_identifier_names, must_be_immutable, sized_box_for_whitespace, use_build_context_synchronously, avoid_function_literals_in_foreach_calls

import '../../efsqlite.dart';
import 'package:flutter/material.dart';

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
            const SizedBox(
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
        child: const Icon(Icons.add),
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
      child: Container(
        height: widget.heightDialog,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...(textFields).SelectMulti(() => const SizedBox(
                      height: 10,
                    )),
                const SizedBox(
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
                          child: const Text("Delete"),
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
    list.forEach((e) {
      widget.query.table.properties!
          .firstWhere((element) => element.name == e['label'].toString())
          .propertySet!(item, convert(e));
    });
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
