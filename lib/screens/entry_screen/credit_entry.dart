
import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/dropdown_test.dart';
import 'package:hisabio/entry_widgets/custom_container_entry.dart';
import 'package:hisabio/entry_widgets/custom_textfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';

import '../../customs/elevated_button.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/credits/credit.dart';
import '../../model_classes/entries/entries_customer_model.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';

class CreditEntry extends StatefulWidget {
  final FormMode mode;
  final Credit? credit;

  const CreditEntry({
    super.key,
    this.mode = FormMode.add,
    this.credit,
  });

  @override
  State<CreditEntry> createState() => _CreditEntryState();
}
class _CreditEntryState extends State<CreditEntry> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool isExpanded = true;
  bool isTransactionExpanded = false;
  bool isAdditionalExpanded = false;
  EntriesModel? selectedSupplier;
  String? selectedSupplierName;
  EntriesCustomerModel? selectedCustomer;
  String? selectedCustomerName;
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
  final List<String> paymentModeList = ["NEFT_RTGS", "UPI", "CASH", "CHEQUE"];

  bool get isViewMode => widget.mode == FormMode.view;
  // AddCreditRequest _buildRequest() {
  //   return AddCreditRequest(
  //     billNumber: invoiceController.text.trim(),
  //     supplierId: selectedSupplier!.id!.toInt(),
  //     customerId: selectedCustomer!.id!.toInt(),
  //     paymentType: paymentMode!,
  //     referenceNumber: referenceController.text.trim(),
  //     referenceDate: referenceDateController.text.trim(),
  //     date: transactionDateController.text.trim(),
  //     slipNumber: slipController.text.trim(),
  //     drawType: drawType,
  //     receivedAmount:
  //     double.tryParse(receivedAmountController.text) ?? 0,
  //     remark: remarksController.text.trim(),
  //   );
  // }
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
    _scrollController.dispose();
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
    transactionDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();
      await Future.wait([provider.fetchSuppliers(), provider.fetchCustomer()]);
      if (widget.credit != null) {
        _fillData(provider);
      }
    });
  }

  void _fillData(EntriesProvider provider) {
    final credit = widget.credit;

    if (credit == null) return;

    invoiceController.text = credit.billNumber ?? "";
    receivedAmountController.text =
        credit.receivedAmount?.toString() ?? "";

    referenceController.text =
        credit.referenceNumber ?? "";

    referenceDateController.text =
        credit.referenceDate ?? "";

    transactionDateController.text =
        credit.date ?? "";

    slipController.text =
        credit.slipNumber ?? "";

    remarksController.text =
        credit.remark ?? "";

    paymentMode = credit.paymentType;
    drawType = credit.drawType;

    if (credit.supplierId != null) {
      selectedSupplier = provider.entries.firstWhere(
            (e) => e.id == credit.supplierId,
        orElse: () => provider.entries.first,
      );
      selectedSupplierName = selectedSupplier?.supplierName;
    }

    if (credit.customerId != null) {
      selectedCustomer = provider.customerEntries.firstWhere(
            (e) => e.id == credit.customerId,
        orElse: () => provider.customerEntries.first,
      );
      selectedCustomerName = selectedCustomer?.customerName;
    }

    setState(() {});
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
      selectedSupplierName = null;
      selectedCustomer = null;
      selectedCustomerName = null;
      paymentMode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        title: widget.mode == FormMode.view
            ? "Credit Details"
            : widget.mode == FormMode.edit
            ? "Edit Credit Details"
            : "Add Credit Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        leading: widget.mode == FormMode.view
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          if (widget.mode != FormMode.view)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ExitConfirmationDialog.show(
                  context,
                  onSave: () async {
                    Navigator.pop(context);
                  },
                  discardButtonText: "Leave",
                  saveButtonText: "Stay",
                  onDiscard: () {
                    Navigator.pop(context);
                    Navigator.pop(context,true);
                  },
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Supplier",
                              items: provider.entries
                                  .map((e) => e.supplierName ?? '')
                                  .toList(),
                              initialValue: selectedSupplierName,
                              validator: (value) {
                                if (value == null) {
                                  return "Supplier is required";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedSupplierName = value;

                                  selectedSupplier = provider.entries.firstWhere(
                                        (e) => e.supplierName == value,
                                  );
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Customer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Customer",
                              items: provider.customerEntries
                                  .map((e) => e.customerName ?? '')
                                  .toList(),
                              initialValue: selectedCustomerName,
                              validator: (value) {
                                if (value == null) {
                                  return "Customer is required";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedCustomerName = value;

                                  selectedCustomer = provider.customerEntries.firstWhere(
                                        (e) => e.customerName == value,
                                  );
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                           CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Payment Mode*",
                              initialValue: paymentMode,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: widget.mode == FormMode.add,
                              controller: invoiceController,
                              hintText: "Invoice Number",
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Received Amount",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              integerOnly: true,
                              decimalAllowed: true,
                              controller: receivedAmountController,
                              hintText: "Received Amount",
                              enabled: !isViewMode,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Reference Number",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: !isViewMode,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryDateTextField(
                              enabled: !isViewMode,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryDateTextField(
                              enabled: !isViewMode,
                              label: "Transaction Date",
                              controller: transactionDateController,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Slip Number",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: !isViewMode,
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
                        if (isAdditionalExpanded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Draw Type",
                              initialValue: drawType,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: !isViewMode,
                              controller: remarksController,
                              hintText: "Remarks",
                            ),
                            SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    if (widget.mode == FormMode.add)
                      Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              text: "Reset",
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              onPressed: () async {
                                clearFields();
                              },
                              borderRadius: 5,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CustomElevatedButton(
                              text: "Save",
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
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
                                  Navigator.pop(context, true);
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => Credit(),
                                  //   ),
                                  // );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldSnackBar.show(context, e.toString());
                                }
                              },
                              borderRadius: 5,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    if (widget.mode == FormMode.edit)
                      CustomElevatedButton(
                        text: "Update",
                        color: AppColors.primaryPurple,
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
                                .updateCreditDetails(
                                  id: widget.credit!.id!.toInt(),
                                  body: body,
                                );

                            if (!context.mounted) return;

                            ScaffoldSnackBar.show(
                              context,
                              response?.message ?? "Updated Successfully",
                            );
                            Navigator.pop(context, true);
                            //
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const Credit(),
                            //   ),
                            // );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldSnackBar.show(context, e.toString());
                          }
                        },
                        borderRadius: 5,
                      ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Consumer<EntriesProvider>(
            builder: (context, provider, child) {
              if (!provider.isLoading) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }
}
