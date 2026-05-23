import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/supplier_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/delete_supplier_dialog.dart';
import 'package:hisabio/drawers/master_drawer.dart';
import 'package:hisabio/screens/master_screens/add_new_customer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../enums/customer_mode.dart';
import '../../provider/delete_customer_provider.dart';
import '../../provider/get_customers_provider.dart';
import '../../provider/search_customer_provider.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CustomersProvider>().fetchCustomers();
    });
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Customer",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      drawer: MasterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 40,
              child: SearchBar(
                controller: searchController,
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search customers...",
                onChanged: (value) {
                  context.read<SearchCustomerProvider>().searchCustomer(value);
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
                      return const Center(child: Text("No Customers Found"));
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
                            return SupplierContainer(
                              elevation: 1,
                              name: isSearching
                                  ? customer.customerName
                                  : customer['customerName'],
                              gst: isSearching
                                  ? customer.customerGstNo
                                  : customer['customerGstNo'],
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
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomDeleteDialog(
                                      dialogBoxName: "Delete Supplier",
                                      name: customer['customerName'],
                                      onDelete: () async {
                                        await context
                                            .read<DeleteCustomerProvider>()
                                            .deleteCustomer({
                                              "customerCode": customer['code'],
                                            });

                                        if (deleteProvider.errorMessage ==
                                            null) {
                                          Navigator.pop(context);

                                          context
                                              .read<CustomersProvider>()
                                              .fetchCustomers();

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Customer deleted successfully",
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                deleteProvider.errorMessage!,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                              copyIconTap: () {},
                              editIconTap: () {final id = isSearching
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
                              );},
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
