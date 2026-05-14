import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/enums/supplier_mode.dart';
import 'package:hisabio/master_widgets/address_details.dart';
import 'package:hisabio/master_widgets/bank_details_form.dart';
import 'package:hisabio/master_widgets/basic_info.dart';
import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
import 'package:hisabio/master_widgets/contact_info.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/add_newsupplier.dart';
import 'package:hisabio/provider/get_supplier_provider.dart';
import 'package:hisabio/provider/get_suppliers_byid_provider.dart';
import 'package:hisabio/provider/get_transport_provider.dart';
import 'package:hisabio/provider/update_supplier_provider.dart';
import 'package:hisabio/screens/master_screens/supplier.dart';
import 'package:provider/provider.dart';

class AddNewSupplier extends StatefulWidget {
  final num? id;
  final SupplierMode mode;
  final dynamic supplierData;

  const AddNewSupplier({
    super.key,
    this.id,
    this.mode = SupplierMode.add,
    this.supplierData,
  });

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

  Map<String, dynamic> submitSupplier() {
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

      "preferredTransportIds": selectedTransportId != null
          ? [int.parse(selectedTransportId!)]
          : [],
      "remark": remarksController.text,

      "contacts": contactList,
    };
    return body;
  }

  @override
  void initState() {
    super.initState();

    if (widget.mode == SupplierMode.view || widget.mode == SupplierMode.edit) {
      Future.microtask(() {
        final provider = context.read<GetSupplierByIdProvider>();
        provider.fetchSupplierById(widget.id!.toInt());

        final s = provider.supplier;
        if (s != null) {

          nameController.text = s.supplierName ?? "";
          emailController.text = s.email ?? "";
          groupController.text = s.groupName ?? "";
          gstController.text = s.gstNo ?? "";
          msmeController.text = s.msme ?? "";
          commissionSchemeController.text = s.commissionScheme ?? "";
          commissionRateController.text =
              s.commissionRate?.toString() ?? "";
          referenceController.text = s.referenceBy ?? "";

          accountholderNameController.text =
              s.accountName ?? "";

          ifscController.text = s.ifscCode ?? "";

          accountNumberController.text =
              s.accountNumber ?? "";

          bankNameController.text = s.bankName ?? "";

          branchNameController.text = s.branchName ?? "";
          addressLine1Controller.text=s.addressLine1??"";
          addressLine2Controller.text=s.addressLine2??"";
          stateController.text = (s.state ?? "").trim();
       //  widget.state.text = s.state ?? "";

          cityController.text=s.city??"";
          pinCodeController.text=s.pinCode??"";
          remarksController.text=s.remark??"";


         // preferredTransportController.text=s.preferredTransports?.toString()??"";

         /* selectedTransportId =
          (s.preferredTransports != null &&
              s.preferredTransports!.isNotEmpty)
              ? s.preferredTransports!.first.toString()
              : null;*/

          contacts = [];

          if ((s.contacts ?? []).isNotEmpty) {
            for (var c in s.contacts!) {
              contacts.add({
                "name":
                TextEditingController(text: c.name ?? ""),
                "mobile":
                TextEditingController(text: c.mobile ?? ""),
                "type":
                TextEditingController(text: c.type ?? ""),
              });
            }
          } else {
            contacts.add({
              "name": TextEditingController(),
              "mobile": TextEditingController(),
              "type": TextEditingController(),
            });
          }

          setState(() {});
        }

              });
    }

    if (widget.mode == SupplierMode.add) {
      contacts.add({
        "name": TextEditingController(),
        "mobile": TextEditingController(),
        "type": TextEditingController(),
      });
    }

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
              title: widget.mode == SupplierMode.add
                  ? "Add New Supplier"
                  : widget.mode == SupplierMode.edit
                  ? "Edit Supplier"
                  : "View Supplier",
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
                      bankName: bankNameController,
                      ifscCode: ifscController,
                      branchName: branchNameController,
                      accountHolderName: accountholderNameController,
                      accountNumber: accountNumberController,
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
                      "Preferred Transports",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
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
                            enabled: widget.mode != SupplierMode.view,
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

                          onChanged: widget.mode == SupplierMode.view
                              ? null
                              : (value) {
                            setState(() {
                              selectedTransportId = value;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      enabled: widget.mode != SupplierMode.view,
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
                      mode: widget.mode,
                      update: () async {
                        try {
                          final body = submitSupplier();

                          final updateProvider =
                          context.read<UpdateSupplierProvider>();

                          await updateProvider.updateSupplier(
                            id: widget.id!.toInt(),
                            body: body,
                          );

                          if (updateProvider.error != null) {
                            ScaffoldSnackBar.show(
                              context,
                              updateProvider.error!,
                              backgroundColor: Colors.red,
                            );
                          } else {
                            ScaffoldSnackBar.show(
                              context,
                              updateProvider.response?.message ??
                                  "Supplier Updated Successfully",
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Supplier(),
                              ),
                            );
                          }
                        } catch (e) {
                          print("something went wrong $e");
                          ScaffoldSnackBar.show(
                              context, "Something Went wrong $e");
                        }
                      },
                        saveAndAddNew:
                        provider.isLoading
                            ? () {}
                            : () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldSnackBar.show(
                                context, "Supplier name is required");
                            return;
                          }
                          final body = submitSupplier();

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
                              provider.response!.message ??
                                  "Supplier Added Successfully by text",
                            );
                            context.read<SupplierProvider>().fetchSuppliers();
                            clearForm();
                          }
                        },
                        saveSupplier: provider.isLoading
                        ? () {}
                            : () async{
                        try {
                        if (nameController.text.isEmpty) {
                        ScaffoldSnackBar.show(context, "Supplier name is required");
                        return;
                        }


                        final body = submitSupplier();
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
                        provider.response!.message ??
                        "Supplier Added Successfully",
                        );

                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (_) => Supplier(),
                        ),
                        );
                        }
                        }catch(e){
                        ScaffoldSnackBar.show(context, "Something went wrong$e");
                        }},
                        cancel: () {
                          Navigator.pop(context);
                        });
                        }
                        ),
                        );
                        }}