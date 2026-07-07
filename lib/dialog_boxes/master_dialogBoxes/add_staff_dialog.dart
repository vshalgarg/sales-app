import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
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
  late final updateProvider = context.watch<UpdateStaffProvider>();

  Map<String, dynamic> getStaffBody() {
    return {
      "staffName": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "joiningDate": dateController.text.trim(),
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
                      widget.mode == StaffMode.add
                          ? Center(
                              child: Text(
                                "Add New Staff",
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontWeight:FontWeight.w200,
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                "Update Details",
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                      SizedBox(height:5),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Iconsax.user,
                                color: AppColors.primaryPurple,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: "Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: phoneController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Iconsax.mobile,
                                color: AppColors.primaryPurple,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "phone",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: dateController,
                            readOnly: true,
                            onTap: selectDate,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                Iconsax.calendar,
                                color: AppColors.primaryPurple,
                              ),
                              hintText: "Date Of Joining",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
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
                                        final addProvider = context
                                            .read<AddNewStaffProvider>();
                                        final getStaffProvider = context
                                            .read<GetStaffProvider>();
                                        await addProvider.addNewStaff({
                                          "staffName": nameController.text
                                              .trim()
                                              .toString(),
                  
                                          "phone": phoneController.text
                                              .trim()
                                              .toString(),
                  
                                          "joiningDate": dateController.text
                                              .trim()
                                              .toString(),
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
                                          addProvider
                                                  .addNewStaffResponse
                                                  ?.message ??
                                              "Staff Added Successfully",
                                        );
                  
                                        Navigator.pop(context,true);
                  
                                        await getStaffProvider.getStaff();
                                      },
                  
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
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
                                      ),
                              ),
                            ),
                          ],
                          if (widget.mode == StaffMode.edit) ...[
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
                  
                                        final updateProvider = context
                                            .read<UpdateStaffProvider>();
                  
                                        final getStaffProvider = context
                                            .read<GetStaffProvider>();
                  
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
                                                  .updateStaffResponse
                                                  ?.message ??
                                              "Staff Updated Successfully",
                                        );

                                        Navigator.pop(context,true);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: updateProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Update Staff",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text("Cancel"),
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
              top: 0,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3F0FF),
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.person_outline_outlined,
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
