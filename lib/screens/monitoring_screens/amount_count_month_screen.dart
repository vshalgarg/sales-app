import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../constants/multiselect_item.dart';
import '../../customs/containers/bottom_model_sheet.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/monitoring_provider/graph_provider.dart';

class AmountCountMonthScreen extends StatefulWidget {
  const AmountCountMonthScreen({super.key});

  @override
  State<AmountCountMonthScreen> createState() => _AmountCountMonthScreenState();
}
class _AmountCountMonthScreenState extends State<AmountCountMonthScreen> {
  List<EntriesModel> selectedSuppliers = [];
  List<EntriesCustomerModel> selectedCustomers = [];
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  void clear() {
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedSuppliers = [];
      selectedCustomers = [];
    });
  }

  @override
  void initState(){
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<EntriesProvider>();
    final graphProvider = context.read<GraphProvider>();

    await Future.wait([provider.fetchSuppliers(), provider.fetchCustomer()]);
    await graphProvider.getMonthlyAnalytics(
      body: {
        "supplierIds": [],
        "customerIds": [],
        "fromDate": null,
        "toDate": null,
      },
    );

    setState(() {
      //  loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final graphProvider = context.watch<GraphProvider>();
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: "Amount & Count vs Month",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (_) {
                  return CustomBottomSheet(
                    onApply: () async {
                      await context.read<GraphProvider>().getMonthlyAnalytics(
                        body: {
                          "supplierIds": selectedSuppliers
                              .map((e) => e.id)
                              .toList(),

                          "customerIds": selectedCustomers
                              .map((e) => e.id)
                              .toList(),

                          "fromDate": fromDateController.text.isEmpty
                              ? null
                              : fromDateController.text,

                          "toDate": toDateController.text.isEmpty
                              ? null
                              : toDateController.text,
                        },
                      );

                      Navigator.pop(context);
                    },
                    onClear: () {
                      clear();
                    },
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Supplier",
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 18,
                          ),
                        ),
                        CustomMultiSelect<EntriesModel>(
                          hintText: "Select Suppliers",

                          items: provider.entries,

                          selectedItems: selectedSuppliers,

                          itemLabel: (e) => e.supplierName ?? "",

                          onChanged: (values) {
                            setState(() {
                              selectedSuppliers = values;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Customer",
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 18,
                          ),
                        ),
                        CustomMultiSelect<EntriesCustomerModel>(
                          hintText: "Select Customers",

                          items: provider.customerEntries,

                          selectedItems: selectedCustomers,

                          itemLabel: (e) => e.customerName ?? "",

                          onChanged: (values) {
                            setState(() {
                              selectedCustomers = values;
                            });
                          },
                        ),

                        SizedBox(height: 10),
                        Text(
                          " From Date",
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 18,
                          ),
                        ),
                        EntryDateTextField(
                          label: " From Date",
                          controller: fromDateController,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "To Date",
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 18,
                          ),
                        ),
                        EntryDateTextField(
                          label: "To Date",
                          controller: toDateController,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (graphProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (graphProvider.graphResponse == null) {
            return const Center(
              child: Text("No Data"),
            );
          }

          return const Center(
            child: Text("Data Loaded"),
          );
        },
      ),

    );
  }
}
