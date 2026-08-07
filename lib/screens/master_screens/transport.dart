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
import '../../model_classes/transport/transport.dart';
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

    Future.microtask(() {
      context.read<TransportProvider>().fetchInitial();
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

    final transports = provider.data.items;

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
                                body: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
                                      const TextSpan(
                                        text: "? This action cannot be undone.",
                                      ),
                                    ],
                                  ),
                                ),
                                saveButtonText: "Yes",
                                discardButtonText: "No",
                                onSave: () async {
                                  Navigator.of(context).pop();

                                  final success =
                                  await provider.deleteTransport(
                                    item.id!.toInt(),
                                  );

                                  if (!mounted) return;

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

                              final data = provider.transportDetails;

                              if (data == null) return;

                              final contact =
                              data.contacts.isNotEmpty
                                  ? data.contacts.first.contactNumber
                                  : "";

                              showDialog(
                                context: context,
                                builder: (_) {
                                  return CustomCopyDetailsDialog(
                                    showCopyBankButton: false,
                                    showCloseIcon: false,
                                    heading: "Transport Details",
                                    firmName: data.name ?? "",
                                    contact: contact,
                                    address: data.addressLine1 ?? "",
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


















// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
//
// import '../../constants/colors_used.dart';
// import '../../customs/app_bar.dart';
// import '../../customs/containers/master_containers/transport_container.dart';
// import '../../dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
// import '../../enums/customer_mode.dart';
// import '../../pop_ups/general_closing_popup.dart';
// import '../../pop_ups/scafold_type.dart';
// import '../../provider/transport_provider.dart';
// import '../home_screen.dart';
//
// class TransportScreen extends StatefulWidget {
//   const TransportScreen({super.key});
//
//   @override
//   State<TransportScreen> createState() => _TransportScreenState();
// }
//
// class _TransportScreenState extends State<TransportScreen> {
//   final TextEditingController _searchController = TextEditingController();
//
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() {
//       context.read<TransportProvider>().refreshTransports();
//     });
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged(String value) {
//     _debounce?.cancel();
//
//     _debounce = Timer(
//       const Duration(milliseconds: 500),
//           () async {
//         final provider = context.read<TransportProvider>();
//
//         if (value.trim().isEmpty) {
//           await provider.clearSearch();
//         } else {
//           await provider.search(value.trim());
//         }
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<TransportProvider>();
//
//     return Scaffold(
//         backgroundColor: AppColors.bodyFillColor,
//
//         appBar: CustomAppBar(
//           title: "Transport Overview",
//           textStyle: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 25,
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const HomeScreen(),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         body: RefreshIndicator(
//             onRefresh: provider.refreshTransports,
//
//             child: Padding(
//                 padding: const EdgeInsets.all(15),
//
//                 child: Column(
//                   children: [
//
//                   Container(
//                   height: 42,
//
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//
//                   child: SearchBar(
//                     controller: _searchController,
//
//                     onChanged: _onSearchChanged,
//
//                     hintText: "Search Transport...",
//
//                     leading: const Icon(
//                       Icons.search,
//                       size: 28,
//                     ),
//
//                     trailing: [
//
//                       if (_searchController.text.isNotEmpty)
//
//                         IconButton(
//                           icon: const Icon(Icons.close),
//
//                           onPressed: () async {
//                             _searchController.clear();
//
//                             setState(() {});
//
//                             await provider.clearSearch();
//                           },
//                         ),
//                     ],
//
//                     backgroundColor:
//                     const WidgetStatePropertyAll(Colors.white),
//
//                     elevation:
//                     const WidgetStatePropertyAll(2),
//
//                     shape: WidgetStatePropertyAll(
//                       RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.circular(5),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 15),
//
//                 Expanded(
//                     child: Builder(
//                         builder: (_) {
//
//                           if (provider.data.isLoading &&
//                               provider.data.items.isEmpty) {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           }
//
//                           if (provider.data.items.isEmpty) {
//                             return const Center(
//                               child: Text(
//                                 "No Transport Available",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             );
//                           }
//
//                           return NotificationListener<ScrollNotification>(
//                               onNotification: (notification) {
//                                 if (notification.metrics.pixels >=
//                                     notification.metrics.maxScrollExtent - 200) {
//                                   provider.loadNextPage();
//                                 }
//
//                                 return false;
//                               },
//
//                               child: ListView.separated(
//                                   physics:
//                                   const AlwaysScrollableScrollPhysics(),
//
//                                 itemCount: provider.data.items.length,
//
//                                   separatorBuilder: (_, __) =>
//                                   const SizedBox(height: 8),
//
//                                   itemBuilder: (context, index) {
//                                     //
//                                     // if (index ==
//                                     //     provider.data.items.length &&
//                                     //     provider.isLoadingMore) {
//                                     //   return const Padding(
//                                     //     padding:
//                                     //     EdgeInsets.symmetric(vertical: 20),
//                                     //     child: Center(
//                                     //       child:
//                                     //       CircularProgressIndicator(),
//                                     //     ),
//                                     //   );
//                                     // }
//
//                                     final transport =
//                                     provider.data.items[index];
//
//                                     final firstContact =
//                                     transport.contacts.isNotEmpty
//                                         ? transport.contacts.first
//                                         : null;
//
//                                     return TransportContainer(
//                                       name: transport.name ?? "-",
//
//                                       status: transport.status ?? "-",
//
//                                       city: transport.city ?? "-",
//
//                                       gst: transport.gstNo ?? "-",
//
//                                       phone:
//                                       firstContact?.contactNumber ?? "-",
//
//                                       editIconTap: () async {
//                                         final result =
//                                         await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) =>
//                                                 AddNewTransport(
//                                                   mode: FormMode.edit,
//                                                   id: transport.id?.toInt(),
//                                                 ),
//                                           ),
//                                         );
//
//                                         if (result == true &&
//                                             mounted) {
//                                           await provider
//                                               .refreshTransports();
//                                         }
//                                       },
//                                       trashIconTap: () {
//                                         ExitConfirmationDialog.show(
//                                           context,
//                                           saveButtonText: "Yes",
//                                           discardButtonText: "No",
//                                           bodyText:
//                                           "Are you sure you want to permanently delete ${transport.name}? This action cannot be undone.",
//                                           onDiscard: () {
//                                             Navigator.pop(context);
//                                           },
//                                           onSave: () async {
//                                             Navigator.pop(context);
//
//                                             final success =
//                                             await provider.deleteTransport(
//                                               transport.id!.toInt(),
//                                             );
//
//                                             if (!mounted) return;
//
//                                             if (success) {
//                                               ScaffoldSnackBar.show(
//                                                 context,
//                                                 "Transport deleted successfully",
//                                               );
//                                             } else {
//                                               ScaffoldSnackBar.show(
//                                                 context,
//                                                 "Failed to delete transport",
//                                               );
//                                             }
//                                           },
//                                         );
//                                       },
//
//                                       copyIconTap: () {
//                                         showDialog(
//                                           context: context,
//                                           builder: (_) {
//                                             return CustomCopyDetailsDialog(
//                                               heading: "Transport Details",
//                                               firmName: transport.name ?? "",
//                                               address: transport.addressLine1 ?? "",
//                                               gstNo: transport.gstNo ?? "",
//                                               contact:
//                                               firstContact?.contactNumber ?? "",
//                                               emails: transport.email ?? "",
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                               ),
//                           );
//                         },
//                     ),
//                 ),
//                   ],
//                 ),
//             ),
//         ),
//
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primaryPurple,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50),
//         ),
//         child: const Icon(
//           Iconsax.add,
//           color: Colors.white,
//           size: 38,
//         ),
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const AddTransportScreen(),
//             ),
//           );
//
//           if (result == true && mounted) {
//             await provider.refreshTransports();
//           }
//         },
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:hisabio/customs/app_bar.dart';
// // import 'package:hisabio/dialog_boxes/master_dialogBoxes/copy_supplier_details_dialog.dart';
// // import 'package:hisabio/pop_ups/scafold_type.dart';
// // import 'package:iconsax/iconsax.dart';
// // import 'package:provider/provider.dart';
// // import '../../constants/colors_used.dart';
// // import '../../customs/containers/master_containers/transport_container.dart';
// // import '../../enums/customer_mode.dart';
// // import '../../pop_ups/general_closing_popup.dart';
// // import '../../provider/delete_transport_provider.dart';
// // import '../../provider/search_transport_provider.dart';
// // import '../../provider/transport_provider.dart';
// // import '../home_screen.dart';
// // import 'add_new_transport.dart';
// //
// // class TransportScreen extends StatefulWidget {
// //   const TransportScreen({super.key});
// //
// //   @override
// //   State<TransportScreen> createState() => _TransportScreenState();
// // }
// //
// // class _TransportScreenState extends State<TransportScreen> {
// //   final searchController = TextEditingController();
// //   Timer? _debounce;
// //   final PageController _pageController = PageController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     Future.microtask(() {
// //       context.read<GetTransportProvider>().getTransportDetails(refresh: true);
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     searchController.dispose();
// //     _debounce?.cancel();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final transportProvider = context.watch<GetTransportProvider>();
// //     final searchProvider = context.watch<SearchTransportProvider>();
// //     final isSearching = searchController.text.trim().isNotEmpty;
// //     if (transportProvider.isLoading) {
// //       return Scaffold(body: Center(child: CircularProgressIndicator()));
// //     }
// //     if (transportProvider.errorMessage != null) {
// //       return Scaffold(
// //         body: Center(child: Text(transportProvider.errorMessage!)),
// //       );
// //     }
// //     return Scaffold(
// //       backgroundColor: AppColors.bodyFillColor,
// //       appBar: CustomAppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () => Navigator.push(
// //             context,
// //             MaterialPageRoute(builder: (context) => HomeScreen()),
// //           ),
// //         ),
// //         title: "Transport Overview",
// //         textStyle: TextStyle(
// //           color: Colors.white,
// //           fontWeight: FontWeight.w600,
// //           fontSize: 25,
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(15.0),
// //         child: Column(
// //           children: [
// //             Container(
// //               width: double.infinity,
// //               height: 40,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: SearchBar(
// //                 shape: WidgetStatePropertyAll(
// //                   RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(5),
// //                   ),
// //                 ),
// //                 controller: searchController,
// //                 trailing: [
// //                   if (searchController.text.isNotEmpty)
// //                     IconButton(
// //                       icon: const Icon(Icons.close),
// //                       onPressed: () {
// //                         searchController.clear();
// //                         setState(() {});
// //                       },
// //                     ),
// //                 ],
// //                 onChanged: (value) async {
// //                   if (_debounce?.isActive ?? false) {
// //                     _debounce!.cancel();
// //                   }
// //
// //                   _debounce = Timer(Duration(milliseconds: 500), () async {
// //                     final keyword = value.trim();
// //
// //                     if (keyword.isEmpty) {
// //                       await context
// //                           .read<GetTransportProvider>()
// //                           .refreshTransport();
// //                       return;
// //                     }
// //                     await context
// //                         .read<SearchTransportProvider>()
// //                         .getSearchTransport(keyword);
// //                   });
// //                 },
// //                 elevation: WidgetStatePropertyAll(2),
// //                 hintText: "Search Transport...",
// //                 leading: Icon(Icons.search_outlined, size: 30),
// //                 backgroundColor: WidgetStatePropertyAll(Colors.white),
// //               ),
// //             ),
// //             SizedBox(height: 15),
// //             Expanded(
// //               child: Builder(
// //                 builder: (context) {
// //                   final itemCount = isSearching
// //                       ? searchProvider.response?.content?.length ?? 0
// //                       : transportProvider.transports.length +
// //                             (transportProvider.isLoadingMore ? 1 : 0);
// //                   if (itemCount == 0) {
// //                     return Center(
// //                       child: Text(
// //                         isSearching
// //                             ? "No Transporter Found"
// //                             : "No Transport Available",
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 20,
// //                         ),
// //                       ),
// //                     );
// //                   }
// //
// //                   return ListView.separated(
// //                     separatorBuilder: (context, index) {
// //                       return SizedBox(height: 8);
// //                     },
// //                     itemCount: isSearching
// //                         ? searchProvider.response?.content?.length ?? 0
// //                         : transportProvider.transports.length +
// //                               (transportProvider.isLoadingMore ? 1 : 0),
// //                     itemBuilder: (context, index) {
// //                       // if (!isSearching &&
// //                       //     index == transportProvider.transports.length &&
// //                       //     transportProvider.isLoadingMore) {
// //                       //   return const Padding(
// //                       //     padding: EdgeInsets.all(15),
// //                       //     child: Center(child: CircularProgressIndicator()),
// //                       //   );
// //                       // }
// //                       final dynamic transport = isSearching
// //                           ? searchProvider.response!.content![index]
// //                           : transportProvider.transports[index];
// //                       final contacts = transport.contacts ?? [];
// //                       final firstContact =
// //                           contacts != null && contacts.isNotEmpty
// //                           ? contacts.first
// //                           : null;
// //
// //                       return GestureDetector(
// //                           onTap: () {
// //                             // Navigator.push(
// //                             //   context,
// //                             //   MaterialPageRoute(
// //                             //     builder: (_) => AddNewTransport(
// //                             //       mode: FormMode.view,
// //                             //       id: transport.id?.toInt(),
// //                             //     ),
// //                             //   ),
// //                             // );
// //                           },
// //                           child: TransportContainer(
// //                         name: (transport.name?.trim().isNotEmpty ?? false)
// //                             ? transport.name!
// //                             : " -",
// //
// //                         status: (transport.status?.trim().isNotEmpty ?? false)
// //                             ? transport.status!
// //                             : " -",
// //
// //                         gst: (transport.gstNo?.trim().isNotEmpty ?? false)
// //                             ? transport.gstNo!
// //                             : " -",
// //
// //                         city: (transport.city?.trim().isNotEmpty ?? false)
// //                             ? transport.city!
// //                             : " -",
// //
// //                         phone:
// //                             (firstContact?.contactNumber?.trim().isNotEmpty ??
// //                                 false)
// //                             ? firstContact!.contactNumber!
// //                             : "-",
// //                         editIconTap: () async {
// //                           // final result = await Navigator.push(
// //                           //   context,
// //                           //   MaterialPageRoute(
// //                           //     builder: (context) => AddNewTransport(
// //                           //       mode: FormMode.edit,
// //                           //       id: transport.id?.toInt(),
// //                           //     ),
// //                           //   ),
// //                           // );
// //
// //                           // if (result is Map) {
// //                           //   context.read<GetTransportProvider>().updateTransportLocally(result);
// //                           // }
// //                         },
// //                         trashIconTap: () {
// //                           final parentContext = context;
// //                           ExitConfirmationDialog.show(
// //                             parentContext,
// //                             saveButtonText: "Yes",
// //                             discardButtonText: "No",
// //                             onDiscard: () {
// //                               Navigator.pop(context);
// //                             },
// //                             bodyText:
// //                                 "Are you sure you want to permanently delete ${transport.name}? This action cannot be undo.",
// //                             onSave: () async {
// //                               final provider =
// //                                   Provider.of<DeleteTransportProvider>(
// //                                     parentContext,
// //                                     listen: false,
// //                                   );
// //
// //                               await provider.deleteTransport(
// //                                 transport.id!.toInt(),
// //                               );
// //                               if (!context.mounted) return;
// //                               Navigator.of(
// //                                 parentContext,
// //                                 rootNavigator: true,
// //                               ).pop();
// //                               if (provider.error != null) {
// //                                 ScaffoldSnackBar.show(
// //                                   parentContext,
// //                                   provider.error!,
// //                                   //backgroundColor: Colors.red,
// //                                 );
// //                               } else {
// //                                 ScaffoldSnackBar.show(
// //                                   parentContext,
// //                                   provider.deleteResponse?.message ??
// //                                       "Transport deleted successfully",
// //                                 );
// //                               }
// //                               if (searchController.text.trim().isNotEmpty) {
// //                                 await parentContext
// //                                     .read<TransportProvider>()
// //                                     .getSearchTransport(
// //                                       searchController.text.trim(),
// //                                     );
// //                               } else {
// //                                 await parentContext
// //                                     .read<TransportProvider>()
// //                                     .refreshTransport();
// //                               }
// //                             },
// //                           );
// //                         },
// //                         copyIconTap: () {
// //                           showDialog(
// //                             context: context,
// //                             builder: (context) {
// //                               return CustomCopyDetailsDialog(
// //                                 heading: "Transport Details",
// //                                 firmName: transport.name ?? "",
// //                                 address: transport.addressLine1 ?? "",
// //                                 gstNo: transport.gstNo ?? "",
// //                                 contact: firstContact?.contactNumber ?? "",
// //                                 emails: transport.email ?? "",
// //                               );
// //                             },
// //                           );
// //                         },
// //                       )
// //                       );
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //         onPressed: () async {
// //           // final result = await Navigator.push(
// //           //   context,
// //           //   MaterialPageRoute(
// //           //     builder: (_) => const AddNewTransport(),
// //           //   ),
// //           // );
// //
// //           // if (result == true) {
// //           //   await context.read<GetTransportProvider>().refreshTransport();
// //           // }
// //         },
// //         backgroundColor: AppColors.primaryPurple,
// //         child: Icon(Iconsax.add, color: Colors.white, size: 40),
// //       ),
// //     );
// //   }
// // }
