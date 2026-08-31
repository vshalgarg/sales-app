import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/colors_used.dart';
import '../customs/dropdown_test.dart';

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

class ReportingFilterSection extends StatefulWidget {
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
  State<ReportingFilterSection> createState() =>
      _ReportingFilterSectionState();
}

class _ReportingFilterSectionState
    extends State<ReportingFilterSection>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _keyboardWasOpen = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    if (!mounted) return;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardIsOpen = bottomInset > 0;

    if (keyboardIsOpen && !_keyboardWasOpen) {
      _keyboardWasOpen = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }

    if (!keyboardIsOpen && _keyboardWasOpen) {
      _keyboardWasOpen = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;

        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        28,
        12,
        24,
        keyboardHeight + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bodyFillColor, width: 2),
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
            controller: widget.fromDateController,
            label: "From Date",
          ),

          const SizedBox(height: 10),

          _buildDateCard(
            context,
            controller: widget.toDateController,
            label: "To Date",
          ),

          const SizedBox(height: 10),

          ...widget.dropdowns.map(
            (dropdown) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomDropdown(
                 label: dropdown.label,
                items: dropdown.items,
                initialValue: dropdown.value,
                hintText: "Select ${dropdown.label.toLowerCase()}",
                onChanged: dropdown.onChanged,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Clear Filters"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
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
                    onPressed: () {

                      widget.onApply();
                    },
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
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      label,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 16,
      ),
    ),

    InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          initialDate: DateTime.now(),
        );

        if (picked != null) {
          controller.text = DateFormat('dd-MM-yyyy').format(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey,
          width: 0.5)
        ),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: Text(
                          value.text.isEmpty ? "Select date" : value.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: value.text.isEmpty
                                ? Colors.grey
                                : Colors.black87,
                          ),
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
    )
    ]
    );
  }
}
