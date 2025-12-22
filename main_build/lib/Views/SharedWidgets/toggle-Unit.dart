import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

class UnitToggle extends StatefulWidget {
  final String leftLabel;
  final String rightLabel;
  final ValueChanged<String> onChanged;

  const UnitToggle({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.onChanged,
  });

  @override
  State<UnitToggle> createState() => _UnitToggleState();
}

class _UnitToggleState extends State<UnitToggle> {
  late String selectedUnit;

  @override
  void initState() {
    super.initState();
    selectedUnit = widget.leftLabel; // default selection
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 255, 255, 255),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitButton(widget.leftLabel, isLeft: true),
          _unitButton(widget.rightLabel, isLeft: false),
        ],
      ),
    );
  }

  Widget _unitButton(String label, {required bool isLeft}) {
    final bool isSelected = selectedUnit == label;

    return GestureDetector(
      onTap: () {
        setState(() => selectedUnit = label);
        widget.onChanged(label);
      },
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 5),
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
              color: isSelected ? AppTheme.darkBackground : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
