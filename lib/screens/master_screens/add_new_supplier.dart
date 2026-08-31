import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/master_widgets/address_details.dart';
import 'package:hisabio/master_widgets/bank_details_form.dart';
import 'package:hisabio/master_widgets/basic_info.dart';
import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
import 'package:hisabio/master_widgets/contact_info.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/model_classes/supplier/supplier_details.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/dropdown_test.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/Transport/transport.dart';
import '../../model_classes/supplier/add_supplier_request.dart';
import '../../model_classes/supplier/bank_details_request.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/master_provider/supplier_provider.dart';
import '../../provider/master_provider/transport_provider.dart';

class ContactControllers {
  final name = TextEditingController();

  final mobile = TextEditingController();

  final type = TextEditingController();

  void dispose() {
    name.dispose();
    mobile.dispose();
    type.dispose();
  }
}

class BankControllers {
  int? id;
  final bankName = TextEditingController();
  final ifscCode = TextEditingController();
  final branchName = TextEditingController();
  final accountName = TextEditingController();
  final accountNumber = TextEditingController();

  void dispose() {
    bankName.dispose();
    ifscCode.dispose();
    branchName.dispose();
    accountName.dispose();
    accountNumber.dispose();
  }
}

class AddNewSupplier extends StatefulWidget {
  final num? id;
  final FormMode mode;

  const AddNewSupplier({super.key, this.id, this.mode = FormMode.add});

  @override
  State<AddNewSupplier> createState() => _AddNewSupplierState();
}

class _AddNewSupplierState extends State<AddNewSupplier> {
  bool isExpanded = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final groupController = TextEditingController();

  final gstController = TextEditingController();

  final msmeController = TextEditingController();

  final commissionSchemeController = TextEditingController();

  final commissionRateController = TextEditingController();

  final referenceController = TextEditingController();

  final addressLine1Controller = TextEditingController();

  final addressLine2Controller = TextEditingController();

  final stateController = TextEditingController();

  final cityController = TextEditingController();

  final pinCodeController = TextEditingController();
  final remarksController = TextEditingController();
  List<ContactControllers> contacts = [];

  List<BankControllers> bankDetails = [];
  List<int> selectedTransportIds = [];
  List<String> selectedTransportNames = [];
  String? nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
  AddSupplierRequest submitSupplier() {
    final List<Map<String, dynamic>> contactList = contacts
        .map((c) => {
      "contactPerson": c.name.text.trim(),
      "mobileNumber": c.mobile.text.trim(),
      "type": c.type.text.trim(),
    })
        .where((contact) =>
    (contact["contactPerson"] as String).isNotEmpty ||
        (contact["mobileNumber"] as String).isNotEmpty ||
        (contact["type"] as String).isNotEmpty)
        .toList();
    final List<BankDetailRequest> bankDetailList = bankDetails
        .map(
          (bank) => BankDetailRequest(
            id: bank.id,
            bankName: bank.bankName.text.trim(),
            accountNumber: bank.accountNumber.text.trim(),
            ifscCode: bank.ifscCode.text.trim(),
            branchName: bank.branchName.text.trim(),
            accountName: bank.accountName.text.trim(),
          ),
        )
        .where(
          (bank) =>
              (bank.bankName?.isNotEmpty ?? false) ||
              (bank.accountNumber?.isNotEmpty ?? false) ||
              (bank.ifscCode?.isNotEmpty ?? false) ||
              (bank.branchName?.isNotEmpty ?? false) ||
              (bank.accountName?.isNotEmpty ?? false),
        )
        .toList();

    return AddSupplierRequest(
      supplierName: nameController.text.trim(),
      email: nullableText(emailController.text),
      supplierGroup: nullableText(groupController.text),
      gstNo: nullableText(gstController.text),

      msme: nullableText(msmeController.text),

      commissionScheme: nullableText(
        commissionSchemeController.text,
      ),
      commissionRate: num.tryParse(commissionRateController.text.trim()),
      referenceBy: nullableText(referenceController.text),

      addressLine1: nullableText(addressLine1Controller.text),
      addressLine2: nullableText(addressLine2Controller.text),
      state: nullableText(stateController.text),
      city: nullableText(cityController.text),
      pinCode: nullableText(pinCodeController.text),

      bankDetails: bankDetailList,
      contacts: contactList,
      preferredTransportIds: selectedTransportIds,

      remark: nullableText(remarksController.text),
    );
  }

