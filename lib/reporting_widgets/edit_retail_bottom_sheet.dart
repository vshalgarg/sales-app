import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool depositExpanded = false;
  bool historyExpanded = false;

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
      dateController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  // Build
  Widget _historyButton({
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: color, fontSize: 14),
            children: [
              TextSpan(
                text: "$title: ",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retailProvider = context.read<RetailDetailsProvider>();
    final entriesProvider = context.read<EntriesProvider>();
    final staffProvider = context.read<StaffProvider>();

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
                if (!retailerExpanded) {
                  retailerExpanded = true;
                  depositExpanded = false;
                  historyExpanded = false;
                } else {
                  retailerExpanded = false;
                }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: retailerController,
                    decoration: const InputDecoration(
                      labelText: "Retailer",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    onTap: pickDate,
                    decoration: InputDecoration(
                      labelText: "Date",
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: pickDate,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: customerIds.contains(selectedCustomerId)
                        ? selectedCustomerId
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Referred By",
                      border: OutlineInputBorder(),
                    ),
                    items: entriesProvider.customerEntries.map((customer) {
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

                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: staffIds.contains(selectedStaffId)
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

                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4057A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                              const SnackBar(
                                content: Text("Retail Updated Successfully"),
                              ),
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
                            : Text(
                                "SAVE INFO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
                if (!depositExpanded) {
                  depositExpanded = true;
                  retailerExpanded = false;
                  historyExpanded = false;
                } else {
                  depositExpanded = false;
                }
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
                  Column(
                    children: List.generate(retail.suppliers.length, (index) {
                      final supplier = retail.suppliers[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E2E2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Supplier",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(supplier.supplierName),
                            ),
                            const SizedBox(height: 16),

                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Balance",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(supplier.balanceAmount.toString()),
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: depositDateControllers[index],
                              readOnly: true,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime.now(),
                                );

                                if (picked != null) {
                                  depositDateControllers[index].text =
                                      DateFormat('dd-MM-yyyy').format(picked);
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: "Date",
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: depositAmountControllers[index],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Amount",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8),

                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child: Consumer<RetailDetailsProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4057A6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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

                                      final date = depositDateControllers[i]
                                          .text
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter at least one deposit",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final success = await provider.addDeposits(
                                      AddDepositModel(deposits: items),
                                    );
                                    debugPrint("Success: $success");
                                    if (!mounted) return;

                                    if (success) {
                                      await provider.fetchRetailDetails(
                                        widget.retailId,
                                      );
                                      for (final supplier
                                          in provider
                                              .retailDetails!
                                              .suppliers) {}
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

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                if (!historyExpanded) {
                  historyExpanded = true;
                  retailerExpanded = false;
                  depositExpanded = false;
                } else {
                  historyExpanded = false;
                }
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
            Column(
              children: List.generate(provider.depositHistory.length, (index) {
                final supplier = provider.depositHistory[index];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.supplierName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _historyButton(
                                title: "Total",
                                value: "₹${supplier.totalAmount}",
                                color: Colors.grey,
                                onTap: () {
                                  setState(() {
                                    expandedSupplierIndex =
                                        expandedSupplierIndex == index
                                        ? null
                                        : index;
                                  });
                                },
                              ),

                              _historyButton(
                                title: "Deposited",
                                value: "₹${supplier.depositAmount}",
                                color: Colors.green,
                                onTap: () {
                                  setState(() {
                                    expandedSupplierIndex =
                                        expandedSupplierIndex == index
                                        ? null
                                        : index;
                                  });
                                },
                              ),

                              _historyButton(
                                title: "Remaining",
                                value: "₹${supplier.balanceAmount}",
                                color: supplier.balanceAmount > 0
                                    ? Colors.orange
                                    : Colors.green,
                                onTap: () {
                                  setState(() {
                                    expandedSupplierIndex =
                                        expandedSupplierIndex == index
                                        ? null
                                        : index;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: expandedSupplierIndex == index
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox(),
                            secondChild: Container(
                              margin: const EdgeInsets.only(top: 8),
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

                                  Column(
                                    children: List.generate(
                                      supplier.deposits.length,
                                      (i) {
                                        final deposit = supplier.deposits[i];

                                        return Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(deposit.date),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "₹${deposit.amount}",
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (i !=
                                                supplier.deposits.length - 1)
                                              const Divider(height: 1),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }
}
