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
    selectedUnit = widget.value ?? widget.leftLabel; // default selection
  }

  @override
  Widget build(BuildContext context) {
    final expanded = widget.width != null || widget.useMaxWidth;
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = widget.useMaxWidth ? screenWidth - 20 : widget.width;

    return Container(
      width: effectiveWidth,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 255, 255, 255),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
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
    final bool isSelected = selectedUnit == label;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() => selectedUnit = label);
        widget.onChanged(label);
      },
      child: Container(
        width: widget.width == null && !widget.useMaxWidth ? null : null,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD9D9D9) : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(16) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(16) : Radius.zero,
            topRight: !isLeft ? const Radius.circular(16) : Radius.zero,
            bottomRight: !isLeft ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppTheme.darkBackground
                  : (isDarkMode ? Colors.white : Colors.black),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
