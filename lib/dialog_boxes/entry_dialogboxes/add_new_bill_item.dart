import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../model_classes/bills/bill_item_model.dart';
import '../../provider/entries_provider/add_bill_item_calculation.dart';

class AddNewBillItem extends StatefulWidget {
  final BillItem? billItem;

  const AddNewBillItem({super.key, this.billItem});

  @override
  State<AddNewBillItem> createState() => _AddNewBillItemState();
}

class _AddNewBillItemState extends State<AddNewBillItem> {
  bool showBillDetails = true;
  bool showDiscountDetails = true;
  bool showAddOnCharges = true;
  bool showGstDetails = true;
  final piecesController = TextEditingController();
  final grossAmountController = TextEditingController();
  final discountPercentageController = TextEditingController();
  final discountAmountController = TextEditingController();
  final addAmountController = TextEditingController();
  final ecrAmountController = TextEditingController();
  final gstPercentageController = TextEditingController();
  final gstAmountController = TextEditingController();

  void calculateValues() {
    final provider = context.read<BillItemProvider>();

    provider.calculate(
      grossAmount: grossAmountController.text,
      discountPercentage: discountPercentageController.text,
      addAmount: addAmountController.text,
      ecrAmount: ecrAmountController.text,
      gstPercentage: gstPercentageController.text,
    );

    discountAmountController.text = provider.discountAmount.toStringAsFixed(2);

    gstAmountController.text = provider.gstAmount.toStringAsFixed(2);
  }

  void clearFields() {
    piecesController.clear();
    grossAmountController.clear();
    discountPercentageController.clear();
    discountAmountController.clear();
    addAmountController.clear();
    ecrAmountController.clear();
    gstPercentageController.clear();
    gstAmountController.clear();

    context.read<BillItemProvider>().reset();
  }

  Widget _summaryRow({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool smallScreen = width < 360;

        final double iconBoxSize = smallScreen ? 46 : 52;
        final double iconSize = smallScreen ? 24 : 28;
        final double titleSize = smallScreen ? 16 : 18;
        final double valueSize = smallScreen ? 17 : 20;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: smallScreen ? 12 : 16,
            vertical: smallScreen ? 11 : 14,
          ),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
              bottom: BorderSide(
                color: Color(0xFFE5E3EC),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ICON
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(
                    smallScreen ? 12 : 14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryPurple,
                  size: iconSize,
                ),
              ),

              SizedBox(
                width: smallScreen ? 12 : 16,
              ),

              // TITLE
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF11132A),
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(
                width: smallScreen ? 8 : 12,
              ),
              // VALUE
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: valueSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Expanded(
      child: SizedBox(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: isPrimary
                    ? null
                    : Border.all(color: const Color(0xFFE0DEEA), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: isPrimary ? Colors.white : AppColors.primaryPurple,
                  ),

                  const SizedBox(width: 10),

                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isPrimary
                              ? Colors.white
                              : AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 70),
            padding: EdgeInsets.symmetric(
              horizontal: width < 360 ? 14 : 20,
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: width < 360 ? 42 : 48,
                  width: width < 360 ? 42 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: width < 360 ? 23 : 27,
                  ),
                ),

                SizedBox(width: width < 360 ? 10 : 15),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width < 360 ? 16 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: width < 360 ? 28 : 32,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _billItemInput({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    bool enabled = true,
    bool integerOnly = false,
    bool decimalAllowed = false,
    VoidCallback? onChanged,
    bool isLast = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive sizes
        final iconSize = width < 360 ? 40.0 : 42.0;
        final iconContainer = width < 360 ? 40.0 : 42.0;
        final titleSize = width < 360 ? 16.0 : 16.0;
        final subtitleSize = width < 360 ? 12.0 : 12.0;
        final inputHeight = width < 360 ? 58.0 : 64.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: width < 360 ? 12 : 18,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: Color(0xFFE8E6EF), width: 1),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ICON
              Container(
                height: iconContainer,
                width: iconContainer,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha:0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryPurple,
                  size: iconSize * 0.55,
                ),
              ),