  AddSupplierRequest updateSupplier() {
    final List<Map<String, dynamic>> contactList = contacts.map((c) {
      return {
        "contactPerson": c.name.text.trim(),
        "mobileNumber": c.mobile.text.trim(),
        "type": c.type.text.trim(),
      };
    }).toList();

    final List<BankDetailRequest> bankDetailList = bankDetails
        .map(
          (bank) => BankDetailRequest(
            bankName: bank.bankName.text.trim(),
            accountNumber: bank.accountNumber.text.trim(),
            ifscCode: bank.ifscCode.text.trim(),
            branchName: bank.branchName.text.trim(),
            accountName: bank.accountName.text.trim(),
          ),
        )
        .where(
          (bank) =>
              (bank.bankName?.isNotEmpty ?? false) ||
              (bank.accountNumber?.isNotEmpty ?? false) ||
              (bank.ifscCode?.isNotEmpty ?? false) ||
              (bank.branchName?.isNotEmpty ?? false) ||
              (bank.accountName?.isNotEmpty ?? false),
        )
        .toList();

    return AddSupplierRequest(
      supplierName: nameController.text.trim(),
      email: emailController.text.trim(),
      supplierGroup: groupController.text.trim(),
      gstNo: gstController.text.trim(),
      msme: msmeController.text.trim(),
      commissionScheme: commissionSchemeController.text.trim(),
      commissionRate: num.tryParse(commissionRateController.text.trim()),
      referenceBy: referenceController.text.trim(),

      bankDetails: bankDetailList,

      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      state: stateController.text.trim(),
      city: cityController.text.trim(),
      pinCode: pinCodeController.text.trim(),
      remark: remarksController.text.trim(),
      contacts: contactList,
      preferredTransportIds: selectedTransportIds,
    );
  }

  void _populateFormFromSupplier(SupplierDetails s) {
    //  BASIC INFO
    nameController.text = s.supplierName ?? "";
    emailController.text = s.email ?? "";
    groupController.text = s.groupName ?? "";
    gstController.text = s.gstNo ?? "";
    log("API GST: ${s.gstNo}");
    log("GST Controller: ${gstController.text}");
    msmeController.text = s.msme?.toUpperCase() ?? "";
    commissionSchemeController.text = s.commissionScheme ?? "";
    commissionRateController.text = s.commissionRate?.toString() ?? "";
    referenceController.text = s.referenceBy ?? "";

    //  BANK DETAILS
    for (final bank in bankDetails) {
      bank.dispose();
    }

    bankDetails.clear();

    if (s.bankDetails.isNotEmpty) {
      for (final bank in s.bankDetails) {
        bankDetails.add(
          BankControllers()
            ..id = bank.id
            ..bankName.text = bank.bankName ?? ""
            ..ifscCode.text = bank.ifscCode ?? ""
            ..branchName.text = bank.branchName ?? ""
            ..accountName.text = bank.accountName ?? ""
            ..accountNumber.text = bank.accountNumber ?? "",
        );
      }
    } else if (widget.mode == FormMode.edit) {
      bankDetails.add(BankControllers());
    }

    //  ADDRESS DETAILS
    addressLine1Controller.text = s.addressLine1 ?? "";
    addressLine2Controller.text = s.addressLine2 ?? "";
    stateController.text = (s.state ?? "").trim();
    cityController.text = s.city ?? "";
    pinCodeController.text = s.pinCode ?? "";

    //  REMARKS
    remarksController.text = s.remark ?? "";

    //  PREFERRED TRANSPORTS
    selectedTransportIds.clear();
    selectedTransportNames.clear();

    for (final transport in s.preferredTransports) {
      if (transport is Map) {
        final id = transport['id'];

        if (id != null) {
          selectedTransportIds.add(int.parse(id.toString()));
        }

        final name = transport['name']?.toString();

        if (name != null && name.isNotEmpty) {
          selectedTransportNames.add(name);
        }
      }
    }

    // CONTACT DETAILS
    for (final contact in contacts) {
      contact.dispose();
    }

    contacts = [];

    bool hasContactData = false;

    for (final c in s.contacts) {
      String name = "";
      String mobile = "";
      String type = "";

      if (c is Map) {
        name = c['contactPerson']?.toString().trim() ?? "";
        mobile = c['mobileNumber']?.toString().trim() ?? "";
        type = c['type']?.toString().trim() ?? "";
      } else {
        name = c.contactPerson?.toString().trim() ?? "";
        mobile = c.mobileNumber?.toString().trim() ?? "";
        type = c.type?.toString().trim() ?? "";
      }

      // Add only contacts that actually contain data
      if (name.isNotEmpty || mobile.isNotEmpty || type.isNotEmpty) {
        hasContactData = true;

        final contact = ContactControllers();

        contact.name.text = name;
        contact.mobile.text = mobile;
        contact.type.text = type;

        contacts.add(contact);
      }
    }

// Add an empty contact only in Add/Edit mode
    if (!hasContactData && widget.mode != FormMode.view) {
      contacts.add(ContactControllers());
    }
  }
  @override
  void initState() {
    super.initState();

    if (widget.mode == FormMode.view || widget.mode == FormMode.edit) {
      final provider = context.read<SupplierProvider>();
      Future.microtask(() async {
        await provider.fetchSupplierDetails(widget.id!.toInt());

        final s = provider.supplierDetails;
        if (s == null || !mounted) return;

        _populateFormFromSupplier(s);
        log("API pinCode: ${s.pinCode}");
        log("Controller pinCode: ${pinCodeController.text}");
        setState(() {});
      });
    }

    if (widget.mode == FormMode.add) {
      contacts.add(ContactControllers());
      bankDetails.add(BankControllers());
    }

    final transportProvider = Provider.of<TransportProvider>(
      context,
      listen: false,
    );

    Future.microtask(() {
      transportProvider.fetchAllTransports();
    });
  }

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

