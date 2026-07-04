import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/containers/master_containers/transport_container.dart';
import '../../dialog_boxes/master_dialogBoxes/custom_copy_details_dialog.dart';
import '../../enums/customer_mode.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/delete_transport_provider.dart';
import '../../provider/get_transport_details_provider.dart';
import '../../provider/search_transport_provider.dart';
import '../home_screen.dart';
import 'add_new_transport.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<GetTransportProvider>().getTransportDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transportProvider = context.watch<GetTransportProvider>();
    final searchProvider = context.watch<SearchTransportProvider>();
    final isSearching = searchController.text.trim().isNotEmpty;
    if (transportProvider.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (transportProvider.errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(transportProvider.errorMessage!)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ),
        ),
        title: "Transport Overview",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SearchBar(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                controller: searchController,
                trailing: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
                onChanged: (value) async {
                  if (_debounce?.isActive ?? false) {
                    _debounce!.cancel();
                  }

                  _debounce = Timer(Duration(milliseconds: 500), () async {
                    final keyword = value.trim();

                    if (keyword.isEmpty) {
                      await context
                          .read<GetTransportProvider>()
                          .getTransportDetails();
                      return;
                    }
                    await context
                        .read<SearchTransportProvider>()
                        .getSearchTransport(keyword);
                  });
                },
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search Transport...",
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Builder(
                builder: (context) {
                  final itemCount = isSearching
                      ? searchProvider.response?.content?.length ?? 0
                      : transportProvider.transportData?.content?.length ?? 0;

                  if (itemCount == 0) {
                    return Center(
                      child: Text(
                        isSearching
                            ? "No Transporter Found"
                            : "No Transport Available",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 8);
                    },
                    itemCount: isSearching
                        ? searchProvider.response?.content?.length ?? 0
                        : transportProvider.transportData?.content?.length ?? 0,
                    itemBuilder: (context, index) {
                      final dynamic transport = isSearching
                          ? searchProvider.response!.content![index]
                          : transportProvider.transportData!.content![index];
                      final contacts = transport.contacts ?? [];
                      final firstContact =
                          contacts != null && contacts.isNotEmpty
                          ? contacts.first
                          : null;
                      return TransportContainer(
                        name: (transport.name?.trim().isNotEmpty ?? false)
                            ? transport.name!
                            : "-",

                        status: (transport.status?.trim().isNotEmpty ?? false)
                            ? transport.status!
                            : "-",

                        gst: (transport.gstNo?.trim().isNotEmpty ?? false)
                            ? transport.gstNo!
                            : "-",

                        city: (transport.city?.trim().isNotEmpty ?? false)
                            ? transport.city!
                            : "-",

                        phone: (firstContact?.contactNumber?.trim().isNotEmpty ?? false)
                            ? firstContact!.contactNumber!
                            : "-",
                        editIconTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNewTransport(
                                mode: FormMode.edit,
                                id: transport.id?.toInt(),
                              ),
                            ),
                          );
                        },
                        trashIconTap: () {
                          ExitConfirmationDialog.show(
                            context,
                            saveButtonText: "Yes",
                            discardButtonText: "No",
                            onClose: () {
                              Navigator.pop(context);
                            },
                            onDiscard: () {
                              Navigator.pop(context);
                            },
                            bodyText:
                                "Are you sure you want to permanently delete ${transport.name}? This action cannot be undo.",
                            onSave: () async {
                              final provider =
                                  Provider.of<DeleteTransportProvider>(
                                    context,
                                    listen: false,
                                  );

                              await provider.deleteTransport(
                                transport.id!.toInt(),
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              if (provider.error != null) {
                                ScaffoldSnackBar.show(
                                  context,
                                  provider.error!,
                                  backgroundColor: Colors.red,
                                );
                              } else {
                                ScaffoldSnackBar.show(
                                  context,
                                  provider.deleteResponse?.message ??
                                      "Transport deleted successfully",
                                );
                              }
                              await context
                                  .read<GetTransportProvider>()
                                  .getTransportDetails();
                            },
                          );
                        },
                        copyIconTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return CustomCopyDialog(
                                headingText: "Transport Details",
                                firmName: transport.name ?? "",
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewTransport()),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
