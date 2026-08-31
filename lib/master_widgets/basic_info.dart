import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisabio/constants/list_items.dart';

import '../constants/colors_used.dart';
import '../customs/dropdown_test.dart';
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
  final String partyType;
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
    required this.partyType,
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
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();

    selectedMsme = widget.msmeController?.text.isEmpty ?? true
        ? null
        : widget.msmeController!.text.toUpperCase();

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
        selectedMsme = widget.msmeController?.text.trim().toUpperCase();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });},

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
          Text(
            widget.mode == FormMode.view
                ? "Name"
                : "Name *",
          style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          TextFormField(
            controller: widget.nameController,
            enabled: widget.mode != FormMode.view,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Name is required.";
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,

              hintText: "Name ",
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
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
              hintStyle: const TextStyle(
                  color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 15),

          Text(
            "Group Name",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          TextFormField(
            enabled: widget.mode != FormMode.view,
            controller: widget.groupController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Group Name",
              hintStyle: const TextStyle(
                  color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 15),

           const Text(
            "GST Number",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          TextFormField(
            enabled: widget.mode != FormMode.view,
            controller: widget.gstNoController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "GST Number",
              hintStyle: const TextStyle(
                  color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 15),

          Text("MSME", style: TextStyle(color: Colors.white, fontSize: 18)),
          CustomDropdown(
            isDisabled: widget.mode == FormMode.view,
            hintText: "MSME",
            items: ListItems.msmeItems,
            initialValue: selectedMsme,
            onChanged: (value) {
              setState(() {
                selectedMsme = value?.toUpperCase();
                widget.msmeController?.text = value?.toUpperCase() ?? "";
              });
            },
          ),
          if (widget.showCommissionScheme) ...[
            SizedBox(height: 15),

            Text(
              "Commission Scheme",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            CustomDropdown(
              isDisabled: widget.mode == FormMode.view,
              hintText: "Commission Scheme",

              items: ListItems.commissionScheme,
              initialValue: selectedCommissionScheme,
              onChanged: (value) {
                setState(() {
                  selectedCommissionScheme = value;
                  widget.commissionSchemeController?.text = value ?? "";
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              enabled: widget.mode != FormMode.view,
              controller: widget.commissionRateController,

              inputFormatters: [
                TextInputFormatter.withFunction(
                      (oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return newValue;
                    }
                    final validFormat = RegExp(r'^\d+(\.\d{0,2})?$');
                    if (!validFormat.hasMatch(newValue.text)) {
                      return oldValue;
                    }

                    final value = double.tryParse(newValue.text);

                    if (value != null && value <= 100) {
                      return newValue;
                    }

                    // Do not remove existing text
                    return oldValue;
                  },
                ),
              ],

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null;
                }

                final rate = num.tryParse(value.trim());

                if (rate == null) {
                  return "Enter a valid commission rate";
                }

                if (rate < 0 || rate > 100) {
                  return "Commission rate must be between 0% and 100%";
                }

                return null;
              },

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Commission % (Rate)",
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
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
              hintStyle: const TextStyle(
                  color: Colors.grey),
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
