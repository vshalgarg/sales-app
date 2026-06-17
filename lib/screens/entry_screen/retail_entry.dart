import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';
import '../../drawers/entries_drawer.dart';
import '../../entry_widgets/custom_api_textfield.dart';
import '../../entry_widgets/custom_container_entry.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../entry_widgets/custom_textfield.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../model_classes/get_staff_entry.dart';
import '../../provider/entries_provider/entries_section_provider.dart';

class RetailEntryScreen extends StatefulWidget {
  const RetailEntryScreen({super.key});

  @override
  State<RetailEntryScreen> createState() => _RetailEntryScreenState();
}

class _RetailEntryScreenState extends State<RetailEntryScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  GetStaffEntry? selectedStaff;
  EntriesCustomerModel? selectedReffered;
  List<EntriesModel?> selectedSuppliers = [null];
  List<TextEditingController> totalAmount = [TextEditingController()];
  List<TextEditingController> depositAmount = [TextEditingController()];
  List<TextEditingController> balancedAmount = [TextEditingController()];
  List<int> suppliers = [0];

  void calculateBalance(int index) {
    final total = double.tryParse(totalAmount[index].text) ?? 0.0;

    final deposit = double.tryParse(depositAmount[index].text) ?? 0.0;

    final balance = total - deposit;

    balancedAmount[index].text = balance.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    selectedSuppliers.add(null);
    totalAmount.add(TextEditingController());
    depositAmount.add(TextEditingController());
    balancedAmount.add(TextEditingController());
    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();
      await provider.fetchStaff();
      await provider.fetchCustomer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      appBar: CustomAppBar(
        title: "Retail Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      drawer: EntryDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              EntryContainer(
                children: [
                  Text(
                    "Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  EntryDateTextField(label: "Date", controller: dateController),
                  EntryTextField(
                    controller: nameController,
                    hintText: "Retailer Name",
                  ),
                  CustomApiTextField<GetStaffEntry>(
                    hintText: "Staff",
                    value: selectedStaff,
                    items: provider.staffList,
                    itemLabel: (e) => e.staffName ?? '',
                    onChanged: (value) {
                      setState(() {
                        selectedStaff = value;
                      });
                    },
                  ),
                  CustomApiTextField<EntriesCustomerModel>(
                    hintText: "Customer",
                    value: selectedReffered,
                    items: provider.customerEntries,
                    itemLabel: (e) => e.customerName ?? '',
                    onChanged: (value) {
                      setState(() {
                        selectedReffered = value;
                      });
                    },
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suppliers.length,
                itemBuilder: (context, index) => EntryContainer(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Suppliers",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CustomElevatedButton(
                          color: AppColors.primaryPurple,
                          text: "+ Add More Supplier",
                          textStyle: TextStyle(color: Colors.white),
                          onPressed: () async {
                            setState(() {
                              suppliers.add(suppliers.length);
                              totalAmount.add(TextEditingController());
                              balancedAmount.add(TextEditingController());
                              depositAmount.add(TextEditingController());

                              selectedSuppliers.add(null);
                            });
                          },
                          borderRadius: 10,
                        ),
                      ],
                    ),
                    EntryContainer(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Supplier ${index + 1} "),
                            GestureDetector(
                              onTap: () {
                                if (suppliers.length > 1) {
                                  setState(() {
                                    suppliers.removeAt(index);
                                    totalAmount.removeAt(index);
                                    balancedAmount.removeAt(index);
                                    depositAmount.removeAt(index);
                                    selectedSuppliers.removeAt(index);
                                  });
                                }
                              },
                              child: Icon(Iconsax.trash, color: Colors.red),
                            ),
                          ],
                        ),

                        CustomApiTextField<EntriesModel>(
                          hintText: "Supplier",
                          value: selectedSuppliers[index],
                          items: provider.entries,
                          itemLabel: (e) => e.supplierName ?? '',
                          onChanged: (value) {
                            setState(() {
                              selectedSuppliers[index] = value;
                            });
                          },
                        ),
                        EntryTextField(
                          controller: totalAmount[index],
                          hintText: "Total Amount",
                          onChanged: (_) {
                            calculateBalance(index);
                          },
                        ),
                        EntryTextField(
                          controller: depositAmount[index],
                          hintText: "Deposit Amount",
                          onChanged: (_) {
                            calculateBalance(index);
                          },
                        ),
                        EntryTextField(
                          controller: balancedAmount[index],
                          hintText: "Balance Amount",
                          enabled: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomElevatedButton(
                    text: "Reset",
                    textStyle: TextStyle(color: Colors.black, fontSize: 20),
                    onPressed: () async {},
                    borderRadius: 10,
                  ),
                  SizedBox(width: 20),
                  CustomElevatedButton(
                    text: "Save",
                    textStyle: TextStyle(color: Colors.white, fontSize: 20),
                    onPressed: () async {
                      final payload = {
                        "date": dateController.text,
                        "name": nameController.text,
                        "staffId": selectedStaff?.staffId,
                        "referredByCustomerId": selectedReffered?.id,
                        "suppliers": List.generate(
                          selectedSuppliers.length,
                          (index) => {
                            "supplierId": selectedSuppliers[index]?.id,
                            "totalAmount":
                                double.tryParse(totalAmount[index].text) ?? 0,
                            "depositAmount":
                                double.tryParse(depositAmount[index].text) ?? 0,
                            "balanceAmount":
                                double.tryParse(balancedAmount[index].text) ??
                                0,
                          },
                        ),
                      };

                      try {
                        final message = await provider.addRetailEntry(payload);

                        if (!context.mounted) return;
                        ScaffoldSnackBar.show(context, message??"Retail Entry Saved");

                      } catch (e) {
                        ScaffoldSnackBar.show(context, e.toString());
                      }
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
