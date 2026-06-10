import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/bottom_navigation_bar.dart';
import 'package:hisabio/customs/elevated_button.dart';
import 'package:hisabio/drawers/entries_drawer.dart';
import 'package:hisabio/entry_widgets/custom_container_entry.dart';
import 'package:hisabio/entry_widgets/custom_date_textfield.dart';
import 'package:hisabio/entry_widgets/custom_textfield.dart';
import 'package:hisabio/model_classes/entries_customer_model.dart';
import 'package:hisabio/model_classes/get_transportname_id_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../entry_widgets/custom_api_textfield.dart';
import '../../model_classes/entries_supplier.dart';
import '../../provider/entries_provider/entries_section_provider.dart';

class EntriesBillEntry extends StatefulWidget {
  const EntriesBillEntry({super.key});

  @override
  State<EntriesBillEntry> createState() => _EntriesBillEntryState();
}

class _EntriesBillEntryState extends State<EntriesBillEntry> {
  EntriesModel? selectedSupplier;
  EntriesCustomerModel? selectedCustomer;
  GetTransportnameIdModel? selectedTransport;
  final dateController = TextEditingController();
  final receivedDateController = TextEditingController();
  final invoiceController = TextEditingController();
  final supplierGroupController = TextEditingController();
  final supplierGstController = TextEditingController();
  final customerGroupController = TextEditingController();
  final customerGstController = TextEditingController();
  final lrNumberController = TextEditingController();
  final remarksController = TextEditingController();
  final supplierController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    receivedDateController.dispose();
    invoiceController.dispose();
    supplierGroupController.dispose();
    supplierGstController.dispose();
    customerGroupController.dispose();
    customerGstController.dispose();
    lrNumberController.dispose();
    remarksController.dispose();
    supplierController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();

      await provider.fetchSuppliers();
      await provider.fetchCustomer();
      await provider.fetchTransport();
    });

    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    // final customerProvider=context.watch<EntriesProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Bill Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      drawer: EntryDrawer(),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              EntryContainer(
                children: [
                  Text(
                    "Order Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  EntryDateTextField(label: "Date", controller: dateController),
                  SizedBox(height: 10),
                  EntryDateTextField(
                    label: "Received Date",
                    controller: receivedDateController,
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    controller: invoiceController,
                    hintText: "Invoice",
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              EntryContainer(
                children: [
                  Text(
                    "Supplier Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CustomApiTextField<EntriesModel>(
                    hintText: "Supplier",
                    value: selectedSupplier,
                    items: provider.entries,
                    itemLabel: (e) => e.supplierName ?? '',
                    onChanged: (value) {
                      setState(() {
                        selectedSupplier = value;
                      });

                      supplierGroupController.text = value?.supplierGroup ?? '';

                      supplierGstController.text = value?.supplierGstNo ?? '';
                    },
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    hintText: "Supplier Group",
                    controller: supplierGroupController,
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    hintText: "GSTIN",
                    controller: supplierGstController,
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              EntryContainer(
                children: [
                  Text(
                    "Customer Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CustomApiTextField<EntriesCustomerModel>(
                    hintText: "Customer",
                    value: selectedCustomer,
                    items: provider.customerEntries,
                    itemLabel: (e) => e.customerName ?? '',
                    onChanged: (value) {
                      setState(() {
                        selectedCustomer = value;
                      });

                      customerGroupController.text = value?.customerGroup ?? '';

                      customerGstController.text = value?.customerGstNo ?? '';
                    },
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    hintText: "Customer Group",
                    controller: customerGroupController,
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    hintText: "GSTIN",
                    controller: customerGstController,
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap:(){},
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurpleLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.document_upload,color: AppColors.primaryPurple,),
                        Text(
                          "Upload Documents",
                          style: TextStyle(color: AppColors.primaryPurple,fontSize:15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              EntryContainer(
                children: [
                  Text(
                    "Logistics & Notes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CustomApiTextField<GetTransportnameIdModel>(
                    hintText: "Transport",
                    value: selectedTransport,
                    items: provider.transportDetails,
                    itemLabel: (e) => e.name ?? '',
                    onChanged: (value) {
                      setState(() {
                        selectedTransport = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    hintText: "LR Number",
                    controller: lrNumberController,
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    hintText: "Remarks",
                    controller: remarksController,
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomElevatedButton(
                    text: "Reset",
                    textStyle: TextStyle(color: Colors.black, fontSize: 20),
                    onPressed: () async {},
                    borderRadius: 10,
                  ),
                  SizedBox(width: 20),
                  CustomElevatedButton(
                    text: "Save",
                    textStyle: TextStyle(color: Colors.white, fontSize: 20),
                    onPressed: () async {},
                    borderRadius: 10,
                    color: AppColors.primaryPurple,
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
