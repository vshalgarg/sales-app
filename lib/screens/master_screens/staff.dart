import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/containers/master_containers/staff_container.dart';
import '../../dialog_boxes/master_dialogBoxes/add_staff_dialog.dart';
import '../../enums/staff_mode.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/delete_staff_provider.dart';
import '../../provider/get_staff_provider.dart';
import '../../provider/search_staff_provider.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final searchStaffController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<GetStaffProvider>().getStaff();
    });
  }

  @override
  void dispose() {
    searchStaffController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final searchProvider = context.watch<SearchStaffProvider>();
    final deleteProvider = context.watch<DeleteStaffProvider>();
    final staffProvider = context.watch<GetStaffProvider>();
    if (staffProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (staffProvider.errorMessage != null) {
      return Scaffold(body: Center(child: Text(staffProvider.errorMessage!)));
    }
    return Scaffold(
        backgroundColor: AppColors.bodyFillColor,
        appBar: CustomAppBar(leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
          title: "Staff Overview",
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    height: 40,
                    width: double.infinity,
                    child: SearchBar(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      controller: searchStaffController,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) {
                          _debounce!.cancel();
                        }
                        if (value
                            .trim()
                            .isEmpty) {
                          context.read<SearchStaffProvider>().clearSearch();
                          return;
                        }
                        _debounce =
                            Timer(const Duration(milliseconds: 500), () {
                              context.read<SearchStaffProvider>().searchStaff(
                                  value);
                            });
                      },
                      elevation: WidgetStatePropertyAll(2),
                      hintText: "Search Staff...",
                      leading: Icon(Icons.search_outlined, size: 30),
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                  ),
                  SizedBox(height: 25),
                  Expanded(
                    child: Consumer<SearchStaffProvider>(
                      builder: (context, searchProvider, child) {
                        final bool isSearching = searchStaffController.text
                            .trim()
                            .isNotEmpty;
                        final List<dynamic> staffs = isSearching
                            ? searchProvider.searchStaffModel?.content ?? []
                            : staffProvider.staffData?.content ?? [];
                        if (searchProvider.isLoading && isSearching) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (searchProvider.errorMessage != null &&
                            isSearching) {
                          return Center(
                              child: Text(searchProvider.errorMessage!));
                        }
                        if (staffs.isEmpty) {
                          return const Center(child: Text("No Staff Found"));
                        }
                        return ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 10);
                          },
                          itemCount: staffs.length,
                          itemBuilder: (context, index) {
                            final staff = staffs[index];
                            return StaffContainer(
                              elevation: 1,
                              name: staff.staffName ?? "",
                              number: staff.phone ?? "",
                              joiningDate: staff.joiningDate ?? "",
                              editIconTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AddStaffDialog(mode: StaffMode.edit,
                                          id: staff.staffId),
                                );
                              },
                              trashIconTap: () {
                                ExitConfirmationDialog.show(
                                  context,
                                  saveButtonText: "Delete",
                                  onClose: () {
                                    Navigator.pop(context);
                                  },
                                  onDiscard: () {
                                    Navigator.pop(context);
                                  },
                                  bodyText: "Are you sure you want to permanently delete ${staff
                                      .staffName ??
                                      ""}? This action cannot be undo.",

                                  onSave: () async {
                                    await context
                                        .read<DeleteStaffProvider>()
                                        .deleteStaff(
                                        {"staffId": staff.staffId});
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    if (deleteProvider.errorMessage != null) {
                                      ScaffoldSnackBar.show(
                                        context,
                                        deleteProvider.errorMessage!,
                                      );

                                      return;
                                    }
                                    if (!context.mounted) return;
                                    ScaffoldSnackBar.show(
                                      context,
                                      deleteProvider
                                          .deleteStaffResponse
                                          ?.message ??
                                          "Deleted Successfully",
                                    );
                                    await context
                                        .read<GetStaffProvider>()
                                        .getStaff();
                                  },
                                );
                              },
                            );
                          },
                        );
                      },

                    ),
                  ),
                ],
            ),
        ),
      floatingActionButton: FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      onPressed: () {
        showDialog(context: context,
            builder: (context) => AddStaffDialog(mode: StaffMode.add));
      },
      backgroundColor: AppColors.primaryPurple,
      child: Icon(Iconsax.add, color: Colors.white, size: 40),
    )
    ,
    );
  }
}
