import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../enums/staff_mode.dart';
import '../../model_classes/staff/add_staff_request.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/staff_provider.dart';

class AddStaffDialog extends StatefulWidget {
  final int? id;
  final StaffMode? mode;

  const AddStaffDialog({super.key, this.id, this.mode});

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  AddStaffRequest get request => AddStaffRequest(
    staffName: nameController.text.trim(),
    phone: phoneController.text.trim(),
    joiningDate: dateController.text.trim(),
  );

  @override
  void initState() {
    super.initState();

    if (widget.mode != StaffMode.add && widget.id != null) {
      Future.microtask(() async {
        final provider = context.read<StaffProvider>();

        final success = await provider.fetchStaffDetails(widget.id!);

        if (!mounted || !success) return;

        final staff = provider.staffDetails;

        if (staff != null) {
          nameController.text = staff.staffName ?? "";
          phoneController.text = staff.phone ?? "";
          dateController.text = staff.joiningDate ?? "";
        }
      });
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
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Iconsax.user,
                            color: AppColors.primaryPurple,
                          ),
                          hintText: "Name",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
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
                          hintText: "Phone",
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
                          hintText: "Date of Joining",
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
                              onPressed: provider.actionLoading
                                  ? null
                                  : () async {
                                      if (nameController.text.trim().isEmpty ||
                                          phoneController.text.trim().isEmpty ||
                                          dateController.text.trim().isEmpty) {
                                        ScaffoldSnackBar.show(
                                          context,
                                          "All the fields are required",
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

                                      if (!mounted) return;

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
                              child: provider.actionLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
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
          ],
        ),
      ),
    );
  }
}