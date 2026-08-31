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
import '../../provider/master_provider/transport_provider.dart';
import 'add_new_supplier.dart';

class AddNewTransport extends StatefulWidget {
  final int? id;
  final FormMode mode;

  const AddNewTransport({super.key, this.id, this.mode = FormMode.add});

  @override
  State<AddNewTransport> createState() => _AddNewTransportState();
}

class _AddNewTransportState extends State<AddNewTransport> {
  bool isExpanded = true;
  String? transportNameError;
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

  bool validateTransportName() {
    if (transportNameController.text.trim().isEmpty) {
      setState(() {
        transportNameError = "Transport Name is required";
      });

      ScaffoldSnackBar.show(
        context,
        "Transport Name is required",
      );

      return false;
    }

    if (transportNameError != null) {
      setState(() {
        transportNameError = null;
      });
    }

    return true;
  }
  @override
  void initState() {
    super.initState();

    contacts.add(ContactControllers());

    if ((widget.mode == FormMode.edit || widget.mode == FormMode.view) &&
        widget.id != null) {
      final provider = context.read<TransportProvider>();
      Future.microtask(() async {
        final success = await provider.fetchTransportDetails(widget.id!);

        if (!success) return;

        final data = provider.transportDetails;

        if (data == null) return;

        status = data.status;

        transportNameController.text = data.name ?? "";

        gstNoController.text = data.gstNo ?? "";

        emailController.text = data.email ?? "";

        addressLine1Controller.text = data.addressLine1 ?? "";

        addressLine2Controller.text = data.addressLine2 ?? "";

        stateController.text = data.state ?? "";

        cityController.text = data.city ?? "";

        pinCodeController.text = data.pinCode ?? "";

        contacts.clear();

        bool hasContactData = false;

        for (final contact in data.contacts) {
          final name = contact.contactPerson?.trim() ?? "";
          final mobile = contact.contactNumber?.trim() ?? "";
          final type = contact.type?.trim() ?? "";

          if (name.isNotEmpty || mobile.isNotEmpty || type.isNotEmpty) {
            hasContactData = true;

            final controller = ContactControllers();

            controller.name.text = name;
            controller.mobile.text = mobile;
            controller.type.text = type;

            contacts.add(controller);
          }
        }

// Add one empty contact for Add/Edit only
        if (!hasContactData && widget.mode != FormMode.view) {
          contacts.add(ContactControllers());
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

      body:
          provider.detailsLoading &&
              (widget.mode == FormMode.edit || widget.mode == FormMode.view)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,

              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

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
                          fillColor: AppColors.primaryPurple,

                          hintText: "Basic Information",

                          hintStyle: const TextStyle(color: Colors.white),

                          suffixIcon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    if (isExpanded) ...[
                      const SizedBox(height: 15),

                      Text(
                        widget.mode == FormMode.view
                            ? "Transport Name":"Transport Name * ",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        controller: transportNameController,
                        enabled: widget.mode != FormMode.view,
                        onChanged: (value) {
                          if (value.trim().isNotEmpty && transportNameError != null) {
                            setState(() {
                              transportNameError = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Transport Name ",
                          hintStyle: const TextStyle(color: Colors.grey),
                          errorText: transportNameError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "GST No",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        controller: gstNoController,

                        enabled: widget.mode != FormMode.view,

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "GST Number",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Email",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        controller: emailController,

                        enabled: widget.mode != FormMode.view,

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    AddressDetails(
                      mode: widget.mode,
                      addressLine1: addressLine1Controller,
                      addressLine2: addressLine2Controller,
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
                      scrollController: _scrollController,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationButton(
        mode: widget.mode,

        saveSupplier: () async {
          if (!validateTransportName()) {
            return;
          }

          final provider = context.read<TransportProvider>();

          final success = await provider.addTransport(
            buildRequest(),
          );

          if (!context.mounted) return;

          final message = provider.message;

          if (!success) {
            // Backend error — stay on this screen and show message
            ScaffoldSnackBar.show(
              context,
              message ?? "Something went wrong",
            );
            return;
          }

          // Success — show message before leaving
          ScaffoldSnackBar.show(
            context,
            message ?? "Transport Added Successfully",
          );

          await Future.delayed(const Duration(milliseconds: 300));

          if (!context.mounted) return;
          Navigator.pop(context, true);
        },

        update: () async {
          if (!validateTransportName()) {
            return;
          }

          final provider = context.read<TransportProvider>();

          final success = await provider.updateTransport(
            id: widget.id!,
            request: buildRequest(),
          );

          if (!context.mounted) return;

          final message = provider.message;

          if (!success) {
            // Backend error — stay on this screen and show message
            ScaffoldSnackBar.show(
              context,
              message ?? "Something went wrong",
            );
            return;
          }

          // Success — show message before leaving
          ScaffoldSnackBar.show(
            context,
            message ?? "Transport Updated Successfully",
          );

          await Future.delayed(const Duration(milliseconds: 300));

          if (!context.mounted) return;
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
