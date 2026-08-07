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
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
    //  context.read<SupplierProvider>().fetchInitial();
      final provider = context.read<SupplierProvider>();

      searchController.clear();
      await provider.clearSearch();
    });
  }

  @override
  void dispose() {
    context.read<SupplierProvider>().clearSearch();
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
                          body: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
                                const TextSpan(
                                  text: "? This action cannot be undone.",
                                ),
                              ],
                            ),
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
                        final provider = context.read<SupplierProvider>();

                        await provider.fetchSupplierDetails(item.id.toInt());

                        final data = provider.supplierDetails;
                        print("Bank Name: ${data?.bankName}");
                        print("Account Holder: ${data?.accountName}");
                        print("Account Number: ${data?.accountNumber}");
                        print("IFSC: ${data?.ifscCode}");
                        if (data == null) return;

                        String contactNumber = "";

                        if (data.contacts.isNotEmpty) {
                          final firstContact = data.contacts[0];

                          if (firstContact is Map) {
                            contactNumber = firstContact['mobileNumber'] ?? "";
                          }
                        }
                        showDialog(
                          context: context,
                          builder: (_) {
                            return CustomCopyDetailsDialog(
                              firmName: data.supplierName ?? "",
                              contact: contactNumber,
                              address: data.addressLine1 ?? "",
                              gstNo: data.gstNo ?? "",
                              emails: data.email ?? "",
                              bankName: data.bankName ?? "",
                              accountHolder: data.accountName ?? "",
                              accountNumber: data.accountNumber ?? "",
                              ifscCode: data.ifscCode ?? "",
                            );
                          },
                        );
                      },
                      editIconTap: () async {
                        final supplierProvider = context.read<
                            SupplierProvider>();

                        final refresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddNewSupplier(
                                  id: item.id,
                                  mode: FormMode.edit,
                                ),
                          ),
                        );
                        if (!mounted) return;

                        if (refresh == true) {
                          // await context.read<SupplierProvider>().refreshSuppliers();
                          // }
                          await supplierProvider.refreshSuppliers();
                        }
                      }
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
