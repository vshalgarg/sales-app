import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/staff_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/add_staff_dialog.dart';
import 'package:hisabio/enums/staff_mode.dart';
import 'package:hisabio/model_classes/staff/staff.dart';
import 'package:hisabio/pagination/pagination_widget.dart';
import 'package:hisabio/pop_ups/general_closing_popup.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/staff_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final searchController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<StaffProvider>().fetchInitial();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

    final staffs = provider.data.items;

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Staff Overview",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              child: SearchBar(
                controller: searchController,
                elevation: const WidgetStatePropertyAll(2),
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                hintText: "Search Staff...",
                leading: const Icon(Icons.search_outlined, size: 30),
                trailing: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        searchController.clear();

                        await context.read<StaffProvider>().clearSearch();

                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                ],
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) {
                    _debounce!.cancel();
                  }

                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (value.trim().isEmpty) {
                      context.read<StaffProvider>().clearSearch();

                      if (mounted) {
                        setState(() {});
                      }

                      return;
                    }

                    context.read<StaffProvider>().search(value);
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: PaginationWidget<Staff>(
                pagination: provider.data.pagination,
                items: staffs,
                loading: provider.data.isLoading,
                fetchPage: provider.fetchPage,
                refresh: provider.refreshStaffs,
                itemBuilder: (context, item) {
                  return StaffContainer(
                    elevation: 1,
                    name: item.staffName,
                    number: item.phone ?? "-",
                    joiningDate: item.joiningDate ?? "-",

                    editIconTap: () async {
                      final refresh = await showDialog<bool>(
                        context: context,
                        builder: (_) => AddStaffDialog(
                          id: item.id,
                          mode: StaffMode.edit,
                        ),
                      );
                    },

                    trashIconTap: () {
                      ExitConfirmationDialog.show(
                        context,
                        saveButtonText: "Yes",
                        discardButtonText: "No",
                        body: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "Are you sure you want to permanently delete ",
                              ),
                              TextSpan(
                                text: item.staffName,
                                style: const TextStyle(
                                  color: AppColors.orangeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: "? This action cannot be undone.",
                              ),
                            ],
                          ),
                        ),

                        onSave: () async {
                          Navigator.pop(context);

                          final success = await provider.deleteStaff(item.id);

                          if (!context.mounted) return;

                          ScaffoldSnackBar.show(
                            context,
                            success
                                ? "Staff deleted successfully"
                                : "Failed to delete staff",
                          );
                        },

                        onDiscard: () {
                          Navigator.pop(context);
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
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Iconsax.add, color: Colors.white, size: 40),
        onPressed: () async {
          final refresh = await showDialog<bool>(
            context: context,
            builder: (_) => const AddStaffDialog(mode: StaffMode.add),
          );

          if (!mounted) return;

          if (refresh == true) {
            await provider.refreshStaffs();
          }
        },
      ),
    );
  }
}
