import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlainChip extends StatelessWidget {
  Color backgroundColor;
  Color? foregroundColor;
  String? label;
  Widget? customLabel;
  EdgeInsetsGeometry? padding;

  PlainChip(
      {super.key,
      required this.backgroundColor,
      this.foregroundColor,
      this.label,
      this.customLabel,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return Skeleton.ignore(
        child: Chip(
            backgroundColor: backgroundColor,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            labelPadding: padding ??
                const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
            side: const BorderSide(color: Colors.transparent, width: 0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(120))),
            label: customLabel ??
                Text((label ?? "Deleted").toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                    ))));
  }
}
