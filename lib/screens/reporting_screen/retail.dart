import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_spacing.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../customs/card_entrance_examination.dart';
import '../../model_classes/retailers/retail_model.dart' as retail_model;
import '../../pagination/pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/master_provider/config_provider.dart';
import '../../provider/master_provider/permission_provider.dart';
import '../../provider/reporting_provider/retail_provider.dart';
import '../../provider/master_provider/staff_provider.dart';
import '../../reporting_widgets/edit_retail_screen.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../reporting_widgets/retail_card.dart';
import '../../reporting_widgets/retail_details_screen.dart';
import 'add_supplier.dart';
import '../entry_screen/retail_entry.dart';

class Retail extends StatefulWidget {
  const Retail({super.key});

  @override
  State<Retail> createState() => _RetailState();
}

class _RetailState extends State<Retail> {
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  bool isOpening = false;

  bool isFilterApplied = false;

  String? selectedSupplier;

  int? selectedCustomerId;

  int? selectedStaffId;

  String _toApiDate(String date) {
    if (date.isEmpty) return date;

    final parsed = DateFormat("dd-MM-yyyy").parse(date);
    return DateFormat("yyyy-MM-dd").format(parsed);
  }

  void _showBottomSheetSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        bottom: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.containerFillColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    final formatter = DateFormat("dd-MM-yyyy");

    final defaultFromDate = formatter.format(oneMonthAgo);
    final defaultToDate = formatter.format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      final configProvider = context.read<ConfigProvider>();
      final permissions = context.read<PermissionProvider>();

      // Check configuration first.
      if (!configProvider.retailEnabled) return;

      // Check permissions only when configuration is ON.
      final canView = permissions.hasPermission('RETAIL_REPORT_VIEW');
      final canCreate = permissions.hasPermission('RETAIL_CREATE');
      final canUpdate = permissions.hasPermission('RETAIL_REPORT_UPDATE');
      final canDelete = permissions.hasPermission('RETAIL_REPORT_DELETE');
      final canAddSupplier = permissions.hasPermission(
        'RETAIL_REPORT_ADD_SUPPLIER',
      );

      if (!canView && !canCreate) return;

      final entriesProvider = context.read<EntriesProvider>();

      await entriesProvider.fetchSuppliers();

      await entriesProvider.fetchCustomer();

      await context.read<StaffProvider>().refreshStaffs();

      final provider = context.read<RetailProvider>();

      provider.applyFilters(
        fromDate: _toApiDate(defaultFromDate),
        toDate: _toApiDate(defaultToDate),
      );

