import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';

import 'package:hisabio/customs/elevated_button.dart';
import 'package:hisabio/entry_widgets/custom_api_textfield.dart';
import 'package:hisabio/entry_widgets/custom_container_entry.dart';
import 'package:hisabio/entry_widgets/custom_textfield.dart';
import 'package:hisabio/model_classes/get_staff_entry.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../dialog_boxes/entry_dialogboxes/bill_section_upload_documents_dialog.dart';

import '../../entry_widgets/custom_date_textfield.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../home_screen.dart';

class PurchaseEntryScreen extends StatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  bool isExpanded=false;
  bool isSupplierExpanded=false;
  EntriesCustomerModel? selectedCustomer;
  GetStaffEntry? selectedStaff;
  List<int> suppliers = [0];
  final transactionController = TextEditingController();
  List<TextEditingController> remarksControllers = [TextEditingController()];

  List<EntriesModel?> selectedSuppliers = [null];
  List<PlatformFile> uploadedFiles = [];

  void clearFields() {
    transactionController.clear();
    setState(() {
      selectedStaff = null;
      suppliers = [0];
      selectedCustomer = null;
      remarksControllers = [TextEditingController()];
      selectedSuppliers = [null];
      uploadedFiles = [];
    });
  }

  @override
  void initState() {
    super.initState();
    transactionController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();

      await provider.fetchCustomer();
      await provider.fetchSuppliers();
      await provider.fetchStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
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
        title: "Purchase Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(onTap:(){setState(() {
                isExpanded=!isExpanded;
              });},
                child: EntryContainer(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                        enabled: false,
                        filled: true,
                        fillColor: AppColors.primaryPurple,
                        hintText: "Information",
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if(isExpanded)...[
                    SizedBox(height: 10),
                    CustomApiTextField<EntriesCustomerModel>(
                      hintText: "Customer",
                      value: selectedCustomer,
                      items: provider.customerEntries,
                      itemLabel: (e) => e.customerName ?? '',
                      onChanged: (value) {
                        setState(() {
                          selectedCustomer = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    CustomApiTextField<GetStaffEntry>(
                      hintText: "Staff",
                      value: selectedStaff,
                      items: provider.staffList,
                      itemLabel: (e) => e.staffName ?? '',
                      onChanged: (value) {
                        setState(() {
                          selectedStaff = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    EntryDateTextField(
                      label: "Transaction Date",
                      controller: transactionController,
                    ),
                  ],
                ]),
              ),
              SizedBox(height: 15),
              GestureDetector(onTap:(){setState(() {
                isSupplierExpanded=!isSupplierExpanded;
              });},
                child: EntryContainer(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          isSupplierExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                        enabled: false,
                        filled: true,
                        fillColor: AppColors.primaryPurple,
                        hintText: "Suppliers",
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if(isSupplierExpanded)...[
                    CustomElevatedButton(
                      color: AppColors.primaryPurple,
                      text: "+ Add More Supplier",
                      textStyle: TextStyle(color: Colors.white),
                      onPressed: () async {
                        setState(() {
                          suppliers.add(suppliers.length);
                          remarksControllers.add(TextEditingController());

                          selectedSuppliers.add(null);
                        });
                      },
                      borderRadius: 5,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.bodyFillColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              CustomApiTextField<EntriesModel>(
                                hintText: "Supplier",
                                value: selectedSuppliers[index],
                                items: provider.entries,
                                itemLabel: (e) => e.supplierName ?? '',
                                onChanged: (value) {
                                  setState(() {
                                    selectedSuppliers[index] = value;
                                  });
                                },
                              ),
                              SizedBox(height: 10),
                              EntryTextField(
                                controller: remarksControllers[index],
                                hintText: "Remarks",
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final files =
                                          await showDialog<
                                            List<PlatformFile>
                                          >(
                                            context: context,
                                            builder: (context) =>
                                                const BillEntryUploadDocuments(),
                                          );

                                      if (files != null) {
                                        setState(() {
                                          uploadedFiles = files;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurpleLight,
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Iconsax.document_upload,
                                              color: AppColors.primaryPurple,
                                            ),
                                            Text(
                                              "Upload Documents",
                                              style: TextStyle(
                                                color:
                                                    AppColors.primaryPurple,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${uploadedFiles.length} Files",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
               ] ),
              ),
              SizedBox(height: 15),
              Column(
                children: [
                  CustomElevatedButton(
                    text: "Reset",
                    textStyle: TextStyle(color: Colors.black, fontSize: 20),
                    onPressed: () async {
                      clearFields();
                    },
                    borderRadius: 5,
                  ),
                  SizedBox(height: 5),
                  CustomElevatedButton(
                    color: AppColors.primaryPurple,
                    text: "Save",
                    textStyle: TextStyle(color: Colors.white, fontSize: 20),
                    onPressed: () async {
                      if(selectedCustomer==null||selectedSuppliers.isEmpty){
                        ScaffoldSnackBar.show(context,"Please select  customer and supplier");
                        return;
                      }
                      final payload = {
                        "date": transactionController.text,
                        "staffId": selectedStaff?.staffId,
                        "customerId": selectedCustomer?.id,
                        "suppliers": List.generate(
                          selectedSuppliers.length,
                          (index) => {
                            "supplierId": selectedSuppliers[index]?.id,
                            "remarks": remarksControllers[index].text,
                          },
                        ),
                      };
                      final images = uploadedFiles
                          .where((e) => e.path != null)
                          .map((e) => File(e.path!))
                          .toList();

                      print(jsonEncode(payload));
                      try {
                        final message = await provider.savePurchase(
                          payload: payload,
                          images: images,
                        );
                        if (!context.mounted) return;
                        ScaffoldSnackBar.show(
                          context,
                          message ?? "Purchase Saved Successfully",
                        );

                        clearFields();
                      } catch (e) {
                        ScaffoldSnackBar.show(context, e.toString());
                      }
                    },
                    borderRadius: 5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
