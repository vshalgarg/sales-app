import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/bottom_navigation_bar.dart';
import 'package:hisabio/customs/containers/master_containers/supplier_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/delete_supplier_dialog.dart';
import 'package:hisabio/drawers/master_drawer.dart';
import 'package:hisabio/enums/supplier_mode.dart';
import 'package:hisabio/model_classes/add_newsupplier.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/delete_supplier_provider.dart';
import 'package:hisabio/provider/get_supplier_provider.dart';
import 'package:hisabio/provider/get_suppliers_byid_provider.dart';
import 'package:hisabio/screens/master_screens/add_new_supplier.dart';

//import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class Supplier extends StatefulWidget {
  const Supplier({super.key});

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SupplierProvider>().fetchSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Supplier",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      drawer: MasterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              height: 40,
              width: double.infinity,
              child: SearchBar(
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search suppliers...",
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            SizedBox(height: 25),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text(provider.error!))
                  : ListView.separated(
                      itemCount: provider.data?.content?.length ?? 0,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 8);
                      },
                      itemBuilder: (context, index) {
                        final item = provider.data!.content![index];
                        return SupplierContainer(
                          elevation: 1,
                          name: item.supplierName,
                          gst: item.supplierGstNo,
                          code: item.code,
                          city: item.city,
                          eyeIconTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNewSupplier(
                                  id: item.id,
                                  mode: SupplierMode.view,
                                  supplierData: AddNewsupplier.fromJson(
                                    item.toJson(),
                                  ),
                                ),
                              ),
                            );
                          },
                          trashIconTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CustomDeleteDialog(
                                  supplierName: item.supplierName ?? "",
                                  onDelete: () async {
                                    final provider =
                                        Provider.of<DeleteSupplierProvider>(
                                          context,
                                          listen: false,
                                        );
                                    await provider.deleteSupplier(item.code!);
                                    await context
                                        .read<SupplierProvider>()
                                        .fetchSuppliers();
                                    Navigator.pop(context);
                                    ScaffoldSnackBar.show(
                                      context,
                                      provider.message,
                                    );
                                  },
                                );
                              },
                            );
                          },
                          copyIconTap: ()async {
                            final provider = context.read<GetSupplierByIdProvider>();
                            await provider.fetchSupplierById(item.id!.toInt());
                            final data = provider.supplier;

                            if (data == null) return;

                            String contactNumber = "";

                            if (data.contacts != null && data.contacts!.isNotEmpty) {
                              final firstContact = data.contacts![0];

                              if (firstContact is Map) {
                                contactNumber = firstContact['mobileNumber'] ?? "";
                              }
                            }
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CustomCopyDetailsDialog(
                                  firmName: provider.supplier?.supplierName??"",
                                  contact: contactNumber,
                                  address:  provider.supplier?.addressLine1??"" ,
                                  gstNo:  provider.supplier?.gstNo??"",

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
                                  mode: SupplierMode.edit,
                                  supplierData: AddNewsupplier.fromJson(
                                    item.toJson(),
                                  ),
                                ),
                              ),
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
            MaterialPageRoute(builder: (context) => AddNewSupplier()),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
