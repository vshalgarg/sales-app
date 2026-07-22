import 'package:flutter/material.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/colors_used.dart';
import '../customs/app_bar.dart';
import '../model_classes/add_deposit_model.dart';
import '../model_classes/retail_deposit_history_model.dart';
import '../model_classes/retail_model.dart';
import '../pop_ups/general_closing_popup.dart';
import '../provider/entries_provider/entries_section_provider.dart';
import '../provider/retail_provider.dart';
import '../provider/staff_provider.dart';

class EditRetailScreen extends StatefulWidget {
  final int retailId;

  const EditRetailScreen({Key? key, required this.retailId}) : super(key: key);

  @override
  State<EditRetailScreen> createState() => _EditRetailScreenState();
}

class _EditRetailScreenState extends State<EditRetailScreen> {
  final retailerController = TextEditingController();

  final dateController = TextEditingController();

  final List<TextEditingController> depositAmountControllers = [];

  final List<TextEditingController> depositDateControllers = [];

  // Dropdowns

  int? selectedCustomerId;
  int? selectedStaffId;

  // Expand / Collapse

  bool showRetailInfo = true;

  bool showDeposits = false;

  bool showHistory = false;

  int? expandedSupplierIndex;

  // Loading

  bool initialized = false;

  // Init

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final retailProvider = context.read<RetailDetailsProvider>();

      final entriesProvider = context.read<EntriesProvider>();

      final staffProvider = context.read<StaffProvider>();
      for (var controller in depositDateControllers) {
        controller.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
      }

      await Future.wait([
        retailProvider.fetchRetailDetails(widget.retailId),
        retailProvider.fetchDepositHistory(widget.retailId),
      ]);

      if (entriesProvider.customerEntries.isEmpty) {
        await entriesProvider.fetchCustomer();
      }

      if (staffProvider.staffs.isEmpty) {
        await staffProvider.fetchStaffs();
      }

      final retail = retailProvider.retailDetails;

      depositAmountControllers.clear();
      depositDateControllers.clear();

      if (retail != null) {
        retailerController.text = retail.name;

        dateController.text = retail.date;

        selectedCustomerId = retail.customerId;

        selectedStaffId = retail.staffId;

        for (int i = 0; i < retail.suppliers.length; i++) {
          depositAmountControllers.add(TextEditingController());

          depositDateControllers.add(TextEditingController());
        }
      }

