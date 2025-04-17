import 'package:flutter/material.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/utils.dart';

class FormButtonGroup extends StatelessWidget {
  const FormButtonGroup({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    this.backgroundColor,
    this.foregroundColor,
  });

  final int step;
  final int totalSteps;
  final void Function() onBack;
  final void Function() onNext;

  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Expanded(
                  child: TextButton(
                onPressed: () {
                  onBack();
                },
                child: Text((step > 0) ? "BACK" : "",
                    style: TextStyle(
                        color: Color(SariTheme.neutralPalette.get(70)))),
              )),

              const SizedBox(width: 8),

              // Proceed Button
              Expanded(
                  child: ElevatedButton(
                      onPressed: () async {
                        onNext();
                      },
                      style: FillButtonStyle(background: backgroundColor),
                      child: Text(
                        (step < totalSteps - 1) ? "PROCEED" : "SUBMIT",
                        style: ButtonTextStyle(color: foregroundColor),
                      )))
            ]));
  }
}
