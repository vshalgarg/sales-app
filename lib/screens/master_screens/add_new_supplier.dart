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
  String? selectedTransportId;

  AddSupplierRequest submitSupplier() {
    List<Map<String, dynamic>> contactList = contacts.map((c) {
      return {
        "contactPerson": c.name.text,
        "mobileNumber": c.mobile.text,
        "type": c.type.text,
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
      preferredTransportIds: selectedTransportId != null
          ? [int.parse(selectedTransportId!)]
          : [],
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
      preferredTransportIds: selectedTransportId != null
          ? [int.parse(selectedTransportId!)]
          : [],
    );
  }

  void _populateFormFromSupplier(SupplierDetails s) {
    nameController.text = s.supplierName ?? "";
    emailController.text = s.email ?? "";
    groupController.text = s.groupName ?? "";
    gstController.text = s.gstNo ?? "";
    msmeController.text = s.msme ?? "";
    commissionSchemeController.text = s.commissionScheme ?? "";
    commissionRateController.text = s.commissionRate?.toString() ?? "";
    referenceController.text = s.referenceBy ?? "";

    if (s.bankDetails.isNotEmpty) {
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

      if (bankDetails.isEmpty && widget.mode != FormMode.view) {
        bankDetails.add(BankControllers());
      }
      addressLine1Controller.text = s.addressLine1 ?? "";
      addressLine2Controller.text = s.addressLine2 ?? "";
      stateController.text = (s.state ?? "").trim();
      cityController.text = s.city ?? "";
      pinCodeController.text = s.pinCode ?? "";
      remarksController.text = s.remark ?? "";

      if (s.preferredTransports.isNotEmpty) {
        final first = s.preferredTransports.first;
        if (first is Map) {
          selectedTransportId = first['id']?.toString();
        } else {
          selectedTransportId = first.toString();
        }
      }

      contacts = [];

      if ((s.contacts).isNotEmpty) {
        for (var c in s.contacts) {
          final contact = ContactControllers();

          if (c is Map) {
            contact.name.text = c['contactPerson']?.toString() ?? "";

            contact.mobile.text = c['mobileNumber']?.toString() ?? "";

            contact.type.text = c['type']?.toString() ?? "";
          } else {
            contact.name.text = c.contactPerson ?? "";

            contact.mobile.text = c.mobileNumber ?? "";

            contact.type.text = c.type ?? "";
          }

          contacts.add(contact);
        }
      } else {
        contacts.add(ContactControllers());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.mode == FormMode.view || widget.mode == FormMode.edit) {
      Future.microtask(() async {
        final provider = context.read<SupplierProvider>();

        await provider.fetchSupplierDetails(widget.id!.toInt());

        final s = provider.supplierDetails;
        if (s == null || !mounted) return;

        _populateFormFromSupplier(s);
        print("API pinCode: ${s.pinCode}");
        print("Controller pinCode: ${pinCodeController.text}");
        setState(() {});
      });
    }

    if (widget.mode == FormMode.add) {
      contacts.add(ContactControllers());
      bankDetails.add(BankControllers());
    }

    Future.microtask(() {
      Provider.of<TransportProvider>(context, listen: false).fetchInitial();
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
    if (bankDetails.length >= 4) {
      ScaffoldSnackBar.show(context, "Maximum 4 bank details can be added");
      return;
    }

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
      selectedTransportId = null;
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

    setState(() {
      selectedTransportId = null;

      contacts = [ContactControllers()];
    });
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
                    //   Navigator.pushReplacement(
                    //     context,
                    //    MaterialPageRoute(builder: (context) => Supplier()),
                    //   );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SupplierBasicInfo(
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
                  builder: (context, provider, child) {
                    return CustomDropdown(
                      isDisabled: widget.mode == FormMode.view,
                      hintText: "Preferred Transport",
                      items: provider.data.items
                          .map((e) => e.name ?? "")
                          .toList(),
                      initialValue:
                          provider.data.items.any(
                            (e) => e.id.toString() == selectedTransportId,
                          )
                          ? provider.data.items
                                .firstWhere(
                                  (e) => e.id.toString() == selectedTransportId,
                                )
                                .name
                          : null,
                      onChanged: (value) {
                        final transport = provider.data.items.firstWhere(
                          (e) => e.name == value,
                        );

                        setState(() {
                          selectedTransportId = transport.id.toString();
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

      bottomNavigationBar: Consumer<SupplierProvider>(
        builder: (context, provider, child) {
          return BottomNavigationButton(
            mode: widget.mode,

            update: () async {
              try {
                final request = updateSupplier();

                print("Update Request: ${request.toJson()}");
                final success = await provider.updateSupplier(
                  id: widget.id!.toInt(),
                  request: request,
                );

                if (!context.mounted) return;

                if (success) {
                  ScaffoldSnackBar.show(
                    context,
                    "Supplier Updated Successfully",
                  );

                  Navigator.pop(context, true);
                } else {
                  ScaffoldSnackBar.show(context, "Failed to update supplier");
                }
              } catch (e) {
                ScaffoldSnackBar.show(context, "Something went wrong: $e");
              }
            },

            // saveSupplier: () async {
            //   print("🔥 SAVE BUTTON CLICKED");
            //
            //   try {
            //     print("actionLoading = ${provider.actionLoading}");
            //
            //     if (nameController.text.trim().isEmpty) {
            //       print(" Supplier name is empty");
            //
            //       ScaffoldSnackBar.show(context, "Supplier name is required");
            //       return;
            //     }
            //
            //     for (int i = 0; i < bankDetails.length; i++) {
            //       print("========== BANK ${i + 1} ==========");
            //       print("Bank Name: ${bankDetails[i].bankName.text}");
            //       print("IFSC: ${bankDetails[i].ifscCode.text}");
            //       print("Branch: ${bankDetails[i].branchName.text}");
            //       print("Account Holder: ${bankDetails[i].accountName.text}");
            //       print("Account Number: ${bankDetails[i].accountNumber.text}");
            //     }
            //
            //     final request = submitSupplier();
            //
            //     print("🔥 SUPPLIER REQUEST:");
            //     print(request.toJson());
            //
            //     final success = await provider.addSupplier(request);
            //
            //     print("🔥 ADD SUCCESS: $success");
            //
            //     if (!context.mounted) return;
            //
            //     if (success) {
            //       ScaffoldSnackBar.show(context, "Supplier Added Successfully");
            //
            //       Navigator.pop(context, true);
            //     } else {
            //       ScaffoldSnackBar.show(context, "Failed to add supplier");
            //     }
            //   } catch (e, stackTrace) {
            //     print("🔥 SAVE ERROR: $e");
            //     print(stackTrace);
            //
            //     if (!context.mounted) return;
            //
            //     ScaffoldSnackBar.show(context, "Something went wrong: $e");
            //   }
            // },

            saveSupplier: provider.actionLoading
                ? () {}
                : () async {
              try {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldSnackBar.show(
                    context,
                    "Supplier name is required",
                  );
                  return;
                }

                final request = submitSupplier();
                print("Supplier Request: ${request.toJson()}");
                final success = await provider.addSupplier(request);

                if (!context.mounted) return;

                if (success) {
                  ScaffoldSnackBar.show(
                    context,
                    "Supplier Added Successfully",
                  );

                  Navigator.pop(context, true);
                } else {
                  ScaffoldSnackBar.show(
                    context,
                    "Failed to add supplier",
                  );
                }
              } catch (e) {
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
