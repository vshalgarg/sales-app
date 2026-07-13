import 'package:flutter/material.dart';

import '../constants/colors_used.dart';
import '../customs/app_bar.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> purchaseData;

  const PurchaseDetailsScreen({super.key, required this.purchaseData});

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  bool basicInfoExpanded = true;
  bool attachmentExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Purchase Details",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.bodyFillColor,
          child:  SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                      _sectionCard(
                        title: "Basic Information",
                        isExpanded: basicInfoExpanded,
                        onTap: () {
                          setState(() {
                            basicInfoExpanded = !basicInfoExpanded;
                          });
                        },
                        child: Column(
                          children: [
                            _field("Date", widget.purchaseData["date"] ?? ""),
                            _field(
                              "Staff",
                              widget.purchaseData["staffName"] ?? "",
                            ),
                            _field(
                              "Customer",
                              widget.purchaseData["customerName"] ?? "",
                            ),
                            _field(
                              "Remarks",
                              widget.purchaseData["remarks"] ?? "",
                            ),
                            _field(
                              "Supplier",
                              (widget.purchaseData["supplier"]
                                      as Map<
                                        String,
                                        dynamic
                                      >?)?["supplierName"] ??
                                  "",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionCard(
                        title:
                            "Attachments (${(widget.purchaseData['publicUrls'] as List? ?? []).length})",
                        isExpanded: attachmentExpanded,
                        onTap: () {
                          setState(() {
                            attachmentExpanded = !attachmentExpanded;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "No Attachments",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
          ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color:AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),

        if (isExpanded) ...[
          const SizedBox(height: 15),
          child,
        ],
      ],
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value.isEmpty ? "-" : value),
          ),
        ],
      ),
    );
  }
}
