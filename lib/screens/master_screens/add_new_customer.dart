import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/master_widgets/address_details.dart';
import 'package:hisabio/master_widgets/bank_details_form.dart';
import 'package:hisabio/master_widgets/basic_info.dart';
import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
import 'package:hisabio/master_widgets/contact_info.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:provider/provider.dart';
import '../../customs/new_test.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/get_customer_byid_model.dart';
import '../../provider/add_customer.dart';
import '../../provider/get_customer_byid_provider.dart';
import '../../provider/get_customers_provider.dart';
import '../../provider/get_transport_provider.dart';
import '../../provider/update_customer_provider.dart';

class AddNewCustomer extends StatefulWidget {
  final num? id;
  final FormMode mode;
  final dynamic customerData;

  const AddNewCustomer({
    super.key,
    this.id,
    this.mode = FormMode.add,
    this.customerData,
  });

  @override
  State<AddNewCustomer> createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  bool isDataSet = false;
  bool isLoading = false;

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
          "contactPerson": c["name"]!.text,
          "mobileNumber": c["mobile"]!.text,
          "type": c["type"]!.text,
        };
      }).toList(),

      "remarks": remarksController.text,
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
          "contactPerson": c["name"]!.text,
          "mobileNumber": c["mobile"]!.text,
          "type": c["type"]!.text,
        };
      }).toList(),

      "remarks": remarksController.text,
    };
  }

  void _populateFormFromCustomer(s) {
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
    //commissionSchemeController.text = s.commissionScheme ?? "";
    //commissionRateController.text = s.commissionRate?.toString() ?? "";
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
        selectedTransportId = first['id']?.toString();
        selectedType = first['name']?.toString();
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
        if (c is Map) {
          contacts.add({
            "name": TextEditingController(
              text: c['contactPerson']?.toString() ?? "",
            ),
            "mobile": TextEditingController(
              text: c['mobileNumber']?.toString() ?? "",
            ),
            "type": TextEditingController(text: c['type']?.toString() ?? ""),
          });
        } else {
          contacts.add({
            "name": TextEditingController(text: c.contactPerson ?? ""),
            "mobile": TextEditingController(text: c.mobileNumber ?? ""),
            "type": TextEditingController(text: c.type?.toString() ?? ""),
          });
        }
      }
    } else {
      contacts.add({
        "name": TextEditingController(),
        "mobile": TextEditingController(),
        "type": TextEditingController(),
      });
    }
  }
  Future<void> loadData() async {

    final transportProvider =
    context.read<TransportProvider>();

    final customerProvider =
    context.read<GetCustomerByIdProvider>();

    await transportProvider.fetchTransports();

    if (widget.mode == FormMode.view ||
        widget.mode == FormMode.edit) {

      await customerProvider.getCustomerById(
        widget.id!.toInt(),
      );

      final customerData =
          customerProvider.customer;

      if (customerData != null &&
          customerData.data != null) {

        _populateFormFromCustomer(
          customerData.data!,
        );
      }
    } else {

      contacts.add({
        "name": TextEditingController(),
        "mobile": TextEditingController(),
        "type": TextEditingController(),
      });
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {

    super.initState();

    isLoading = true;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      loadData();

    });
  }
  String? selectedType;
  String? selectedTransportId;

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
  List<Map<String, TextEditingController>> contacts = [];

  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
  }

  void addContact() {
    setState(() {
      contacts.add({
        "name": TextEditingController(),
        "mobile": TextEditingController(),
        "type": TextEditingController(),
      });
    });
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    groupController.clear();
    gstController.clear();
    msmeController.clear();
    referenceController.clear();

    bankNameController.clear();
    ifscController.clear();
    branchNameController.clear();
    accountholderNameController.clear();
    accountNumberController.clear();

    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    pinCodeController.clear();

    remarksController.clear();
    preferredTransportController.clear();

    setState(() {
      selectedType = null;
      selectedTransportId = null;
      contacts.clear();
      addContact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
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
          isLoading &&
              (widget.mode == FormMode.view || widget.mode == FormMode.edit)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Financial and Logistics",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),
                    Consumer<TransportProvider>(
                      builder: (context, transportProvider, child) {
                        if (transportProvider.isLoading) {
                          return const CircularProgressIndicator();
                        }

                        final transports = transportProvider.transports;

                        return CustomDropdownMenu(
                          //label: "Preferred Transport",
                          items: transports.map((e) => e.name ?? "").toList(),

                          initialValue: selectedType,

                          isDisabled: widget.mode == FormMode.view,

                          width: MediaQuery.of(context).size.width,

                          onChanged: (value) {
                            final selected = transports.firstWhere(
                              (e) => e.name == value,
                            );

                            setState(() {
                              selectedType = selected.name;

                              selectedTransportId = selected.id.toString();

                              preferredTransportController.text =
                                  selectedType ?? "";
                            });
                          },
                        );
                      },
                    ),

                    /* CustomDropdown(
          // label: "Preferred Transports",
                items: const [
                  "Battery",
                  "DC",
                  "Solar",
                  "Inverter",
                ],

                initialValue: selectedType,

                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },

                isRequired: true,
              ),*/
                    SizedBox(height: 15),
                    TextFormField(
                      enabled: widget.mode != FormMode.view,
                      controller: remarksController,
                      decoration: InputDecoration(
                        labelText: "Remarks (optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
      bottomNavigationBar: Consumer2<AddCustomerProvider, UpdateCustomerProvider>(
        builder: (context, provider,updateProvider, child) {
          return BottomNavigationButton(
            mode: widget.mode,
            update: () async{ if (nameController.text.isEmpty) {
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

            if (updateProvider.errorMessage == null) {

              await context
                  .read<CustomersProvider>()
                  .fetchCustomers();

              ScaffoldSnackBar.show(
                context,
                updateProvider
                    .updateCustomerResponse
                    ?.message ??
                    "Customer Updated Successfully",
              );

              Navigator.pop(context);

            } else {

              ScaffoldSnackBar.show(
                context,
                updateProvider.errorMessage ?? "",
              );
            }},
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

                    if (provider.error == null) {
                      await context.read<CustomersProvider>().fetchCustomers();
                      ScaffoldSnackBar.show(
                        context,
                        provider.message ?? "Customer Added Successfully",
                      );

                      Navigator.pop(context);
                    } else {
                      ScaffoldSnackBar.show(context, provider.error ?? "");
                    }
                  },
            saveAndAddNew: provider.isLoading
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

                    if (provider.error == null) {
                      await context.read<CustomersProvider>().fetchCustomers();
                      ScaffoldSnackBar.show(
                        context,
                        provider.message ?? "Customer Added Successfully",
                      );

                      _clearForm();
                    } else {
                      ScaffoldSnackBar.show(context, provider.error!);
                    }
                  },
            cancel: () {
              Navigator.pop(context);
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

      contact["name"]?.dispose();
      contact["mobile"]?.dispose();
      contact["type"]?.dispose();
    }

    super.dispose();
  }
}
