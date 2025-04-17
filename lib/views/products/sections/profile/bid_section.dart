import 'package:flutter/material.dart';
import 'package:sari/models/views/bid_view_model.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';

class BidSection extends StatelessWidget {
  List<BidViewModel> bids;
  BidSection({super.key, required this.bids});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 44, 32, 0),
      child: bids.isEmpty
          ? const IconPlaceholder(
              iconPath: "assets/bid_hammer.png",
              title: "No bids yet...",
              message: "Be the first to bid on this product!")
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bids.map((b) {
                String bidder = truncate(b.purchased_by.display_name, 16);

                return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// [Bidder Information]
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// [Icon]
                                CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(b.purchased_by.photo_url)),
                                const SizedBox(width: 16),

                                /// [Name]
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(bidder,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: SariTheme.secondary)),
                                      Text("Bidder",
                                          style: TextStyle(
                                              color: Color(SariTheme
                                                  .neutralPalette
                                                  .get(60))))
                                    ]),
                              ]),

                          /// [Bid Amount]
                          Text(formatToCurrency(b.bid_amount),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: SariTheme.primary)),
                        ]));
              }).toList()),
    ));
  }
}
