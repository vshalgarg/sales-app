import 'package:flutter/material.dart';
import 'package:hisabio/customs/dropdown_test.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../constants/save_excel_ledger.dart';
import '../../customs/app_bar.dart';
import '../../model_classes/entries/entries_customer_model.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/reporting_provider/ledger_provider.dart';
import '../home_screen.dart';
import 'ledger_details_screen.dart';

class LedgerReporting extends StatefulWidget {
  const LedgerReporting({super.key});

  @override
  State<LedgerReporting> createState() => _LedgerReportingState();
}

class _LedgerReportingState extends State<LedgerReporting> {
  bool loading = true;

  EntriesModel? selectedSupplier;
  String? selectedSupplierName;

  EntriesCustomerModel? selectedCustomer;
  String? selectedCustomerName;

  String? generatingFor;

  final List<String> generatesList = [
    "SUPPLIER",
    "CUSTOMER",
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LedgerProvider>().clearLedger();
    });

    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<EntriesProvider>();

    await Future.wait([
      provider.fetchSuppliers(),
      provider.fetchCustomer(),
    ]);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> _submitLedger() async {
    if (selectedSupplier == null ||
        selectedCustomer == null ||
        generatingFor == null) {
      ScaffoldSnackBar.show(
        context,
        "Please Select Required Fields",
      );
      return;
    }

    try {
      await context.read<LedgerProvider>().fetchLedger(
        supplierId: selectedSupplier!.id!.toInt(),
        customerId: selectedCustomer!.id!.toInt(),
        viewType: generatingFor!,
      );

      if (!mounted) return;

      final ledger = context.read<LedgerProvider>().ledger;

      if (ledger == null) {
        ScaffoldSnackBar.show(
          context,
          "No ledger data found",
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LedgerDetailsScreen(
            viewType: generatingFor!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldSnackBar.show(
        context,
        e.toString(),
      );
    }
  }

  Future<void> _downloadLedger() async {
    if (selectedSupplier == null ||
        selectedCustomer == null ||
        generatingFor == null) {
      ScaffoldSnackBar.show(
        context,
        "Please Select Required Fields",
      );
      return;
    }

    try {
      final bytes = await context
          .read<LedgerProvider>()
          .downloadLedger(
        supplierId: selectedSupplier!.id!,
        customerId: selectedCustomer!.id!,
        viewType: generatingFor!,
      );

      if (bytes == null) {
        if (!mounted) return;

        ScaffoldSnackBar.show(
          context,
          "Failed to download ledger",
        );
        return;
      }

      await saveExcel(bytes);

      if (!mounted) return;

      ScaffoldSnackBar.show(
        context,
        "Ledger downloaded successfully",
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldSnackBar.show(
        context,
        e.toString(),
      );
    }
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
            context.read<LedgerProvider>().clearLedger();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(),
              ),
            );
          },
        ),
        title: "Ledger",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              // SUPPLIER
              const Text(
                "Supplier * ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 5),

              CustomDropdown(
                hintText: "Supplier * ",
                initialValue: selectedSupplierName,
                items: provider.entries
                    .map((e) {
                  final name = e.supplierName ?? "";
                  final city = e.city ?? "";

                  if (city.isEmpty) {
                    return name;
                  }

                  return "$name - $city";
                })
                    .where((e) => e.isNotEmpty)
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;

                  final supplier = provider.entries.firstWhere(
                        (e) {
                      final name = e.supplierName ?? "";
                      final city = e.city ?? "";

                      final displayName = city.isEmpty
                          ? name
                          : "$name - $city";

                      return displayName == value;
                    },
                  );

                  setState(() {
                    selectedSupplierName = value;
                    selectedSupplier = supplier;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                "Customer * ",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              CustomDropdown(
                hintText: "Customer * ",
                initialValue: selectedCustomerName,
                items: provider.customerEntries
                    .map((e) {
                  final name = e.customerName ?? "";
                  final city = e.city ?? "";

                  if (city.isEmpty) {
                    return name;
                  }

                  return "$name - $city";
                })
                    .where((e) => e.isNotEmpty)
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;

                  final customer = provider.customerEntries.firstWhere(
                        (e) {
                      final name = e.customerName ?? "";
                      final city = e.city ?? "";

                      final displayName = city.isEmpty
                          ? name
                          : "$name - $city";

                      return displayName == value;
                    },
                  );

                  setState(() {
                    selectedCustomerName = value;
                    selectedCustomer = customer;
                  });
                },
              ),

              const SizedBox(height: 15),

              // GENERATING FOR
              const Text(
                "Generating for * ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 5),

              CustomDropdown(
                hintText: "Generating for * ",
                initialValue: generatingFor,
                items: generatesList,
                onChanged: (value) {
                  setState(() {
                    generatingFor = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // SUBMIT + DOWNLOAD
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  // SUBMIT
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _submitLedger,
                      child: const Text(
                        "SUBMIT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // DOWNLOAD
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                        AppColors.primaryPurple,
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _downloadLedger,
                      child: const Text(
                        "DOWNLOAD",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

