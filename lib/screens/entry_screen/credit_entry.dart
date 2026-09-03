import 'dart:developer';
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
import '../../model_classes/credits/add_credit_request.dart';
import '../../model_classes/credits/credit.dart';
import '../../model_classes/entries/entries_customer_model.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/reporting_provider/credit_provider.dart';

class CreditEntry extends StatefulWidget {
  final FormMode mode;
  final Credit? credit;

  const CreditEntry({super.key, this.mode = FormMode.add, this.credit});

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
  String? _toApiDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    try {
      return DateFormat('yyyy-MM-dd').format(
        DateFormat('dd-MM-yyyy').parse(value.trim()),
      );
    } catch (_) {
      return value;
    }
  }
  Map<String, dynamic> _creditBody() {
    return {
      "billNumber": invoiceController.text.trim(),
      "customerId": selectedCustomer?.id,
      "supplierId": selectedSupplier?.id,
      "paymentType": paymentMode,

      "receivedAmount": receivedAmountController.text.trim().isEmpty
          ? null
          : num.parse(receivedAmountController.text.trim()),

      "referenceNumber": referenceController.text.trim(),

      "referenceDate": _toApiDate(
        referenceDateController.text,
      ),

      "date": _toApiDate(
        transactionDateController.text,
      ),

      "slipNumber": slipController.text.trim(),
      "drawType": drawType,
      "remark": remarksController.text.trim(),
    };
  }

  AutovalidateMode _validationMode = AutovalidateMode.disabled;

  void _enableValidation() {
    setState(() {
      _validationMode = AutovalidateMode.always;
    });
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

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == FormMode.add) {
      transactionDateController.text = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final provider = context.read<EntriesProvider>();

    Future.microtask(() async {

      await Future.wait([provider.fetchSuppliers(), provider.fetchCustomer()]);

      if (!mounted) return;

      if (widget.credit != null) {
        _fillData(provider);
      }

      setState(() {});
    });
  }
  String _formatDisplayDate(String? value) {
    if (value == null || value.trim().isEmpty) return "";

    try {
      return DateFormat('dd-MM-yyyy').format(
        DateTime.parse(value.trim()),
      );
    } catch (_) {
      return value;
    }
  }
  void _fillData(EntriesProvider provider) {
    final credit = widget.credit;

    if (credit == null) return;

    invoiceController.text = credit.billNumber ?? "";
    receivedAmountController.text =
        credit.receivedAmount?.toString() ?? "";

    referenceController.text = credit.referenceNumber ?? "";

    referenceDateController.text =
        _formatDisplayDate(credit.referenceDate);

    transactionDateController.text =
        _formatDisplayDate(credit.date);

    slipController.text = credit.slipNumber ?? "";
    remarksController.text = credit.remark ?? "";

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
    setState(() {
      drawType = null;
      selectedSupplier = null;
      selectedSupplierName = null;
      selectedCustomer = null;
      selectedCustomerName = null;
      paymentMode = null;
      _validationMode = AutovalidateMode.disabled;
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
                    Navigator.pop(context, true);
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
                    EntryContainer(
                      children: [
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    "Party Information",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                icon: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded) ...[
                          SizedBox(height: 10),
                          Text(
                            widget.mode == FormMode.add ? "Supplier * " : "Supplier",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          CustomDropdown(
                            isDisabled: isViewMode,
                            hintText: "Supplier ",
                            items: provider.entries
                                .map((e) => e.supplierName ?? '')
                                .where((e) => e.isNotEmpty)
                                .toList(),
                            initialValue: selectedSupplierName,
                            autovalidateMode: _validationMode,
                            validator: (value) {
                              if (selectedSupplier == null ||
                                  value == null ||
                                  value.trim().isEmpty) {
                                return "Supplier is required";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value == null) return;

                              final supplier = provider.entries.firstWhere(
                                (e) => e.supplierName == value,
                              );

                              setState(() {
                                selectedSupplierName = value;
                                selectedSupplier = supplier;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.mode == FormMode.add ? "Customer * " : "Customer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          CustomDropdown(
                            isDisabled: isViewMode,
                            hintText: "Customer  ",
                            items: provider.customerEntries
                                .map((e) => e.customerName ?? '')
                                .where((e) => e.isNotEmpty)
                                .toList(),
                            initialValue: selectedCustomerName,
                            autovalidateMode: _validationMode,
                            validator: (value) {
                              if (selectedCustomer == null ||
                                  value == null ||
                                  value.trim().isEmpty) {
                                return "Customer is required";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value == null) return;

                              final customer = provider.customerEntries
                                  .firstWhere((e) => e.customerName == value);

                              setState(() {
                                selectedCustomerName = value;
                                selectedCustomer = customer;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      ],
                    ),
                    SizedBox(height: 15),

              EntryContainer(
                        children: [
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      "Transaction Details",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isTransactionExpanded = !isTransactionExpanded;
                                    });
                                  },
                                  icon: Icon(
                                    isTransactionExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isTransactionExpanded) ...[
                            SizedBox(height: 10),
                            Text(
                              widget.mode == FormMode.add ? "Payment Mode * " : "Payment Mode",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Payment Mode ",
                              initialValue: paymentMode,
                              items: paymentModeList,
                              autovalidateMode: _validationMode,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                              widget.mode == FormMode.add ? " Reference Number * " : "Reference Number",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: !isViewMode,
                              controller: referenceController,
                              hintText: "Reference Number ",
                              autovalidateMode: _validationMode,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Reference Number is required";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.mode == FormMode.add ? "Reference Date * " : "Reference Date",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryDateTextField(
                              enabled: !isViewMode,
                              label: "Reference Date  ",
                              controller: referenceDateController,
                              autovalidateMode: _validationMode,
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
                              autovalidateMode: _validationMode,
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
                    SizedBox(height: 15),
              EntryContainer(
                        children: [
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      "Additional Information",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isAdditionalExpanded = !isAdditionalExpanded;
                                    });
                                  },
                                  icon: Icon(
                                    isAdditionalExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
                    SizedBox(height: 15),
                    if (widget.mode == FormMode.add)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 10),
                        child: Row(
                          children: [
                            // RESET
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () {
                                    clearFields();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color(0xFFE5E2EE),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.refresh_rounded,
                                          color: AppColors.primaryPurple,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 10),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Reset",
                                            style: TextStyle(
                                              color: AppColors.primaryPurple,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // SAVE
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () async {

                                    setState(() {
                                      isExpanded = true;
                                      isTransactionExpanded = true;
                                      isAdditionalExpanded = true;
                                      _validationMode = AutovalidateMode.always;
                                    });

                                    await Future<void>.delayed(Duration.zero);

                                    if (!mounted) return;

                                    final isValid =
                                        _formKey.currentState?.validate() ??
                                            false;

                                    if (!isValid) {

                                      ScaffoldSnackBar.show(
                                        context,
                                        "Please fill all required fields",
                                      );

                                      return;
                                    }

                                    final body = _creditBody();
                                    try {
                                      final request = AddCreditRequest.fromJson(
                                        body,
                                      );

                                      final success = await context
                                          .read<CreditProvider>()
                                          .addCredit(request: request);

                                      if (!mounted) return;

                                      if (success) {
                                        Navigator.pop(context, true);
                                      }
                                    } catch (e, stackTrace) {
                                      log("ADD CREDIT ERROR: $e",
                                        stackTrace: stackTrace,
                                      );

                                      if (!mounted) return;

                                      final message = e
                                          .toString()
                                          .replaceFirst("Exception: ", "")
                                          .trim();

                                      ScaffoldSnackBar.show(context, message);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.save_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 10),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Save",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                              "Credit entry successfully added."
                              "Failed to add credit entry",
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

                            Navigator.pop(context, true);
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
        ],
      ),
    );
  }
}
