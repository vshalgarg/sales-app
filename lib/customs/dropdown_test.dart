import 'package:flutter/material.dart';

import '../constants/colors_used.dart';

class CustomDropdown extends StatefulWidget {
  final String? label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool expandMultiSelect;

  final bool isDisabled;
  final bool isRequired;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isEmbedded;

  // Multi-select support
  final bool isMultiSelect;
  final List<String>? initialValues;
  final ValueChanged<List<String>>? onMultiChanged;
  final AutovalidateMode? autovalidateMode;
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
    this.autovalidateMode,
    this.expandMultiSelect = false,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final GlobalKey<FormFieldState<String>> _formFieldKey =
  GlobalKey<FormFieldState<String>>();

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  String? selectedValue;
  List<String> selectedValues = [];

  // Search directly inside the dropdown field
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    selectedValue = widget.initialValue;
    selectedValues = List<String>.from(widget.initialValues ?? []);

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue) {
      selectedValue = widget.initialValue;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final fieldState = _formFieldKey.currentState;

        fieldState?.didChange(selectedValue);

        // Clear old validation error after a real value exists.
        if (selectedValue != null &&
            selectedValue!.trim().isNotEmpty) {
          fieldState?.reset();
          fieldState?.didChange(selectedValue);
        }
      });
    }

    if (widget.initialValues != oldWidget.initialValues) {
      selectedValues = List<String>.from(
        widget.initialValues ?? [],
      );
    }

    if (widget.initialValue != oldWidget.initialValue ||
        widget.initialValues != oldWidget.initialValues) {
      if (_overlayEntry != null) {
        _removeOverlay();
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay(isDisposing: true);

    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    _overlayEntry?.markNeedsBuild();
  }

  List<String> get _filteredItems {
    final searchText = _searchController.text.trim().toLowerCase();

    if (searchText.isEmpty) {
      return widget.items;
    }

    return widget.items.where((item) {
      return item.toLowerCase().contains(searchText);
    }).toList();
  }

  void _toggle() {
    if (widget.isDisabled) return;

    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay({bool isDisposing = false}) {
    final entry = _overlayEntry;

    _overlayEntry = null;

    if (!isDisposing) {
      _searchFocusNode.unfocus();
      _searchController.clear();

      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }

    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }
  void _showOverlay() {
    if (widget.isDisabled) return;

    final renderBox =
    _fieldKey.currentContext!.findRenderObject() as RenderBox;

    final size = renderBox.size;

    // Start with an empty search every time it opens.
    _searchController.clear();

    setState(() {
      _isSearching = true;
    });

    const double itemHeight = 49.0;
    const double maxHeight = 400.0;

    _overlayEntry = OverlayEntry(
      builder: (_) {
        final filteredItems = _filteredItems;

        final double dropdownHeight =
        (filteredItems.isEmpty
            ? itemHeight
            : filteredItems.length * itemHeight)
            .clamp(0.0, maxHeight)
            .toDouble();

        return Stack(
          children: [
            // Close dropdown when clicking outside
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
                    child: filteredItems.isEmpty
                        ? const Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          'No options',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (_, index) {
                        final item = filteredItems[index];

                        final bool isSelected = widget.isMultiSelect
                            ? selectedValues.contains(item)
                            : selectedValue == item;

                        return InkWell(
                          onTap: () {
                            if (widget.isMultiSelect) {
                              setState(() {
                                if (!selectedValues.contains(item)) {
                                  selectedValues.add(item);
                                }
                              });

                              widget.onMultiChanged?.call(
                                List<String>.from(selectedValues),
                              );

                              _removeOverlay();
                            } else {
                              setState(() {
                                selectedValue = item;
                              });
                              final fieldState = _formFieldKey.currentState;

                              fieldState?.didChange(item);
                              widget.onChanged(item);

                              if (mounted) {
                                setState(() {});
                              }

                              _removeOverlay();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            color: isSelected
                                ? Colors.grey.shade100
                                : Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                if (widget.isMultiSelect &&
                                    isSelected)
                                  const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: AppColors.primaryBlue,
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
        );
      },
    );

    final overlay = Overlay.maybeOf(context);

    if (overlay != null && mounted) {
      overlay.insert(_overlayEntry!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _overlayEntry == null) return;

        _searchFocusNode.requestFocus();
      });
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
        ],

        FormField<String>(
          key: _formFieldKey,
          initialValue: selectedValue,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    key: _fieldKey,

                    // When closed -> open dropdown
                    // When already open -> keep TextField focused
                    onTap: () {
                      if (_isSearching) {
                        _searchFocusNode.requestFocus();
                      } else {
                        _toggle();
                      }
                    },

                    child:Container(
                      height: widget.expandMultiSelect ? null : 58,
                      constraints: widget.expandMultiSelect
                          ? const BoxConstraints(minHeight: 58)
                          : null,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: field.hasError
                              ? Colors.red
                              : Colors.grey.shade500,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: widget.isMultiSelect
                                ? _buildMultiSelectValue()
                                : _buildSearchOrValue(field),
                          ),

                          if (!widget.isDisabled)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Icon(
                                _isSearching
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 5,
                    ),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchOrValue(FormFieldState<String> field) {
    // Dropdown is open:
    // show SEARCH TEXT FIELD in the SAME Supplier/Customer field.
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          _overlayEntry?.markNeedsBuild();
        },
      );
    }

    // Dropdown closed:
    // show selected value normally.
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        (selectedValue == null || selectedValue!.trim().isEmpty)
            ? widget.hintText
            : selectedValue!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          color: widget.isDisabled
              ? Colors.grey
              : (selectedValue == null ||
              selectedValue!.trim().isEmpty)
              ? Colors.grey
              : Colors.black,
        ),
      ),
    );
  }

  Widget _buildMultiSelectValue() {
    if (selectedValues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          widget.hintText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
        right: 8,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: selectedValues.map((value) {
          return Container(
            constraints: const BoxConstraints(
              maxWidth: 280,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 220,
                  ),
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ),

                if (!widget.isDisabled) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedValues.remove(value);
                      });

                      widget.onMultiChanged?.call(
                        List<String>.from(selectedValues),
                      );
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
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
    );
  }
}
