import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sari/models/review_model.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';

class ReviewSection extends StatelessWidget {
  List<Review> reviews;
  ReviewSection({super.key, required this.reviews});

  /// Return the remaining time in a human-readable format.
  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes == 0) {
      return "Just now";
    } else if (difference.inHours == 0) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inDays == 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays > 15) {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 44, 32, 0),
      child: reviews.isEmpty
          ? const IconPlaceholder(
              iconPath: "assets/rating.png",
              title: "No reviews yet...",
              message: "Be the first to rate and review the product!")
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reviews.map((r) {
                return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// [User Information]
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// [Avatar]
                                      CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              r.reviewed_by!.photo_url)),
                                      const SizedBox(width: 16),

                                      /// [Name and Rating]
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                r.reviewed_by?.display_name ??
                                                    "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w900)),

                                            /// [Rating]
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 4, 0, 0),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 0, 8, 0),
                                                          child: Icon(
                                                              FontAwesomeIcons
                                                                  .solidStar,
                                                              color: SariTheme
                                                                  .yellow,
                                                              size: 12)),
                                                      Text(
                                                          r.product_rating
                                                              .toStringAsFixed(
                                                                  2),
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(SariTheme
                                                                      .neutralPalette
                                                                      .get(
                                                                          50))))
                                                    ]))
                                          ]),
                                    ]),

                                /// [Time]
                                Text(
                                    _timeAgo(
                                        convertToLocalTimezone(r.created_at!)),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Color(SariTheme
                                                .neutralPalette
                                                .get(50))))
                              ]),

                          /// [Review]
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(r.review,
                                  textAlign: TextAlign.justify,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Color(SariTheme.neutralPalette
                                              .get(50))))),

                          /// [Divider]
                          reviews.indexOf(r) == reviews.length - 1
                              ? Container()
                              : const Divider(),
                        ]));
              }).toList()),
    ));
  }
}
