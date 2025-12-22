import 'package:flutter/material.dart';

Widget buildPicker(
  List<String> items,
  String selectedValue,

  Function(String) onSelected, {
  required double fontSize,
  required double selectedHeight,
  FixedExtentScrollController? controller,
}) {
  final int selectedIndex = items.indexOf(selectedValue);

  return SizedBox(
    height: selectedHeight,
    width: 80,
    child: ListWheelScrollView.useDelegate(
      controller:
          controller ??
          FixedExtentScrollController(
            initialItem: selectedIndex >= 0 ? selectedIndex : 0,
          ),
      itemExtent: 55,
      perspective: 0.000003,
      diameterRatio: 2.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) => onSelected(items[index]),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final isSelected = items[index] == selectedValue;
          return Center(
            child: Text(
              items[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: isSelected ? fontSize + 4 : fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    ),
  );
}
