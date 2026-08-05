import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../enums/customer_mode.dart';
import '../../master_widgets/address_details.dart';
import '../../master_widgets/bottomnavigation_button.dart';
import '../../master_widgets/contact_info.dart';
import '../../model_classes/Transport/add_transport_request.dart';
import '../../model_classes/Transport/transport.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/transport_provider.dart';
import 'add_new_supplier.dart';

class AddNewTransport extends StatefulWidget {
  final int? id;
  final FormMode mode;

  const AddNewTransport({
    super.key,
    this.id,
    this.mode = FormMode.add,
  });

  @override
  State<AddNewTransport> createState() => _AddNewTransportState();
}

class _AddNewTransportState extends State<AddNewTransport> {
  bool isExpanded = true;

  final ScrollController _scrollController = ScrollController();

  final transportNameController = TextEditingController();
  final gstNoController = TextEditingController();
  final emailController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final cityController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  String? status;
  final List<ContactControllers> contacts = [];

  @override
  void initState() {
    super.initState();

    contacts.add(ContactControllers());

    if ((widget.mode == FormMode.edit ||
        widget.mode == FormMode.view) &&
        widget.id != null) {
      Future.microtask(() async {
        final provider = context.read<TransportProvider>();

        final success = await provider.fetchTransportDetails(
          widget.id!,
        );

        if (!success) return;

        final data = provider.transportDetails;

        if (data == null) return;

        status = data.status;

        transportNameController.text = data.name ?? "";

        gstNoController.text = data.gstNo ?? "";

        emailController.text = data.email ?? "";

        addressLine1Controller.text =
            data.addressLine1 ?? "";

        addressLine2Controller.text =
            data.addressLine2 ?? "";

        stateController.text = data.state ?? "";

        cityController.text = data.city ?? "";

        pinCodeController.text = data.pinCode ?? "";

        contacts.clear();

        for (final contact in data.contacts) {
          final controller = ContactControllers();

          controller.name.text =
              contact.contactPerson ?? "";

          controller.mobile.text =
              contact.contactNumber ?? "";

          controller.type.text =
              contact.type ?? "";

          contacts.add(controller);
        }

        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    transportNameController.dispose();
    gstNoController.dispose();
    emailController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    cityController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();

    for (final contact in contacts) {
      contact.dispose();
    }

    super.dispose();
  }

  AddTransportRequest buildRequest() {
    return AddTransportRequest(
      name: transportNameController.text.trim(),
      gstNo: gstNoController.text.trim(),
      email: emailController.text.trim(),
      state: stateController.text.trim(),
      city: cityController.text.trim(),
      pinCode: pinCodeController.text.trim(),
      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      status: status,
      contacts: contacts
          .map(
            (e) => TransportContact(
              contactPerson: e.name.text.trim(),
              contactNumber: e.mobile.text.trim(),
              type: e.type.text.trim(),
             // name: e.name.text.trim(),
             // phone: e.mobile.text.trim(),
        ),
      )
          .toList(),
    );
  }

  void addContact() {
    setState(() {
      contacts.add(ContactControllers());
    });
  }

  void deleteContact(int index) {
    contacts[index].dispose();

    setState(() {
      contacts.removeAt(index);
    });
  }

  void clearForm() {
    transportNameController.clear();
    gstNoController.clear();
    emailController.clear();
    stateController.clear();
    cityController.clear();
    pinCodeController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();

    for (final contact in contacts) {
      contact.dispose();
    }

    contacts
      ..clear()
      ..add(ContactControllers());

    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransportProvider>();

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: CustomAppBar(
        leading: widget.mode == FormMode.view
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : null,

        actions: [
          if (widget.mode != FormMode.view)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ExitConfirmationDialog.show(
                  context,
                  saveButtonText: "Stay",
                  discardButtonText: "Leave",
                  onSave: () async {
                    Navigator.pop(context);
                  },
                  onDiscard: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                );
              },
            ),
        ],

        title: widget.mode == FormMode.add
            ? "Add New Transport"
            : widget.mode == FormMode.edit
            ? "Edit Transport"
            : "View Transport",

        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),

      body: provider.detailsLoading &&
          (widget.mode == FormMode.edit ||
              widget.mode == FormMode.view)
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        controller: _scrollController,

        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },

                child: TextFormField(
                  enabled: false,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                    AppColors.primaryPurple,

                    hintText: "Basic Information",

                    hintStyle: const TextStyle(
                      color: Colors.white,
                    ),

                    suffixIcon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(5),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ),

              if (isExpanded) ...[
                const SizedBox(height: 15),

                const Text(
                  "Transport Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                TextFormField(
                  controller:
                  transportNameController,

                  enabled:
                  widget.mode != FormMode.view,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Transport Name",

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(5),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "GST No",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                TextFormField(
                  controller: gstNoController,

                  enabled:
                  widget.mode != FormMode.view,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "GST Number",

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(5),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                TextFormField(
                  controller: emailController,

                  enabled:
                  widget.mode != FormMode.view,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(5),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 15),

              AddressDetails(
                mode: widget.mode,
                addressLine1:
                addressLine1Controller,
                addressLine2:
                addressLine2Controller,
                state: stateController,
                city: cityController,
                pinCode: pinCodeController,
              ),

              const SizedBox(height: 15),

              ContactInfo(
                mode: widget.mode,
                contacts: contacts,
                onAdd: addContact,
                onDelete: deleteContact,
                scrollController:
                _scrollController,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationButton(
        mode: widget.mode,

        saveSupplier: () async {
          if (transportNameController.text.trim().isEmpty) {
            ScaffoldSnackBar.show(
              context,
              "Please fill the transporter name",
            );
            return;
          }

          final provider = context.read<TransportProvider>();

          final success = await provider.addTransport(
            buildRequest(),
          );

          if (!mounted) return;

          if (success) {
            ScaffoldSnackBar.show(
              context,
              "Transport Added Successfully",
            );

            Navigator.pop(context, true);
          } else {
            ScaffoldSnackBar.show(
              context,
              "Failed to add transport",
            );
          }
        },

        update: () async {
          if (transportNameController.text.trim().isEmpty) {
            ScaffoldSnackBar.show(
              context,
              "Please fill the transporter name",
            );
            return;
          }

          final provider = context.read<TransportProvider>();
          debugPrint("Contacts count = ${contacts.length}");
         // debugPrint(contacts.toJson().toString());
          final success = await provider.updateTransport(
            id: widget.id!,
            request: buildRequest(),
          );

          if (!mounted) return;

          if (success) {
            ScaffoldSnackBar.show(
              context,
              "Transport Updated Successfully",
            );

            Navigator.pop(context, true);
          } else {
            ScaffoldSnackBar.show(
              context,
              "Failed to update transport",
            );
          }
        },
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:hisabio/customs/app_bar.dart';
// import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
// import 'package:hisabio/master_widgets/contact_info.dart';
// import 'package:hisabio/pop_ups/scafold_type.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors_used.dart';
// import '../../enums/customer_mode.dart';
// import '../../master_widgets/address_details.dart';
// import '../../pop_ups/general_closing_popup.dart';
// import '../../provider/transport_provider.dart';
// import 'add_new_supplier.dart';
//
// class AddNewTransport extends StatefulWidget {
//   final int? id;
//   final FormMode mode;
//
//   const AddNewTransport({super.key, this.mode = FormMode.add, this.id});
//
//   @override
//   State<AddNewTransport> createState() => _AddNewTransportState();
// }
//
// class _AddNewTransportState extends State<AddNewTransport> {
//   bool isExpanded = true;
//   final ScrollController _scrollController = ScrollController();
//   @override
//   @override
//   void initState() {
//     super.initState();
//
//     contacts.add(ContactControllers());
//
//     if ((widget.mode == FormMode.edit ||
//         widget.mode == FormMode.view) &&
//         widget.id != null) {
//       Future.microtask(() async {
//         final provider = context.read<TransportProvider>();
//
//         await provider.getTransportById(widget.id!);
//
//         final data = provider.transport;
//
//         if (data == null) return;
//
//         transportNameController.text = data.name ?? "";
//
//         gstNoController.text = data.gstNo ?? "";
//
//         emailController.text = data.email ?? "";
//
//         addressLine1Controller.text = data.addressLine1 ?? "";
//
//         addressLine2Controller.text = data.addressLine2 ?? "";
//
//         stateController.text = data.state ?? "";
//
//         cityController.text = data.city ?? "";
//
//         pinCodeController.text = data.pinCode ?? "";
//
//         contacts.clear();
//
//         for (var contact in data.contacts ?? []) {
//           final controller = ContactControllers();
//
//           controller.name.text = contact.contactPerson ?? "";
//
//           controller.mobile.text = contact.contactNumber ?? "";
//
//           controller.type.text = contact.type ?? "";
//
//           contacts.add(controller);
//         }
//
//         setState(() {});
//       });
//     }
//   }
//
//   final transportNameController = TextEditingController();
//   final gstNoController = TextEditingController();
//   final emailController = TextEditingController();
//   final stateController = TextEditingController();
//   final pinCodeController = TextEditingController();
//   final cityController = TextEditingController();
//   final addressLine1Controller = TextEditingController();
//   final addressLine2Controller = TextEditingController();
//   final List<ContactControllers> contacts = [];
//
//   Map<String, dynamic> addTransportBody() {
//     return {
//       "name": transportNameController.text,
//
//       "gstNo": gstNoController.text,
//
//       "email": emailController.text,
//
//       "addressLine1": addressLine1Controller.text,
//
//       "addressLine2": addressLine2Controller.text,
//
//       "state": stateController.text,
//
//       "city": cityController.text,
//
//       "pincode": pinCodeController.text,
//
//       "contacts": contacts.map((e) {
//         return {
//           "contactPerson": e.name.text,
//
//           "contactNumber": e.mobile.text,
//
//           "type": e.type.text,
//         };
//       }).toList(),
//     };
//   }
//
//   void deleteContact(int index) {
//     contacts[index].dispose();
//     setState(() {
//       contacts.removeAt(index);
//     });
//   }
//
//   void addContact() {
//     setState(() {
//       contacts.add(ContactControllers());
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     transportNameController.dispose();
//     gstNoController.dispose();
//     emailController.dispose();
//     stateController.dispose();
//     pinCodeController.dispose();
//     cityController.dispose();
//     addressLine1Controller.dispose();
//     addressLine2Controller.dispose();
//
//     for (var contact in contacts) {
//       contact.dispose();
//     }
//
//     super.dispose();
//   }
//
//   void clearForm() {
//     transportNameController.clear();
//
//     gstNoController.clear();
//
//     emailController.clear();
//
//     addressLine1Controller.clear();
//
//     addressLine2Controller.clear();
//
//     stateController.clear();
//
//     cityController.clear();
//
//     pinCodeController.clear();
//
//     for (var contact in contacts) {
//       contact.name.clear();
//
//       contact.mobile.clear();
//
//       contact.type.clear();
//     }
//
//     contacts.clear();
//
//     contacts.add(ContactControllers());
//
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final getTransportProvider = context.watch<GetTransportByIdProvider>();
//     return Scaffold(
//       backgroundColor: AppColors.bodyFillColor,
//       appBar: CustomAppBar(
//         leading: widget.mode == FormMode.view
//             ? IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         )
//             : null,
//         actions: [
//           if (widget.mode != FormMode.view)
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () {
//               ExitConfirmationDialog.show(
//                 context,
//                 onSave: () async{
//                   Navigator.pop(context);
//                 },
//                 saveButtonText: "Stay",
//                 discardButtonText: "Leave",
//                 onDiscard: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context,true);
//                 },
//               );
//             },
//           ),
//         ],
//         title: widget.mode == FormMode.add
//             ? "Add New Transport"
//             : widget.mode == FormMode.edit
//             ? "Edit Transport"
//             : "View Transport",
//         textStyle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 25,
//         ),
//       ),
//       body: getTransportProvider.isLoading &&
//           (widget.mode == FormMode.edit ||
//               widget.mode == FormMode.view)
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         controller: _scrollController,
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     isExpanded = !isExpanded;
//                   });
//                 },
//                 child: TextFormField(
//                   enabled: false,
//                   decoration: InputDecoration(
//                     suffixIcon: Icon(
//                       isExpanded
//                           ? Icons.keyboard_arrow_up
//                           : Icons.keyboard_arrow_down,
//                       color: Colors.white,
//                     ),
//                     iconColor: Colors.white,
//                     filled: true,
//                     fillColor: AppColors.primaryPurple,
//                     hintText: "Basic Information",
//                     hintStyle: TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ),
//               if (isExpanded) ...[
//                 SizedBox(height: 15),
//                 Text(
//                   "Transport Name",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//                 TextFormField(
//                   maxLines: 5,
//                   minLines: 1,
//                   controller: transportNameController,
//                   enabled: widget.mode != FormMode.view,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: "Transport Name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "GST No",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//                 TextFormField(
//                   controller: gstNoController,
//                   enabled: widget.mode != FormMode.view,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: "GST No",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Email",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//                 TextFormField(
//                   controller: emailController,
//                   enabled: widget.mode != FormMode.view,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: "Email",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ],
//               SizedBox(height: 15),
//               AddressDetails(
//                 mode: widget.mode,
//                 addressLine1: addressLine1Controller,
//                 addressLine2: addressLine2Controller,
//                 state: stateController,
//                 city: cityController,
//                 pinCode: pinCodeController,
//               ),
//               SizedBox(height: 15),
//               ContactInfo(
//                 mode: widget.mode,
//                 contacts: contacts,
//                 onAdd: addContact,
//                 onDelete: deleteContact,
//                 scrollController: _scrollController,
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationButton(
//         mode: widget.mode,
//         saveSupplier: () async {
//           if(transportNameController.text.isEmpty){
//             ScaffoldSnackBar.show(context,"Please fill the transporter name");
//             return;
//           }
//           final addTransportProvider = Provider.of<AddNewTransportProvider>(
//             context,
//             listen: false,
//           );
//
//           final body = addTransportBody();
//
//           await addTransportProvider.addNewTransport(body);
//           if (!context.mounted) return;
//
//           if (addTransportProvider.error != null) {
//             ScaffoldSnackBar.show(context, addTransportProvider.error!);
//             return;
//           } else {
//             ScaffoldSnackBar.show(
//               context,
//               addTransportProvider.response?.message ??
//                   "Transport Added Successfully",
//             );
//            //
//           //  Navigator.pop(context);
//             Navigator.pop(context,true);
//           }
//         },
//         update: () async {
//           if(transportNameController.text.isEmpty){
//             ScaffoldSnackBar.show(context,"Please fill the transporter name");
//             return;
//           }
//           final updateProvider = Provider.of<AddNewTransportProvider>(
//             context,
//             listen: false,
//           );
//
//           final body = addTransportBody();
//           final id= widget.id!;
//
//           await updateProvider.updateTransport(body,id);
//           print("Updated Name: ${transportNameController.text}");
//           if (!context.mounted) return;
//
//
//           if (updateProvider.error != null) {
//             ScaffoldSnackBar.show(context, updateProvider.error!);
//             return;
//           } else {
//             ScaffoldSnackBar.show(
//               context,
//               updateProvider.updateResponse?.message ??
//                   "Transport update manually message Successfully",
//             );
//          //   await context.read<GetTransportProvider>().getTransportDetails();
//            // Navigator.pop(context,true);
//             Navigator.pop(context, {
//               "id": widget.id,
//               "name": transportNameController.text,
//               "gstNo": gstNoController.text,
//               "city": cityController.text,
//             });
//           }
//         },
//       ),
//     );
//   }
// }
