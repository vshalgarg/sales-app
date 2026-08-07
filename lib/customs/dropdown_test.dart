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
  final bool isEmbedded;
  final Color? color;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    this.label,
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.color,
    this.isDisabled = false,
    this.isRequired = false,
    this.hintText = "Select",
    this.isEmbedded = false,
    this.validator,
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
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedValue = widget.items.contains(widget.initialValue)
        ? widget.initialValue
        : null;
  }

  @override
  void didUpdateWidget(covariant CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue) {
      selectedValue = widget.initialValue;

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
                    //  border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (_, index) {
                      final item = widget.items[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedValue = item;
                          });

                          _formFieldKey.currentState?.didChange(
                            item,
                          ); // <-- Important
                          _formFieldKey.currentState
                              ?.validate(); // <-- Removes error immediately

                          widget.onChanged(item);
                          _removeOverlay();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Text(item),
                            ),
                            // Light divider
                            if (index != widget.items.length - 1)
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Colors.grey.shade300,
                              ),
                          ],
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
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 18.0,
                                bottom: 18,
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
                                                selectedValue!.trim().isEmpty
                                            ? Colors.grey
                                            : Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: widget.isDisabled == true
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
