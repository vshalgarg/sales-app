import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/master_container.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/screens/master_screens/add_new_customer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/customer/customer.dart';
import '../../pagination/pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/master_provider/customer_provider.dart';
import '../home_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String displayValue(dynamic value) {
    if (value == null) return "   -   ";
    final text = value.toString().trim();
    return text.isEmpty ? "-" : text;
  }

 // final PageController _pageController = PageController();
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CustomerProvider>();

    Future.microtask(() async{
      searchController.clear();
      await provider.clearSearch();
      await provider.fetchPage(0);
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
    final provider = context.watch<CustomerProvider>();
    final customers = provider.data.items;
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
                        FocusScope.of(context).unfocus();
                        context.read<CustomerProvider>().clearSearch();
                        setState(() {});
                      },
                    ),
                ],
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search customers...",
                onChanged: (value) {
                  _debounce?.cancel();

                  _debounce = Timer(
                    const Duration(milliseconds: 500),
                        () {
                      if (value.trim().isEmpty) {
                        context.read<CustomerProvider>().clearSearch();
                      } else {
                        context.read<CustomerProvider>().search(value.trim());
                      }
                    },
                  );
                },
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: PaginationWidget<Customer>(
                    pagination: provider.data.pagination,
                    items: customers,
                    loading: provider.data.isLoading,
                    fetchPage: provider.fetchPage,
                    refresh: provider.refreshCustomers,
                    itemBuilder: (context, customer) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddNewCustomer(
                                    mode: FormMode.view,
                                    id: customer.id,
                                  ),
                            ),
                          );
                        },

                        // return PageView.builder(
                        //   controller: _pageController,
                        //   itemCount: provider.data.pagination.totalPages,
                        //   onPageChanged: (page) async {
                        //     if (page != provider.data.pagination.currentPage) {
                        //       await provider.fetchPage(page);
                        //     }
                        //   },
                        //   itemBuilder: (context, pageIndex) {
                        //     return RefreshIndicator(
                        //       onRefresh: provider.refreshCustomers,
                        //       child: ListView.separated(
                        //         physics: const AlwaysScrollableScrollPhysics(),
                        //         padding: const EdgeInsets.only(bottom: 100),
                        //         separatorBuilder: (_, _) =>
                        //         const SizedBox(height: 8),
                        //         itemCount: customers.length,
                        //         itemBuilder: (context, index) {
                        //           final customer = customers[index];
                        //
                        //           return GestureDetector(
                        //             onTap: () {
                        //               Navigator.push(
                        //                 context,
                        //                 MaterialPageRoute(
                        //                   builder: (_) => AddNewCustomer(
                        //                     mode: FormMode.view,
                        //                     id: customer.id,
                        //                   ),
                        //                 ),
                        //               );
                        //             },
                        child: MasterContainer(
                          elevation: 1,

                          name: displayValue(customer.customerName),

                          mobile: displayValue(
                            customer.contacts.isNotEmpty
                                ? (customer.contacts.first.mobileNumber ?? "")
                                : "",
                          ),

                          code: displayValue(customer.code),

                          city: displayValue(customer.city),

                          eyeIconTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddNewCustomer(
                                      mode: FormMode.view,
                                      id: customer.id,
                                    ),
                              ),
                            );
                          },

                          editIconTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddNewCustomer(
                                      mode: FormMode.edit,
                                      id: customer.id,
                                    ),
                              ),
                            );
                          },

                          copyIconTap: () async {
                            final provider = context.read<CustomerProvider>();

                            await provider.fetchCustomerDetails(customer.id);
                            if (!context.mounted) return;
                            final data = provider.customerDetails;

                            if (data == null) return;

                            String fullAddress = [
                              data.addressLine1,
                              data.addressLine2,
                              data.city,
                              data.state,
                              data.pinCode,
                            ]
                                .where((e) =>
                            (e ?? "")
                                .trim()
                                .isNotEmpty)
                                .join(", ");

                            String contactsText = "";

                            if (data.contacts.isNotEmpty) {
                              contactsText = data.contacts.map((c) {
                                final name = (c.contactPerson ?? "").trim();
                                final mobile = (c.mobileNumber ?? "").trim();

                                if (name.isNotEmpty && mobile.isNotEmpty) {
                                  return "$name - $mobile";
                                }

                                if (name.isNotEmpty) {
                                  return name;
                                }

                                if (mobile.isNotEmpty) {
                                  return mobile;
                                }

                                return "";
                              }).where((e) => e.isNotEmpty).join("\n");
                            }

                            String transportText = "";

                            if (data.preferredTransports.isNotEmpty) {
                              transportText = data.preferredTransports.map((t) {
                                if (t is Map) {
                                  return ['name'].toString();
                                }

                                return t.name ?? "";
                              }).join("\n");
                            }
                            await showDialog(
                              context: context,
                              builder: (_) {
                                return CustomCopyDetailsDialog(
                                  heading: "Customer Details",
                                  firmName: data.customerName ?? "",
                                  contact: contactsText,
                                  address: fullAddress,
                                  gstNo: data.gstNo ?? "",
                                  emails: data.email ?? "",
                                  transport: transportText,
                                  bankDetails: data.bankDetails,
                                );
                              },
                            );
                          },
                          trashIconTap: () {
                            ExitConfirmationDialog.show(
                              context,
                              isDelete: true,
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
                                          text: customer.customerName,
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
                              saveButtonText: "Delete",
                              discardButtonText: "Cancel",
                              onSave: () async {
                                Navigator.of(context).pop();
                                final provider = context.read<
                                    CustomerProvider>();

                                final success = await provider.deleteCustomer(
                                  customer.code,
                                );

                                if (!context.mounted) return;
                                ScaffoldSnackBar.show(
                                  context,
                                  success
                                      ? "Customer deleted successfully"
                                      : "Failed to delete Customer",
                                );
                              },
                              onDiscard: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
              )
        ]
  )
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
