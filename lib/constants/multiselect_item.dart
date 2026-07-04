import 'package:flutter/material.dart';

class CustomMultiSelect<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final ValueChanged<List<T>> onChanged;
  final String hintText;

  const CustomMultiSelect({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.onChanged,
    required this.hintText,
  });

  @override
  State<CustomMultiSelect<T>> createState() => _CustomMultiSelectState<T>();
}

class _CustomMultiSelectState<T> extends State<CustomMultiSelect<T>> {
  late List<T> selected;
  @override
  void didUpdateWidget(covariant CustomMultiSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedItems != widget.selectedItems) {
      setState(() {
        selected = List.from(widget.selectedItems);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedItems);
  }

  Future<void> _showDialog() async {
    List<T> tempSelected = List.from(selected);
    List<T> filteredItems = List.from(widget.items);

    bool selectAll = tempSelected.length == widget.items.length;

    TextEditingController searchController = TextEditingController();

    await showDialog(

      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          filteredItems = widget.items.where((element) {
                            return widget
                                .itemLabel(element)
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),

                    CheckboxListTile(
                      title: const Text(
                        "Select All",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: selectAll,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setDialogState(() {
                          selectAll = value ?? false;

                          if (selectAll) {
                            tempSelected = List.from(widget.items);
                          } else {
                            tempSelected.clear();
                          }
                        });
                      },
                    ),

                    const Divider(),

                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(widget.itemLabel(item)),
                            value: tempSelected.contains(item),
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelected.add(item);
                                } else {
                                  tempSelected.remove(item);
                                }

                                selectAll = tempSelected.length == widget.items.length;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selected = tempSelected;
                    });

                    widget.onChanged(selected);

                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon:Icon(Icons.arrow_drop_down) ,
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          selected.isEmpty
              ? widget.hintText
              : selected.map(widget.itemLabel).join(", "),
          maxLines: 2,
          style: TextStyle(fontSize:16,color:Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}