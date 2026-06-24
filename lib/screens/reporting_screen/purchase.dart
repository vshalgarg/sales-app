import 'package:flutter/material.dart';
import 'package:hisabio/screens/entry_screen/purchase_entry.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../customs/bottom_navigation_bar.dart';
import '../../drawers/reporting_drawer.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/purchase_provider.dart';
import '../../provider/staff_provider.dart';
import '../../reporting_widgets/edit_purchase_bottom_sheet.dart';
import '../../reporting_widgets/purchase_details_bottom_sheet.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../services/purchase_details_api.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  bool isDeleting = false;
  bool isOpeningView = false;
  bool isOpeningEdit = false;
  bool isOpening = false;
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  String? selectedSupplier;
  String? selectedCustomer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<EntriesProvider>(context, listen: false);

      await provider.fetchSuppliers();
      await provider.fetchCustomer();
    });
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  void _applyFilters() async {
    final provider = Provider.of<EntriesProvider>(context, listen: false);

    final purchaseProvider = Provider.of<PurchaseProvider>(
      context,
      listen: false,
    );

    int? supplierId;
    int? customerId;

    if (selectedSupplier != null) {
      final supplier = provider.entries.firstWhere(
        (e) => e.supplierName == selectedSupplier,
      );

      supplierId = supplier.id?.toInt();
    }

    if (selectedCustomer != null) {
      final customer = provider.customerEntries.firstWhere(
        (e) => e.customerName == selectedCustomer,
      );
      customerId = customer.id?.toInt();
    }
    String? fromDate = fromDateController.text.isEmpty
        ? null
        : fromDateController.text;

    String? toDate = toDateController.text.isEmpty
        ? null
        : toDateController.text;
    print("FROM DATE => $fromDate");
    print("TO DATE => $toDate");
    print("SUPPLIER ID => $supplierId");
    print("CUSTOMER ID => $customerId");
    await purchaseProvider.searchPurchases(
      fromDate: fromDate,
      toDate: toDate,
      supplierId: supplierId,
      customerId: customerId,
    );
  }

  void _clearFilters() async {
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedSupplier = null;
      selectedCustomer = null;
    });

    await context.read<PurchaseProvider>().searchPurchases();
  }

  void _showFilterBottomSheet() {
    final provider = Provider.of<EntriesProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
           return Container(
            height: 500,
                decoration: const BoxDecoration(
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
                      items: provider.entries
                          .map((e) => e.supplierName ?? '')
                          .where((e) => e.isNotEmpty)
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
                      label: "Customer",
                      value: selectedCustomer,
                      items: provider.customerEntries
                          .map((e) => e.customerName ?? '')
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      onChanged: (value) {
                        bottomSheetSetState(() {
                          selectedCustomer = value;
                        });

                        setState(() {
                          selectedCustomer = value;
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
                      selectedCustomer = null;
                    });

                    setState(() {
                      fromDateController.clear();
                      toDateController.clear();
                      selectedSupplier = null;
                      selectedCustomer = null;
                    });
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
        title: "Purchases",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: width < 600 ? 22 : 26,
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color(0xFF9CA4DA)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PurchaseEntryScreen()),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.015,
        ),
        child: Consumer<EntriesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child:IconButton(
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        size: width * 0.075,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          final provider = context.read<EntriesProvider>();

                          await provider.fetchSuppliers();
                          await provider.fetchCustomer();

                          if (!mounted) return;

                          Navigator.pop(context);

                          _showFilterBottomSheet();
                        } catch (e) {
                          if (!mounted) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to load filters: $e"),
                            ),
                          );
                        }
                      },
                    ),
                    )],
                ),

                SizedBox(height: height * 0.02),
                Expanded(
                  child: Consumer<PurchaseProvider>(
                    builder: (context, purchaseProvider, child) {
                      if (purchaseProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (purchaseProvider.purchaseEntries.isEmpty) {
                        return Center(
                          child: Text(
                            "Apply filters to view purchase history",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.06,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: purchaseProvider.purchaseEntries.length,
                        itemBuilder: (context, index) {
                          final purchase =
                              purchaseProvider.purchaseEntries[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: height * 0.015),
                            child: ReportingCard(
                              fields: [
                                MapEntry("Date", purchase.date),
                                MapEntry("Staff", purchase.staffName),
                                MapEntry("Supplier", purchase.supplierName),
                                MapEntry("Customer", purchase.customerName),
                                MapEntry("Remarks", purchase.remarks),
                              ],
                              onView: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final data = await getPurchaseDetails(
                                    purchase.id,
                                  );

                                  if (!mounted) return;

                                  Navigator.pop(context);

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    builder: (_) => PurchaseDetailsBottomSheet(
                                      purchaseData: data["data"],
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text("$e")));
                                }
                              },
                              onEdit: () async {
                                final details = await getPurchaseDetails(
                                  purchase.id,
                                );

                                if (!context.mounted) return;

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => EditPurchaseBottomSheet(
                                    purchaseData: details["data"],
                                  ),
                                );
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Purchase"),
                                    content: const Text(
                                      "Are you sure you want to delete this purchase entry?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;

                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  final token = await AppStorage.getToken();

                                  await context
                                      .read<PurchaseProvider>()
                                      .deletePurchaseEntry(
                                        purchase.id!,
                                        token!,
                                      );

                                  if (!mounted) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Purchase entry deleted successfully",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
