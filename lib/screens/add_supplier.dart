import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/colors_used.dart';
import '../model_classes/entries_supplier.dart';
import '../provider/entries_provider/entries_section_provider.dart';

class AddSupplier extends StatefulWidget {
  final int retailId;
  final String? headingText;

  const AddSupplier({super.key, this.headingText, required this.retailId});

  @override
  State<AddSupplier> createState() => _AddSupplierState();
}

class _AddSupplierState extends State<AddSupplier> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController depositController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  EntriesModel? selectedSupplier;

  @override
  void initState() {
    super.initState();
    print("Received retailId = ${widget.retailId}");
    dateController.text = DateFormat("dd-MM-yyyy").format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EntriesProvider>();

      if (provider.entries.isEmpty) {
        provider.fetchSuppliers();
      }
    });

    totalController.addListener(_calculateBalance);
    depositController.addListener(_calculateBalance);
  }

  @override
  void dispose() {
    dateController.dispose();
    totalController.dispose();
    depositController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  void _calculateBalance() {
    final total = double.tryParse(totalController.text) ?? 0;
    final deposit = double.tryParse(depositController.text) ?? 0;

    balanceController.text = (total - deposit).toStringAsFixed(2);
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text = DateFormat("dd-MM-yyyy").format(picked);
    }
  }

  InputDecoration decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntriesProvider>(
      builder: (context, provider, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.60,
            ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 35,
                    left: 15,
                    right: 15,
                    bottom: 15,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.headingText ?? "Add Suppliers",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      SizedBox(height: 15),
                  Expanded(
                 child: SingleChildScrollView(
                    child:  Form(
                         key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        DropdownButtonFormField<EntriesModel>(
                                          initialValue: selectedSupplier,
                                          isExpanded: true,
                                          decoration: decoration("Supplier*"),
                                          items: provider.entries.map((e) {
                                            return DropdownMenuItem(
                                              value: e,
                                              child: Text(e.supplierName ?? ""),
                                            );
                                          }).toList(),
                                          validator: (v) => v == null
                                              ? "Select Supplier"
                                              : null,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedSupplier = value;
                                            });
                                          },
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              TextFormField(
                                controller: dateController,
                                readOnly: true,
                                decoration: decoration("Date").copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                  ),
                                ),
                                onTap: pickDate,
                              ),

                              const SizedBox(height: 15),

                              TextFormField(
                                controller: totalController,
                                keyboardType: TextInputType.number,
                                decoration: decoration("Total Amount"),
                                validator: (v) =>
                                    v!.isEmpty ? "Enter amount" : null,
                              ),

                              const SizedBox(height: 15),

                              TextFormField(
                                controller: depositController,
                                keyboardType: TextInputType.number,
                                decoration: decoration("Deposit Amount",),

                              ),

                              const SizedBox(height: 15),

                              TextFormField(
                                controller: balanceController,
                                readOnly: true,
                                decoration: decoration("Balance Amount"),
                              ),

                              const SizedBox(height: 20),

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
                                    if (!_formKey.currentState!.validate())
                                      return;

                                    final body = {
                                      "retailId": widget.retailId,
                                      "supplierId": selectedSupplier!.id,
                                      "totalAmount":
                                          double.tryParse(
                                            totalController.text,
                                          ) ??
                                          0,
                                      "depositAmount":
                                          double.tryParse(
                                            depositController.text,
                                          ) ??
                                          0,
                                      "depositDate": DateFormat("dd-MM-yyyy")
                                          .parse(dateController.text)
                                          .toIso8601String(),
                                    };
                                    print(body);
                                    try {
                                      print("Calling API...");
                                      final message = await context
                                          .read<EntriesProvider>()
                                          .addSupplier(body);
                                      print("Calling API...");
                                      if (!mounted) return;

                                      Navigator.pop(context, true);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "ADD SUPPLIER",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  )
                  )
                    ],
                  ),
                ),
              ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F0FF),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(
                    Icons.location_city ,
                    color: AppColors.primaryPurple,
                    size: 35,
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}
