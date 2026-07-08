import 'package:flutter/material.dart';

class PurchaseDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> purchaseData;

  const PurchaseDetailsBottomSheet({super.key, required this.purchaseData});

  @override
  State<PurchaseDetailsBottomSheet> createState() =>
      _PurchaseDetailsBottomSheetState();
}

class _PurchaseDetailsBottomSheetState
    extends State<PurchaseDetailsBottomSheet> {
  bool basicInfoExpanded = true;
  bool attachmentExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9CA4DA),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9499D8), Color(0xFFB8BDE5)],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Purchase Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
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
            ],
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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF4057A6),
              borderRadius: BorderRadius.circular(8),
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
