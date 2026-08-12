import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/master_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/screens/home_screen.dart';
import 'package:hisabio/screens/master_screens/add_new_supplier.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../enums/customer_mode.dart';
import '../../model_classes/supplier/supplier.dart';
import '../../pagination/pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/master_provider/supplier_provider.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierState();
}

class _SupplierState extends State<SupplierScreen> {
  late SupplierProvider supplierProvider;
  bool _isOpeningCopyDialog = false;
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      //  context.read<SupplierProvider>().fetchInitial();
      final provider = context.read<SupplierProvider>();
    //  supplierProvider = context.read<SupplierProvider>();

      searchController.clear();
      await provider.clearSearch();
    });
  }

  @override
  void dispose() {
    supplierProvider.clearSearch();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();

    // final isSearching = searchController.text.trim().isNotEmpty;

    final suppliers = provider.data.items;
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
        ),
        title: "Suppliers",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.containerFillColor,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 40,
              width: double.infinity,
              child: SearchBar(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                controller: searchController,
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search suppliers...",
                leading: Icon(Icons.search, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                trailing: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        searchController.clear();
                        await context.read<SupplierProvider>().clearSearch();
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
                      context.read<SupplierProvider>().clearSearch();
                      if (mounted) setState(() {});
                      return;
                    }
                    context.read<SupplierProvider>().search(value);
                  });
                },
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: PaginationWidget<Supplier>(
                pagination: provider.data.pagination,
                items: suppliers,
                loading: provider.data.isLoading,
                fetchPage: provider.fetchPage,
                refresh: provider.refreshSuppliers,
                itemBuilder: (context, item) {
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddNewSupplier(id: item.id, mode: FormMode.view),
                        ),
                      );
                    },
                    child: MasterContainer(
                      elevation: 1,
                      name: item.supplierName,
                      mobile: item.mobile ?? "-",
                      code: item.code,
                      city: item.city ?? "-",
                      trashIconTap: () {
                        ExitConfirmationDialog.show(
                          context,
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
                                      text: item.supplierName,
                                      style: const TextStyle(
                                        color: AppColors.orangeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: "?"),
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
                          saveButtonText: "Yes",
                          discardButtonText: "No",
                          onSave: () async {
                            Navigator.of(context).pop();
                            final provider = context.read<SupplierProvider>();

                            final success = await provider.deleteSupplier(
                              item.code,
                            );

                            if (!context.mounted) return;
                            ScaffoldSnackBar.show(
                              context,
                              success
                                  ? "Supplier deleted successfully"
                                  : "Failed to delete supplier",
                            );
                          },
                          onDiscard: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                      copyIconTap: () async {
                        if (_isOpeningCopyDialog) return;

                        _isOpeningCopyDialog = true;
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          final provider = context.read<SupplierProvider>();

                          await provider.fetchSupplierDetails(item.id.toInt());

                          if (mounted) {
                            Navigator.of(context).pop(); // Close loader
                          }

                          if (!mounted) return;

                          final data = provider.supplierDetails;

                          if (data == null) {
                            ScaffoldSnackBar.show(
                              context,
                              "Failed to load supplier details",
                            );
                            return;
                          }

                          String fullAddress = [
                            data.addressLine1,
                            data.addressLine2,
                            data.city,
                            data.state,
                            data.pinCode,
                          ]
                              .where((e) => (e ?? "").trim().isNotEmpty)
                              .join(", ");

                          String contactsText = "";

                          if (data.contacts.isNotEmpty) {
                            contactsText = data.contacts.map((c) {
                              if (c is Map) {
                                return "${c['contactPerson'] ?? ""} - ${c['mobileNumber'] ?? ""}";
                              }

                              return "${c.contactPerson ?? ""} - ${c.mobileNumber ?? ""}";
                            }).join("\n");
                          }

                          String transportText = "";

                          if (data.preferredTransports.isNotEmpty) {
                            transportText = data.preferredTransports.map((t) {
                              if (t is Map) {
                                return t['name']?.toString() ?? "";
                              }

                              return t.name ?? "";
                            }).join("\n");
                          }
                          final bank = data.bankDetails.isNotEmpty
                              ? data.bankDetails.first
                              : null;

                          await showDialog(
                            context: context,
                            builder: (_) => CustomCopyDetailsDialog(
                              firmName: data.supplierName ?? "",
                              contact: contactsText,
                              address: fullAddress,
                              gstNo: data.gstNo ?? "",
                              emails: data.email ?? "",
                              transport: transportText,
                              accountHolder: bank?.accountName ?? "",
                              bankName: bank?.bankName ?? "",
                              accountNumber: bank?.accountNumber ?? "",
                              ifscCode: bank?.ifscCode ?? "",
                              branchName: bank?.branchName ?? "",
                            ),
                          );
                        } catch (e) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          ScaffoldSnackBar.show(
                            context,
                            "Something went wrong",
                          );
                        } finally {
                          _isOpeningCopyDialog = false;
                        }
                      },
                      editIconTap: () async {
                        final supplierProvider = context
                            .read<SupplierProvider>();

                        final refresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddNewSupplier(
                              id: item.id,
                              mode: FormMode.edit,
                            ),
                          ),
                        );
                        if (!mounted) return;

                        if (refresh == true) {
                          await supplierProvider.refreshSuppliers();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNewSupplier()),
          );

          if (refresh == true && mounted) {
            await context.read<SupplierProvider>().refresh();
          }
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
