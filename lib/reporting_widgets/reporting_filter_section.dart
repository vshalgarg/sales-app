import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/colors_used.dart';

class FilterDropdown {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
}

class ReportingFilterSection extends StatelessWidget {
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final List<FilterDropdown> dropdowns;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const ReportingFilterSection({
    super.key,
    required this.fromDateController,
    required this.toDateController,
    required this.dropdowns,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFC7CAF9),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.filter_alt_outlined,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Apply Filters",
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          _buildDateCard(
            context,
            controller: fromDateController,
            label: "From Date",
          ),

          const SizedBox(height: 10),

          _buildDateCard(
            context,
            controller: toDateController,
            label: "To Date",
          ),

          const SizedBox(height: 10),

          ...dropdowns.map(
                (dropdown) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildDropdownCard(dropdown),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Clear Filters"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(
                        color: AppColors.primaryBlue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onApply,
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: const Text("Apply Filters"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
      }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: DateTime.now(),
        );

        if (picked != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      },
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primaryBlue,
              size: 18,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        value.text.isEmpty
                            ? "Select date"
                            : value.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: value.text.isEmpty
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3FF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primaryBlue,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard(FilterDropdown dropdown) {
    IconData icon = dropdown.label == "Supplier"
        ? Icons.storefront_outlined
        : Icons.person_outline;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dropdown.label,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1
                  ),
                ),
                const SizedBox(height: 2),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    itemHeight: 48,
                    isExpanded: true,
                    value: dropdown.items.contains(dropdown.value)
                        ? dropdown.value
                        : null,
                    icon: const SizedBox.shrink(),
                    hint: Text(
                      "Select ${dropdown.label.toLowerCase()}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    items: dropdown.items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: dropdown.onChanged,
                  ),
                ),
              ],
            ),
          ),


            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBlue,
              size: 18,
            ),
        ],
      ),
    );
  }
}