import 'package:flutter/material.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class FormIndicator extends StatelessWidget {
  FormIndicator({
    required this.step,
    required this.totalSteps,
    this.color,
    super.key,
  });

  late int step;
  late int totalSteps;
  late Color? color;

  @override
  Widget build(BuildContext context) {
    return StepProgressIndicator(
      totalSteps: totalSteps,
      padding: 0,
      currentStep: step + 1,
      size: 5,
      unselectedColor: Color(SariTheme.neutralPalette.get(87)),
      selectedColor: color ?? SariTheme.primary,
    );
  }
}
