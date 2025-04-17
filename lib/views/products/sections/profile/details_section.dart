import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:sari/utils/sari_theme.dart';

class DetailsSection extends StatelessWidget {
  List<dynamic> meetupPlaces;
  List<dynamic> paymentMethods;

  DetailsSection({
    super.key,
    required this.meetupPlaces,
    required this.paymentMethods,
  });

  /// Render a container that consists of meetup information.
  ///
  /// Return a [Widget] that contains the meetup section.
  Widget _buildMeetupSection(
      BuildContext context,
      String title,
      String titleIconPath,
      List<dynamic> options,
      IconData entryIcon,
      Color entryColor,
      TonalPalette palette) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
            border: Border.all(
              color: Color(palette.get(88)),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
            color: Color(palette.get(98))),
        child: Column(children: [
          /// [Section Header]
          Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 12),
              child: Row(children: [
                // Label
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(palette.get(32)),
                        )),
                // Icon
                Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Image.asset(titleIconPath))
              ])),

          /// [Divider]
          Divider(color: Color(palette.get(88))),

          /// [Section Body]
          Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
              child: Column(
                  children: options.map((e) {
                return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child:
                                  Icon(entryIcon, color: entryColor, size: 16)),

                          // Name
                          Text(e,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: SariTheme.black))
                        ]));
              }).toList()))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// [Meetup Places]
                  _buildMeetupSection(
                    context,
                    "Meetup Places",
                    "assets/meetup_places.png",
                    meetupPlaces,
                    FontAwesomeIcons.locationDot,
                    Theme.of(context).colorScheme.error,
                    SariTheme.secondaryPalette,
                  ),

                  /// [Payment Methods]
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                      child: _buildMeetupSection(
                        context,
                        "Payment Options",
                        "assets/payment_methods.png",
                        paymentMethods,
                        FontAwesomeIcons.solidCircleCheck,
                        SariTheme.green,
                        SariTheme.greenPalette,
                      )),
                ])));
  }
}
