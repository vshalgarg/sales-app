import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../constants/multiselect_item.dart';
import '../../customs/supplier_charts_amount_monitoring.dart';
import '../../customs/containers/bottom_model_sheet.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../model_classes/entries_supplier.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/monitoring_provider/graph_provider.dart';

class SupplierAmountScreen extends StatefulWidget {
  const SupplierAmountScreen({super.key});

  @override
  State<SupplierAmountScreen> createState() => _SupplierAmountScreenState();
}

class _SupplierAmountScreenState extends State<SupplierAmountScreen> {
  List<EntriesModel> selectedSuppliers = [];
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  void clear() {
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedSuppliers = [];
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData();

    Future.microtask(() {
      context.read<GraphProvider>().getSupplierAmount(
        body: {
          "supplierIds": [],
          "fromDate": "",
          "toDate": "",
        },
      );
    });
  }
  Future<void> _loadData() async {
    final provider = context.read<EntriesProvider>();

    await Future.wait([provider.fetchSuppliers(),]);
    print("Supplier Count: ${provider.entries.length}");
    print(provider.entries);


    setState(() {
      //  loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
        title: "Supplier vs Amount",
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

                        context.read<GraphProvider>().getSupplierAmount(
                          body: {

                            "supplierIds":
                            selectedSuppliers
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
            title: "Supplier vs Amount",
            chartData: graphProvider.response!.chartData,
          );
        },
      ),
    );
  }
}
