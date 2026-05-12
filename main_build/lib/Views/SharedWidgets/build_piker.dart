import 'package:flutter/material.dart';

/// A drum-roll picker that correctly highlights the centred item and
/// never clips labelled strings like "175 cm" or "190 lbs".
///
/// Key fixes vs the original:
///  • Width is unconstrained (uses the full available width) — no more clipping.
///  • The selected-item highlight is driven by the *scroll position*
///    (tracked locally via [onSelectedItemChanged]) rather than a string
///    comparison against [selectedValue], which could lag by a frame.
///  • [selectedValue] is still used to set the initial scroll position when
///    no external [controller] is supplied.
Widget buildPicker(
  List<String> items,
  String selectedValue,
  bool isDarkMode,
  Function(String) onSelected, {
  required double fontSize,
  required double selectedHeight,
  FixedExtentScrollController? controller,
}) {
  final int initialIndex = items
      .indexOf(selectedValue)
      .clamp(0, items.isEmpty ? 0 : items.length - 1);

  return _PickerWidget(
    items: items,
    initialIndex: initialIndex,
    isDarkMode: isDarkMode,
    onSelected: onSelected,
    fontSize: fontSize,
    selectedHeight: selectedHeight,
    controller: controller,
  );
}

// ─────────────────────────────────────────────
// Internal stateful widget so we can own the
// highlighted-index without touching the parent.
// ─────────────────────────────────────────────
class _PickerWidget extends StatefulWidget {
  const _PickerWidget({
    required this.items,
    required this.initialIndex,
    required this.isDarkMode,
    required this.onSelected,
    required this.fontSize,
    required this.selectedHeight,
    this.controller,
  });

  final List<String> items;
  final int initialIndex;
  final bool isDarkMode;
  final Function(String) onSelected;
  final double fontSize;
  final double selectedHeight;
  final FixedExtentScrollController? controller;

  @override
  State<_PickerWidget> createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<_PickerWidget> {
  late int _centredIndex;
  late FixedExtentScrollController _ctrl;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _centredIndex = widget.initialIndex;
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = FixedExtentScrollController(initialItem: widget.initialIndex);
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(_PickerWidget old) {
    super.didUpdateWidget(old);
    // If the parent pushed a new selectedValue (e.g. unit conversion),
    // the external controller will have already jumped; just sync our index.
    if (widget.controller != null && widget.controller!.hasClients) {
      final newIndex = widget.controller!.selectedItem;
      if (newIndex != _centredIndex) {
        setState(() => _centredIndex = newIndex);
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = widget.isDarkMode ? Colors.white : Colors.black;
    final Color inactiveColor = widget.isDarkMode
        ? Colors.white38
        : Colors.black38;

    return SizedBox(
      height: widget.selectedHeight,
      // ↓ double.infinity so the picker fills the Column/Row slot it's in;
      //   no fixed 80 px that clips longer labels.
      width: double.infinity,
      child: ListWheelScrollView.useDelegate(
        controller: _ctrl,
        itemExtent: 55,
        perspective: 0.000003,
        diameterRatio: 2.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          // Update highlight immediately — no frame lag.
          setState(() => _centredIndex = index);
          widget.onSelected(widget.items[index]);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.items.length,
          builder: (context, index) {
            final isSelected = index == _centredIndex;
            return Center(
              child: Text(
                widget.items[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? activeColor : inactiveColor,
                  fontSize: isSelected ? widget.fontSize + 4 : widget.fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
