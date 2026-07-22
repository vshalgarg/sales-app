import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors_used.dart';
import '../customs/app_bar.dart';

class BillDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const BillDetailsScreen({super.key, required this.data});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  double taxableValue = 0;
  double billAmount = 0;
  bool showBillInfo = true;
  bool showSupplierInfo = false;
  bool showCustomerInfo = false;
  bool showBillItems = false;
  bool showTransportInfo = false;
  bool showAttachments = false;
  List<Map<String, dynamic>> items = [];
  @override
  void initState() {
    super.initState();
    taxableValue = (widget.data['taxableValue'] ?? 0).toDouble();
    billAmount = (widget.data['billAmount'] ?? 0).toDouble();
    items = List<Map<String, dynamic>>.from(widget.data['items'] ?? []);
    if (items.isEmpty) {
      items.add({
        "pieces": "",
        "grossAmount": "",
        "discountPercent": "",
        "discountAmount": "",
        "addOnAmount": "",
        "ecrAmount": "",
        "gstPercent": "",
        "gstAmount": "",
      });
    }

    _calculateTotals();

  }
  void _calculateTotals() {
    double taxable = 0;
    double total = 0;

    for (final item in items) {
      final gross =
          double.tryParse(item['grossAmount']?.toString() ?? '0') ?? 0;

      final discount =
          double.tryParse(item['discountAmount']?.toString() ?? '0') ?? 0;

      final addOn =
          double.tryParse(item['addOnAmount']?.toString() ?? '0') ?? 0;

      final ecr =
          double.tryParse(item['ecrAmount']?.toString() ?? '0') ?? 0;

      final gst =
          double.tryParse(item['gstAmount']?.toString() ?? '0') ?? 0;

      final taxableItem = gross - discount + addOn - ecr;

      taxable += taxableItem;
      total += taxableItem + gst;
    }

    taxableValue = taxable;
    billAmount = total;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: "Bill Details",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      title: "Bill Information",
                      expanded: showBillInfo,
                      onTap: () {
                        setState(() {
                          showBillInfo = !showBillInfo;
                        });
                      },
                    ),
                    if (showBillInfo) ...[
                      const SizedBox(height: 16),
                      _detailRow(
                        "Bill Number",
                        widget.data['billNumber'] ?? "",
                        "Bill Date",
                        widget.data['date'] ?? "",
                      ),

                      _detailRow(
                        "Received Date",
                        widget.data['receivedDate'] ?? "",
                        "Invoice Number",
                        widget.data['invoiceNo'] ?? "",
                      ),
                    ],
                    const SizedBox(height: 15),

                    _sectionTitle(
                      title: "Supplier Information",
                      expanded: showSupplierInfo,
                      onTap: () {
                        setState(() {
                          showSupplierInfo = !showSupplierInfo;
                        });
                      },
                    ),
                    if (showSupplierInfo) ...[
                      const SizedBox(height: 16),
                      _detailRow(
                        "Supplier Name",
                        widget.data['supplierName'] ?? "",
                        "Supplier Group",
                        widget.data['supplierGroup'] ?? "",
                      ),

                      _detailRow(
                        "MSME",
                        widget.data['supplierMsme'] ?? "",
                        "GSTIN",
                        widget.data['supplierGstNo'] ?? "",
                      ),
                    ],
                    const SizedBox(height: 15),

                    _sectionTitle(
                      title: "Customer Information",
                      expanded: showCustomerInfo,
                      onTap: () {
                        setState(() {
                          showCustomerInfo = !showCustomerInfo;
                        });
                      },
                    ),
                    if (showCustomerInfo) ...[
                      const SizedBox(height: 16),
                      _detailRow(
                        "Customer Name",
                        widget.data['customerName'] ?? "",
                        "Customer Group",
                        widget.data['customerGroup'] ?? "",
                      ),

                      _detailRow(
                        "MSME",
                        widget.data['customerMsme'] ?? "",
                        "GSTIN",
                        widget.data['customerGstNo'] ?? "",
                      ),
                    ],
                    const SizedBox(height: 15),

                    _sectionTitle(
                      title: "Bill Items",
                      expanded: showBillItems,
                      onTap: () {
                        setState(() {
                          showBillItems = !showBillItems;
                        });
                      },
                    ),

                    if (showBillItems) ...[
                      Builder(
                        builder: (context) {
                          final items = List<Map<String, dynamic>>.from(
                            widget.data['items'] ?? [],
                          );

                          final displayItems = items.isEmpty
                              ? [
                                  {
                                    "pieces": 0,
                                    "grossAmount": 0,
                                    "discountPercent": 0,
                                    "discountAmount": 0,
                                    "addOnAmount": 0,
                                    "ecrAmount": 0,
                                    "gstPercent": 0,
                                    "gstAmount": 0,
                                  },
                                ]
                              : items;

                          return Column(
                            children: displayItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16,top:15),
                               // padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                 // color: Colors.white.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:AppColors.primaryPurple,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        "Item ${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: _billField(
                                            "Pieces",
                                            "${item['pieces'] ?? 0}",
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _billField(
                                            "Gross Amount",
                                            "${item['grossAmount'] ?? 0}",
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: _billField(
                                            "Disc %",
                                            "${item['discountPercent'] ?? 0}",
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _billField(
                                            "Disc Amount",
                                            "${item['discountAmount'] ?? 0}",
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: _billField(
                                            "Add-On",
                                            "${item['addOnAmount'] ?? 0}",
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _billField(
                                            "ECR",
                                            "${item['ecrAmount'] ?? 0}",
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: _billField(
                                            "GST %",
                                            "${item['gstPercent'] ?? 0}",
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _billField(
                                            "GST Amount",
                                            "${item['gstAmount'] ?? 0}",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      Container(
                       // padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          //color: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Taxable Value",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                  Text(
                              "₹${taxableValue.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(color: Colors.white38, height: 24),

                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Bill Amount",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  "₹${billAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),

                    _sectionTitle(
                      title: "Transport & Logistics Information",
                      expanded: showTransportInfo,
                      onTap: () {
                        setState(() {
                          showTransportInfo = !showTransportInfo;
                        });
                      },
                    ),

                    if (showTransportInfo) ...[
                      const SizedBox(height: 16),
                      _field("Transport", widget.data['transport'] ?? "-"),

                      const SizedBox(height: 16),

                      _field("LR Number", widget.data['lrNumber'] ?? "-"),

                      const SizedBox(height: 16),

                      _field("Remarks", widget.data['remarks'] ?? "-"),
                    ],

                    const SizedBox(height: 15),

                    _sectionTitle(
                      title: "Attachments",
                      expanded: showAttachments,
                      onTap: () {
                        setState(() {
                          showAttachments = !showAttachments;
                        });
                      },
                    ),
                    if (showAttachments) ...[
                      SizedBox(height:16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Builder(
                          builder: (context) {
                            final publicUrls = List<String>.from(
                              widget.data['publicUrls'] ?? [],
                            );

                            if (publicUrls.isEmpty) {
                              return Container(
                                height: 150,
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: AppColors.primaryPurple,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "No Attachments Found",
                                      style: TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: publicUrls.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3.2,
                                  ),
                              itemBuilder: (context, index) {
                                final imageUrl = publicUrls[index];

                                final fileName =
                                    (widget.data['originalFileNames'] != null &&
                                        index <
                                            (widget.data['originalFileNames']
                                                    as List)
                                                .length)
                                    ? widget.data['originalFileNames'][index]
                                    : 'Attachment ${index + 1}';

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fileName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () async {
                                          await launchUrl(
                                            Uri.parse(imageUrl),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.blue,
                                            size: 22,
                                          ),
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () async {
                                          await launchUrl(
                                            Uri.parse(imageUrl),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Icon(
                                            Icons.download,
                                            color: Colors.green,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
          )
          ),
        ),
      );
  }

  Widget _sectionTitle({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        //margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
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
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(child: _field(leftLabel, leftValue)),

          const SizedBox(width: 20),

          Expanded(child: _field(rightLabel, rightValue)),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
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
    );
  }

  Widget _billField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
