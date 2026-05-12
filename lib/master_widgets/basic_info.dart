import 'package:flutter/material.dart';
import 'package:hisabio/constants/list_items.dart';

class SupplierBasicInfo extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController? emailController;
  final TextEditingController? groupController;
  final TextEditingController? gstNoController;
  final TextEditingController? msmeController;
  final TextEditingController? commissionSchemeController;
  final TextEditingController? commissionRateController;
  final TextEditingController? referenceController;

  const SupplierBasicInfo({
    super.key,
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
          controller: widget.nameController,
          decoration: InputDecoration(
            hintText: "Supplier Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        TextFormField(
          controller: widget.emailController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        TextFormField(
          controller: widget.groupController,
          decoration: InputDecoration(
            hintText: "Group",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Email is required";
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: widget.gstNoController,
          decoration: InputDecoration(
            hintText: "GST Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
          //controller: msmeController,
          decoration: InputDecoration(
            hintText: "MSME",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: ListItems.msmeItems.map((msme) {
            return DropdownMenuItem(value: msme, child: Text(msme));
          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedMsme = value;

              widget.msmeController!.text = value ?? "";
            });
          },
        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(

          //controller: widget.commissionSchemeController,
          decoration: InputDecoration(

            hintText: "Commission Scheme",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),

          items: ListItems.commissionScheme.map((commissionSchemeList) {
            return DropdownMenuItem(
              value: commissionSchemeList,
              child: Text(commissionSchemeList),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedCommissionScheme = value;

              widget.commissionSchemeController!.text = value ?? "";
            });
          },
        ),
        SizedBox(height: 15),
        TextFormField(  keyboardType: TextInputType.number,
          controller: widget.commissionRateController,
          decoration: InputDecoration(
            hintText: "Commission % (Rate)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Email is required";
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: widget.referenceController,
          decoration: InputDecoration(
            hintText: "Reference By",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Email is required";
            }
            return null;
          },
        ),
      ],
    );
  }
}
