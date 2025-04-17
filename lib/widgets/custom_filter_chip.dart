// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:sari/utils/sari_theme.dart';

class CustomFilterChip extends StatefulWidget {
  final String label;
  final Function(bool) onSelected;
  final Function(bool) onChanged;
  bool selected;

  CustomFilterChip(
      {super.key,
      required this.selected,
      required this.label,
      required this.onSelected,
      required this.onChanged});

  @override
  CustomFilterChipState createState() => CustomFilterChipState();
}

class CustomFilterChipState extends State<CustomFilterChip> {
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      selectedColor: Color(SariTheme.primaryPalette.get(92)),
      checkmarkColor: SariTheme.primary,
      labelStyle: TextStyle(
        color: widget.selected
            ? SariTheme.primary
            : Color(SariTheme.neutralPalette.get(40)),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(80),
      ),
      selected: widget.selected,
      onSelected: (value) {
        setState(() => widget.selected = value);
        widget.onSelected(value);
        widget.onChanged(value);
      },
    );
  }
}
