import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/master_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/delete_supplier_provider.dart';
import 'package:hisabio/provider/get_supplier_provider.dart';
import 'package:hisabio/provider/get_suppliers_byid_provider.dart';
import 'package:hisabio/provider/search_supplier_provider.dart';
import 'package:hisabio/screens/home_screen.dart';
import 'package:hisabio/screens/master_screens/add_new_supplier.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../enums/customer_mode.dart';
import '../../pop_ups/general_closing_popup.dart';

class Supplier extends StatefulWidget {
  const Supplier({super.key});

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  final ScrollController _scrollController = ScrollController();
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      context.read<SupplierProvider>().fetchSuppliers(refresh: true);

    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<SupplierProvider>().fetchSuppliers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchSupplierProvider>();

    final provider = context.watch<SupplierProvider>();

    final isSearching = searchController.text.trim().isNotEmpty;

    final List<dynamic> suppliers = isSearching
        ? searchProvider.searchSupplier?.content ?? []
        : provider.suppliers;
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: "Supplier",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0,),
      // drawer: MasterDrawer(),
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
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) {
                    _debounce!.cancel();
                  }

                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (value.trim().isEmpty) {
                      setState(() {});
                      return;
                    }

                    context.read<SearchSupplierProvider>().searchSuppliers(
                      value,
                    );
                  });
                },
              ),
            ),
            SizedBox(height: 25),
            Expanded(
              child: provider.isLoading
                  ? Center(child: const CircularProgressIndicator())
                  : suppliers.isEmpty
                  ? const Center(
                      child: Text(
                        "No Supplier Found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      itemCount:
                          suppliers.length +
                          ((!isSearching && provider.isLoadingMore) ? 1 : 0),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 8);
                      },
                      itemBuilder: (context, index) {
                        if (!isSearching &&
                            index == suppliers.length &&
                            provider.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final item = suppliers[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNewSupplier(
                                  id: item.id,
                                  mode: FormMode.view,
                                ),
                              ),
                            );
                          },
                          child: MasterContainer(
                            elevation: 1,
                            name: (item.supplierName?.toString().trim().isNotEmpty ?? false)
                                ? item.supplierName!
                                : "-",

                            mobile: (item.mobile?.toString().trim().isNotEmpty ?? false)
                                ? item.mobile!
                                : "-",

                            code: (item.code?.toString().trim().isNotEmpty ?? false)
                                ? item.code!
                                : "-",

                            city: (item.city?.toString().trim().isNotEmpty ?? false)
                                ? item.city!
                                : "-",
                            trashIconTap: () {
                              ExitConfirmationDialog.show(
                                context,
                                discardButtonText: "No",
                                saveButtonText: "Yes",
                                onClose: () {
                                  Navigator.pop(context);
                                },
                                onDiscard: () {
                                  Navigator.pop(context);
                                },
                                bodyText:
                                    "Are you sure you want to permanently delete ${item.supplierName}? This action cannot be undo.",
                                onSave: () async {
                                  final provider =
                                      Provider.of<DeleteSupplierProvider>(
                                        context,
                                        listen: false,
                                      );
                                  await provider.deleteSupplier(item.code!);
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  if (searchController.text.trim().isNotEmpty) {
                                    await context.read<SearchSupplierProvider>().searchSuppliers(
                                      searchController.text.trim(),
                                    );
                                  } else {
                                    await context.read<SupplierProvider>().refreshSuppliers();
                                  }
                                  if(!context.mounted)return;

                                  ScaffoldSnackBar.show(
                                    context,
                                    provider.message,
                                  );
                                  await context.read<SupplierProvider>().refreshSuppliers();
                                },
                              );
                            },
                            copyIconTap: () async {
                              final provider = context
                                  .read<GetSupplierByIdProvider>();
                              await provider.fetchSupplierById(
                                item.id!.toInt(),
                              );
                              final data = provider.supplier;

                              if (data == null) return;

                              String contactNumber = "";

                              if (data.contacts != null &&
                                  data.contacts!.isNotEmpty) {
                                final firstContact = data.contacts![0];

                                if (firstContact is Map) {
                                  contactNumber =
                                      firstContact['mobileNumber'] ?? "";
                                }
                              }
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return CustomCopyDetailsDialog(
                                    firmName:
                                        provider.supplier?.supplierName ?? "",
                                    contact: contactNumber,
                                    address:
                                        provider.supplier?.addressLine1 ?? "",
                                    gstNo: provider.supplier?.gstNo ?? "",
                                    emails: provider.supplier?.email??"",
                                  );
                                },
                              );
                            },
                            editIconTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddNewSupplier(
                                    id: item.id,
                                    mode: FormMode.edit,
                                  ),
                                ),
                              );
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewSupplier()),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
