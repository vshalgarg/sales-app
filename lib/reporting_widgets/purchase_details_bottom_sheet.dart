import 'package:flutter/material.dart';
class PurchaseDetailsBottomSheet
    extends StatelessWidget {

  final Map<String, dynamic>
  purchaseData;

  const PurchaseDetailsBottomSheet({
    super.key,
    required this.purchaseData,
  });

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
              colors: [
                Color(0xFF9499D8),
                Color(0xFFB8BDE5),
              ],
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Purchase Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
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
                        child: Column(
                          children: [
                            _field(
                              "Date",
                              purchaseData["date"] ?? "",
                            ),
                            _field(
                              "Staff",
                              purchaseData["staffName"] ?? "",
                            ),
                            _field(
                              "Customer",
                              purchaseData["customerName"] ?? "",
                            ),
                            _field(
                              "Remarks",
                              purchaseData["remarks"] ?? "",
                            ),
                            _field(
                              "Supplier",
                              (purchaseData["supplier"] as Map<String, dynamic>?)
                              ?["supplierName"] ??
                                  ""
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionCard(
                        title:
                        "Attachments (${(purchaseData['publicUrls'] as List? ?? []).length})",
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
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

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.white,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        12),
                                  ),
                                ),
                                child: const Text(
                                  "Back",
                                  style: TextStyle(
                                    color:
                                    Color(0xFF35539C),
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.white,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        12),
                                  ),
                                ),
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                    color:
                                    Color(0xFF35539C),
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
  }) {
    return Column(
      children: [
        Container(
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
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        child,
      ],
    );
  }

  Widget _field(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(6),
            ),
            child: Text(
              value.isEmpty ? "-" : value,
            ),
          ),
        ],
      ),
    );
  }
}