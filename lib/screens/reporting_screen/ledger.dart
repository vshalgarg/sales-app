import 'package:flutter/material.dart';
import 'package:hisabio/customs/dropdown_test.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../constants/save_excel_ledger.dart';
import '../../customs/app_bar.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/ledger_provider.dart';
import '../../services/get_ledger_details_services.dart';
import '../home_screen.dart';

class LedgerReporting extends StatefulWidget {
  const LedgerReporting({super.key});

  @override
  State<LedgerReporting> createState() => _LedgerReportingState();
}

class _LedgerReportingState extends State<LedgerReporting> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<EntriesProvider>();

    await Future.wait([provider.fetchSuppliers(), provider.fetchCustomer()]);

    setState(() {
      loading = false;
    });
  }

  bool loading = true;
  EntriesModel? selectedSupplier;
  String?selectedSupplierName;
  EntriesCustomerModel? selectedCustomer;
  String?selectedCustomerName;
  String? generatingFor;
  final List<String> generatesList = ["SUPPLIER", "CUSTOMER"];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    final ledgerProvider = context.watch<GetLedgerDetailsProvider>();
    final ledger = ledgerProvider.ledgerDetails?.data;
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<GetLedgerDetailsProvider>().clearLedger();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
        ),
        title: "Ledger",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Supplier",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    CustomDropdown(
                      hintText: "Supplier",
                      initialValue: selectedSupplierName,
                      items: provider.entries
                          .map((e) => e.supplierName ?? "")
                          .toList(),
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
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    CustomDropdown(
                      hintText: "Customer",
                      initialValue: selectedCustomerName,
                      items: provider.customerEntries
                          .map((e) => e.customerName ?? "")
                          .toList(),
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
                    Text(
                      "Generating for",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    CustomDropdown(
                      hintText: "Generating for",
                      initialValue: generatingFor,
                      items: generatesList,
                      onChanged: (value) {
                        setState(() {
                          generatingFor = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: AppColors.primaryPurple,
                          ),
                          onPressed: () async {
                            if (selectedSupplier == null ||
                                selectedCustomer == null ||
                                generatingFor == null) {
                              ScaffoldSnackBar.show(
                                context,
                                "Please Select Required Fields",
                              );
                              return;
                            }

                            await context
                                .read<GetLedgerDetailsProvider>()
                                .getLedgerDetails(
                                  selectedSupplier?.id?.toInt() ?? 0,
                                  selectedCustomer?.id?.toInt() ?? 0,
                                  generatingFor ?? "",
                                );
                          },
                          child: ledgerProvider.isLoading
                              ? const SizedBox(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "SUBMIT",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              if (selectedSupplier == null ||
                                  selectedCustomer == null ||
                                  generatingFor == null) {
                                ScaffoldSnackBar.show(
                                  context,
                                  "Please Select Required Fields",
                                );
                                return;
                              }

                              final bytes = await GetLedgerDetailsServices()
                                  .downloadLedger(
                                    selectedSupplier?.id?.toInt() ?? 0,
                                    selectedCustomer?.id?.toInt() ?? 0,
                                    generatingFor ?? "",
                                  );

                              await saveExcel(bytes);
                              if (!context.mounted) return;
                              ScaffoldSnackBar.show(
                                context,
                                "Ledger downloaded successfully",
                              );
                            } catch (e) {
                              ScaffoldSnackBar.show(context, e.toString());
                            }
                          },

                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              // side: BorderSide(
                              // color: AppColors.primaryPurple,
                              //width: 1,
                              //),
                            ),
                          ),
                          child: Text("DOWNLOAD"),
                        ),
                      ],
                    ),
                    SizedBox(height:10),
                    if (ledger != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                generatingFor == "CUSTOMER"
                                    ? "Supplier Details"
                                    : "Customer Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                              Divider(thickness: 0.5),
                              Text(
                                ledger.party?.name ?? "",
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text("Mobile : ${ledger.party?.phone ?? "-"}"),
                              Text("Email : ${ledger.party?.email ?? "-"}"),
                              Text("GST No : ${ledger.party?.gstNo ?? "-"}"),
                              Text("Address : ${ledger.party?.address ?? "-"}"),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    if (!ledgerProvider.hasSearched)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            "Apply filters to view transaction history",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (ledger?.entries?.isEmpty ?? true)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            "No transactions found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 8);
                      },
                      itemCount: ledger?.entries?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = ledger!.entries![index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Invoice Number : ${item.invoiceNo ?? "-"}",
                                ),
                                Text("Date : ${item.date ?? "-"}"),
                                Text("Particular : ${item.particular ?? "-"}"),
                                Text("Debit : ${item.debit ?? 0}"),
                                Text("Credit : ${item.credit ?? 0}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
