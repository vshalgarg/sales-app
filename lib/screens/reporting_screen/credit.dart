import 'package:flutter/material.dart';
import 'package:hisabio/screens/entry_screen/credit_entry.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../provider/credit_provider.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../reporting_widgets/credit_details_bottom_sheet.dart';
import '../../reporting_widgets/edit_credit_bottom_sheet.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../services/delete_credit_api.dart';

class Credit extends StatefulWidget {
  const Credit({super.key});

  @override
  State<Credit> createState() => _CreditState();
}

class _CreditState extends State<Credit> {
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

    final creditProvider = Provider.of<CreditProvider>(context, listen: false);

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

    await creditProvider.fetchCredits(
      fromDate: fromDate,
      toDate: toDate,
      supplierId: supplierId,
      customerId: customerId,
    );
  }

  void _clearFilters() {
    setState(() {
      fromDateController.clear();
      toDateController.clear();

      selectedSupplier = null;
      selectedCustomer = null;
    });
  }

  void _showFilterBottomSheet() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final provider = Provider.of<EntriesProvider>(context, listen: false);

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
        title: "Credits",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: width < 600 ? 22 : 26,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: isOpening
            ? null
            : () async {
                setState(() {
                  isOpening = true;
                });
                await Future.delayed(const Duration(milliseconds: 100));
                if (!mounted) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreditEntry()),
                );
                if (mounted) {
                  setState(() {
                    isOpening = false;
                  });
                }
              },
        child: isOpening
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add, color: Color(0xFF9CA4DA)),
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
                    Align(alignment: Alignment.topRight,
                      child: IconButton(
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

                          Navigator.pop(context); // close loader

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
                  child: Consumer<CreditProvider>(
                    builder: (context, creditProvider, child) {
                      if (creditProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (creditProvider.credits.isEmpty) {
                        return Center(
                          child: Text(
                            "Apply filters to view credits",
                            style: TextStyle(
                              fontSize: width * 0.06,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: creditProvider.credits.length,
                        itemBuilder: (context, index) {
                          final credit = creditProvider.credits[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: height * 0.015),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return ReportingCard(
                                  fields: [
                                    MapEntry(
                                      "Bill No",
                                      credit.billNumber ?? "",
                                    ),

                                    MapEntry("Date", credit.date ?? ""),

                                    MapEntry(
                                      "Payment Type",
                                      credit.paymentType ?? "",
                                    ),

                                    MapEntry(
                                      "Reference No",
                                      credit.referenceNumber ?? "",
                                    ),
                                    MapEntry(
                                      "Supplier",
                                      credit.supplierName ?? "",
                                    ),

                                    MapEntry(
                                      "Customer",
                                      credit.customerName ?? "",
                                    ),

                                    MapEntry(
                                      "Amount",
                                      "₹${credit.receivedAmount ?? 0}",
                                    ),
                                  ],
                                  onView: () async {
                                    setState(() {
                                      isOpeningView = true;
                                    });

                                    await Future.delayed(
                                      const Duration(milliseconds: 300),
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      isOpeningView = false;
                                    });

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      builder: (_) => CreditDetailsBottomSheet(
                                        credit: credit,
                                      ),
                                    );
                                  },

                                    onEdit: () async {
                                      setState(() {
                                        isOpeningEdit = true;
                                      });

                                      await Future.delayed(
                                        const Duration(milliseconds: 300),
                                      );

                                      if (!mounted) return;

                                      setState(() {
                                        isOpeningEdit = false;
                                      });

                                      final provider = context.read<CreditProvider>();

                                      final updated = await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (_) => EditCreditBottomSheet(
                                          credit: credit,
                                        ),
                                      );

                                      if (!mounted) return;

                                      if (updated == true) {
                                        await provider.fetchCredits(
                                          page: 0,
                                          size: 50,
                                        );
            final index = provider.credits.indexWhere(
            (e) => e.id == credit.id,
            );

            if (index != -1) {
            final updatedCredit = provider.credits.removeAt(index);
            provider.credits.insert(0, updatedCredit);
            provider.notifyListeners();
            }
            }
                                      },

                                  onDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (dialogContext) {
                                        bool isDeleting = false;

                                        return StatefulBuilder(
                                          builder: (context, setDialogState) {
                                            return AlertDialog(
                                              title: const Text(
                                                "Delete Credit",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 18,
                                                  ),
                                                  children: [
                                                    const TextSpan(
                                                      text:
                                                          "Are you sure you want to delete credit ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          credit.billNumber ??
                                                          "",
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text:
                                                          "? This action cannot be undone.",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actionsPadding:
                                                  const EdgeInsets.all(16),
                                              actions: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: ElevatedButton(
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .grey
                                                                        .shade300,
                                                              ),
                                                          onPressed: isDeleting
                                                              ? null
                                                              : () {
                                                                  Navigator.pop(
                                                                    dialogContext,
                                                                    false,
                                                                  );
                                                                },
                                                          child: const Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: ElevatedButton(
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                          onPressed: isDeleting
                                                              ? null
                                                              : () async {
                                                                  final messenger =
                                                                      ScaffoldMessenger.of(
                                                                        context,
                                                                      );

                                                                  setDialogState(
                                                                    () {
                                                                      isDeleting =
                                                                          true;
                                                                    },
                                                                  );

                                                                  try {
                                                                    await deleteCredit(
                                                                      credit
                                                                          .id!,
                                                                    );

                                                                    if (!mounted)
                                                                      return;

                                                                    await context
                                                                        .read<
                                                                          CreditProvider
                                                                        >()
                                                                        .fetchCredits(
                                                                          page:
                                                                              0,
                                                                          size:
                                                                              7,
                                                                        );

                                                                    if (!mounted)
                                                                      return;

                                                                    Navigator.pop(
                                                                      dialogContext,
                                                                      true,
                                                                    );

                                                                    messenger.showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text(
                                                                              "Credit deleted successfully",
                                                                            ),
                                                                      ),
                                                                    );
                                                                  } catch (e) {
                                                                    setDialogState(() {
                                                                      isDeleting =
                                                                          false;
                                                                    });

                                                                    messenger.showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                              "Delete failed: $e",
                                                                            ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                          child: isDeleting
                                                              ? const SizedBox(
                                                                  width: 22,
                                                                  height: 22,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                )
                                                              : const Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
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
