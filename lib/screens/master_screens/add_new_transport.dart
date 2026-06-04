import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/master_widgets/bottomnavigation_button.dart';
import 'package:hisabio/master_widgets/contact_info.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:provider/provider.dart';

import '../../enums/customer_mode.dart';
import '../../master_widgets/address_details.dart';
import '../../provider/add_new_transport.dart';
import '../../provider/get_transport_by_id_provider.dart';
import '../../provider/get_transport_details_provider.dart';
import 'add_new_supplier.dart';

class AddNewTransport extends StatefulWidget {
   final int?id;
  final FormMode mode;

  const AddNewTransport({super.key, this.mode = FormMode.add,this.id});

  @override
  State<AddNewTransport> createState() => _AddNewTransportState();
}

class _AddNewTransportState extends State<AddNewTransport> {
  @override
  @override
  void initState() {

    super.initState();

    contacts.add(ContactControllers());

    if (widget.mode == FormMode.edit &&
        widget.id != null) {

      Future.microtask(() async {

        final provider = context
            .read<GetTransportByIdProvider>();

        await provider.getTransportById(
            widget.id!);

        final data =
            provider.transport;

        if (data == null) return;

        transportNameController.text =
            data.name ?? "";

        gstNoController.text =
            data.gstNo ?? "";

        emailController.text =
            data.email ?? "";

        addressLine1Controller.text =
            data.addressLine1 ?? "";

        addressLine2Controller.text =
            data.addressLine2 ?? "";

        stateController.text =
            data.state ?? "";

        cityController.text =
            data.city ?? "";

        pinCodeController.text =
            data.pinCode ?? "";

        contacts.clear();

        for (var contact
        in data.contacts ?? []) {

          final controller =
          ContactControllers();

          controller.name.text =
              contact.contactPerson ?? "";

          controller.mobile.text =
              contact.contactNumber ?? "";

          controller.type.text =
              contact.type ?? "";

          contacts.add(controller);
        }

        setState(() {});
      });
    }
  }

  final transportNameController = TextEditingController();
  final gstNoController = TextEditingController();
  final emailController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final cityController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final List<ContactControllers> contacts = [];

  Map<String, dynamic> addTransportBody() {
    return {
      "name": transportNameController.text,

      "gstNo": gstNoController.text,

      "email": emailController.text,

      "addressLine1": addressLine1Controller.text,

      "addressLine2": addressLine2Controller.text,

      "state": stateController.text,

      "city": cityController.text,

      "pinCode": pinCodeController.text,

      "contacts": contacts.map((e) {
        return {
          "name": e.name.text,

          "mobile": e.mobile.text,

          "type": e.type.text,
        };
      }).toList(),
    };
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

  @override
  void dispose() {
    transportNameController.dispose();
    gstNoController.dispose();
    emailController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    cityController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();

    for (var contact in contacts) {
      contact.dispose();
    }

    super.dispose();
  }
  void clearForm() {

    transportNameController.clear();

    gstNoController.clear();

    emailController.clear();

    addressLine1Controller.clear();

    addressLine2Controller.clear();

    stateController.clear();

    cityController.clear();

    pinCodeController.clear();

    for (var contact in contacts) {

      contact.name.clear();

      contact.mobile.clear();

      contact.type.clear();
    }

    contacts.clear();

    contacts.add(
      ContactControllers(),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:widget.mode==FormMode.edit?
            "Edit Transport"
        :"Add New Transport",
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
              Text(
                "Basic Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: transportNameController,
                decoration: InputDecoration(
                  hintText: "Transport Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: gstNoController,
                decoration: InputDecoration(
                  hintText: "GST No",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                mode: widget.mode,
                contacts: contacts,
                onAdd: addContact,
                onDelete: deleteContact,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationButton(
        mode: widget.mode,
        saveSupplier: () async {
          final addTransportProvider = Provider.of<AddNewTransportProvider>(
            context,
            listen: false,
          );

          final body = addTransportBody();

          await addTransportProvider.addNewTransport(body);
          if(!context.mounted)return;

          if (addTransportProvider.error != null) {
            ScaffoldSnackBar.show(context, addTransportProvider.error!);
            return;
          }
          else {
            ScaffoldSnackBar.show(
              context,
              addTransportProvider.response?.message ??
                  "Transport Added Successfully",
            );
            Navigator.pop(context);
           await Provider.of<GetTransportProvider>(context, listen: false)
                .getTransportDetails();
          }
        },
        saveAndAddNew: () async {final addTransportProvider = Provider.of<AddNewTransportProvider>(
          context,
          listen: false,
        );

        final body = addTransportBody();

        await addTransportProvider.addNewTransport(body);
        if(!context.mounted)return;

        if (addTransportProvider.error != null) {
          ScaffoldSnackBar.show(context, addTransportProvider.error!);
          return;
        }
        else {
          ScaffoldSnackBar.show(
            context,
            addTransportProvider.response?.message ??
                "Transport Added Successfully",
          );
          clearForm();
        }},
        cancel: () {Navigator.pop(context);},
        update: () {},
      ),
    );
  }
}