      await provider.refresh();
    });
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    final entriesProvider = context.read<EntriesProvider>();

    int? supplierId;

    if (selectedSupplier != null) {
      final supplier = entriesProvider.entries.firstWhere(
            (e) => e.supplierName == selectedSupplier,
      );

      supplierId = supplier.id?.toInt();
    }
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("dd-MM-yyyy");
    final provider = context.read<RetailProvider>();

    final fromDate = fromDateController.text.isNotEmpty
        ? fromDateController.text
        : formatter.format(tenDaysAgo);

    final toDate = toDateController.text.isNotEmpty
        ? toDateController.text
        : formatter.format(now);

    provider.applyFilters(
      fromDate: _toApiDate(fromDate),
      toDate: _toApiDate(toDate),
      supplierId: supplierId,
      customerId: selectedCustomerId,
      staffId: selectedStaffId,
    );
    setState(() {
      isFilterApplied = true;
    });

    await provider.refresh();
  }

  Future<void> _clearFilters() async {
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("dd-MM-yyyy");
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedSupplier = null;
      selectedCustomerId = null;
      selectedStaffId = null;
      isFilterApplied = false;
    });

    final provider = context.read<RetailProvider>();

    provider.clearFilters();

    provider.applyFilters(
      fromDate: formatter.format(tenDaysAgo),
      toDate: formatter.format(now),
      supplierId: null,
      customerId: null,
      staffId: null,
    );

    await provider.refresh();
  }

  void _showFilterBottomSheet() {
    final entriesProvider = context.read<EntriesProvider>();

    final staffProvider = context.read<StaffProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ReportingFilterSection(
                fromDateController: fromDateController,
                toDateController: toDateController,
                dropdowns: [
                  FilterDropdown(
                    label: "Supplier",
                    value: selectedSupplier,
                    items: entriesProvider.entries
                        .map((e) => e.supplierName ?? "")
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    onChanged: (value) {
                      setBottomState(() {
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
                          (e) => e.id?.toInt() == selectedCustomerId,
                    )
                        .customerName,
                    items: entriesProvider.customerEntries
                        .map((e) => e.customerName ?? "")
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    onChanged: (value) {
                      final customer = entriesProvider.customerEntries
                          .firstWhere((e) => e.customerName == value);

                      setBottomState(() {
                        selectedCustomerId = customer.id?.toInt();
                      });

                      setState(() {
                        selectedCustomerId = customer.id?.toInt();
                      });
                    },
                  ),

                  FilterDropdown(
                    label: "Staff",
                    value: selectedStaffId == null
                        ? null
                        : staffProvider.data.items
                        .firstWhere((e) => e.id == selectedStaffId)
                        .staffName,
                    items: staffProvider.data.items
                        .map((e) => e.staffName ?? "")
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    onChanged: (value) {
                      final staff = staffProvider.data.items.firstWhere(
                            (e) => e.staffName == value,
                      );

                      setBottomState(() {
                        selectedStaffId = staff.id;
                      });

                      setState(() {
                        selectedStaffId = staff.id;
                      });
                    },
                  ),
                ],
                onApply: () async {
                  final hasFilter =
                      fromDateController.text.isNotEmpty ||
                          toDateController.text.isNotEmpty ||
                          selectedSupplier != null ||
                          selectedCustomerId != null ||
                          selectedStaffId != null;

                  if (!hasFilter) {
                    _showBottomSheetSnackBar(
                      context,
                      "Please select at least one filter.",
                    );
                    return;
                  }

                  Navigator.pop(context);

                  await _applyFilters();
                },
                onClear: () async {
                  await _clearFilters();

                  setBottomState(() {});
                },
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (!mounted) return;

      setState(() {
        fromDateController.clear();
        toDateController.clear();
        selectedSupplier = null;
        selectedCustomerId = null;
      });
    });
  }

  Future<void> _resetRetailBeforeExit() async {
    final provider = context.read<RetailProvider>();

    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("dd-MM-yyyy");

    final fromDate = formatter.format(tenDaysAgo);
    final toDate = formatter.format(now);

    provider.applyFilters(
      fromDate: _toApiDate(fromDate),
      toDate: _toApiDate(toDate),
      supplierId: null,
      customerId: null,
      staffId: null,
    );
    isFilterApplied = false;

    fromDateController.text = fromDate;
    toDateController.text = toDate;

    provider.applyFilters(
      fromDate: fromDate,
      toDate: toDate,
      supplierId: null,
      customerId: null,
      staffId: null,
    );

    provider.clear();
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigProvider>();

    // Configuration check comes first.
    if (!configProvider.retailEnabled) {
      return const Scaffold(
        body: Center(child: Text("Retailers are disabled.")),
      );
    }

    final permissions = context.watch<PermissionProvider>();

    final canView = permissions.hasPermission('RETAIL_REPORT_VIEW');

    final canCreate = permissions.hasPermission('RETAIL_CREATE');
    final canUpdate = permissions.hasPermission('RETAIL_REPORT_UPDATE');
    final canDelete = permissions.hasPermission('RETAIL_REPORT_DELETE');
    final canAddSupplier = permissions.hasPermission(
      'RETAIL_REPORT_ADD_SUPPLIER',
    );

    if (!canView && !canCreate) {
      return const Scaffold(
        body: Center(
          child: Text("You do not have permission to access Retailers."),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            await _resetRetailBeforeExit();

            if (!context.mounted) return;

            Navigator.pop(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.bodyFillColor,

            appBar: CustomAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await _resetRetailBeforeExit();

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
              ),
              title: "Retailers",
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
              actions: [
                if (canView)
                  IconButton(
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
              ],
            ),

            floatingActionButton: canCreate
                ? FloatingActionButton(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: isOpening
                  ? null
                  : () async {
                setState(() {
                  isOpening = true;
                });

                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RetailEntryScreen(),
                  ),
                );

                if (!context.mounted) return;

                if (refresh == true) {
                  await context.read<RetailProvider>().refresh();
                }

                setState(() {
                  isOpening = false;
                });
              },
              child: isOpening
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Iconsax.add,
                color: Colors.white,
                size: 34,
              ),
            )
                : null,

            body: !canView
                ? const Center(
              child: Text(
                "You can create Retailers, but cannot view Retailer records.",
                style: TextStyle(color: Colors.white),
              ),
            )
                : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              child: Consumer<RetailProvider>(
                builder: (context, provider, child) {
                  return PaginationWidget<retail_model.Retail>(
                    pagination: provider.pagination,

                    items: provider.data.items,

                    loading: provider.loading,

                    fetchPage: (page) async {
                      await provider.fetchPage(page);
                    },

                    refresh: () async {
                      await provider.refresh();
                    },

                    itemBuilder: (context, retail) {
                      return CardEntranceAnimation(
                        key: ValueKey('retail-card-${retail.id}'),
                        delay: Duration(milliseconds: (provider.data.items.indexOf(retail).clamp(0, 5)) * 65),
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: RetailCard(
                            fields: [
                              MapEntry(
                                "Date",
                                DateFormat(
                                  "dd-MM-yyyy",
                                ).format(retail.date),
                              ),

                              MapEntry("Retailer", retail.name),

                              MapEntry("Referred By", retail.customerName),

                              MapEntry("Staff", retail.staffName ?? "-"),
                            ],
                            onTap: () async {
                              final refresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RetailDetailsScreen(
                                    retailId: retail.id,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (refresh == true) {
                                await provider.refresh();
                              }
                            },

                            onEdit: canUpdate
                                ? () async {
                              final refresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditRetailScreen(
                                    retailId: retail.id,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (refresh == true) {
                                await provider.refresh();
                              }
                            }
                                : null,

                            onAdd: canAddSupplier
                                ? () async {
                              final refresh = await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    AddSupplier(retailId: retail.id),
                              );

                              if (!mounted) return;

                              if (refresh == true) {
                                await provider.refresh();
                              }
                            }
                                : null,

                            onDelete: canDelete
                                ? () async {
                              ExitConfirmationDialog.show(
                                context,
                                isDelete: true,
                                body: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text:
                                            "Are you sure you want to delete Retailer :  ",
                                          ),
                                          TextSpan(
                                            text: retail.name,
                                            style: const TextStyle(
                                              color: AppColors
                                                  .orangeColor,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: "?"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                saveButtonText: "Delete",

                                discardButtonText: "Cancel",

                                onDiscard: () {
                                  Navigator.pop(context);
                                },

                                onSave: () async {
                                  Navigator.pop(context);

                                  final success = await provider
                                      .deleteRetail(retail.id);

                                  if (success) {
                                    await provider.refresh();
                                  }

                                  if (!context.mounted) return;

                                  ScaffoldSnackBar.show(
                                    context,
                                    success
                                        ? "Retail deleted successfully"
                                        : "Failed to delete retail",
                                  );
                                },
                              );
                            }
                                : null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
