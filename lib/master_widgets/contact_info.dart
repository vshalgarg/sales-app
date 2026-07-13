import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:iconsax/iconsax.dart';

import '../enums/customer_mode.dart';
import '../screens/master_screens/add_new_supplier.dart';

class ContactInfo extends StatefulWidget {
  final List<ContactControllers> contacts;
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
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final contacts = widget.contacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              suffixIcon: Icon(isExpanded?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down, color: Colors.white),
              iconColor: Colors.white,
              filled: true,
              fillColor: AppColors.primaryPurple,
              hintText: "Contact Information",
              hintStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (isExpanded) ...[
          SizedBox(height: 15),

          Column(
            children: List.generate(contacts.length, (index) {
              final contact = contacts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Container(
                  // margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.bodyFillColor,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Contact ${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold,color:Colors.white),
                          ),

                          if (widget.mode != FormMode.view && index > 0)
                            IconButton(
                              icon: Icon(Iconsax.trash, color: Colors.red),
                              onPressed: () => widget.onDelete(index),
                            ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Contact Person",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      TextFormField(
                        enabled: widget.mode != FormMode.view,
                        controller: contact.name,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Contact Person",
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Mobile No",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        //maxLength: 10,
                        enabled: widget.mode != FormMode.view,
                        controller: contact.mobile,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Mobile No.",
                        ),
                      ),
                      Text(
                        "Type",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      TextFormField(
                        enabled: widget.mode != FormMode.view,
                        controller: contact.type,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Type",
                        ),
                      ),
                     // SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          widget.mode == FormMode.view
              ? SizedBox()
              : Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white),
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
          ),
        ],
      ],
    );
  }
}
