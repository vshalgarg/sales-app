import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
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
      final item = widget.billItem!;

      piecesController.text = item.pieces.toString();
      grossAmountController.text = item.grossAmount.toString();

      discountPercentageController.text =
          item.discountPercent.toString();

      discountAmountController.text =
          item.discountAmount.toString();

      addAmountController.text =
          item.addOnAmount.toString();

      ecrAmountController.text =
          item.ecrAmount.toString();

      gstPercentageController.text =
          item.gstPercent.toString();

      gstAmountController.text =
          item.gstAmount.toString();

      calculateValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillItemProvider>();
    return Scaffold(backgroundColor: AppColors.bodyFillColor,
      appBar:CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: widget.billItem == null
            ? "Add Bill Item"
            : "Edit Bill Item",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body:SingleChildScrollView(
        child: Column(
          children: [
            Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
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
                    Text("Taxable Value",style: TextStyle(color:Colors.white),),
                    Text(provider.taxableValue.toStringAsFixed(0),style: TextStyle(color:Colors.white)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("GST Amount",style: TextStyle(color:Colors.white)),
                    Text(provider.gstValue.toStringAsFixed(0),style: TextStyle(color:Colors.white)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Bill Amount",style: TextStyle(color:Colors.white)),
                    Text(provider.billValue.toStringAsFixed(0),style: TextStyle(color:Colors.white)),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        text: "Reset",
                        textStyle: TextStyle(color: Colors.black, fontSize: 20),
                        onPressed: () async {
                          clearFields();
                        },
                        borderRadius: 5,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomElevatedButton(
                        text: "Save",
                        textStyle: TextStyle(color: Colors.white, fontSize: 20),
                        onPressed: () async {
                          if(piecesController.text.isEmpty||grossAmountController.text.isEmpty)
                            {return ScaffoldSnackBar.show(context,"Please Enter Pieces and Gross Amount");}
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
                        borderRadius: 5,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height:30)
              ],
            ),
          ),
          ],
        ),
      ));
  }
}
