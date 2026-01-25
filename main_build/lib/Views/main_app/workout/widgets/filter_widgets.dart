import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  final ValueChanged<String> onBodyPartChanged;
  final ValueChanged<String> onEquipmentChanged;

  const Filters({
    super.key,
    required this.onBodyPartChanged,
    required this.onEquipmentChanged,
  });

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  String _body = 'all';
  String _equip = 'all';
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final chipsTextStyle = const TextStyle(color: Colors.white70);
    return Column(
      children: [
        // Filter toggle button with dropdown arrow
        InkWell(
          onTap: () {
            setState(() => _showFilters = !_showFilters);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Settings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _showFilters ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more,
                    color: Colors.yellow,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expandable filters section
        if (_showFilters) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23).withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Body Part',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: 'All',
                      selected: _body == 'all',
                      onSelected: () {
                        setState(() => _body = 'all');
                        widget.onBodyPartChanged('all');
                      },
                      textStyle: chipsTextStyle,
                    ),
                    for (final part in [
                      'chest',
                      'back',
                      'legs',
                      'shoulders',
                      'core',
                      'glutes',
                      'hamstrings',
                    ])
                      FilterChip(
                        label: part,
                        selected: _body == part,
                        onSelected: () {
                          setState(() => _body = part);
                          widget.onBodyPartChanged(part);
                        },
                        textStyle: chipsTextStyle,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Equipment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: 'All',
                      selected: _equip == 'all',
                      onSelected: () {
                        setState(() => _equip = 'all');
                        widget.onEquipmentChanged('all');
                      },
                      textStyle: chipsTextStyle,
                    ),
                    for (final equip in [
                      'body weight',
                      'dumbbell',
                      'barbell',
                      'kettle bell',
                      'resistance band',
                      'cable',
                    ])
                      FilterChip(
                        label: equip,
                        selected: _equip == equip,
                        onSelected: () {
                          setState(() => _equip = equip);
                          widget.onEquipmentChanged(equip);
                        },
                        textStyle: chipsTextStyle,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final TextStyle textStyle;

  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.yellow.withOpacity(0.15)
              : const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.yellow : Colors.white24),
        ),
        child: Text(
          label,
          style: textStyle.copyWith(
            color: selected ? Colors.yellow : Colors.white70,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
