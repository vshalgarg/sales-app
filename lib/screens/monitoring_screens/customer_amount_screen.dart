import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../constants/multiselect_item.dart';
import '../../customs/supplier_charts_amount_monitoring.dart';
import '../../customs/containers/bottom_model_sheet.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/monitoring_provider/graph_provider.dart';

class CustomerAmountScreen extends StatefulWidget {
  const CustomerAmountScreen({super.key});

  @override
  State<CustomerAmountScreen> createState() => _CustomerAmountScreenState();
}

class _CustomerAmountScreenState extends State<CustomerAmountScreen> {
  List<EntriesCustomerModel> selectedCustomers = [];
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  void clear() {
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedCustomers = [];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    Future.microtask(() {
      context.read<GraphProvider>().getCustomerAmount(
        body: {
          "customerIds": [],
          "fromDate": "",
          "toDate": "",
        },
      );
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<EntriesProvider>();

    await Future.wait([provider.fetchCustomer()]);

    setState(() {
      //  loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
        title: "Customer vs Amount",
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
                    onApply: () {
                      final body = {
                        "customerIds": selectedCustomers.map((e) => e.id).toList(),
                        "fromDate": fromDateController.text,
                        "toDate": toDateController.text,
                      };

                      print(body);
                      context.read<GraphProvider>().getCustomerAmount(
                        body: {

                          "customerIds":
                          selectedCustomers
                              .map((e) => e.id)
                              .toList(),

                          "fromDate": fromDateController.text,

                          "toDate": toDateController.text,
                        },
                      );

                      Navigator.pop(context);
                    },
                    onClear: (){clear();},
                    content: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            color:AppColors.primaryPurple,
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
      body: Consumer<GraphProvider>(
        builder: (context, graphProvider, child) {
          if (graphProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (graphProvider.error != null) {
            return Center(
              child: Text(graphProvider.error!),
            );
          }

          if (graphProvider.response == null) {
            return const Center(
              child: Text("No Data"),
            );
          }

          return AmountChartData(
            title: "Customer vs Amount",
            chartData: graphProvider.customerResponse!.chartData,
          );
        },
      ),
    );
  }
}
