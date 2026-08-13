import 'package:flutter/material.dart';

import '../constants/colors_used.dart';

class CustomDropdown extends StatefulWidget {
  final String? label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  final bool isDisabled;
  final bool isRequired;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isEmbedded;

  // Multi-select support
  final bool isMultiSelect;
  final List<String>? initialValues;
  final ValueChanged<List<String>>? onMultiChanged;

  const CustomDropdown({
    super.key,
    this.label,
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.isDisabled = false,
    this.isRequired = false,
    this.hintText = "Select",
    this.validator,
    this.isEmbedded = false,
    this.isMultiSelect = false,
    this.initialValues,
    this.onMultiChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final GlobalKey<FormFieldState<String>> _formFieldKey =
      GlobalKey<FormFieldState<String>>();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String? selectedValue;
  List<String> selectedValues = [];
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    selectedValue = widget.initialValue;

    selectedValues = List<String>.from(widget.initialValues ?? []);
  }

  @override
  void didUpdateWidget(covariant CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue) {
      selectedValue = widget.initialValue;

      if (widget.initialValues != oldWidget.initialValues) {
        selectedValues = List<String>.from(widget.initialValues ?? []);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _formFieldKey.currentState?.didChange(selectedValue);

        if (_overlayEntry != null) {
          _removeOverlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggle() {
    if (widget.isDisabled) return;
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    final entry = _overlayEntry;
    _overlayEntry = null;

    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }

  void _refreshOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;

    final size = renderBox.size;

    const double itemHeight = 49.0;
    const double maxHeight = 400.0;

    final double dropdownHeight = (widget.items.length * itemHeight).clamp(
      0.0,
      maxHeight,
    );

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
            ),
          ),

          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height),

            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(5),

              child: SizedBox(
                height: dropdownHeight,
                width: size.width,

                child: Container(
                  width: size.width,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),

                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items.length,

                    itemBuilder: (_, index) {
                      final item = widget.items[index];

                      final bool isSelected =
                          widget.isMultiSelect && selectedValues.contains(item);

                      return InkWell(
                        onTap: () {
                          if (widget.isMultiSelect) {
                            setState(() {
                              // Add only if not already selected
                              if (!selectedValues.contains(item)) {
                                selectedValues.add(item);
                              }
                            });

                            widget.onMultiChanged?.call(
                              List<String>.from(selectedValues),
                            );

                            // Close after selecting
                            _removeOverlay();
                          } else {
                            setState(() {
                              selectedValue = item;
                            });

                            _formFieldKey.currentState?.didChange(item);
                            _formFieldKey.currentState?.validate();

                            widget.onChanged(item);

                            _removeOverlay();
                          }
                        },

                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final overlay = Overlay.maybeOf(context);

    if (overlay != null && mounted) {
      overlay.insert(_overlayEntry!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
              ),
              children: [
                TextSpan(text: widget.label),
                if (widget.isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          //const SizedBox(height: 6),
        ],
        FormField<String>(
          key: _formFieldKey,
          initialValue: selectedValue,
          validator: widget.validator,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    key: _fieldKey,
                    onTap: _toggle,
                    child: Container(
                      padding: widget.isEmbedded
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(horizontal: 12),
                      decoration: widget.isEmbedded
                          ? null
                          : BoxDecoration(
                              color: widget.isDisabled
                                  ? Colors.white
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: field.hasError
                                    ? Colors.red
                                    : Colors.grey,
                                width: 0.5,
                              ),
                            ),
                      child: Row(
                        children: [
                          Expanded(
                            child: widget.isMultiSelect
                                ? selectedValues.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          child: Text(
                                            widget.hintText,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: selectedValues.map((
                                              value,
                                            ) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      value,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black,
                                                      ),
                                                    ),

                                                    if (!widget.isDisabled) ...[
                                                      const SizedBox(width: 6),

                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            selectedValues
                                                                .remove(value);
                                                          });

                                                          widget.onMultiChanged
                                                              ?.call(
                                                                List<
                                                                  String
                                                                >.from(
                                                                  selectedValues,
                                                                ),
                                                              );
                                                        },
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                          child: const Icon(
                                                            Icons.close,
                                                            size: 13,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    child: Text(
                                      (selectedValue == null ||
                                              selectedValue!.trim().isEmpty)
                                          ? widget.hintText
                                          : selectedValue!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: widget.isDisabled
                                            ? Colors.grey
                                            : (selectedValue == null ||
                                                      selectedValue!
                                                          .trim()
                                                          .isEmpty
                                                  ? Colors.grey
                                                  : Colors.black),
                                      ),
                                    ),
                                  ),
                          ),

                          Icon(
                            Icons.keyboard_arrow_down,
                            color: widget.isDisabled
                                ? Colors.grey
                                : Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 5),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
