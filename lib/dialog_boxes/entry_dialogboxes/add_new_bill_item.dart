import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';
import '../../entry_widgets/custom_container_entry.dart';
import '../../entry_widgets/custom_textfield.dart';
import '../../model_classes/bill_item_model.dart';
import '../../provider/entries_provider/add_bill_item_calculation.dart';

class AddNewBillItem extends StatefulWidget {
  final BillItem? billItem;

  const AddNewBillItem({super.key, this.billItem});

  @override
  State<AddNewBillItem> createState() => _AddNewBillItemState();
}

class _AddNewBillItemState extends State<AddNewBillItem> {
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

  @override
  void initState() {
    super.initState();

    if (widget.billItem != null) {
      piecesController.text = widget.billItem!.pieces.toString();
      grossAmountController.text = widget.billItem!.grossAmount.toString();

      gstPercentageController.text = widget.billItem!.gstAmount.toString();

      calculateValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillItemProvider>();
    return Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Bill Item",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              EntryContainer(
                children: [
                  Text(
                    "Bill Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  EntryTextField(
                    controller: piecesController,
                    hintText: "Pieces",
                    integerOnly: true,
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    controller: grossAmountController,
                    hintText: "Gross Amount",
                    integerOnly: true,
                  //  decimalAllowed: true,
                    onChanged: (_) => calculateValues(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              EntryContainer(
                children: [
                  Text(
                    "Add Discount",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  EntryTextField(
                    controller: discountPercentageController,
                    hintText: "Discount %",
                    integerOnly: true,
                    decimalAllowed: true,
                    onChanged: (_) => calculateValues(),
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    enabled: false,
                    controller: discountAmountController,
                    hintText: "Discount Amount",
                    onChanged: (_) => calculateValues(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              EntryContainer(
                children: [
                  Text(
                    "Add On Charges",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  EntryTextField(
                    controller: addAmountController,
                    hintText: "Add Amount",
                    integerOnly: true,
                    decimalAllowed: true,
                    onChanged: (_) => calculateValues(),
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    controller: ecrAmountController,
                    hintText: "ECR Amount",
                    integerOnly: true,
                    decimalAllowed: true,
                    onChanged: (_) => calculateValues(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              EntryContainer(
                children: [
                  Text(
                    "Add Gst Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  EntryTextField(
                    controller: gstPercentageController,
                    hintText: "GST %",
                    integerOnly: true,
                    decimalAllowed: true,
                    onChanged: (_) => calculateValues(),
                  ),
                  SizedBox(height: 10),
                  EntryTextField(
                    enabled: false,
                    controller: gstAmountController,
                    hintText: "GST Amount",
                    onChanged: (_) => calculateValues(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Taxable Value"),
                  Text(provider.taxableValue.toStringAsFixed(0)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("GST Amount"),
                  Text(provider.gstValue.toStringAsFixed(0)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bill Amount"),
                  Text(provider.billValue.toStringAsFixed(0)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomElevatedButton(
                    text: "Reset",
                    textStyle: TextStyle(color: Colors.black, fontSize: 10),
                    onPressed: () async {
                      clearFields();
                    },
                    borderRadius: 10,
                  ),
                  SizedBox(width: 20),
                  CustomElevatedButton(
                    text: "Save",
                    textStyle: TextStyle(color: Colors.white, fontSize: 10),
                    onPressed: () async {
                      final provider = context.read<BillItemProvider>();

                      final item = BillItem(
                        pieces: int.tryParse(piecesController.text) ?? 0,
                        grossAmount:
                            double.tryParse(grossAmountController.text) ?? 0,

                        discountPercent:
                            double.tryParse(
                              discountPercentageController.text,
                            ) ??
                            0,

                        discountAmount:
                            double.tryParse(discountAmountController.text) ?? 0,

                        addOnAmount:
                            double.tryParse(addAmountController.text) ?? 0,

                        ecrAmount:
                            double.tryParse(ecrAmountController.text) ?? 0,

                        gstPercent:
                            double.tryParse(gstPercentageController.text) ?? 0,

                        gstAmount:
                            double.tryParse(gstAmountController.text) ?? 0,

                        taxableValue: provider.taxableValue,
                        totalAmount: provider.billValue,
                      );
                      Navigator.pop(context, item);
                    },
                    borderRadius: 10,
                    color: AppColors.primaryPurple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
