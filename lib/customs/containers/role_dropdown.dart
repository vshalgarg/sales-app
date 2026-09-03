import 'package:flutter/material.dart';

class RoleDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const RoleDropdown({
    super.key,
    this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  final List<String> roles = const [
    "ADMIN",
    "AGENT",
  ];

  bool get _isOpen => _overlayEntry != null;

  void _toggleDropdown() {
    if (_isOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox? renderBox =
    _fieldKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeDropdown,
                behavior: HitTestBehavior.translucent,
              ),
            ),

            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height),
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(
                    maxHeight: 180,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: roles.length,
                    itemBuilder: (context, index) {
                      final String role = roles[index];

                      return InkWell(
                        onTap: () {
                          widget.onChanged(role);
                          _removeDropdown();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 16,
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    setState(() {});
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue =
        widget.value != null && widget.value!.trim().isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        key: _fieldKey,
        readOnly: true,

        controller: TextEditingController(
          text: hasValue ? widget.value! : "",
        ),

        onTap: _toggleDropdown,

        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),

        decoration: InputDecoration(
          labelText: "Role * ",

          hintStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          errorText: widget.errorText,
          filled: true,
          fillColor: Colors.white,

          suffixIcon: Icon(
            _isOpen
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: Colors.black54,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: widget.errorText != null
                  ? Colors.red
                  : Colors.grey,
              width: widget.errorText != null ? 1 : 0.5,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: widget.errorText != null
                  ? Colors.red
                  : Colors.grey,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}