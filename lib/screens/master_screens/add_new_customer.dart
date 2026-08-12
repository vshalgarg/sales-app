import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/master_widgets/address_details.dart';
import 'package:hisabio/master_widgets/bank_details_form.dart';
import 'package:hisabio/master_widgets/basic_info.dart';
import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
import 'package:hisabio/master_widgets/contact_info.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/dropdown_test.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/customer/add_customer_request.dart';
import '../../model_classes/customer/customer_details.dart';
import '../../model_classes/supplier/bank_details_request.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/master_provider/customer_provider.dart';
import '../../provider/master_provider/transport_provider.dart';
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
  int? selectedState;
  int? selectedCity;
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final groupController = TextEditingController();

  final gstController = TextEditingController();

  final msmeController = TextEditingController();

  final referenceController = TextEditingController();

  final addressLine1Controller = TextEditingController();

  final addressLine2Controller = TextEditingController();

  final stateController = TextEditingController();

  final cityController = TextEditingController();

  final pinCodeController = TextEditingController();

  final preferredTransportController = TextEditingController();

  final remarksController = TextEditingController();
  List<ContactControllers> contacts = [];
  List<BankControllers> bankDetails = [];
  void addInitialBank() {
    if (bankDetails.isEmpty) {
      bankDetails.add(BankControllers());
    }
  }
  void addBankDetails() {
    if (bankDetails.length >= 4) return;

    setState(() {
      bankDetails.add(BankControllers());
    });
  }
  void deleteBankDetails(int index) {
    bankDetails[index].dispose();

    setState(() {
      bankDetails.removeAt(index);
    });
  }
  AddCustomerRequest _buildCustomerRequest() {
    return AddCustomerRequest(
      customerName: nameController.text,
      email: emailController.text.isEmpty ? null : emailController.text,
      groupId: null,
      gstNo: gstController.text.isEmpty ? null : gstController.text,
      referencedBy: referenceController.text.isEmpty
          ? null
          : referenceController.text,
      msme: msmeController.text.isEmpty ? null : msmeController.text,
      remark: remarksController.text.isEmpty ? null : remarksController.text,
      addressLine1: addressLine1Controller.text.isEmpty
          ? null
          : addressLine1Controller.text,
      addressLine2: addressLine2Controller.text.isEmpty
          ? null
          : addressLine2Controller.text,
      state: stateController.text,
      city: cityController.text,
      pinCode: pinCodeController.text.isEmpty
          ? null
          : pinCodeController.text,
      bankDetails: bankDetails.map((bank) {
        return BankDetailRequest(
          bankName: bank.bankName.text.trim().isEmpty
              ? null
              : bank.bankName.text.trim(),

          accountNumber: bank.accountNumber.text.trim().isEmpty
              ? null
              : bank.accountNumber.text.trim(),

          ifscCode: bank.ifscCode.text.trim().isEmpty
              ? null
              : bank.ifscCode.text.trim(),

          branchName: bank.branchName.text.trim().isEmpty
              ? null
              : bank.branchName.text.trim(),

          accountName: bank.accountName.text.trim().isEmpty
              ? null
              : bank.accountName.text.trim(),
        );
      }).toList(),
      preferredTransportIds: selectedTransportId == null
          ? []
          : [int.parse(selectedTransportId!)],
      contacts: contacts
          .map(
            (c) => CustomerContactRequest(
          contactPerson: c.name.text,
          mobileNumber: c.mobile.text,
          type: c.type.text.isEmpty ? null : c.type.text,
        ),
      )
          .toList(),
    );
  }
  void _populateFormFromCustomer(CustomerDetails s) {
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

    // BANK DETAILS
    for (final bank in bankDetails) {
      bank.dispose();
    }

    bankDetails.clear();

    for (final bank in s.bankDetails) {
      bankDetails.add(
        BankControllers()
          ..bankName.text = bank.bankName ?? ""
          ..ifscCode.text = bank.ifscCode ?? ""
          ..branchName.text = bank.branchName ?? ""
          ..accountName.text = bank.accountName ?? ""
          ..accountNumber.text = bank.accountNumber ?? "",
      );
    }

    // For edit mode, if API has no bank, still show Bank 1.
    if (bankDetails.isEmpty && widget.mode != FormMode.view) {
      bankDetails.add(BankControllers());
    }

    // ADDRESS
    addressLine1Controller.text = s.addressLine1 ?? "";
    addressLine2Controller.text = s.addressLine2 ?? "";
    stateController.text = (s.state ?? "").trim();
    cityController.text = s.city ?? "";
    pinCodeController.text = s.pinCode ?? "";
    remarksController.text = s.remark ?? "";

    // TRANSPORT
    if (s.preferredTransports.isNotEmpty) {
      final transport = s.preferredTransports.first;

      selectedTransportId = transport.id.toString();
      selectedType = transport.name;
      preferredTransportController.text = transport.name ?? "";
    }

    // CONTACTS
    for (final contact in contacts) {
      contact.dispose();
    }

    contacts.clear();

    if (s.contacts.isNotEmpty) {
      for (final c in s.contacts) {
        final contact = ContactControllers();

        contact.name.text = c.contactPerson ?? "";
        contact.mobile.text = c.mobileNumber ?? "";
        contact.type.text = c.type ?? "";

        contacts.add(contact);
      }
    } else {
        contacts.add(ContactControllers());
        addInitialBank();
      }
    }

  Future<void> loadData() async {
    final transportProvider = context.read<TransportProvider>();
    final customerProvider = context.read<CustomerProvider>();

    await transportProvider.fetchInitial();

    if (widget.mode == FormMode.view || widget.mode == FormMode.edit) {
      final success = await customerProvider.fetchCustomerDetails(
        widget.id!.toInt(),
      );

      if (success && customerProvider.customerDetails != null) {
        _populateFormFromCustomer(customerProvider.customerDetails!);
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
    context.read<CustomerProvider>().setDetailsLoading(true);
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
    final customerProvider = context.watch<CustomerProvider>();
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
                    Navigator.pop(context,true);

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
      // customerProvider.detailsLoading &&
      //         (widget.mode == FormMode.view || widget.mode == FormMode.edit)
      //     ? const Center(child: CircularProgressIndicator())
           SingleChildScrollView(
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
                      banks: bankDetails,
                      onAdd: addBankDetails,
                      onDelete: deleteBankDetails,
                      scrollController: _scrollController,
                    ),

                    SizedBox(height: 15),
                    AddressDetails(
                      mode: widget.mode,
                      addressLine1: addressLine1Controller,
                      addressLine2: addressLine2Controller,
                      state: stateController,
                      city: cityController,
                      pinCode: pinCodeController,
                      onStateSelected: (id) {
                        selectedState = id;
                      },

                      onCitySelected: (id) {
                        selectedCity = id;
                      },
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
                              if (transportProvider.data.isLoading) {
                                return const CircularProgressIndicator();
                              }

                              final transports = transportProvider.data.items;

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
      bottomNavigationBar: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return BottomNavigationButton(
            mode: widget.mode,

            update: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldSnackBar.show(
                  context,
                  "Please enter customer name",
                );
                return;
              }

              final success = await provider.updateCustomer(
                id: widget.id!.toInt(),
                request: _buildCustomerRequest(),
              );

              if (!context.mounted) return;

              if (success) {
                await provider.refreshCustomers();

                if (!context.mounted) return;

                ScaffoldSnackBar.show(
                  context,
                  "Customer updated successfully",
                );

                Navigator.pop(context, true);
              } else {
                ScaffoldSnackBar.show(
                  context,
                 "Unable to update customer",
                );
              }
            },

            saveSupplier: provider.actionLoading
                ? () {}
                : () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldSnackBar.show(
                  context,
                  "Please enter customer name",
                );
                return;
              }

              final success = await provider.addCustomer(
                _buildCustomerRequest(),
              );

              if (!context.mounted) return;

              if (success) {
                await provider.refreshCustomers();

                if (!context.mounted) return;

                ScaffoldSnackBar.show(
                  context,
                  "Customer added successfully",
                );

                Navigator.pop(context, true);
              } else {
                ScaffoldSnackBar.show(
                  context,
                  "Unable to add customer",
                );
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

    for (final bank in bankDetails) {
      bank.dispose();
    }

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
