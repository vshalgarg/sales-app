import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/drawers/entries_drawer.dart';
import 'package:hisabio/entry_widgets/custom_container_entry.dart';
import 'package:hisabio/entry_widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';
import '../../entry_widgets/custom_api_textfield.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../entry_widgets/custom_list_textfield.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../provider/entries_provider/entries_section_provider.dart';

class CreditEntry extends StatefulWidget {
  const CreditEntry({super.key});

  @override
  State<CreditEntry> createState() => _CreditEntryState();
}

class _CreditEntryState extends State<CreditEntry> {
  EntriesModel? selectedSupplier;
  EntriesCustomerModel? selectedCustomer;
  String?drawType;
  String?paymentMode;
  final invoiceController = TextEditingController();
  final receivedAmountController = TextEditingController();
  final referenceController = TextEditingController();
  final slipController = TextEditingController();
  final referenceDateController = TextEditingController();
  final transactionDateController = TextEditingController();
  final remarksController = TextEditingController();
  final List<String> drawTypeList=["DRAW","CHEQUE"];
final List<String> paymentModeList=["NEFT/RTGS","UPI","CASH","CHEQUE"];
@override
void dispose(){
  invoiceController.dispose();
  receivedAmountController.dispose();
  referenceController.dispose();
  slipController.dispose();
  referenceDateController.dispose();
  transactionDateController.dispose();
  remarksController.dispose();
  super.dispose();
}
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();

      await provider.fetchSuppliers();
      await provider.fetchCustomer();
    });
  }
  void clearFields() {
    invoiceController.clear();
    receivedAmountController.clear();
    remarksController.clear();
    referenceController.clear();
    slipController.clear();
    referenceDateController.clear();
    transactionDateController.clear();
    setState(() {
      drawType = null;
      selectedSupplier = null;
      selectedCustomer=null;
      paymentMode=null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Credit Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      drawer: EntryDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              EntryContainer(
                children: [
                  Text(
                    "Party Information",
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
                    },
                  ),
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
                ],
              ),
              SizedBox(height: 20),
              EntryContainer(
                children: [
                  Text(
                    "Transaction Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CustomListTextField(
                    hintText: "Payment Mode",
                    value: paymentMode,
                    items:paymentModeList,
                    onChanged: (value) {
                      setState(() {
                        paymentMode = value;
                      });
                    },
                  ),SizedBox(height:10),
                  EntryTextField(
                    controller: invoiceController,
                    hintText: "Invoice Number",
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    controller: receivedAmountController,
                    hintText: "Received Amount",
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    controller: referenceController,
                    hintText: "Reference Number",
                  ),
                  SizedBox(height: 10),
                  EntryDateTextField(
                    label: "Reference Date",
                    controller: referenceDateController,
                  ),
                  SizedBox(height: 10),
                  EntryDateTextField(
                    label: "Transaction Date",
                    controller: transactionDateController,
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    controller: slipController,
                    hintText: "Slip Number",
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              EntryContainer(
                children: [
                  Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CustomListTextField(
                    hintText: "Draw Type",
                    value: drawType,
                    items: drawTypeList,
                    onChanged: (value) {
                      setState(() {
                        drawType = value;
                      });
                    },
                  ),
                  SizedBox(height:10),
                  EntryTextField(
                    controller: remarksController,
                    hintText: "Remarks",
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height:20),
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomElevatedButton(
                    text: "Reset",
                    textStyle: TextStyle(color: Colors.black, fontSize: 20),
                    onPressed: ()async{clearFields();},
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
