import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import '../../constants/colors_used.dart';
import '../../customs/containers/bottom_model_sheet.dart';
import '../../entry_widgets/custom_date_textfield.dart';

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
  Widget build(BuildContext context) {
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
                    onApply: (){},
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
    );
  }
}
