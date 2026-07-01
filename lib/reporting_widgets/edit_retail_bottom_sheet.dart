import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors_used.dart';
import '../model_classes/add_deposit_model.dart';
import '../model_classes/retail_model.dart';
import '../provider/entries_provider/entries_section_provider.dart';
import '../provider/retail_provider.dart';
import '../provider/staff_provider.dart';

class EditRetailBottomSheet extends StatefulWidget {
  final int retailId;

  const EditRetailBottomSheet({Key? key, required this.retailId})
    : super(key: key);

  @override
  State<EditRetailBottomSheet> createState() => _EditRetailBottomSheetState();
}

class _EditRetailBottomSheetState extends State<EditRetailBottomSheet> {
  // Controllers
  final TextEditingController retailerController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final List<TextEditingController> depositAmountControllers = [];

  final List<TextEditingController> depositDateControllers = [];
  int? expandedSupplierIndex;

  // Selected Dropdown Values

  int? selectedCustomerId;
  int? selectedStaffId;

  // Expand/Collapse

  bool retailerExpanded = true;
  bool depositExpanded = true;
  bool historyExpanded = true;

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

      await Future.wait([
        retailProvider.fetchRetailDetails(widget.retailId),

        retailProvider.fetchDepositHistory(widget.retailId),

        entriesProvider.fetchCustomer(),

        staffProvider.fetchStaffs(),
      ]);

