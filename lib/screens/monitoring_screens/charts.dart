import 'package:flutter/material.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../constants/multiselect_item.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../model_classes/entries_customer_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../provider/entries_provider/entries_section_provider.dart';

class Monitoring extends StatefulWidget {
  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<EntriesProvider>();

    await Future.wait([provider.fetchSuppliers(), provider.fetchCustomer()]);

    setState(() {
      loading = false;
    });
  }

  bool loading = true;
  List<EntriesModel> selectedSuppliers=[];
  List<EntriesCustomerModel> selectedCustomers = [];
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Monitoring",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
       body: loading
    ? const Center(child: CircularProgressIndicator())
           : Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  iconColor: Colors.white,
                  filled: true,
                  fillColor: AppColors.primaryPurple,
                  hintText: "Amount & Count vs Month",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Supplier",
                style: TextStyle(color: Colors.white, fontSize: 18),
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
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              CustomMultiSelect<EntriesCustomerModel>(
                hintText: "Select Customers",

                items: provider.customerEntries,

                selectedItems: selectedCustomers,

                itemLabel: (e) => e.customerName  ?? "",

                onChanged: (values) {
                  setState(() {
                    selectedCustomers = values;
                  });
                },
              ),

              SizedBox(height: 10),
              Text(
                " From Date",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(
                label: " From Date",
                controller: fromDateController,
              ),
              SizedBox(height: 10),
              Text(
                "To Date",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(label: "To Date", controller: toDateController),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.check),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.restart_alt),
                    ),
                  ),
                ],
              ),
              TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  iconColor: Colors.white,
                  filled: true,
                  fillColor: AppColors.primaryPurple,
                  hintText: "Count vs Staff",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                " From Date",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(
                label: " From Date",
                controller: fromDateController,
              ),
              SizedBox(height: 10),
              Text(
                "To Date",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(label: "To Date", controller: toDateController),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.check),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.restart_alt),
                    ),
                  ),
                ],
              ),
              TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  iconColor: Colors.white,
                  filled: true,
                  fillColor: AppColors.primaryPurple,
                  hintText: "Supplier vs Amount",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Suppliers",
                style: TextStyle(color: Colors.white, fontSize: 18),
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
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(
                label: " From Date",
                controller: fromDateController,
              ),
              SizedBox(height: 10),
              Text(
                "To Date",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(label: "To Date", controller: toDateController),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.check),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.restart_alt),
                    ),
                  ),
                ],
              ),
              TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  iconColor: Colors.white,
                  filled: true,
                  fillColor: AppColors.primaryPurple,
                  hintText: "Customer vs Amount",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Customers",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              CustomMultiSelect<EntriesCustomerModel>(
                hintText: "Select Customers",

                items: provider.customerEntries,

                selectedItems: selectedCustomers,

                itemLabel: (e) => e.customerName  ?? "",

                onChanged: (values) {
                  setState(() {
                    selectedCustomers = values;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                " From Date",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(
                label: " From Date",
                controller: fromDateController,
              ),
              SizedBox(height: 10),
              Text(
                "To Date",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              EntryDateTextField(label: "To Date", controller: toDateController),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.check),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.restart_alt),
                    ),
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
