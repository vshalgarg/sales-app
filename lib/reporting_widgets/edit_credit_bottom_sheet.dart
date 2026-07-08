import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors_used.dart';
import '../model_classes/search_credit.dart';
import '../provider/entries_provider/entries_section_provider.dart';
import '../services/update_credit_api.dart';

class EditCreditBottomSheet extends StatefulWidget {
  final SearchCreditEntry credit;

  const EditCreditBottomSheet({super.key, required this.credit});

  @override
  State<EditCreditBottomSheet> createState() => _EditCreditBottomSheetState();
}

class _EditCreditBottomSheetState extends State<EditCreditBottomSheet> {
  late TextEditingController invoiceController;
  late TextEditingController dateController;
  late TextEditingController referenceController;
  late TextEditingController referenceDateController;
  late TextEditingController slipController;
  late TextEditingController amountController;
  late TextEditingController remarkController;
  bool isLoading = false;
  String? paymentType;
  String? drawType;
  String? supplier;
  String? customer;
  int? supplierId;
  int? customerId;
  final paymentTypes = ["CASH", "UPI", "NEFT_RTGS", "CHEQUE"];

  final drawTypes = ["DRAW", "CHEQUE"];

  Widget _fieldContainer({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    supplierId = widget.credit.supplierId;
    customerId = widget.credit.customerId;
    invoiceController = TextEditingController(
      text: widget.credit.billNumber ?? "",
    );

    dateController = TextEditingController(text: widget.credit.date ?? "");

    referenceController = TextEditingController(
      text: widget.credit.referenceNumber ?? "",
    );

    referenceDateController = TextEditingController(
      text: widget.credit.referenceDate ?? "",
    );

    slipController = TextEditingController(
      text: widget.credit.slipNumber ?? "",
    );

    amountController = TextEditingController(
      text: "${widget.credit.receivedAmount ?? 0}",
    );

    remarkController = TextEditingController(text: widget.credit.remark ?? "");

    paymentType = widget.credit.paymentType;
    drawType = widget.credit.drawType;
    supplier = widget.credit.supplierName;
    customer = widget.credit.customerName;

    final provider = Provider.of<EntriesProvider>(context, listen: false);
    if (provider.entries.isEmpty) {
      provider.fetchSuppliers();
    }

    if (provider.customerEntries.isEmpty) {
      provider.fetchCustomer();
    }
  }

  @override
  void dispose() {
    invoiceController.dispose();
    dateController.dispose();
    referenceController.dispose();
    referenceDateController.dispose();
    slipController.dispose();
    amountController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  Future<void> pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Material(
        color: const Color(0xFF9CA4DA),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 30, bottom: 2, left: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffe0e0e0))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Edit Credit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _fieldContainer(
                      label: "Invoice Number",
                      child: TextField(
                        controller: invoiceController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    _dateField(dateController, "Date"),

                    _dropdownField("Payment Type", paymentType, paymentTypes, (
                      v,
                    ) {
                      setState(() {
                        paymentType = v;
                      });
                    }),

                    Consumer<EntriesProvider>(
                      builder: (context, provider, child) {
                        final suppliers = provider.entries
                            .map((e) => e.supplierName ?? '')
                            .toSet()
                            .toList();

                        return _fieldContainer(
                          label: "Supplier",
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: suppliers.contains(supplier)
                                  ? supplier
                                  : null,
                              items: suppliers.map((name) {
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                final selected = provider.entries.firstWhere(
                                  (e) => e.supplierName == value,
                                );

                                setState(() {
                                  supplier = value;
                                  supplierId = selected.id?.toInt();
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Consumer<EntriesProvider>(
                      builder: (context, provider, child) {
                        final customers = provider.customerEntries
                            .map((e) => e.customerName ?? '')
                            .toSet()
                            .toList();

                        return _fieldContainer(
                          label: "Customer",
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: customers.contains(customer)
                                  ? customer
                                  : null,
                              items: customers.map((name) {
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                final selected = provider.customerEntries
                                    .firstWhere((e) => e.customerName == value);

                                setState(() {
                                  customer = value;
                                  customerId = selected.id?.toInt();
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    _textField(referenceController, "Reference Number"),
                    _dateField(referenceDateController, "Reference Date"),
                    _textField(slipController, "Slip Number"),

                    _dropdownField("Draw Type", drawType, drawTypes, (v) {
                      setState(() {
                        drawType = v;
                      });
                    }),

                    _textField(amountController, "Received Amount"),
                    _fieldContainer(
                      label: "Remark",
                      child: TextField(
                        controller: remarkController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await updateCredit(
                              id: widget.credit.id!,
                              date: dateController.text,
                              supplierId: supplierId ?? 0,
                              paymentType: paymentType ?? "",
                              customerId: customerId,
                              referenceNumber: referenceController.text,
                              referenceDate: referenceDateController.text,
                              slipNumber: slipController.text,
                              drawType: drawType,
                              receivedAmount:
                                  double.tryParse(amountController.text) ?? 0,
                              remark: remarkController.text,
                            );

                            if (!mounted) return;

                            Navigator.pop(context, true);
                          } catch (e) {
                            if (!mounted) return;
                            // Navigator.pop(context, true);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Update Failed: $e")),
                            );
                          }
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return _fieldContainer(
      label: label,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _dateField(TextEditingController controller, String label) {
    return _fieldContainer(
      label: label,
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => pickDate(controller),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final safeValue = items.contains(value) ? value : null;

    return _fieldContainer(
      label: label,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: safeValue,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
