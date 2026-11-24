import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/staff_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/add_staff_dialog.dart';
import 'package:hisabio/enums/staff_mode.dart';
import 'package:hisabio/model_classes/staff/staff.dart';
import 'package:hisabio/pagination/pagination_widget.dart';
import 'package:hisabio/pop_ups/general_closing_popup.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/master_provider/staff_provider.dart';
import 'package:hisabio/provider/master_provider/permission_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../customs/card_entrance_examination.dart';

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

    final staffProvider = context.read<StaffProvider>();
    final permissionProvider = context.read<PermissionProvider>();

    Future.microtask(() async {
      searchController.clear();

      if (permissionProvider.canView('STAFF')) {
        await staffProvider.initializeStaff();
      }/////////
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void clear() {
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();
    final staffs = provider.data.items;

    final permissionProvider = context.watch<PermissionProvider>();

    final canView = permissionProvider.canView('STAFF');
    final canCreate = permissionProvider.canCreate('STAFF');
    final canUpdate = permissionProvider.canUpdate('STAFF');
    final canDelete = permissionProvider.canDelete('STAFF');

    final canAccess = canView || canCreate;

    if (!canAccess) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You do not have permission to access Staff.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            searchController.clear();
            context.read<StaffProvider>().resetSearch();
            Navigator.pop(context);
          },
        ),
        title: "Staff Overview",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),

      body: Padding(
        padding: AppSpacing.screen,
        child: Column(
          children: [
            if (canView) ...[
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
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
                    _debounce?.cancel();

                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      if (value.trim().isEmpty) {
                        context.read<StaffProvider>().clearSearch();

                        if (mounted) {
                          setState(() {});
                        }

                        return;
                      }

                      context.read<StaffProvider>().search(value.trim());
                    });
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              Expanded(
                child: PaginationWidget<Staff>(
                  pagination: provider.data.pagination,
                  items: staffs,
                  loading: provider.data.isLoading,
                  fetchPage: provider.fetchPage,
                  refresh: () => provider.refreshStaffs(showLoader: false),
                  itemBuilder: (context, item) {
                    return CardEntranceAnimation(
                      key: ValueKey('staff-card-${item.id}'),
                      delay: Duration(milliseconds: (staffs.indexOf(item).clamp(0, 5)) * 65),
                      child: StaffContainer(
                        elevation: 1,
                        name: item.staffName,
                        number: item.phone ?? "-",
                        joiningDate: item.joiningDate ?? "-",

                        editIconTap: canUpdate
                            ? () async {
                          await showDialog<bool>(
                            context: context,
                            builder: (_) => AddStaffDialog(
                              id: item.id,
                              mode: StaffMode.edit,
                              staff: item,
                            ),
                          );
                        }
                            : null,

                        trashIconTap: canDelete
                            ? () {
                          ExitConfirmationDialog.show(
                            context,
                            isDelete: true,
                            saveButtonText: "Delete",
                            discardButtonText: "Cancel",
                            body: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
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
                                      const TextSpan(text: "?"),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  "This action cannot be undone.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),

                            onSave: () async {
                              Navigator.pop(context);

                              final success = await provider.deleteStaff(
                                item.id,
                              );

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
                        }
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'You can add staff, but cannot view staff records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      floatingActionButton: canCreate
          ? FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Iconsax.add, color: Colors.white, size: 40),
        onPressed: () async {
          final refresh = await showDialog<bool>(
            context: context,
            builder: (_) => const AddStaffDialog(mode: StaffMode.add),
          );

          if (!mounted) return;

          if (refresh == true && canView) {
            await provider.refreshStaffs();
          }
        },
      )
          : null,
    );
  }
}