              SizedBox(width: width < 360 ? 10 : 14),
              // TITLE + SUBTITLE
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF11132A),
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF5E6280),
                        fontSize: subtitleSize,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: width < 360 ? 8 : 12),
              // INPUT
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: inputHeight,
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    textAlign: TextAlign.right,
                    keyboardType: integerOnly
                        ? TextInputType.number
                        : decimalAllowed
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                    onChanged: (_) {
                      onChanged?.call();
                    },
                    style: TextStyle(
                      color: const Color(0xFF5E6280),
                      fontSize: width < 360 ? 16 : 18,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width < 360 ? 10 : 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFDCD9E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFDCD9E8)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFDCD9E8)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.billItem != null) {
      final item = widget.billItem!;

      piecesController.text = item.pieces.toString();
      grossAmountController.text = item.grossAmount.toString();

      discountPercentageController.text = item.discountPercent.toString();

      discountAmountController.text = item.discountAmount.toString();

      addAmountController.text = item.addOnAmount.toString();

      ecrAmountController.text = item.ecrAmount.toString();

      gstPercentageController.text = item.gstPercent.toString();

      gstAmountController.text = item.gstAmount.toString();

      calculateValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillItemProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: widget.billItem == null ? "Add Bill Item" : "Edit Bill Item",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 360 ? 8 : 12,
                vertical: 12,
              ),
              child: Column(
                children: [
                  // BILL DETAILS
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          icon: Icons.receipt_long,
                          title: "Bill Details",
                          isExpanded: showBillDetails,
                          onTap: () {
                            setState(() {
                              showBillDetails = !showBillDetails;
                            });
                          },
                        ),

                        if (showBillDetails) ...[
                          _billItemInput(
                            icon: Icons.inventory_2_outlined,
                            title: "Pieces * ",
                            subtitle: "Enter number of pieces",
                            controller: piecesController,
                            integerOnly: true,
                          ),

                          _billItemInput(
                            icon: Icons.currency_rupee,
                            title: "Gross Amount * ",
                            subtitle: "Enter gross amount",
                            controller: grossAmountController,
                            integerOnly: true,
                            onChanged: calculateValues,
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // DISCOUNT DETAILS
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          icon: Icons.percent,
                          title: "Discount Details",
                          isExpanded: showDiscountDetails,
                          onTap: () {
                            setState(() {
                              showDiscountDetails = !showDiscountDetails;
                            });
                          },
                        ),

                        if (showDiscountDetails) ...[
                          _billItemInput(
                            icon: Icons.percent,
                            title: "Discount %",
                            subtitle: "Enter discount percentage",
                            controller: discountPercentageController,
                            decimalAllowed: true,
                            onChanged: calculateValues,
                          ),

                          _billItemInput(
                            icon: Icons.discount_outlined,
                            title: "Discount Amount",
                            subtitle: "Auto calculated",
                            controller: discountAmountController,
                            enabled: false,
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ADD ON CHARGES
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          icon: Icons.add_box_outlined,
                          title: "Add On Charges",
                          isExpanded: showAddOnCharges,
                          onTap: () {
                            setState(() {
                              showAddOnCharges = !showAddOnCharges;
                            });
                          },
                        ),

                        if (showAddOnCharges) ...[
                          _billItemInput(
                            icon: Icons.currency_rupee,
                            title: "Add-On Amount",
                            subtitle: "Enter add-on amount",
                            controller: addAmountController,
                            decimalAllowed: true,
                            onChanged: calculateValues,
                          ),

                          _billItemInput(
                            icon: Icons.credit_card_outlined,
                            title: "ECR Amount",
                            subtitle: "Enter ECR amount",
                            controller: ecrAmountController,
                            decimalAllowed: true,
                            onChanged: calculateValues,
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // GST DETAILS
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          icon: Icons.percent,
                          title: "GST Details",
                          isExpanded: showGstDetails,
                          onTap: () {
                            setState(() {
                              showGstDetails = !showGstDetails;
                            });
                          },
                        ),

                        if (showGstDetails) ...[
                          _billItemInput(
                            icon: Icons.percent,
                            title: "GST %",
                            subtitle: "Enter GST percentage",
                            controller: gstPercentageController,
                            decimalAllowed: true,
                            onChanged: calculateValues,
                          ),

                          _billItemInput(
                            icon: Icons.calculate_outlined,
                            title: "GST Amount",
                            subtitle: "Auto calculated",
                            controller: gstAmountController,
                            enabled: false,
                            isLast: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // TOTAL SUMMARY
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // PURPLE HEADER
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final smallScreen = width < 360;

                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: smallScreen ? 14 : 20,
                                vertical: smallScreen ? 11 : 12,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPurple,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: smallScreen ? 44 : 48,
                                    height: smallScreen ? 44 : 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha:0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.pie_chart,
                                      color: Colors.white,
                                      size: smallScreen ? 25 : 28,
                                    ),
                                  ),

                                  SizedBox(
                                    width: smallScreen ? 12 : 15,
                                  ),

                                  Expanded(
                                    child: Text(
                                      "Total Summary",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: smallScreen ? 18 : 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // SUMMARY ROWS
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Column(
                            children: [
                              _summaryRow(
                                icon: Icons.calculate_outlined,
                                title: "Taxable Value",
                                value: provider.taxableValue.toStringAsFixed(2),
                              ),

                              _summaryRow(
                                icon: Icons.percent,
                                title: "GST Amount",
                                value: provider.gstValue.toStringAsFixed(2),
                              ),

                              _summaryRow(
                                icon: Icons.account_balance_wallet_outlined,
                                title: "Bill Amount",
                                value: provider.billValue.toStringAsFixed(2),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RESET + SAVE
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        _buildBottomButton(
                          icon: Icons.refresh,
                          title: "Reset",
                          isPrimary: false,
                          onTap: () {
                            clearFields();
                          },
                        ),

                        const SizedBox(width: 16),

                        _buildBottomButton(
                          icon: Icons.save_outlined,
                          title: "Save",
                          isPrimary: true,
                          onTap: () async {
                            final pieces = int.tryParse(piecesController.text.trim());
                            final grossAmount = double.tryParse(grossAmountController.text.trim());

                            if (grossAmount == null || grossAmount <= 0) {
                              return ScaffoldSnackBar.show(
                                context,
                                "Gross Amount is required and must be greater than zero",
                              );
                            }
                            if (pieces == null || pieces<=0) {
                              return ScaffoldSnackBar.show(
                                context,
                                "Please enter at least 1 piece",
                              );
                            }
                            final provider = context.read<BillItemProvider>();

                            final item = BillItem(
                              pieces: int.tryParse(piecesController.text) ?? 0,

                              grossAmount:
                                  double.tryParse(grossAmountController.text) ??
                                  0,

                              discountPercent:
                                  double.tryParse(
                                    discountPercentageController.text,
                                  ) ??
                                  0,

                              discountAmount:
                                  double.tryParse(
                                    discountAmountController.text,
                                  ) ??
                                  0,

                              addOnAmount:
                                  double.tryParse(addAmountController.text) ??
                                  0,

                              ecrAmount:
                                  double.tryParse(ecrAmountController.text) ??
                                  0,

                              gstPercent:
                                  double.tryParse(
                                    gstPercentageController.text,
                                  ) ??
                                  0,

                              gstAmount:
                                  double.tryParse(gstAmountController.text) ??
                                  0,

                              taxableValue: provider.taxableValue,
                              totalAmount: provider.billValue,
                            );

                            Navigator.pop(context, item);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