      final retail = retailProvider.retailDetails;
      depositAmountControllers.clear();
      depositDateControllers.clear();
      if (retail != null) {
        for (int i = 0; i < retail.suppliers.length; i++) {
          depositAmountControllers.add(TextEditingController());

          depositDateControllers.add(TextEditingController());
        }
        retailerController.text = retail.name;

        dateController.text = retail.date;

        selectedCustomerId = retail.customerId;
        selectedStaffId = retail.staffId;
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
    for (final controller in depositAmountControllers) {
      controller.dispose();
    }

    for (final controller in depositDateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Pick Date

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2024),

      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = picked.toIso8601String().split("T").first;

      setState(() {});
    }
  }

  // Build

  @override
  Widget build(BuildContext context) {
    return Consumer3<RetailDetailsProvider, EntriesProvider, StaffProvider>(
      builder:
          (context, retailProvider, entriesProvider, staffProvider, child) {
            if (retailProvider.isLoading || !initialized) {
              return const SizedBox(
                height: 500,

                child: Center(child: CircularProgressIndicator()),
              );
            }

            final retail = retailProvider.retailDetails!;

            return Container(
              height: MediaQuery.of(context).size.height * .92,

              decoration: const BoxDecoration(
                color: AppColors.bodyFillColor,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),

                  topRight: Radius.circular(25),
                ),
              ),

              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),

                        child: Column(
                          children: [
                            _buildRetailInfo(
                              retail,
                              retailProvider,
                              entriesProvider,
                              staffProvider,
                            ),

                            const SizedBox(height: 20),
                            _buildDepositSection(retail),

                            const SizedBox(height: 20),
                            _buildHistorySection(retailProvider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  Widget _buildRetailInfo(
    retail,
    RetailDetailsProvider retailProvider,
    EntriesProvider entriesProvider,
    StaffProvider staffProvider,
  ) {
    final customerIds = entriesProvider.customerEntries
        .map((e) => e.id?.toInt())
        .toList();

    final staffIds = staffProvider.staffs.map((e) => e.staffId).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                retailerExpanded = !retailerExpanded;
              });
            },
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF4057A6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Retailer Info",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Icon(
                    retailerExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          if (retailerExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Retailer",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: retailerController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Date",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: dateController,
                              readOnly: true,
                              onTap: pickDate,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: pickDate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: customerIds.contains(selectedCustomerId)
                              ? selectedCustomerId
                              : null,
                          decoration: const InputDecoration(
                            labelText: "Referred By",
                            border: OutlineInputBorder(),
                          ),
                          items: entriesProvider.customerEntries.map((
                            customer,
                          ) {
                            return DropdownMenuItem<int>(
                              value: customer.id!.toInt(),
                              child: Text(customer.customerName ?? ""),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCustomerId = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: staffIds.contains(selectedStaffId)
                              ? selectedStaffId
                              : null,
                          decoration: const InputDecoration(
                            labelText: "Staff",
                            border: OutlineInputBorder(),
                          ),
                          items: staffProvider.staffs.map((staff) {
                            return DropdownMenuItem<int>(
                              value: staff.staffId,
                              child: Text(staff.staffName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStaffId = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4057A6),
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
                            const SnackBar(
                              content: Text("Retail Updated Successfully"),
                            ),
                          );
                        }
                      },
                      child: retailProvider.isUpdating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SAVE INFO",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDepositSection(RetailModel retail) {
    while (depositAmountControllers.length < retail.suppliers.length) {
      depositAmountControllers.add(TextEditingController());
      depositDateControllers.add(TextEditingController());
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                depositExpanded = !depositExpanded;
              });
            },
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF4057A6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Add Deposits",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    depositExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          if (depositExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: retail.suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = retail.suppliers[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E2E2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 700) {
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: supplier.supplierName,
                                      decoration: const InputDecoration(
                                        labelText: "Supplier",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      readOnly: true,
                                      initialValue: supplier.balanceAmount
                                          .toString(),
                                      decoration: const InputDecoration(
                                        labelText: "Balance",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: depositDateControllers[index],
                                      readOnly: true,
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2024),
                                          lastDate: DateTime(2100),
                                        );

                                        if (picked != null) {
                                          depositDateControllers[index].text =
                                              picked
                                                  .toIso8601String()
                                                  .split('T')
                                                  .first;
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: "Date",
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller:
                                          depositAmountControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: "Amount",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                TextFormField(
                                  readOnly: true,
                                  initialValue: supplier.supplierName,
                                  decoration: const InputDecoration(
                                    labelText: "Supplier",
                                    border: OutlineInputBorder(),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        readOnly: true,
                                        initialValue: supplier.balanceAmount
                                            .toString(),
                                        decoration: const InputDecoration(
                                          labelText: "Balance",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            depositDateControllers[index],
                                        readOnly: true,
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2024),
                                            lastDate: DateTime(2100),
                                          );

                                          if (picked != null) {
                                            depositDateControllers[index].text =
                                                picked
                                                    .toIso8601String()
                                                    .split('T')
                                                    .first;
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          labelText: "Date",
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: depositAmountControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Amount",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Consumer<RetailDetailsProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4057A6),
                          ),
                          onPressed: provider.isSavingDeposits
                              ? null
                              : () async {
                                  final List<DepositItem> items = [];

                                  for (
                                    int i = 0;
                                    i < retail.suppliers.length;
                                    i++
                                  ) {
                                    final amount = depositAmountControllers[i]
                                        .text
                                        .trim();

                                    final date = depositDateControllers[i].text
                                        .trim();

                                    if (amount.isEmpty || date.isEmpty) {
                                      continue;
                                    }

                                    final parsedAmount = int.tryParse(amount);

                                    if (parsedAmount == null) {
                                      continue;
                                    }

                                    items.add(
                                      DepositItem(
                                        retailSupplierId: retail
                                            .suppliers[i]
                                            .retailSupplierId,
                                        depositDate: date,
                                        amount: parsedAmount,
                                      ),
                                    );
                                  }

                                  if (items.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please enter at least one deposit",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  print("Saving Deposits...");
                                  final success = await provider.addDeposits(
                                    AddDepositModel(deposits: items),
                                  );
                                  print("Success: $success");
                                  if (!mounted) return;

                                  if (success) {
                                    await provider.fetchRetailDetails(
                                      widget.retailId,
                                    );
                                    for (final supplier
                                        in provider.retailDetails!.suppliers) {
                                      print(
                                        "${supplier.supplierName} Balance: ${supplier.balanceAmount}",
                                      );
                                    }
                                    await provider.fetchDepositHistory(
                                      widget.retailId,
                                    );

                                    if (!mounted) return;

                                    for (final controller
                                        in depositAmountControllers) {
                                      controller.clear();
                                    }

                                    for (final controller
                                        in depositDateControllers) {
                                      controller.clear();
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Deposits Added Successfully",
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: provider.isSavingDeposits
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
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
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(RetailDetailsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                historyExpanded = !historyExpanded;
              });
            },
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xff4057A6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Icon(
                    historyExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          if (historyExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.depositHistory.length,
              itemBuilder: (context, index) {
                final supplier = provider.depositHistory[index];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.supplierName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _historyButton(
                            title: "Total",
                            value: "₹${supplier.totalAmount}",
                            color: Colors.grey,
                            index: index,
                          ),
                          _historyButton(
                            title: "Deposited",
                            value: "₹${supplier.depositAmount}",
                            color: Colors.green,
                            index: index,
                          ),
                          _historyButton(
                            title: "Remaining",
                            value: "₹${supplier.balanceAmount}",
                            color: supplier.balanceAmount > 0
                                ? Colors.red
                                : Colors.green,
                            index: index,
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: expandedSupplierIndex == index
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(),
                        secondChild: Container(
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4057A6),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Date",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Deposit Amount",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: supplier.deposits.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final deposit = supplier.deposits[i];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(deposit.date)),
                                        Expanded(
                                          child: Text(
                                            "₹${deposit.amount}",
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _historyButton({
    required String title,
    required String value,
    required Color color,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          if (expandedSupplierIndex == index) {
            expandedSupplierIndex = null;
          } else {
            expandedSupplierIndex = index;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Edit Retail",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
