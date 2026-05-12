import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

class UnitToggle extends StatefulWidget {
  final String leftLabel;
  final String rightLabel;
  final String? value;
  final ValueChanged<String> onChanged;
  final double? width;
  final bool useMaxWidth;

  const UnitToggle({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    this.value,
    required this.onChanged,
    this.width,
    this.useMaxWidth = false,
  });

  @override
  State<UnitToggle> createState() => _UnitToggleState();
}

class _UnitToggleState extends State<UnitToggle> {
  late String selectedUnit;

  @override
  void initState() {
    super.initState();
    selectedUnit = widget.value ?? widget.leftLabel;
  }

  @override
  void didUpdateWidget(UnitToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep internal state in sync when parent drives `value`
    if (widget.value != null && widget.value != selectedUnit) {
      selectedUnit = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors; // theme extension
    final expanded = widget.width != null || widget.useMaxWidth;
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = widget.useMaxWidth ? screenWidth - 20 : widget.width;

    return Container(
      width: effectiveWidth,
      decoration: BoxDecoration(
        border: Border.all(color: c.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: c.surfaceRaised,
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (expanded)
            Expanded(
              child: _unitButton(context, widget.leftLabel, isLeft: true),
            )
          else
            _unitButton(context, widget.leftLabel, isLeft: true),
          if (expanded)
            Expanded(
              child: _unitButton(context, widget.rightLabel, isLeft: false),
            )
          else
            _unitButton(context, widget.rightLabel, isLeft: false),
        ],
      ),
    );
  }

  Widget _unitButton(
    BuildContext context,
    String label, {
    required bool isLeft,
  }) {
    final c = context.colors;
    final bool isSelected = selectedUnit == label;

    return GestureDetector(
      onTap: () {
        setState(() => selectedUnit = label);
        widget.onChanged(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          // Selected → accent colour; unselected → transparent over surfaceRaised
          color: isSelected ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(15) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(15) : Radius.zero,
            topRight: !isLeft ? const Radius.circular(15) : Radius.zero,
            bottomRight: !isLeft ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              // On accent → black; otherwise use theme text colours
              color: isSelected ? Colors.black : c.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
