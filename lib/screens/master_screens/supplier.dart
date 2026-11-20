import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/master_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/screens/master_screens/add_new_supplier.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../enums/customer_mode.dart';
import '../../model_classes/supplier/supplier.dart';
import '../../pagination/pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/master_provider/permission_provider.dart';
import '../../provider/master_provider/supplier_provider.dart';

// Animates supplier cards as they enter the visible list.
class _SupplierCardEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _SupplierCardEntrance({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  @override
  State<_SupplierCardEntrance> createState() => _SupplierCardEntranceState();
}

class _SupplierCardEntranceState extends State<_SupplierCardEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);

    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierState();
}

class _SupplierState extends State<SupplierScreen> {
  late SupplierProvider supplierProvider;
  bool _isOpeningCopyDialog = false;
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    supplierProvider = context.read<SupplierProvider>();

    Future.microtask(() async {
      final permissionProvider = context.read<PermissionProvider>();

      if (!permissionProvider.canView('SUPPLIER')) {
        return;
      }

      searchController.clear();
      await supplierProvider.clearSearch();
      await supplierProvider.fetchPage(0);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    final permissionProvider = context.watch<PermissionProvider>();

    final canView = permissionProvider.canView('SUPPLIER');
    final canCreate = permissionProvider.canCreate('SUPPLIER');
    final canUpdate = permissionProvider.canUpdate('SUPPLIER');
    final canDelete = permissionProvider.canDelete('SUPPLIER');

    final canAccess = canView || canCreate;
    final suppliers = provider.data.items;
    if (!canAccess) {
      return const Scaffold(
        body: Center(
          child: Text('You do not have permission to access Suppliers'),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: "Suppliers",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: AppSpacing.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canView) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.containerFillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 40,
                width: double.infinity,
                child: SearchBar(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  controller: searchController,
                  elevation: WidgetStatePropertyAll(2),
                  hintText: "Search suppliers...",
                  leading: Icon(Icons.search, size: 30),
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                  trailing: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          searchController.clear();
                          await context.read<SupplierProvider>().clearSearch();
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                  ],
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }

                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      if (value.trim().isEmpty) {
                        context.read<SupplierProvider>().clearSearch();
                        if (mounted) setState(() {});
                        return;
                      }
                      context.read<SupplierProvider>().search(value);
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Expanded(
                child: PaginationWidget<Supplier>(
                  pagination: provider.data.pagination,
                  items: suppliers,
                  loading: provider.data.isLoading,
                  fetchPage: provider.fetchPage,
                  refresh: provider.refreshSuppliers,
                  itemBuilder: (context, item) {
                    final itemIndex = suppliers.indexWhere(
                          (supplier) => supplier.id == item.id,
                    );
                    final entranceDelay = Duration(
                      milliseconds:
                      (itemIndex < 0 ? 0 : itemIndex.clamp(0, 5).toInt()) *
                          65,
                    );

                    return GestureDetector(
                      onTap: () async {
                        final supplierProvider = context
                            .read<SupplierProvider>();

                        final details = await supplierProvider
                            .fetchSupplierDetails(item.id.toInt());

                        if (!context.mounted || details == null) return;

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddNewSupplier(
                              id: item.id,
                              mode: FormMode.view,
                              supplierDetails: details,
                            ),
                          ),
                        );
                      },
                      child: _SupplierCardEntrance(
                        key: ValueKey('supplier-card-${item.id}'),
                        delay: entranceDelay,
                        child: MasterContainer(
                          elevation: 1,
                          name: item.supplierName,
                          mobile: item.mobile ?? "-",
                          code: item.code,
                          city: item.city ?? "-",
                          trashIconTap: canDelete
                              ? () {
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
                                          "Are you sure you want to permanently delete ",
                                        ),
                                        TextSpan(
                                          text: item.supplierName,
                                          style: const TextStyle(
                                            color: AppColors.orangeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: "?"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    "This action cannot be undone.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              saveButtonText: "Delete",
                              discardButtonText: "Cancel",
                              onSave: () async {
                                Navigator.of(context).pop();
                                final provider = context
                                    .read<SupplierProvider>();

                                final success = await provider
                                    .deleteSupplier(item.code);

                                if (!context.mounted) return;
                                ScaffoldSnackBar.show(
                                  context,
                                  success
                                      ? "Supplier deleted successfully"
                                      : "Failed to delete supplier",
                                );
                              },
                              onDiscard: () {
                                Navigator.pop(context);
                              },
                            );
                          }
                              : null,
                          copyIconTap: canView
                              ? () async {
                            if (_isOpeningCopyDialog) return;

                            _isOpeningCopyDialog = true;
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              final provider = context
                                  .read<SupplierProvider>();

                              await provider.fetchSupplierDetails(
                                item.id.toInt(),
                              );

                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              if (!context.mounted) return;

                              final data = provider.supplierDetails;

                              if (data == null) {
                                ScaffoldSnackBar.show(
                                  context,
                                  "Failed to load supplier details",
                                );
                                return;
                              }

                              String fullAddress =
                              [
                                data.addressLine1,
                                data.addressLine2,
                                data.city,
                                data.state,
                                data.pinCode,
                              ]
                                  .where(
                                    (e) =>
                                (e ?? "").trim().isNotEmpty,
                              )
                                  .join(", ");

                              String contactsText = "";

                              if (data.contacts.isNotEmpty) {
                                contactsText = data.contacts
                                    .map((c) {
                                  if (c is Map) {
                                    return "${c['contactPerson'] ?? ""} - ${c['mobileNumber'] ?? ""}";
                                  }

                                  return "${c.contactPerson ?? ""} - ${c.mobileNumber ?? ""}";
                                })
                                    .join("\n");
                              }

                              String transportText = "";

                              if (data.preferredTransports.isNotEmpty) {
                                transportText = data.preferredTransports
                                    .map((t) {
                                  if (t is Map) {
                                    return t['name']?.toString() ??
                                        "";
                                  }

                                  return t.name ?? "";
                                })
                                    .join("\n");
                              }

                              await showDialog(
                                context: context,
                                builder: (_) => CustomCopyDetailsDialog(
                                  firmName: data.supplierName ?? "",
                                  contact: contactsText,
                                  address: fullAddress,
                                  gstNo: data.gstNo ?? "",
                                  emails: data.email ?? "",
                                  transport: transportText,
                                  bankDetails: data.bankDetails,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                              ScaffoldSnackBar.show(
                                context,
                                "Something went wrong",
                              );
                            } finally {
                              _isOpeningCopyDialog = false;
                            }
                          }
                              : null,
                          editIconTap: canUpdate
                              ? () async {
                            final supplierProvider = context
                                .read<SupplierProvider>();

                            final details = await supplierProvider
                                .fetchSupplierDetails(item.id.toInt());

                            if (!context.mounted || details == null)
                              return;

                            final refresh = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNewSupplier(
                                  id: item.id,
                                  mode: FormMode.edit,
                                  supplierDetails: details,
                                ),
                              ),
                            );

                            if (!mounted) return;

                            if (refresh == true) {
                              await supplierProvider.refreshSuppliers();
                            }
                          }
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Text(
                    'You can add suppliers, but cannot view supplier records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: canCreate
          ? TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.75, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          onPressed: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (_) => const AddNewSupplier()),
            );

            if (!mounted) return;

            // Only refresh and show Snackbar after successful save.
            if (result == null || result.isEmpty) return;

            await context.read<SupplierProvider>().refresh();

            if (!mounted) return;

            ScaffoldSnackBar.show(context, result);
          },
          backgroundColor: AppColors.primaryPurple,
          child: Icon(Iconsax.add, color: Colors.white, size: 40),
        ),
      )
          : null,
    );
  }
}
