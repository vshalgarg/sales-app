import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';

import '../enums/customer_mode.dart';
class ContactInfo extends StatefulWidget {
  final List<Map<String, TextEditingController>> contacts;
  final VoidCallback onAdd;
  final Function(int) onDelete;
  final FormMode? mode;

  const ContactInfo({
    super.key,
    this.mode,
    required this.contacts,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  // late List<Map<String, TextEditingController>> contacts;

  /*void addContact() {
    setState(() {
      contacts.add({
        "name": TextEditingController(),
        "mobile": TextEditing

  /*@override
  void initState() {
    super.initState();
    contacts = widget.contacts;

    if (contacts.isEmpty) {
      addContact();
    }
  }*/

  /*  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });Controller(),
        "type": TextEditingController(),
      });
    });
  }*/
  }*/

  @override
  Widget build(BuildContext context) {
    final contacts = widget.contacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contact Information",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),

        Column(
          children: List.generate(  contacts.isEmpty ? 1 : contacts.length, (index) {
            final contact = contacts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Container(
                // margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Contact ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        if (widget.mode != FormMode.view && index > 0)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => widget.onDelete(index),
                          ),
                      ],
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      enabled: widget.mode != FormMode.view,
                      controller: contact["name"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Contact Person",
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      enabled: widget.mode != FormMode.view,
                      controller: contact["mobile"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Mobile No.",
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      enabled: widget.mode != FormMode.view,
                      controller: contact["type"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Type",
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        widget.mode == FormMode.view
            ? SizedBox()
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.primaryPurple),
                ),
                child: TextButton(
                  onPressed: widget.onAdd,
                  child: const Text(
                    "+ ADD CONTACT",
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
