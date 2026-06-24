import 'package:flutter/material.dart';
import 'package:hisabio/constants/list_items.dart';

import '../constants/colors_used.dart';
import '../enums/customer_mode.dart';

class SupplierBasicInfo extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController? emailController;
  final TextEditingController? groupController;
  final TextEditingController? gstNoController;
  final TextEditingController? msmeController;
  final TextEditingController? commissionSchemeController;
  final TextEditingController? commissionRateController;
  final TextEditingController? referenceController;
  final FormMode? mode;
  final bool showCommissionScheme;
  final bool showCommissionRate;

  const SupplierBasicInfo({
    super.key,
    this.mode,
    required this.showCommissionScheme,
    required this.showCommissionRate,
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
  bool isExpanded=false;

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

    if (widget.commissionSchemeController?.text != selectedCommissionScheme) {
      setState(() {
        selectedCommissionScheme = widget.commissionSchemeController?.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(onTap:(){setState(() {
            isExpanded=!isExpanded;

          });},
            child: TextFormField(
              enabled: false,
              decoration: InputDecoration(
                suffixIcon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white),
                iconColor: Colors.white,
                filled: true,
                fillColor: AppColors.primaryPurple,
                hintText: "Basic Information",
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
          Text("Name", style: TextStyle(color: Colors.white, fontSize: 18)),
          TextFormField(
            enabled: widget.mode != FormMode.view,
            controller: widget.nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 15),

          Text("Email", style: TextStyle(color: Colors.white, fontSize: 18)),
          TextFormField(
            enabled: widget.mode != FormMode.view,
            controller: widget.emailController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 15),

          Text("Group Name", style: TextStyle(color: Colors.white, fontSize: 18)),
          TextFormField(
            enabled: widget.mode != FormMode.view,
            controller: widget.groupController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Group Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 15),

          Text("GST Number", style: TextStyle(color: Colors.white, fontSize: 18)),
          TextFormField(
            enabled: widget.mode != FormMode.view,
            controller: widget.gstNoController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "GST Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 15),

          Text("MSME", style: TextStyle(color: Colors.white, fontSize: 18)),
          DropdownButtonFormField<String>(
            initialValue: ListItems.msmeItems.contains(selectedMsme)
                ? selectedMsme
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabled: widget.mode != FormMode.view,
              hintText: "MSME",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
            items: ListItems.msmeItems.map((msme) {
              return DropdownMenuItem(value: msme, child: Text(msme));
            }).toList(),

            onChanged: widget.mode == FormMode.view
                ? null
                : (value) {
                    setState(() {
                      selectedMsme = value;

                      widget.msmeController!.text = value ?? "";
                    });
                  },
          ),
          if (widget.showCommissionScheme) ...[
            SizedBox(height: 15),

            Text(
              "Commission Scheme",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            DropdownButtonFormField<String>(
              initialValue:
                  ListItems.commissionScheme.contains(selectedCommissionScheme)
                  ? selectedCommissionScheme
                  : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                enabled: widget.mode != FormMode.view,
                hintText: "Commission Scheme",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
              ),

              items: ListItems.commissionScheme.map((commissionSchemeList) {
                return DropdownMenuItem(
                  value: commissionSchemeList,
                  child: Text(commissionSchemeList),
                );
              }).toList(),

              onChanged: widget.mode == FormMode.view
                  ? null
                  : (value) {
                      setState(() {
                        selectedCommissionScheme = value;

                        widget.commissionSchemeController!.text = value ?? "";
                      });
                    },
            ),
          ],
          if (widget.showCommissionRate) ...[
            SizedBox(height: 15),
            Text(
              "Commission % (Rate)",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              enabled: widget.mode != FormMode.view,
              controller: widget.commissionRateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Commission % (Rate)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          SizedBox(height: 15),
          Text(
            "Reference By",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          TextFormField(
            enabled: widget.mode != FormMode.view,
            controller: widget.referenceController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Reference By",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        ],
    );
  }
}
