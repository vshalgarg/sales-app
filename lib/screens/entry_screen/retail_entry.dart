
import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/dropdown_test.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';
import '../../entry_widgets/custom_container_entry.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../entry_widgets/custom_textfield.dart';
import '../../model_classes/entries/entries_customer_model.dart';
import '../../model_classes/entries/get_staff_entry.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/entries_provider/entries_section_provider.dart';

class RetailEntryScreen extends StatefulWidget {
  const RetailEntryScreen({super.key});

  @override
  State<RetailEntryScreen> createState() => _RetailEntryScreenState();
}
class _RetailEntryScreenState extends State<RetailEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  GetStaffEntry? selectedStaff;
  String?selectedStaffName;
  EntriesCustomerModel? selectedReffered;
  String?selectedRefferedName;
  final transactionController = TextEditingController();
  List<String?> selectedSuppliers = [null];
  List<int?> selectedSupplierIds = [null];
  String?selectedSupplierName;
  List<TextEditingController> totalAmount = [TextEditingController()];
  List<TextEditingController> depositAmount = [TextEditingController()];
  List<TextEditingController> balancedAmount = [TextEditingController()];
  List<int> suppliers = [0];
  bool isExpanded = true;
  bool isSupplierExpanded = false;
  void clearFields() {
    _formKey.currentState?.reset();

    dateController.clear();
    nameController.clear();

    setState(() {
      selectedStaff = null;
      selectedReffered = null;

      suppliers = [0];
      selectedSuppliers = [null];
      selectedSupplierIds = [null];
      totalAmount = [TextEditingController()];
      depositAmount = [TextEditingController()];
      balancedAmount = [TextEditingController()];

      isExpanded = true;
      isSupplierExpanded = true;
    });
  }
  void calculateBalance(int index) {
    final total = double.tryParse(totalAmount[index].text) ?? 0.0;

    final deposit = double.tryParse(depositAmount[index].text) ?? 0.0;

    final balance = total - deposit;
    balancedAmount[index].text = balance.toStringAsFixed(2);
  }


  @override
  void initState() {
    super.initState();

    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();
      await Future.wait([
        provider.fetchStaff(),
        provider.fetchCustomer(),
        provider.fetchSuppliers(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        title: "Retail Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ExitConfirmationDialog.show(
                context,
                onSave: () async {
                  Navigator.pop(context);
                },discardButtonText: "Leave",
                saveButtonText: "Stay",
                onDiscard: () {
                  Navigator.pop(context);
                  Navigator.pop(context,true);
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children:[ Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          filled: true,
                          suffixIcon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          fillColor: AppColors.primaryPurple,
                          hintText: "Information",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    EntryContainer(
                      children: [
                        if (isExpanded) ...[
                          SizedBox(height: 15),
                          Text(
                            "Date",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          EntryDateTextField(
                            label: "Date",
                            controller: dateController,
                              validator: (value) {
                                if (value == null || value
                                    .trim()
                                    .isEmpty) {
                                  return "Please enter date";
                                }
                                return null;
                              }
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Retailer Name",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          EntryTextField(
                            controller: nameController,
                            hintText: "Retailer Name*",
                              validator: (value) {
                                if (value == null || value
                                    .trim()
                                    .isEmpty) {
                                  return "Please enter a retailer name";
                                }
                                return null;
                              }
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Staff",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          CustomDropdown(
                            hintText: "Staff",
                            initialValue: selectedStaffName,
                            items: provider.staffList.map((e)=>e.staffName??'')
                              .toList(),
                            onChanged: (value) {
                              final staff = provider.staffList.firstWhere(
                                    (e) => e.staffName == value,
                              );

                              setState(() {
                                selectedStaffName = value;
                                selectedStaff = staff;
                              });
                            },
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Customer",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          CustomDropdown(
                            hintText: "Customer",
                            initialValue: selectedRefferedName,
                            items: provider.customerEntries
                                .map((e) => e.customerName ?? '')
                                .toList(),
                            validator: (value) {
                              if (value == null) {
                                return "Please select at least one customer";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              final customer = provider.customerEntries.firstWhere(
                                    (e) => e.customerName == value,
                              );

                              setState(() {
                                selectedRefferedName = value;
                                selectedReffered = customer;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSupplierExpanded = !isSupplierExpanded;
                        });
                      },
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          filled: true,
                          suffixIcon: Icon(
                            isSupplierExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          fillColor: AppColors.primaryPurple,
                          hintText: "Suppliers",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),

                        ),
                      ),
                    ),
                    if (isSupplierExpanded) ...[
                      SizedBox(height: 15),
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
                            selectedSupplierIds.add(null);
                          });
                        },
                        borderRadius: 5,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: suppliers.length,
                        itemBuilder: (context, index) => EntryContainer(
                          children: [
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Supplier ${index + 1} ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                if (suppliers.length > 1)
                                GestureDetector(
                                  onTap: () {
                                    {setState(() {
                                        suppliers.removeAt(index);
                                        totalAmount.removeAt(index);
                                        balancedAmount.removeAt(index);
                                        selectedSuppliers.removeAt(index);
                                        selectedSupplierIds.removeAt(index);
                                      });
                                    }
                                  },
                                  child: Icon(Iconsax.trash, color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Supplier",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            CustomDropdown(
                              hintText: index == 0 ? "Supplier *" : "Supplier",
                              validator: (value) {
                                if (index == 0 && (value == null || value.isEmpty)) {
                                  return "Please select at least one supplier";
                                }
                                return null;
                              },
                              initialValue: selectedSuppliers[index],
                              items: provider.entries
                                  .map((e) => e.supplierName ?? '')
                                  .toList(),
                              onChanged: (value) {
                                final supplier = provider.entries.firstWhere(
                                      (e) => e.supplierName == value,
                                );

                                setState(() {
                                  selectedSuppliers[index] = value;
                                  selectedSupplierIds[index] = supplier.id?.toInt();
                                });
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Total Amount",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            EntryTextField(integerOnly: true,
                              controller: totalAmount[index],
                              hintText: "Total Amount",
                              onChanged: (_) {
                                calculateBalance(index);
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Deposit Amount",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            EntryTextField(integerOnly: true,
                              controller: depositAmount[index],
                              hintText: "Deposit Amount",
                              onChanged: (_) {
                                calculateBalance(index);
                              },
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Balance Amount",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            EntryTextField(integerOnly: true,
                              controller: balancedAmount[index],
                              hintText: "Balance Amount",
                              enabled: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            text: "Reset",
                            textStyle: TextStyle(color: Colors.black, fontSize: 20),
                            onPressed: ()async{
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
                              if (!_formKey.currentState!.validate()) {
                                ScaffoldSnackBar.show(
                                  context,
                                  "Please fill all the required fields",
                                );
                                return;
                              }

                              final payload = {
                                "date": dateController.text,
                                "name": nameController.text,
                                "staffId": selectedStaff?.staffId,
                                "referredByCustomerId": selectedReffered?.id,
                                "suppliers": List.generate(
                                  selectedSuppliers.length,
                                  (index) => {
                                    "supplierId": selectedSupplierIds[index],
                                    "totalAmount":
                                        double.tryParse(totalAmount[index].text) ??
                                        0,
                                    "depositAmount":
                                        double.tryParse(
                                          depositAmount[index].text,
                                        ) ??
                                        0,
                                    "balanceAmount":
                                        double.tryParse(
                                          balancedAmount[index].text,
                                        ) ??
                                        0,
                                  },
                                ),
                              };

                              try {
                                final message = await provider.addRetailEntry(
                                  payload,
                                );

                                if (!context.mounted) return;
                                ScaffoldSnackBar.show(
                                  context,
                                    "Retail Entry Saved",
                                );
                                Navigator.pop(context,true);
                              } catch (e) {
                                ScaffoldSnackBar.show(context, e.toString());
                              }
                            },
                            borderRadius: 5,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),Consumer<EntriesProvider>(
          builder: (context, provider, child) {
            if (!provider.isLoading) {
              return const SizedBox.shrink();
            }

            return Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        )],
      ),
    );
  }
}