  void addBankDetails() {
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

  void clearForm() {
    nameController.clear();
    emailController.clear();
    groupController.clear();
    gstController.clear();
    msmeController.clear();
    commissionSchemeController.clear();
    commissionRateController.clear();
    referenceController.clear();
    for (final bank in bankDetails) {
      bank.dispose();
    }

    setState(() {
      bankDetails = [BankControllers()];
      selectedTransportIds.clear();
      selectedTransportNames.clear();
      contacts = [ContactControllers()];
    });
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    stateController.clear();
    cityController.clear();
    pinCodeController.clear();
    remarksController.clear();
    for (var c in contacts) {
      c.name.clear();
      c.mobile.clear();
      c.type.clear();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    emailController.dispose();
    groupController.dispose();
    gstController.dispose();
    msmeController.dispose();
    commissionSchemeController.dispose();
    commissionRateController.dispose();
    referenceController.dispose();
    for (final bank in bankDetails) {
      bank.dispose();
    }
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    stateController.dispose();
    cityController.dispose();
    pinCodeController.dispose();
    remarksController.dispose();

    for (var c in contacts) {
      c.name.dispose();
      c.mobile.dispose();
      c.type.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () async {
                ExitConfirmationDialog.show(
                  context,
                  onSave: () async {
                    Navigator.pop(context);
                  },
                  discardButtonText: "Leave",
                  saveButtonText: "Stay",
                  onDiscard: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                );
              },
            ),
        ],

        title: widget.mode == FormMode.add
            ? "Add New Supplier"
            : widget.mode == FormMode.edit
            ? "Edit Supplier"
            : "View Supplier",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SupplierBasicInfo(
                partyType: "Supplier",
                showCommissionScheme: true,
                showCommissionRate: true,
                mode: widget.mode,
                nameController: nameController,
                emailController: emailController,
                groupController: groupController,
                gstNoController: gstController,
                msmeController: msmeController,
                commissionSchemeController: commissionSchemeController,
                commissionRateController: commissionRateController,
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                  if (isExpanded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
                    hintText: "Preferred Transports",
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (isExpanded) ...[
                SizedBox(height: 15),
                Text(
                  "Preferred Transport",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Consumer<TransportProvider>(
                  builder: (context, transportProvider, child) {

                    final List<Transport> transports = transportProvider
                        .data.items.cast<Transport>();

                    return CustomDropdown(
                      hintText: "Preferred Transports",

                      items: transports
                          .map<String>((e) => e.name ?? "")
                          .where((name) => name.isNotEmpty)
                          .toList(),

                      isMultiSelect: true,
                      expandMultiSelect: true,

                      initialValues: List<String>.from(selectedTransportNames),

                      isDisabled: widget.mode == FormMode.view,

                      onChanged: (_) {},

                      onMultiChanged: (values) {
                        final List<String> names = List<String>.from(values);

                        setState(() {
                          selectedTransportNames = names;

                          selectedTransportIds = names.map<int>((name) {
                            final transport = transports.firstWhere(
                              (e) => e.name == name,
                            );

                            return transport.id!.toInt();
                          }).toList();
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
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
      bottomNavigationBar: Consumer<SupplierProvider>(
        builder: (context, provider, child) {
          return BottomNavigationButton(
            mode: widget.mode,

            update: () async {
              try {
                final request = updateSupplier();

                log("Update Request: ${request.toJson()}");

                final message = await provider.updateSupplier(
                  id: widget.id!.toInt(),
                  request: request,
                );

                if (!context.mounted) return;

                if (message != null && message.isNotEmpty) {
                  ScaffoldSnackBar.show(context, message);
                  Navigator.pop(context, true);
                } else {
                  ScaffoldSnackBar.show(
                    context,
                    "Failed to update supplier",
                  );
                }
              } catch (e) {
                log("Update supplier error: $e");

                if (!context.mounted) return;

                ScaffoldSnackBar.show(
                  context,
                  "Failed to update supplier: $e",
                );
              }
            },

            saveSupplier: () async {
              try {
                final isValid = _formKey.currentState!.validate();

                if (!isValid) {
                  ScaffoldSnackBar.show(
                    context,
                    " Name is required.",
                  );
                  return;
                }


                final request = submitSupplier();

                final message = await provider.addSupplier(request);

                if (!context.mounted) return;

                if (message != null && message.isNotEmpty) {
                  Navigator.pop(context, message);
                }
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldSnackBar.show(
                  context,
                  "Something went wrong: $e",
                );
              }
            },
          );
        },
      ),
    );
  }
}
