import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../enums/staff_mode.dart';
import '../../model_classes/staff/add_staff_request.dart';
import '../../model_classes/staff/staff.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/master_provider/staff_provider.dart';

class AddStaffDialog extends StatefulWidget {
  final int? id;
  final StaffMode? mode;
  final Staff? staff;

  const AddStaffDialog({
    super.key,
    this.id,
    this.mode,
    this.staff,
  });

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? nameError;
  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  AddStaffRequest get request => AddStaffRequest(
    staffName: nameController.text.trim(),
    phone: phoneController.text.trim(),
    joiningDate: dateController.text.trim().isEmpty
        ? ""
        : DateFormat('yyyy-MM-dd').format(
      DateFormat('dd-MM-yyyy').parse(dateController.text.trim()),
    ),
  );

  @override
  void initState() {
    super.initState();

    if (widget.mode == StaffMode.add) {
      dateController.text =
          DateFormat('dd-MM-yyyy').format(DateTime.now());
    } else if (widget.staff != null) {
      final staff = widget.staff!;

      nameController.text = staff.staffName ?? "";
      phoneController.text = staff.phone ?? "";

      if (staff.joiningDate != null &&
          staff.joiningDate!.trim().isNotEmpty) {
        dateController.text = DateFormat('dd-MM-yyyy').format(
          DateTime.parse(staff.joiningDate!),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 35,
                  left: 15,
                  right: 15,
                  bottom: 15,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.mode == StaffMode.add
                            ? "Add New Staff"
                            : "Update Staff",
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: nameController,
                        readOnly: false,
                        onChanged: (value) {
                          if (value.trim().isNotEmpty && nameError != null) {
                            setState(() {
                              nameError = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Iconsax.user,
                            color: AppColors.primaryPurple,
                          ),
                          labelText: "Staff Name *",
                          filled: true,
                          fillColor: Colors.white,
                          errorText: nameError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: phoneController,
                        readOnly: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Iconsax.mobile,
                            color: AppColors.primaryPurple,
                          ),
                          labelText: "Phone Number",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap:
                        selectDate,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Iconsax.calendar,
                            color: AppColors.primaryPurple,
                          ),
                          labelText: "Joining Date*",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:()async {
                                if (nameController.text.trim().isEmpty) {
                                  setState(() {
                                    nameError = "Staff Name is required";
                                  });

                                  ScaffoldSnackBar.show(
                                    context,
                                    "Staff Name is required.",
                                  );

                                  return;
                                }

                                setState(() {
                                  nameError = null;
                                });

                                if (dateController.text.trim().isEmpty) {
                                  ScaffoldSnackBar.show(
                                    context,
                                    "Joining Date is required.",
                                  );
                                  return;
                                }

                                      bool success;

                                      if (widget.mode == StaffMode.add) {
                                        success = await provider.addStaff(
                                          request,
                                        );
                                      } else {
                                        success = await provider.updateStaff(
                                          id: widget.id!,
                                          request: request,
                                        );
                                      }

                                      if (!context.mounted) return;

                                      if (success) {
                                        ScaffoldSnackBar.show(
                                          context,
                                          widget.mode == StaffMode.add
                                              ? "Staff Added Successfully"
                                              : "Staff Updated Successfully",
                                        );

                                        Navigator.pop(context, true);
                                      } else {
                                        ScaffoldSnackBar.show(
                                          context,
                                          widget.mode == StaffMode.add
                                              ? "Failed to add staff"
                                              : "Failed to update staff",
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                      widget.mode == StaffMode.add
                                          ? "Save Staff"
                                          : "Update Staff",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primaryPurple,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top:0,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3F0FF),
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: Icon(
                 Iconsax.user_edit,
                  color: AppColors.primaryPurple,
                  size: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}