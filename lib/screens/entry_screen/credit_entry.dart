import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/entry_widgets/custom_container_entry.dart';
import 'package:hisabio/entry_widgets/custom_textfield.dart';
import 'package:hisabio/screens/home_screen.dart';
import 'package:hisabio/screens/reporting_screen/credit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';

import '../../customs/elevated_button.dart';
import '../../entry_widgets/custom_api_textfield.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../entry_widgets/custom_list_textfield.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';

class CreditEntry extends StatefulWidget {
  const CreditEntry({super.key});

  @override
  State<CreditEntry> createState() => _CreditEntryState();
}

class _CreditEntryState extends State<CreditEntry> {
  final _formKey = GlobalKey<FormState>();
  bool isExpanded = true;
  bool isTransactionExpanded = false;
  bool isAdditionalExpanded = false;
  EntriesModel? selectedSupplier;
  EntriesCustomerModel? selectedCustomer;
  String? drawType;
  String? paymentMode;
  final invoiceController = TextEditingController();
  final receivedAmountController = TextEditingController();
  final referenceController = TextEditingController();
  final slipController = TextEditingController();
  final referenceDateController = TextEditingController();
  final transactionDateController = TextEditingController();
  final remarksController = TextEditingController();
  final List<String> drawTypeList = ["DRAW", "CHEQUE"];
  final List<String> paymentModeList = ["NEFT/RTGS", "UPI", "CASH", "CHEQUE"];

  Map<String, dynamic> _creditBody() {
    return {
      "billNumber": invoiceController.text.trim(),
      "customerId": selectedCustomer?.id,
      "supplierId": selectedSupplier?.id,
      "paymentType": paymentMode,
      "receivedAmount": receivedAmountController.text.trim(),
      "referenceNumber": referenceController.text.trim(),
      "referenceDate": referenceDateController.text.trim(),
      "date": transactionDateController.text.trim(),
      "slipNumber": slipController.text.trim(),
      "drawType": drawType,
      "remark": remarksController.text.trim(),
    };
  }

  @override
  void dispose() {
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
    transactionDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();
      await Future.wait([provider.fetchSuppliers(), provider.fetchCustomer()]);
    });
  }

  void clearFields() {
    _formKey.currentState?.reset();

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
      selectedCustomer = null;
      paymentMode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        title: "Credit Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ExitConfirmationDialog.show(
                context,
                onSave: () async {
                  Navigator.pop(context);
                  if (!_formKey.currentState!.validate()) {
                    ScaffoldSnackBar.show(
                      context,
                      "Please fill all the required fields",
                    );
                    return;
                  }
                  try {
                    final body = _creditBody();
                    final response = await context
                        .read<EntriesProvider>()
                        .addCreditEntry(body);

                    if (!context.mounted) return;
                    ScaffoldSnackBar.show(
                      context,
                      response?.message ?? "Success",
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Credit()),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldSnackBar.show(context, e.toString());
                  }
                },onClose: () {
                Navigator.pop(context);
              },
                onDiscard: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Credit(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
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
                          hintText: "Party Information",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (isExpanded) ...[
                        SizedBox(height: 10),
                        Text(
                          "Supplier",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        CustomApiTextField<EntriesModel>(
                          hintText: "Supplier*",
                          value: selectedSupplier,
                          items: provider.entries,
                          itemLabel: (e) => e.supplierName ?? '',
                          validator: (value) {
                            if (value == null) {
                              return "Supplier is required";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedSupplier = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Customer",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        CustomApiTextField<EntriesCustomerModel>(
                          hintText: "Customer*",
                          value: selectedCustomer,
                          items: provider.customerEntries,
                          itemLabel: (e) => e.customerName ?? '',
                          validator: (value) {
                            if (value == null) {
                              return "Customer is required";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedCustomer = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 15),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isTransactionExpanded = !isTransactionExpanded;
                    });
                  },
                  child: EntryContainer(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            isTransactionExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          enabled: false,
                          filled: true,
                          fillColor: AppColors.primaryPurple,
                          hintText: "Transaction Details",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (isTransactionExpanded) ...[
                        SizedBox(height: 10),
                        Text(
                          "Payment Mode",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        CustomListTextField(
                          hintText: "Payment Mode*",
                          value: paymentMode,
                          items: paymentModeList,
                          validator: (value) {
                            if (value == null) {
                              return "Payment Mode is required";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              paymentMode = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Invoice Number",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        EntryTextField(
                          controller: invoiceController,
                          hintText: "Invoice Number",
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Received Amount",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        EntryTextField(integerOnly: true,decimalAllowed: true,
                          controller: receivedAmountController,
                          hintText: "Received Amount",
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Reference Number",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        EntryTextField(
                          controller: referenceController,
                          hintText: "Reference Number*",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Reference Number is required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Reference Date",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        EntryDateTextField(
                          label: "Reference Date*",
                          controller: referenceDateController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Reference Date is required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Transaction Date",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        EntryDateTextField(
                          label: "Transaction Date",
                          controller: transactionDateController,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Slip Number",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        EntryTextField(
                          controller: slipController,
                          hintText: "Slip Number",
                        ),
                        SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAdditionalExpanded = !isAdditionalExpanded;
                    });
                  },
                  child: EntryContainer(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            isAdditionalExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          enabled: false,
                          filled: true,
                          fillColor: AppColors.primaryPurple,
                          hintText: "Additional Information",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (isAdditionalExpanded) ...[
                        SizedBox(height: 10),
                        Text(
                          "Draw Type",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
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
                        SizedBox(height: 10),
                        Text(
                          "Remarks",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        EntryTextField(
                          controller: remarksController,
                          hintText: "Remarks",
                        ),
                        SizedBox(height: 10),
                      ],
                    ],
                  ),
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
                      text: "Save",
                      textStyle: TextStyle(color: Colors.white, fontSize: 20),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          ScaffoldSnackBar.show(
                            context,
                            "Please fill all the required fields",
                          );
                          return;
                        }
                        try {
                          final body = _creditBody();
                          final response = await context
                              .read<EntriesProvider>()
                              .addCreditEntry(body);

                          if (!context.mounted) return;
                          ScaffoldSnackBar.show(
                            context,
                            response?.message ?? "Success",
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Credit()),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldSnackBar.show(context, e.toString());
                        }
                      },
                      borderRadius: 5,
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
