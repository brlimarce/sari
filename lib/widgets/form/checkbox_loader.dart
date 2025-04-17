import 'package:flutter/material.dart';
import 'package:sari/utils/mock_data.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CheckboxLoader extends StatelessWidget {
  final bool isLoading;

  const CheckboxLoader({required this.isLoading, super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enabled: isLoading,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
            child: Column(
                children: MockData.checkboxes.map((option) {
              return CheckboxListTile(
                title: const Text("Name"),
                value: false,
                onChanged: (checked) {},
              );
            }).toList())));
  }
}