      if (mounted) {
        setState(() {
          initialized = true;
        });
      }
    });
  }

  // Dispose

  @override
  void dispose() {
    retailerController.dispose();

    dateController.dispose();

    for (final c in depositAmountControllers) {
      c.dispose();
    }

    for (final c in depositDateControllers) {
      c.dispose();
    }

    super.dispose();
  }

  // Pick Date

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text = DateFormat("dd-MM-yyyy").format(picked);
    }
  }

  Widget sectionHeader({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget buildRetailInformation(
    RetailModel retail,
    RetailDetailsProvider retailProvider,
    EntriesProvider entriesProvider,
    StaffProvider staffProvider,
  ) {
    final customerIds = entriesProvider.customerEntries
        .map((e) => e.id?.toInt())
        .toList();

    final staffIds = staffProvider.staffs.map((e) => e.staffId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        sectionHeader(
          title: "Retail Information",
          expanded: showRetailInfo,
          onTap: () {
            setState(() {
              showRetailInfo = !showRetailInfo;

              if (showRetailInfo) {
                //showDeposits = false;
                //showHistory = false;
              }
            });
          },
        ),

       //

        if (showRetailInfo) ...[
          const SizedBox(height: 10),
          buildField(
            label: "Retailer",
            child: TextFormField(
              controller: retailerController,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),

          buildField(
            label: "Date",
            child: TextFormField(
              controller: dateController,
              readOnly: true,
              onTap: pickDate,
              decoration: const InputDecoration(
                border: InputBorder.none,
                suffixIcon: Icon(Iconsax.calendar),
              ),
            ),
          ),

          buildField(
            label: "Referred By",
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: customerIds.contains(selectedCustomerId)
                    ? selectedCustomerId
                    : null,
                items: entriesProvider.customerEntries
                    .map(
                      (customer) => DropdownMenuItem<int>(
                        value: customer.id!.toInt(),
                        child: Text(customer.customerName ?? ""),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomerId = value;
                  });
                },
              ),
            ),
          ),

          buildField(
            label: "Staff",
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: staffIds.contains(selectedStaffId)
                    ? selectedStaffId
                    : null,
                items: staffProvider.staffs
                    .map(
                      (staff) => DropdownMenuItem<int>(
                        value: staff.staffId,
                        child: Text(staff.staffName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStaffId = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: () async {
              final success = await retailProvider.updateRetail(
                retailId: retail.retailId,
                name: retailerController.text,
                date: dateController.text,
                referredByCustomerId: selectedCustomerId!,
                staffId: selectedStaffId,
              );

              if (success && mounted) {
                context.read<RetailProvider>().fetchRetails();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Retail Updated Successfully")),
                );
              }
            },
            child: retailProvider.isUpdating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "SAVE INFORMATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildDepositSection(RetailModel retail) {
    while (depositAmountControllers.length < retail.suppliers.length) {
      depositAmountControllers.add(TextEditingController());
      depositDateControllers.add(TextEditingController());
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        sectionHeader(
          title: "Add Deposits",
          expanded: showDeposits,
          onTap: () {
            setState(() {
              showDeposits = !showDeposits;

              // if (showDeposits) {
              //   showRetailInfo = true;
              //   showHistory = false;
              // }
            });
          },
        ),

       //

        if (showDeposits) ...[
          ...List.generate(retail.suppliers.length, (index) {
            final supplier = retail.suppliers[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Supplier${index + 1}",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                TextFormField(
                  initialValue: supplier.supplierName,
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Supplier",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 5),
                Text(
                  "Balance",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                TextFormField(
                  initialValue: supplier.balanceAmount.toString(),
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Balance",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 5),
                Text(
                  "Date",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                TextFormField(
                  controller: depositDateControllers[index],
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(Iconsax.calendar),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      depositDateControllers[index].text = DateFormat(
                        "yyy-MM-dd",
                      ).format(picked);
                    }
                  },
                ),

                const SizedBox(height: 5),
                Text(
                  "Amount",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                TextFormField(
                  controller: depositAmountControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Amount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (index != retail.suppliers.length - 1) ...[
                  const Divider(color: Colors.white54, thickness: 1),
                  const SizedBox(height: 20),
                ],
              ],
            );
          }),
          SizedBox(height: 0),
          Consumer<RetailDetailsProvider>(
            builder: (context, provider, child) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: provider.isSavingDeposits
                    ? null
                    : () async {
                        final List<DepositItem> items = [];

                        for (int i = 0; i < retail.suppliers.length; i++) {
                          final amount = depositAmountControllers[i].text;

                          final date = depositDateControllers[i].text;

                          if (amount.isEmpty || date.isEmpty) {
                            continue;
                          }
                          items.add(
                            DepositItem(
                              retailSupplierId:
                                  retail.suppliers[i].retailSupplierId,
                              depositDate: date,
                              amount: int.parse(amount),
                            ),
                          );
                        }

                        if (items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter at least one deposit and select date",
                              ),
                            ),
                          );
                          return;
                        }

                        final result = await provider.addDeposits(
                          AddDepositModel(deposits: items),
                        );

                        if (result["success"]) {
                          await provider.fetchRetailDetails(widget.retailId);
                          await provider.fetchDepositHistory(widget.retailId);

                          for (final c in depositAmountControllers) {
                            c.clear();
                          }

                          for (final c in depositDateControllers) {
                            c.clear();
                          }
                          ScaffoldSnackBar.show(context, result["message"]);
                          Navigator.pop(context);
                        }
                      },
                child: provider.isSavingDeposits
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SAVE DEPOSITS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildHistorySection(
    RetailDetailsProvider provider,
    RetailModel retail,
  ) {
    return Column(
      children: [
        sectionHeader(
          title: "History",
          expanded: showHistory,
          onTap: () {
            setState(() {
              showHistory = !showHistory;

              // if (showHistory) {
              //   showRetailInfo = false;
              //   showDeposits = false;
              // }
            });
          },
        ),

        if (showHistory) ...[
          const SizedBox(height: 15),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: retail.suppliers.length,
            itemBuilder: (context, index) {
              final supplier = retail.suppliers[index];

              final history = provider.depositHistory.firstWhere(
                (e) => e.retailSupplierId == supplier.retailSupplierId,
                orElse: () => RetailDepositHistoryModel(
                  retailSupplierId: supplier.retailSupplierId,
                  supplierId: supplier.supplierId,
                  supplierName: supplier.supplierName,
                  supplierCity: "",
                  totalAmount: supplier.totalAmount,
                  depositAmount: supplier.depositAmount,
                  balanceAmount: supplier.balanceAmount,
                  deposits: [],
                ),
              );

              return buildHistoryCard(
                supplier: supplier,
                history: history,
                retailDate: retail.date,
                staffName: retail.staffName,
                customerName: retail.customerName,
                index: index,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget buildHistoryCard({
    required dynamic supplier,
    required RetailDepositHistoryModel history,
    required String retailDate,
    required String staffName,
    required String customerName,
    required int index,
  }) {
    final bool expanded = expandedSupplierIndex == index;

    return Card(color:Colors.white,
      // margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xffF2EDFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.primaryPurple,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.supplierName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 3),

                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: "Referred By : ",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: customerName),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),

                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: "Staff :              ",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: staffName),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF2E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        retailDate,
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 2),
            const SizedBox(height: 10),

            // Amount Cards
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Total",
                      value: "₹${supplier.totalAmount}",
                      color: Color(0xff3B5BDB),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: const Color(0xffE5E7EB),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.arrow_downward,
                      title: "Deposited",
                      value: "₹${supplier.depositAmount}",
                      color: const Color(0xff3B5BDB),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30,
                    color: const Color(0xffE5E7EB),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.arrow_upward,
                      title: "Remaining",
                      value: "₹${supplier.balanceAmount}",
                      color: const Color(0xff2E9E57),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      setState(() {
                        expandedSupplierIndex = expanded ? null : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (expanded) ...[
              SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    "Deposits (${history.deposits.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              if (history.deposits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                    child: Text(
                      "No Deposit History",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              if (history.deposits.isNotEmpty)
                ...List.generate(history.deposits.length, (i) {
                  final deposit = history.deposits[i];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: AppColors.primaryPurple,
                            ),

                            const SizedBox(width: 8),

                            SizedBox(
                              width: 130,
                              child: Text(
                                deposit.date.isEmpty ? "-" : deposit.date,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),

                            Text(
                              "₹${deposit.amount}",
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 25),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F7EE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Deposited",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3),
                      if (i < history.deposits.length - 1)
                        const DashedDivider(),
                      SizedBox(height: 2),
                    ],
                  );
                }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 0.8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6B7280),
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final retailProvider = context.read<RetailDetailsProvider>();

    final entriesProvider = context.read<EntriesProvider>();

    final staffProvider = context.read<StaffProvider>();

    if (retailProvider.isLoading || !initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final retail = retailProvider.retailDetails!;

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      body: Scaffold(
        backgroundColor: AppColors.bodyFillColor,
        appBar: CustomAppBar(
          title: "Edit Retail",
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.close),

              onPressed: () {
                ExitConfirmationDialog.show(
                  context,
                  //bodyText: "",
                  saveButtonText: "Stay",
                  discardButtonText: "Leave",
                  onSave: () async {
                    Navigator.pop(context);
                  },
                  onDiscard: () {
                    Navigator.pop(context);
                    Navigator.pop(context, false);
                  },
                );
              },
            ),
          ],
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),

            child: Column(
              children: [
                buildRetailInformation(
                  retail,
                  retailProvider,
                  entriesProvider,
                  staffProvider,
                ),

                const SizedBox(height: 5),
                buildDepositSection(retail),
                const SizedBox(height: 5),
                buildHistorySection(retailProvider, retail),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final double height; // Thickness of the line
  final double dashWidth; // Length of each individual dash
  final double dashGap; // Empty space between dashes
  final Color color; // Color of the line

  const DashedDivider({
    super.key,
    this.height = 1.5,
    this.dashWidth = 8.0, // Longer width creates the dash effect
    this.dashGap = 4.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
