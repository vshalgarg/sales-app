import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../enums/staff_mode.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/add_new_staff_provider.dart';
import '../../provider/get_staff_by_id_provider.dart';
import '../../provider/get_staff_provider.dart';
import '../../provider/update_staff_provider.dart';

class AddStaffDialog extends StatefulWidget {
  final int? id;
  final StaffMode? mode;

  const AddStaffDialog({super.key, this.mode, this.id});

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  bool isSaveAndNewLoading = false;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      setState(() {
        dateController.text = formattedDate;
      });
    }
  }

  late final addStaffProvider = context.watch<AddNewStaffProvider>();
  late final updateProvider =
  context.watch<UpdateStaffProvider>();
  Map<String, dynamic> getStaffBody() {

    return {

      "staffName":
      nameController.text.trim(),

      "phone":
      phoneController.text.trim(),

      "joiningDate":
      dateController.text.trim(),
    };
  }

  @override
  void initState() {
    super.initState();

    if (widget.mode == StaffMode.edit && widget.id != null) {
      Future.microtask(() async {
        final provider = context.read<GetStaffByIdProvider>();

        await provider.getStaffById(widget.id!);

        final staff = provider.staffData;

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
    dateController.dispose();
    nameController.dispose;
    phoneController.dispose;
    super.dispose();
  }

  void clearFields() {
    nameController.clear();

    phoneController.clear();

    dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AlertDialog(
        title: widget.mode == StaffMode.add
            ? Text("Add New Staff")
            : Text("Update Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: phoneController,
              decoration: InputDecoration(
                hintText: "phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: dateController,
              readOnly: true,
              onTap: selectDate,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.calendar_month),
                hintText: "Date Of Joining",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
          if (widget.mode == StaffMode.add) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addStaffProvider.isLoading
                    ? null
                    : () async {
                        if (nameController.text.isEmpty ||
                            dateController.text.isEmpty ||
                            phoneController.text.isEmpty) {
                          ScaffoldSnackBar.show(
                            context,
                            "All the fields are required",
                            backgroundColor: Colors.red,
                          );
                          return;
                        }
                        final addProvider = context.read<AddNewStaffProvider>();
                        final getStaffProvider = context
                            .read<GetStaffProvider>();
                        await addProvider.addNewStaff({
                          "staffName": nameController.text.trim().toString(),

                          "phone": phoneController.text.trim().toString(),

                          "joiningDate": dateController.text.trim().toString(),
                        });

                        if (!context.mounted) return;
                        if (addProvider.errorMessage != null) {
                          ScaffoldSnackBar.show(
                            context,
                            addProvider.errorMessage!,
                          );

                          return;
                        }
                        ScaffoldSnackBar.show(
                          context,
                          addProvider.addNewStaffResponse?.message ??
                              "Staff Added Successfully",
                        );

                        Navigator.pop(context);

                        await getStaffProvider.getStaff();
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: addStaffProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )

                    : const Text(
                        "Save Staff",
                        style: TextStyle(color: Colors.white),
                      )

              ),
            )],
            if (widget.mode == StaffMode.add) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaveAndNewLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              dateController.text.isEmpty ||
                              phoneController.text.isEmpty) {
                            ScaffoldSnackBar.show(
                              context,
                              "Name is Required",
                              backgroundColor: Colors.red,
                            );
                            return;
                          }
                          setState(() {
                            isSaveAndNewLoading = true;
                          });
                          final addProvider = context
                              .read<AddNewStaffProvider>();

                          final getStaffProvider = context
                              .read<GetStaffProvider>();

                          await addProvider.addNewStaff(
                            getStaffBody(),
                          );

                          if (!context.mounted) return;
                          if (addProvider.errorMessage != null) {
                            ScaffoldSnackBar.show(
                              context,
                              addProvider.errorMessage!,
                            );

                            return;
                          }

                          ScaffoldSnackBar.show(
                            context,
                            addProvider.addNewStaffResponse?.message ??
                                "Staff Added Successfully",
                          );
                          clearFields();
                          setState(() {
                            isSaveAndNewLoading = false;
                          });

                          await getStaffProvider.getStaff();
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: isSaveAndNewLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Save Staff & Add New ",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
            if(widget.mode==StaffMode.edit)...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateProvider.isLoading
                    ? null
                    : () async {

                  if (nameController.text.isEmpty ||
                      dateController.text.isEmpty ||
                      phoneController.text.isEmpty) {

                    ScaffoldSnackBar.show(
                      context,
                      "All the fields are required",
                      backgroundColor: Colors.red,
                    );

                    return;
                  }

                  final updateProvider =
                  context.read<UpdateStaffProvider>();

                  final getStaffProvider =
                  context.read<GetStaffProvider>();

                  await updateProvider.updateStaff(
                    body: getStaffBody(),
                    id: widget.id!,
                  );

                  if (!context.mounted) return;

                  if (updateProvider.errorMessage != null) {

                    ScaffoldSnackBar.show(
                      context,
                      updateProvider.errorMessage!,
                    );

                    return;
                  }

                  ScaffoldSnackBar.show(
                    context,
                    updateProvider
                        .updateStaffResponse?.message ??
                        "Staff Updated Successfully",
                  );

                  Navigator.pop(context);

                  await getStaffProvider.getStaff();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: updateProvider.isLoading? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                :Text("Update Staff",style: TextStyle( color:Colors.white,)),
              ),
            )],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
