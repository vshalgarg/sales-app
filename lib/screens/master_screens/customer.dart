import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/master_container.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/screens/master_screens/add_new_customer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../dialog_boxes/master_dialogBoxes/custom_copy_details_dialog.dart';
import '../../enums/customer_mode.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/delete_customer_provider.dart';
import '../../provider/get_customers_provider.dart';
import '../../provider/search_customer_provider.dart';
import '../home_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CustomersProvider>().fetchCustomers();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();

    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomersProvider>();
    final deleteProvider = context.watch<DeleteCustomerProvider>();
    final searchProvider = context.watch<SearchCustomerProvider>();
    final isSearching = searchController.text.trim().isNotEmpty;
    final customers = isSearching
        ? (searchProvider.searchResult?.content ?? [])
        : customerProvider.customers;
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
        title: "Customer",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      //drawer: MasterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 40,
              child: SearchBar(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                controller: searchController,
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
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search customers...",
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) {
                    _debounce!.cancel();
                  }

                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (value.trim().isEmpty) {
                      setState(() {});
                      return;
                    }

                    context.read<SearchCustomerProvider>().searchCustomer(
                      value,
                    );
                  });
                },
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Consumer<SearchCustomerProvider>(
                builder: (context, searchProvider, child) {
                  if (searchProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (searchProvider.error != null) {
                    return Center(child: Text(searchProvider.error!));
                  }
                  final searchData = searchProvider.searchResult;
                  if (searchData != null) {
                    final customers = searchData.content ?? [];

                    if (customers.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Customers Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                  }
                  return customerProvider.isLoading
                      ? Center(child: const CircularProgressIndicator())
                      : ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 8);
                          },
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return MasterContainer(
                              elevation: 1,
                              name: isSearching
                                  ? customer.customerName
                                  : customer['customerName'],
                              mobile: isSearching
                                  ? customer.customerGstNo
                                  : customer['mobileNumber'],
                              code: isSearching
                                  ? customer.code
                                  : customer['code'],
                              city: isSearching
                                  ? customer.city
                                  : customer['city'],
                              eyeIconTap: () {
                                final id = isSearching
                                    ? customer.id
                                    : customer['id'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNewCustomer(
                                      mode: FormMode.view,
                                      id: id,
                                    ),
                                  ),
                                );
                              },
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
                                      "Are you sure you want to permanently delete ${isSearching ? customer.customerName : customer['customerName']}? This action cannot be undo.",
                                  onSave: () async {
                                    await context
                                        .read<DeleteCustomerProvider>()
                                        .deleteCustomer({
                                          "customerCode": customer['code'],
                                        });
                                    if (!context.mounted) {
                                      return;
                                    }

                                    if (deleteProvider.errorMessage == null) {
                                      Navigator.pop(context);

                                      context
                                          .read<CustomersProvider>()
                                          .fetchCustomers();
                                      ScaffoldSnackBar.show(
                                        context,
                                        "Customer Deleted successfully",
                                      );
                                    } else {
                                      ScaffoldSnackBar.show(
                                        context,
                                        deleteProvider.errorMessage!,
                                      );
                                    }
                                  },
                                );
                              },

                              copyIconTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomCopyDialog(
                                      headingText: "Customer Details",
                                      firmName: isSearching
                                          ? customer.customerName
                                          : customer['customerName'] ?? "",
                                    );
                                  },
                                );
                              },
                              editIconTap: () {
                                final id = isSearching
                                    ? customer.id
                                    : customer['id'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNewCustomer(
                                      mode: FormMode.edit,
                                      id: id,
                                    ),
                                  ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewCustomer()),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
