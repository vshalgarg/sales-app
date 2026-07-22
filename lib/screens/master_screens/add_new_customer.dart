import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/master_widgets/address_details.dart';
import 'package:hisabio/master_widgets/bank_details_form.dart';
import 'package:hisabio/master_widgets/basic_info.dart';
import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
import 'package:hisabio/master_widgets/contact_info.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/screens/master_screens/customer.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/dropdown_test.dart';
import '../../customs/new_test.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/get_customer_byid_model.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/add_customer.dart';
import '../../provider/get_customer_byid_provider.dart';
import '../../provider/get_customers_provider.dart';
import '../../provider/get_transport_provider.dart';
import '../../provider/update_customer_provider.dart';
import 'add_new_supplier.dart';

class AddNewCustomer extends StatefulWidget {
  final num? id;
  final FormMode mode;

  const AddNewCustomer({super.key, this.id, this.mode = FormMode.add});

  @override
  State<AddNewCustomer> createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  final GlobalKey financialSectionKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool isExpanded = false;
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final groupController = TextEditingController();

  final gstController = TextEditingController();

  final msmeController = TextEditingController();

  final referenceController = TextEditingController();

  final bankNameController = TextEditingController();

  final ifscController = TextEditingController();

  final branchNameController = TextEditingController();

  final accountholderNameController = TextEditingController();

  final accountNumberController = TextEditingController();

  final addressLine1Controller = TextEditingController();

  final addressLine2Controller = TextEditingController();

  final stateController = TextEditingController();

  final cityController = TextEditingController();

  final pinCodeController = TextEditingController();

  final preferredTransportController = TextEditingController();

  final remarksController = TextEditingController();
  List<ContactControllers> contacts = [];

  Map<String, dynamic> _buildCustomerBody() {
    return {
      "customerName": nameController.text,
      "email": emailController.text,
      "customerGroup": groupController.text,
      "customerGstNo": gstController.text,
      "customerMsme": msmeController.text,
      "referencedBy": referenceController.text,
      "addressLine1": addressLine1Controller.text,
      "addressLine2": addressLine2Controller.text,
      "city": cityController.text,
      "state": stateController.text,
      "pinCode": pinCodeController.text,
      "bankName": bankNameController.text,
      "ifsc": ifscController.text,
      "branch": branchNameController.text,
      "accountName": accountholderNameController.text,
      "accountNumber": accountNumberController.text,
      "preferredTransportIds": selectedTransportId == null
          ? []
          : [int.parse(selectedTransportId!)],

      "contacts": contacts.map((c) {
        return {
          "contactPerson": c.name.text,
          "mobileNumber": c.mobile.text,
          "type": c.type.text,
        };
      }).toList(),

      "remark": remarksController.text,
    };
  }

  Map<String, dynamic> updateCustomerBody() {
    return {
      "customerName": nameController.text,
      "email": emailController.text,
      "groupName": groupController.text,
      "gstNo": gstController.text,
      "msme": msmeController.text,
      "referencedBy": referenceController.text,
      "addressLine1": addressLine1Controller.text,
      "addressLine2": addressLine2Controller.text,
      "city": cityController.text,
      "state": stateController.text,
      "pinCode": pinCodeController.text,
      "bankName": bankNameController.text,
      "ifsc": ifscController.text,
      "branch": branchNameController.text,
      "accountName": accountholderNameController.text,
      "accountNumber": accountNumberController.text,
      "preferredTransportIds": selectedTransportId == null
          ? []
          : [int.parse(selectedTransportId!)],
      "contacts": contacts.map((c) {
        return {
          "contactPerson": c.name.text,
          "mobileNumber": c.mobile.text,
          "type": c.type.text,
        };
      }).toList(),

      "remark": remarksController.text,
    };
  }

