import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/master_widgets/address_details.dart';
import 'package:hisabio/master_widgets/bank_details_form.dart';
import 'package:hisabio/master_widgets/basic_info.dart';
import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
import 'package:hisabio/master_widgets/contact_info.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/add_newsupplier.dart';
import 'package:hisabio/provider/get_transport_provider.dart';
import 'package:hisabio/screens/master_screens/supplier.dart';

//import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AddNewSupplier extends StatefulWidget {
  const AddNewSupplier({super.key});

  @override
  State<AddNewSupplier> createState() => _AddNewSupplierState();
}

class _AddNewSupplierState extends State<AddNewSupplier> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final groupController = TextEditingController();

  final gstController = TextEditingController();

  final msmeController = TextEditingController();

  final commissionSchemeController = TextEditingController();

  final commissionRateController = TextEditingController();

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
  String? selectedTransportId;

  Future<void> submitSupplier({required bool addNew}) async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldSnackBar.show(context, "Please fill supplier name");
      return;
    }

    if (selectedTransportId == null) {
      ScaffoldSnackBar.show(context, "Please select transport");
      return;
    }
    final provider = context.read<AddSupplierProvider>();

    List<Map<String, dynamic>> contactList = contacts.map((c) {
      return {
        "name": c["name"]!.text,
        "mobile": c["mobile"]!.text,
        "type": c["type"]!.text,
      };
    }).toList();
    Map<String, dynamic> body = {
      "supplierName": nameController.text,
      "email": emailController.text,
      "supplierGroup": groupController.text,
      "supplierGstNo": gstController.text,
      "supplierMsme": msmeController.text,
      "commissionScheme": commissionSchemeController.text,
      "commissionRate": commissionRateController.text,
      "referenceBy": referenceController.text,

      "bankName": bankNameController.text,
      "ifscCode": ifscController.text,
      "branchName": branchNameController.text,
      "accountName": accountholderNameController.text,
      "accountNumber": accountNumberController.text,

      "addressLine1": addressLine1Controller.text,
      "addressLine2": addressLine2Controller.text,
      "state": stateController.text,
      "city": cityController.text,
      "pinCode": pinCodeController.text,

      "preferredTransportIds": [int.parse(selectedTransportId!)],
      "remark": remarksController.text,

      "contacts": contactList,
    };

    await provider.addSupplier(body);
    if (provider.error != null) {
      ScaffoldSnackBar.show(
        context,
        provider.error!,
        backgroundColor: Colors.red,
      );
    } else {
      ScaffoldSnackBar.show(
        context,
        provider.response!.message ?? "Supplier Added Successfully ",
      );
      if (!addNew) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Supplier()),
        );
      } else {
        clearForm();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    contacts.add({
      "name": TextEditingController(),
      "mobile": TextEditingController(),
      "type": TextEditingController(),
    });
    Future.microtask(() {
      Provider.of<TransportProvider>(context, listen: false).fetchTransports();
    });
  }

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

  void clearForm() {
    nameController.clear();
    emailController.clear();
    groupController.clear();
    gstController.clear();
    msmeController.clear();
    commissionSchemeController.clear();
    commissionRateController.clear();
    referenceController.clear();

    bankNameController.clear();
    ifscController.clear();
    branchNameController.clear();
    accountholderNameController.clear();
    accountNumberController.clear();

    addressLine1Controller.clear();
    addressLine2Controller.clear();
    stateController.clear();
    cityController.clear();
    pinCodeController.clear();

    preferredTransportController.clear();
    remarksController.clear();

    for (var c in contacts) {
      c["name"]!.clear();
      c["mobile"]!.clear();
      c["type"]!.clear();
    }

    setState(() {
      selectedTransportId = null;

      contacts = [
        {
          "name": TextEditingController(),
          "mobile": TextEditingController(),
          "type": TextEditingController(),
        },
      ];
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    groupController.dispose();
    gstController.dispose();
    msmeController.dispose();
    commissionSchemeController.dispose();
    commissionRateController.dispose();
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

    for (var c in contacts) {
      c["name"]!.dispose();
      c["mobile"]!.dispose();
      c["type"]!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Add New Supplier",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SupplierBasicInfo(
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
                bankName: bankNameController,
                ifscCode: ifscController,
                branchName: branchNameController,
                accountHolderName: accountholderNameController,
                accountNumber: accountNumberController,
              ),
              SizedBox(height: 15),
              AddressDetails(
                addressLine1: addressLine1Controller,
                addressLine2: addressLine2Controller,
                state: stateController,
                city: cityController,
                pinCode: pinCodeController,
              ),
              SizedBox(height: 15),
              ContactInfo(
                contacts: contacts,
                onAdd: addContact,
                onDelete: deleteContact,
              ),
              SizedBox(height: 15),
              Text(
                "Preferred Transports",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Consumer<TransportProvider>(
                builder: (context, provider, child) {
                  //  if (provider.isLoading) {
                  //  return CircularProgressIndicator();
                  //}
                  return DropdownButtonFormField<String>(
                    value: selectedTransportId,
                    isExpanded: true,
                    // controller: preferredTransportController,
                    decoration: InputDecoration(
                      labelText: "Preferred Transport",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: provider.transports.map((t) {
                      return DropdownMenuItem<String>(
                        value: t.id.toString(),
                        child: Text(t.name ?? ""),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedTransportId = value;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 15),
              TextFormField(
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

      bottomNavigationBar: Consumer<AddSupplierProvider>(
        builder: (context, provider, child) {
          return BottomNavigationButton(
            saveAndAddNew: provider.isLoading
                ? (){}
                : () async {
                    await submitSupplier(addNew: true);
                    clearForm();
                  },
            saveSupplier:provider.isLoading?(){}: () {
              submitSupplier(addNew: false);
            },
            cancel: () {
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
