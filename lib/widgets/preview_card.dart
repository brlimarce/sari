import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/views/preview_view_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/products/product_profile.dart';
import 'package:sari/widgets/buttons/heart_button.dart';
import 'package:sari/widgets/plain_chip.dart';
import 'package:sari/widgets/server_timer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PreviewCard extends StatelessWidget {
  final PreviewViewModel product;
  final bool loading;
  final Function(bool) onBookmarkTap;

  const PreviewCard({
    super.key,
    required this.product,
    required this.onBookmarkTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Truncate the product name if it's too long.
    String name = truncate(product.name, 14);

    // Check if the product is owned by the current user.
    bool isOwner = context.read<DealerAuthProvider>().user?.uid ==
        product.created_by.fb_id;

    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          String route =
              ProductProfileView.route.replaceAll(':id', product.id!);
          route = route.replaceAll(':seller', product.created_by.fb_id);
          context.push(route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [Product Thumbnail]
            /// Remove the [Stack] widget while a skeleton is displayed.
            AspectRatio(
              aspectRatio: 1 / 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                child: loading
                    ? Image.network(product.thumbnail_url, fit: BoxFit.cover)
                    : Stack(
                        children: [
                          /// [Product Thumbnail]
                          Image.network(product.thumbnail_url,
                              fit: BoxFit.cover),

                          /// [Bookmark Button]
                          if (!isOwner)
                            Positioned(
                                top: 10,
                                right: 8,
                                child: HeartButton(
                                  productId: product.id!,
                                  isBookmarked: product.is_bookmarked ?? false,
                                )),
                        ],
                      ),
              ),
            ),

            /// [Product Information]
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// [Product Name]
                    Expanded(
                        child: Text(name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.w900))),

                    /// [Rating]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FaIcon(FontAwesomeIcons.solidStar,
                            color: SariTheme.yellow, size: 10),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                            child: Text(
                                product.rating?.toStringAsFixed(2) ?? "0.00",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Color(SariTheme.neutralPalette
                                            .get(40))))),
                      ],
                    )
                  ],
                )),

            /// [Selling End Date]
            ServerTimer(milliseconds: product.timestamp),

            /// [Product Price]
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// [Product Price]
                          Text(formatToCurrency(product.default_price),
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontWeight: FontWeight.w900)),

                          /// [Product Status]
                          Skeleton.ignore(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: PlainChip(
                                      label: (ProductStatus
                                                  .NAMES[product.status] ??
                                              "Error")
                                          .toUpperCase(),
                                      backgroundColor:
                                          ProductStatus.getBackgroundColor(
                                              context, product.status),
                                      foregroundColor:
                                          ProductStatus.getForegroundColor(
                                              context, product.status))))
                        ])))
          ],
        ));
  }
}
