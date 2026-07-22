import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String? label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool isDisabled;
  final bool isRequired;
  final String hintText;

  const CustomDropdown({
    super.key,
    this.label,
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.isDisabled = false,
    this.isRequired = false,
    this.hintText = "Select",
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String? selectedValue;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      selectedValue = widget.initialValue;
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
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    final renderBox =
    _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

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
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (_, index) {
                      final item = widget.items[index];
                      return InkWell(
                        onTap: () {
                          setState(() => selectedValue = item);
                          widget.onChanged(item);
                          _removeOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          child: Text(item),
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

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(text: widget.label),
                if (widget.isRequired)
                  const TextSpan(
                      text: " *", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: _fieldKey,
            onTap: _toggle,
            child: Container(
             height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: widget.isDisabled
                    ? Colors.grey.shade200
                    : Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedValue ?? widget.hintText,
                      style: TextStyle(
                        color: selectedValue == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
