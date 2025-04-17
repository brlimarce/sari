import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class TransactionTabs extends StatefulWidget {
  int step;
  final Function(int) onTabPressed;
  final List<String> names;
  final TonalPalette palette;

  TransactionTabs({
    super.key,
    required this.step,
    required this.onTabPressed,
    required this.names,
    required this.palette,
  });

  @override
  TransactionTabsState createState() => TransactionTabsState();
}

class TransactionTabsState extends State<TransactionTabs> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth / 2.5;
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ToggleButtons(
            constraints: BoxConstraints.expand(width: width, height: 36),
            borderRadius: BorderRadius.circular(40),
            selectedColor: Color(widget.palette.get(20)),
            selectedBorderColor: Color(widget.palette.get(80)),
            fillColor: Color(widget.palette.get(96)),
            isSelected: List.generate(
                widget.names.length, (index) => index == widget.step),
            onPressed: (int index) {
              widget.onTabPressed(index);
            },
            children: widget.names.map((name) {
              return SizedBox(
                width: width,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ));
    });
  }
}
