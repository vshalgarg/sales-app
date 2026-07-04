import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model_classes/entries_supplier.dart';
import '../provider/entries_provider/entries_section_provider.dart';

class AddSupplier extends StatefulWidget {
  const AddSupplier({super.key});

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

    dateController.text = DateFormat("dd-MM-yyyy").format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntriesProvider>().fetchSuppliers();
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
      lastDate: DateTime(2100),
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
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xff3157D5), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<EntriesProvider>(
            builder: (_, provider, __) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add Supplier",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 25),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<EntriesModel>(
                        value: selectedSupplier,
                        isExpanded: true,
                        decoration: decoration("Supplier*"),
                        items: provider.entries.map((e) {
                          return DropdownMenuItem<EntriesModel>(
                            value: e,
                            child: Text(e.supplierName ?? ""),
                          );
                        }).toList(),
                        validator: (v) => v == null ? "Select Supplier" : null,
                        onChanged: (value) {
                          setState(() {
                            selectedSupplier = value;
                          });
                        },
                      ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: decoration("Date").copyWith(
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: pickDate,
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: totalController,
                      keyboardType: TextInputType.number,
                      decoration: decoration("Total Amount"),
                      validator: (v) => v!.isEmpty ? "Enter amount" : null,
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: depositController,
                      keyboardType: TextInputType.number,
                      decoration: decoration("Deposit Amount"),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: balanceController,
                      readOnly: true,
                      decoration: decoration("Balance Amount"),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("CANCEL",style:
                            TextStyle(
                              color: Colors.blue,
                            )),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffffffff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              final body = {
                                "supplierId": selectedSupplier!.id,
                                "date": dateController.text,
                                "totalAmount":
                                    double.tryParse(totalController.text) ?? 0,
                                "depositAmount":
                                    double.tryParse(depositController.text) ??
                                    0,
                                "balanceAmount":
                                    double.tryParse(balanceController.text) ??
                                    0,
                              };

                              try {
                                final message = await context
                                    .read<EntriesProvider>()
                                    .addSupplier(body);

                                if (!mounted) return;

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );

                                if (!mounted) return;

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Retail added successfully"),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            child: const Text(
                              "ADD SUPPLIER",
                              style: TextStyle(color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