  void _populateFormFromCustomer(Data s) {
    nameController.text = s.customerName ?? "";
    emailController.text = s.email ?? "";
    groupController.text = s.groupName ?? "";
    gstController.text = s.gstNo ?? "";
    msmeController.text = (s.msme ?? "").toLowerCase() == "small"
        ? "Small"
        : (s.msme ?? "").toLowerCase() == "micro"
        ? "Micro"
        : (s.msme ?? "").toLowerCase() == "medium"
        ? "Medium"
        : s.msme ?? "";
    referenceController.text = s.referencedBy ?? "";
    accountholderNameController.text = s.accountName ?? "";
    ifscController.text = s.ifsc ?? "";
    accountNumberController.text = s.accountNumber ?? "";
    bankNameController.text = s.bankName ?? "";
    branchNameController.text = s.branch ?? "";
    addressLine1Controller.text = s.addressLine1 ?? "";
    addressLine2Controller.text = s.addressLine2 ?? "";
    stateController.text = (s.state ?? "").trim();
    cityController.text = s.city ?? "";
    pinCodeController.text = s.pinCode ?? "";
    remarksController.text = s.remark ?? "";

    if (s.preferredTransports != null && s.preferredTransports!.isNotEmpty) {
      final first = s.preferredTransports!.first;
      if (first is Map) {
        selectedTransportId = first.id?.toString();
        selectedType = first.name?.toString();
      } else if (first is PreferredTransports) {
        selectedTransportId = first.id?.toString();
        selectedType = first.name;
      } else {
        selectedTransportId = first.toString();
        selectedType = null;
      }
      preferredTransportController.text = selectedType ?? "";
    }
    contacts = [];

    if ((s.contacts ?? []).isNotEmpty) {
      for (var c in s.contacts!) {
        final contact = ContactControllers();

        if (c is Map) {
          contact.name.text = c.contactPerson?.toString() ?? "";

          contact.mobile.text = c.mobileNumber?.toString() ?? "";

          contact.type.text = c.type?.toString() ?? "";
        } else {
          contact.name.text = c.contactPerson ?? "";
          contact.mobile.text = c.mobileNumber ?? "";
          contact.type.text = c.type?.toString() ?? "";
        }

        contacts.add(contact);
      }
    } else {
      contacts.add(ContactControllers());
    }
  }

