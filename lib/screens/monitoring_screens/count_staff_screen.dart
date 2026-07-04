import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/containers/bottom_model_sheet.dart';
import '../../customs/donuts_charts.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../provider/monitoring_provider/graph_provider.dart';

class CountStaffScreen extends StatefulWidget {
  const CountStaffScreen({super.key});

  @override
  State<CountStaffScreen> createState() => _CountStaffScreenState();
}

class _CountStaffScreenState extends State<CountStaffScreen> {
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  void clear() {
    setState(() {
      fromDateController.clear();
      toDateController.clear();
    });
  }
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<GraphProvider>().getStaffAnalytics(
        body: {
          "fromDate": "2026-01-01",
          "toDate": "2026-12-31",
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: "Count vs Staff",
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

                        context.read<GraphProvider>().getStaffAnalytics(
                          body: {
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
        builder: (context, provider, child) {


      if (provider.isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (provider.error != null) {
        return Center(
          child: Text(provider.error!),
        );
      }

      if (provider.analytics == null) {
        return const Center(
          child: Text("No Data Found"),
        );
      }


      return SingleChildScrollView(
        child: Column(
          children: [

            StaffDonutChart(
              title: "Supplier Count vs Staff",
              chartData: provider.analytics!.supplierVsStaff,
            ),

            StaffDonutChart(
              title: "Customer Count vs Staff",
              chartData: provider.analytics!.customerVsStaff,
            ),

            StaffDonutChart(
              title: "Supplier + Customer Count vs Staff",
              chartData: provider.analytics!.supplierAndCustomerVsStaff,
            ),
            SizedBox(height:40)

          ],
        ),
      );
    },
    ),
    );
  }
}
