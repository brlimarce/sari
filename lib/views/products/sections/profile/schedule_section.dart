import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/widgets/plain_chip.dart';

class ScheduleSection extends StatelessWidget {
  Map<String, List<String>> schedule;
  ScheduleSection({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: schedule.keys.map((date) {
                  String dateOnly = date.split('(')[0];
                  String dayOnly = date.split('(')[1].replaceAll(')', "");

                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// [Date]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon
                                  Icon(
                                    FontAwesomeIcons.clock,
                                    size: 18,
                                    color:
                                        Color(SariTheme.neutralPalette.get(72)),
                                  ),

                                  // Name
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 4, 0),
                                      child: Text(dateOnly,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: SariTheme.secondary))),

                                  // Day of the Week
                                  PlainChip(
                                    label: dayOnly.toUpperCase(),
                                    foregroundColor: Color(
                                        SariTheme.secondaryPalette.get(20)),
                                    backgroundColor: Color(
                                        SariTheme.secondaryPalette.get(92)),
                                  )
                                ])),

                        /// [Time]
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: schedule[date]!.map((time) {
                              return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 8, 32),
                                  child: Chip(
                                      side: BorderSide(
                                          color: Color(SariTheme.neutralPalette
                                              .get(80))),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: Color(
                                          SariTheme.neutralPalette.get(99)),
                                      label: Text(time,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(SariTheme
                                                      .neutralPalette
                                                      .get(30))))));
                            }).toList()))
                      ]);
                }).toList())));
  }
}
