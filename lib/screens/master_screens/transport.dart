import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/bottom_navigation_bar.dart';
import 'package:hisabio/drawers/master_drawer.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/containers/master_containers/transport_container.dart';
import '../../dialog_boxes/master_dialogBoxes/delete_custom_dialog.dart';
import '../../enums/customer_mode.dart';
import '../../provider/delete_transport_provider.dart';
import '../../provider/get_transport_details_provider.dart';
import '../../provider/search_transport_provider.dart';
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: " Transport Overview",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      drawer: MasterDrawer(),
      bottomNavigationBar: CustomBottomNavigationBar(),
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
                controller: searchController,

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
                            ? "No Data Found"
                            : "No Transport Available",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
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
                        name: transport.name ?? "",
                        status: transport.status ?? "",
                        gst: transport.gstNo ?? "",
                        city: transport.city ?? "",
                        phone: firstContact?.contactNumber ?? "",
                        editIconTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddNewTransport(mode: FormMode.edit,
                                    id: transport.id?.toInt(),),
                            ),
                          );
                        },
                        trashIconTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => CustomDeleteDialog(
                              dialogBoxName: "Delete Transport",
                              name: transport.name ?? "",
                              onDelete: () async {
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
                            ),
                          );
                        },
                        copyIconTap: () {},

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
