import 'package:flutter/material.dart';
import 'package:hisabio/constants/list_items.dart';
import 'package:hisabio/enums/supplier_mode.dart';

class SupplierBasicInfo extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController? emailController;
  final TextEditingController? groupController;
  final TextEditingController? gstNoController;
  final TextEditingController? msmeController;
  final TextEditingController? commissionSchemeController;
  final TextEditingController? commissionRateController;
  final TextEditingController? referenceController;
  final SupplierMode mode;

  const SupplierBasicInfo({
    super.key,
    required this.mode,
    required this.nameController,
    this.emailController,
    this.groupController,
    this.gstNoController,
    this.msmeController,
    this.commissionSchemeController,
    this.commissionRateController,
    this.referenceController,
  });

  @override
  State<SupplierBasicInfo> createState() => _SupplierBasicInfoState();
}

class _SupplierBasicInfoState extends State<SupplierBasicInfo> {
  String? selectedMsme;
  String? selectedCommissionScheme;
  @override
  void initState() {
    super.initState();

    selectedMsme = widget.msmeController?.text.isEmpty ?? true
        ? null
        : widget.msmeController!.text;

    selectedCommissionScheme =
    widget.commissionSchemeController?.text.isEmpty ?? true
        ? null
        : widget.commissionSchemeController!.text;
  }

  @override
  void didUpdateWidget(covariant SupplierBasicInfo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.msmeController?.text != selectedMsme) {
      setState(() {
        selectedMsme = widget.msmeController?.text;
      });
    }

    if (widget.commissionSchemeController?.text !=
        selectedCommissionScheme) {
      setState(() {
        selectedCommissionScheme =
            widget.commissionSchemeController?.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Basic Information",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 15),
        TextFormField(
          enabled: widget.mode != SupplierMode.view,
          controller: widget.nameController,
          decoration: InputDecoration(
            hintText: "Supplier Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        TextFormField(enabled: widget.mode != SupplierMode.view,
          controller: widget.emailController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        TextFormField(enabled: widget.mode != SupplierMode.view,
          controller: widget.groupController,
          decoration: InputDecoration(
            hintText: "Group",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        TextFormField(enabled: widget.mode != SupplierMode.view,
          controller: widget.gstNoController,
          decoration: InputDecoration(
            hintText: "GST Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: ListItems.msmeItems.contains(selectedMsme)
              ? selectedMsme
              : null,
          //controller: msmeController,
          decoration: InputDecoration(
            enabled: widget.mode != SupplierMode.view,
            hintText: "MSME",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: ListItems.msmeItems.map((msme) {
            return DropdownMenuItem(value: msme, child: Text(msme));
          }).toList(),

          onChanged: widget.mode == SupplierMode.view
              ? null
              : (value) {
            setState(() {
              selectedMsme = value;

              widget.msmeController!.text = value ?? "";
            });
          },
        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: ListItems.commissionScheme.contains(selectedCommissionScheme)
              ? selectedCommissionScheme
              : null,
          decoration: InputDecoration(
            enabled: widget.mode != SupplierMode.view,
            hintText: "Commission Scheme",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

          items: ListItems.commissionScheme.map((commissionSchemeList) {
            return DropdownMenuItem(
              value: commissionSchemeList,
              child: Text(commissionSchemeList),
            );
          }).toList(),

          onChanged: widget.mode == SupplierMode.view
              ? null
        :(value) {
            setState(() {
              selectedCommissionScheme = value;

              widget.commissionSchemeController!.text = value ?? "";
            });
          },
        ),
        SizedBox(height: 15),
        TextFormField(  keyboardType: TextInputType.number,
          enabled: widget.mode != SupplierMode.view,
          controller: widget.commissionRateController,
          decoration: InputDecoration(
            hintText: "Commission % (Rate)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        TextFormField(enabled: widget.mode != SupplierMode.view,
          controller: widget.referenceController,
          decoration: InputDecoration(
            hintText: "Reference By",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
      ],
    );
  }
}
