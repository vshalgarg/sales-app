import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/containers/master_containers/transport_container.dart';
import 'package:hisabio/dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/screens/home_screen.dart';
import 'package:hisabio/screens/master_screens/add_new_transport.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../enums/customer_mode.dart';
import '../../model_classes/Transport/transport.dart';
import '../../pagination/pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/master_provider/transport_provider.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TextEditingController searchController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final transportProvider = context.read<TransportProvider>();

    Future.microtask(() async {
      searchController.clear();

      await transportProvider.clearSearch();

      if (!mounted) return;
      await transportProvider.fetchPage(0);
      transportProvider.fetchInitial();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransportProvider>();

    final List<Transport> transports =
    provider.data.items.cast<Transport>();

    return Scaffold(
        backgroundColor: AppColors.bodyFillColor,

        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(),
                ),
              );
            },
          ),
          title: "Transport Overview",
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),

        body: Padding(
            padding: const EdgeInsets.all(15),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

              Container(
              height: 40,
              width: double.infinity,

              decoration: BoxDecoration(
                color: AppColors.containerFillColor,
                borderRadius: BorderRadius.circular(8),
              ),

              child: SearchBar(
                controller: searchController,

                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

                elevation: const WidgetStatePropertyAll(2),

                hintText: "Search Transport...",

                leading: const Icon(
                  Icons.search,
                  size: 30,
                ),

                backgroundColor:
                const WidgetStatePropertyAll(Colors.white),

                trailing: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),

                      onPressed: () async {
                        searchController.clear();

                        await context
                            .read<TransportProvider>()
                            .clearSearch();

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

                  _debounce = Timer(
                    const Duration(milliseconds: 500),
                        () {

                      if (value.trim().isEmpty) {

                        context
                            .read<TransportProvider>()
                            .clearSearch();

                        if (mounted) {
                          setState(() {});
                        }

                        return;
                      }

                      context
                          .read<TransportProvider>()
                          .search(value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 5),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: PaginationWidget<Transport>(
                    pagination: provider.data.pagination,

                    items: transports,

                    loading: provider.data.isLoading,

                    fetchPage: provider.fetchPage,

                    refresh: provider.refreshTransports,

                    itemBuilder: (context, item) {

                      final firstContact =
                      item.contacts.isNotEmpty
                          ? item.contacts.first
                          : null;

                      return GestureDetector(

                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNewTransport(
                                  id: item.id?.toInt(),
                                  mode: FormMode.view,
                                ),
                              ),
                            );
                          },

                          child: TransportContainer(

                            elevation: 1,

                            name: item.name,

                            city: item.city ?? "-",

                            gst: item.gstNo ?? "-",

                            status: item.status ?? "-",

                            phone:
                            firstContact?.contactNumber ?? "-",
                            trashIconTap: () {
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
                                            text: item.name ?? "",
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
                                discardButtonText: "Cancel",
                                saveButtonText: "Delete",
                                onSave: () async {
                                  Navigator.of(context).pop();

                                  final success =
                                  await provider.deleteTransport(
                                    item.id!.toInt(),
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldSnackBar.show(
                                    context,
                                    success
                                        ? "Transport deleted successfully"
                                        : "Failed to delete transport",
                                  );
                                },
                                onDiscard: () {
                                  Navigator.pop(context);
                                },
                              );
                            },

                            copyIconTap: () async {

                              await provider.fetchTransportDetails(
                                item.id!.toInt(),
                              );
                              if (!context.mounted) return;
                              final data = provider.transportDetails;

                              if (data == null) return;

                              String fullAddress = [
                                data.addressLine1,
                                data.addressLine2,
                                data.city,
                                data.state,
                                data.pinCode,
                              ]
                                  .where((e) => (e ?? "").trim().isNotEmpty)
                                  .join(", ");

                              String contactsText = "";

                              if (data.contacts.isNotEmpty) {
                                contactsText = data.contacts.map((c) {
                                  if (c is Map) {
                                    return "${['contactPerson']} - ${['mobileNumber']}";
                                  }

                                  return "${c.contactPerson ?? ""} - ${c.contactNumber ?? ""}";
                                }).join("\n");
                              }

                              showDialog(
                                context: context,
                                builder: (_) {
                                  return CustomCopyDetailsDialog(
                                    showCopyBankButton: false,
                                    showCloseIcon: false,
                                    heading: "Transport Details",
                                    firmName: data.name ?? "",
                                    contact: contactsText,
                                    address: fullAddress ,
                                    gstNo: data.gstNo ?? "",
                                    emails: data.email ?? "",
                                  );
                                },
                              );
                            },

                            editIconTap: () async {
                              final refresh =
                              await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddNewTransport(
                                    id: item.id?.toInt(),
                                    mode: FormMode.edit,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (refresh == true) {
                                await provider.refreshTransports();
                              }
                            },
                          ),
                      );
                    },
                ),
            ),
            )
              ],
            ),
        ),

      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(
          Iconsax.add,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () async {
          final refresh =
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddNewTransport(),
            ),
          );

          if (refresh == true && mounted) {
            await provider.fetchInitial();
          }
        },
      ),
    );
  }
}
