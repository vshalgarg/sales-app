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
  final ScrollController scrollController;
  const ContactInfo({
    super.key,
    this.mode,
    required this.contacts,
    required this.onAdd,
    required this.onDelete,
    required this.scrollController,
  });

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  final GlobalKey _contactKey = GlobalKey();
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final contacts = widget.contacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _contactKey,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
              if (isExpanded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Scrollable.ensureVisible(
                    _contactKey.currentContext!,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    alignment: 0.05,
                  );
                });
              }
            },
            child: TextFormField(
              enabled: false,
              decoration: InputDecoration(
                suffixIcon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
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
        ),
        if (isExpanded) ...[
          SizedBox(height: 15),
          if (contacts.isEmpty && widget.mode == FormMode.view)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Center(
                child: Text(
                  "No Contact Information Available",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
          Column(
            children: List.generate(contacts.length, (index) {
              final contact = contacts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.bodyFillColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Contact ${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                          hintStyle: const TextStyle(
                              color: Colors.grey),
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
                          hintStyle: const TextStyle(
                              color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 15),
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
                          hintStyle: const TextStyle(
                              color: Colors.grey),
                        ),
                      ),
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
                      onPressed: () {
                        widget.onAdd();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.scrollController.animateTo(
                            widget.scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            );
                          }
        );
                      },
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
