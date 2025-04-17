import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/sari_theme.dart';

class HeartButton extends StatefulWidget {
  final String productId;
  final bool isBookmarked;
  final Color? inactiveColor;
  final double? size;

  const HeartButton(
      {super.key,
      required this.productId,
      required this.isBookmarked,
      this.inactiveColor,
      this.size});

  @override
  HeartButtonState createState() => HeartButtonState();
}

class HeartButtonState extends State<HeartButton> {
  @override
  Widget build(BuildContext context) {
    return LikeButton(
      size: 24,
      isLiked: widget.isBookmarked,
      circleColor: CircleColor(
          start: Color(SariTheme.pinkPalette.get(20)),
          end: Color(SariTheme.pinkPalette.get(40))),
      bubblesColor: BubblesColor(
        dotPrimaryColor: Color(SariTheme.pinkPalette.get(60)),
        dotSecondaryColor: Color(SariTheme.pinkPalette.get(80)),
      ),
      likeBuilder: (bool isLiked) {
        return FaIcon(
          isLiked ? FontAwesomeIcons.solidBookmark : FontAwesomeIcons.bookmark,
          color: isLiked
              ? SariTheme.pink
              : widget.inactiveColor ?? Color(SariTheme.neutralPalette.get(84)),
          size: widget.size ?? 24,
        );
      },
      onTap: (bool isLiked) async {
        int status = 0;
        if (isLiked) {
          // Delete the bookmark.
          status = await context
              .read<ProductProvider>()
              .deleteBookmark(widget.productId);
        } else {
          // Create the bookmark.
          status = await context
              .read<ProductProvider>()
              .createBookmark(widget.productId);
        }

        return (status == StatusCode.CREATED || status == StatusCode.NO_CONTENT)
            ? !isLiked
            : isLiked;
      },
    );
  }
}
