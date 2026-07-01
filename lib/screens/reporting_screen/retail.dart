import 'package:flutter/material.dart';
import 'package:hisabio/reporting_widgets/retail_details_bottom_sheet.dart';
import 'package:hisabio/screens/add_supplier.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/retail_provider.dart';
import '../../provider/staff_provider.dart';
import '../../reporting_widgets/edit_retail_bottom_sheet.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../screens/entry_screen/retail_entry.dart';
import '../../services/get_retail_api.dart';
import '../home_screen.dart';

class Retail extends StatefulWidget {
  const Retail({super.key});

  @override
  State<Retail> createState() => _RetailState();
}

class _RetailState extends State<Retail> {
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  String? selectedSupplier;
  int? selectedCustomerId;
  int? selectedStaffId;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RetailProvider>().fetchRetails();
    });
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }
  Future<void> _showRetailDetails(int retailId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) =>
          RetailDetailsBottomSheet(
            retailId: retailId,
          ),
    );
  }

  void _applyFilters() {
    context.read<RetailProvider>().fetchRetails(
      fromDate: fromDateController.text.isEmpty
          ? null
          : fromDateController.text,
      toDate: toDateController.text.isEmpty ? null : toDateController.text,
    );
  }

  void _clearFilters() {
    fromDateController.clear();
    toDateController.clear();

    setState(() {
      selectedSupplier = null;
      selectedCustomerId = null;
      selectedStaffId = null;
    });

    context.read<RetailProvider>().fetchRetails();
  }

  void _showFilterBottomSheet() {
    final entriesProvider = Provider.of<EntriesProvider>(
      context,
      listen: false,
    );
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
            return Container(
              height: 600,
              decoration: BoxDecoration(
                color: Color(0xFFF7F6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ReportingFilterSection(
                fromDateController: fromDateController,
                toDateController: toDateController,
                dropdowns: [
                  FilterDropdown(
                    label: "Supplier",
                    value: selectedSupplier,
                    items: entriesProvider.entries
                        .map((e) => e.supplierName ?? '')
                        .where((e) => e.isNotEmpty)
                        .toSet()
                        .toList(),
                    onChanged: (value) {
                      bottomSheetSetState(() {
                        selectedSupplier = value;
                      });

                      setState(() {
                        selectedSupplier = value;
                      });
                    },
                  ),
                  FilterDropdown(
                    label: "Referred By",
                    value: selectedCustomerId == null
                        ? null
                        : entriesProvider.customerEntries
                        .firstWhere(
                          (e) => e.id!.toInt() == selectedCustomerId,
                    )
                        .customerName,
                    items: entriesProvider.customerEntries
                        .map((e) => e.customerName ?? "")
                        .toSet()
                        .toList(),
                    onChanged: (value) {
                      final customer = entriesProvider.customerEntries.firstWhere(
                            (e) => e.customerName == value,
                      );

                      bottomSheetSetState(() {
                        selectedCustomerId = customer.id!.toInt();
                      });

                      setState(() {
                        selectedCustomerId = customer.id!.toInt();
                      });
                    },
                  ),
                  FilterDropdown(
                    label: "Staff",
                    value: selectedStaffId == null
                        ? null
                        : staffProvider.staffs
                        .firstWhere(
                          (e) => e.staffId == selectedStaffId,
                    )
                        .staffName,
                    items: staffProvider.staffs
                        .map((e) => e.staffName)
                        .toSet()
                        .toList(),
                    onChanged: (value) {
                      final staff = staffProvider.staffs.firstWhere(
                            (e) => e.staffName == value,
                      );

                      bottomSheetSetState(() {
                        selectedStaffId = staff.staffId;
                      });

                      setState(() {
                        selectedStaffId = staff.staffId;
                      });
                    },
                  ),
                ],
                onApply: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                onClear: () {
                  bottomSheetSetState(() {
                    fromDateController.clear();
                    toDateController.clear();
                    selectedSupplier = null;
                    selectedCustomerId = null;
                  });

                  setState(() {
                    selectedSupplier = null;
                    selectedCustomerId = null;
                  });

                  Navigator.pop(context);

                  _clearFilters();
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: "Retailers",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Iconsax.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RetailEntryScreen()),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final entriesProvider = context.read<EntriesProvider>();
                        final staffProvider = context.read<StaffProvider>();

                        if (entriesProvider.entries.isEmpty) {
                          await entriesProvider.fetchSuppliers();
                        }

                        if (entriesProvider.customerEntries.isEmpty) {
                          await entriesProvider.fetchCustomer();
                        }

                        if (staffProvider.staffs.isEmpty) {
                          await staffProvider.fetchStaffs();
                        }

                        if (!mounted) return;

                        _showFilterBottomSheet();
                      },
                    ),
                  ),
              ],
            ),

            SizedBox(height: height * 0.01),

            Expanded(
              child: Consumer<RetailProvider>(
                builder: (context, retailProvider, child) {
                  if (retailProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (retailProvider.error != null) {
                    return Center(
                      child: Text(
                        retailProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (retailProvider.retailEntries.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Retailers Found",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await retailProvider.fetchRetails();
                    },
                    child: ListView.builder(
                      itemCount: retailProvider.retailEntries.length,
                      itemBuilder: (context, index) {
                        final retail = retailProvider.retailEntries[index];
                        print("Retailer: ${retail.name}");
                        print("Referred By: ${retail.customerName}");
                        print("Staff: ${retail.staffName}");
                        return Padding(
                          padding: EdgeInsets.only(bottom: height * 0.015),
                          child: ReportingCard(
                            fields: [
                              MapEntry("Date", retail.date),
                              MapEntry("Retailer", retail.name),
                              MapEntry("Referred By", retail.customerName),
                              MapEntry("Staff", retail.staffName),
                            ],
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => RetailDetailsProvider(),
                                  child: RetailDetailsBottomSheet(
                                    retailId: retail.retailId,
                                  ),
                                ),
                              );
                            },
                            onAdd: () async {
                              await context.read<EntriesProvider>().fetchSuppliers();

                              showDialog(
                                context: context,
                                builder: (_) => const AddSupplier(),
                              );
                            },
                            onEdit: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider(
                                        create: (_) => RetailDetailsProvider(),
                                      ),
                                    ],
                                    child: EditRetailBottomSheet(
                                      retailId: retail.retailId,
                                    ),
                                  );
                                },
                              );

                              if (!mounted) return;

                              context.read<RetailProvider>().fetchRetails();
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Retail"),
                                  content: const Text(
                                    "Are you sure you want to delete this retail?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              final success = await context
                                  .read<RetailProvider>()
                                  .deleteRetail(retail.retailId);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? "Retail deleted successfully"
                                        : "Failed to delete retail",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