  Future<void> loadData() async {
    final transportProvider = context.read<TransportProvider>();

    final customerProvider = context.read<GetCustomerByIdProvider>();

    await transportProvider.fetchTransports();

    if (widget.mode == FormMode.view || widget.mode == FormMode.edit) {
      await customerProvider.getCustomerById(widget.id!.toInt());

      final customerData = customerProvider.customer;

      if (customerData != null && customerData.data != null) {
        _populateFormFromCustomer(customerData.data!);
      }
    } else {
      contacts.add(ContactControllers());
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  String? selectedType;
  String? selectedTransportId;

  void deleteContact(int index) {
    contacts[index].dispose();
    setState(() {
      contacts.removeAt(index);
    });
  }

  void addContact() {
    setState(() {
      contacts.add(ContactControllers());
    });
  }

  @override
  Widget build(BuildContext context) {
    final getCustomerProvider = context.watch<GetCustomerByIdProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: widget.mode == FormMode.view
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          if (widget.mode != FormMode.view)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ExitConfirmationDialog.show(
                  context,
                  onSave: () async {
                    Navigator.pop(context);
                  },
                  discardButtonText: "Leave",
                  saveButtonText: "Stay",
                  onDiscard: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerScreen()),
                    );
                  },
                );
              },
            ),
        ],
        title: widget.mode == FormMode.view
            ? "Customer Details"
            : widget.mode == FormMode.edit
            ? "Update Customer"
            : "Add New Customer",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body:
          getCustomerProvider.isLoading &&
              (widget.mode == FormMode.view || widget.mode == FormMode.edit)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SupplierBasicInfo(
                      mode: widget.mode,
                      showCommissionRate: false,
                      showCommissionScheme: false,
                      nameController: nameController,
                      emailController: emailController,
                      groupController: groupController,
                      gstNoController: gstController,
                      msmeController: msmeController,
                      referenceController: referenceController,
                    ),
                    SizedBox(height: 15),
                    BankDetailsSection(
                      mode: widget.mode,
                      accountNumber: accountNumberController,
                      ifscCode: ifscController,
                      bankName: bankNameController,
                      branchName: branchNameController,
                      accountHolderName: accountholderNameController,
                    ),
                    SizedBox(height: 15),
                    AddressDetails(
                      mode: widget.mode,
                      addressLine1: addressLine1Controller,
                      addressLine2: addressLine2Controller,
                      state: stateController,
                      city: cityController,
                      pinCode: pinCodeController,
                    ),
                    SizedBox(height: 15),

                    ContactInfo(
                      mode: widget.mode,
                      contacts: contacts,
                      onAdd: addContact,
                      onDelete: deleteContact,
                      scrollController: _scrollController,
                    ),
                    SizedBox(height: 15),
                    Container(
                      key: _contactKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                              if (isExpanded) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _scrollController.animateTo(
                                    _scrollController.offset + 250,
                                    // _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                });
                              }
                            },
                            child: TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                iconColor: Colors.white,
                                filled: true,
                                fillColor: AppColors.primaryPurple,
                                hintText: "Financial and Logistics",
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded) ...[
                      Column(
                        key: financialSectionKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),

                          Text(
                            "Preferred Transport",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),

                          Consumer<TransportProvider>(
                            builder: (context, transportProvider, child) {
                              if (transportProvider.isLoading) {
                                return const CircularProgressIndicator();
                              }

                              final transports = transportProvider.transports;

                              return CustomDropdown(
                                hintText: "Preferred Transport",
                                items: transports
                                    .map((e) => e.name ?? "")
                                    .toList(),

                                initialValue: selectedType,

                                isDisabled: widget.mode == FormMode.view,

                                onChanged: (value) {
                                  if (value == null) return;

                                  final selected = transports.firstWhere(
                                    (e) => e.name == value,
                                  );

                                  setState(() {
                                    selectedType = selected.name;
                                    selectedTransportId = selected.id
                                        .toString();
                                    preferredTransportController.text =
                                        selected.name ?? "";
                                  });
                                },
                              );
                            },
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Remarks (Optional)",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          TextFormField(
                            enabled: widget.mode != FormMode.view,
                            controller: remarksController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Remarks (optional)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
      bottomNavigationBar:
          Consumer2<AddCustomerProvider, UpdateCustomerProvider>(
            builder: (context, provider, updateProvider, child) {
              return BottomNavigationButton(
                mode: widget.mode,
                update: () async {
                  if (nameController.text.isEmpty) {
                    ScaffoldSnackBar.show(
                      context,
                      "Please enter customer name",
                    );
                    return;
                  }

                  final body = updateCustomerBody();

                  await updateProvider.updateCustomer(
                    body: body,
                    id: widget.id!.toInt(),
                  );
                  if (!context.mounted) return;

                  if (updateProvider.errorMessage == null) {
                    await context.read<CustomersProvider>().refreshCustomers();
                    if (!context.mounted) return;
                    ScaffoldSnackBar.show(
                      context,
                      updateProvider.updateCustomerResponse?.message ??
                          "Customer Updated Successfully",
                    );

                    Navigator.pop(context);
                  } else {
                    ScaffoldSnackBar.show(
                      context,
                      updateProvider.errorMessage ?? "",
                    );
                  }
                },
                saveSupplier: provider.isLoading
                    ? () {}
                    : () async {
                        if (nameController.text.isEmpty) {
                          ScaffoldSnackBar.show(
                            context,
                            "Please enter customer name",
                          );
                          return;
                        }
                        final body = _buildCustomerBody();

                        await provider.addCustomer(body);
                        if (!context.mounted) return;
                        if (provider.error == null) {
                          await context
                              .read<CustomersProvider>()
                              .refreshCustomers();
                          if (!context.mounted) return;
                          ScaffoldSnackBar.show(
                            context,
                            provider.message ?? "Customer Added Successfully",
                          );

                          Navigator.pop(context);
                        } else {
                          ScaffoldSnackBar.show(context, provider.error ?? "");
                        }
                      },
              );
            },
          ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    groupController.dispose();
    gstController.dispose();
    msmeController.dispose();
    referenceController.dispose();

    bankNameController.dispose();
    ifscController.dispose();
    branchNameController.dispose();
    accountholderNameController.dispose();
    accountNumberController.dispose();

    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    stateController.dispose();
    cityController.dispose();
    pinCodeController.dispose();

    preferredTransportController.dispose();
    remarksController.dispose();

    for (var contact in contacts) {
      contact.dispose();
    }

    super.dispose();
  }
}
