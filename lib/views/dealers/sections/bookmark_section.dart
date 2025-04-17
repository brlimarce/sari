import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/bookmark_model.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/mock_data.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';
import 'package:sari/widgets/preview_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BookmarkSection extends StatefulWidget {
  final String dealer;

  const BookmarkSection({super.key, required this.dealer});

  @override
  BookmarkSectionState createState() => BookmarkSectionState();
}

class BookmarkSectionState extends State<BookmarkSection> {
  final StreamController<List<Bookmark>> _bookmarkStreamController =
      StreamController<List<Bookmark>>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  void _fetchData() async {
    // Fetch the bookmarks from the server.
    Stream<List<Bookmark>> bookmarks =
        context.read<ProductProvider>().getBookmarks(dealer: widget.dealer);
    _bookmarkStreamController.addStream(bookmarks);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _bookmarkStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const IconPlaceholder(
                topMargin: 24,
                iconPath: "assets/error_folder.png",
                title: "Looks like an error...",
                message: BaseError.FETCH_ERROR);
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const IconPlaceholder(
                  topMargin: 24,
                  iconPath: "assets/error_folder.png",
                  title: "Looks like an error...",
                  message: BaseError.NO_CONNECTION_ERROR);

            case ConnectionState.waiting:
              return Skeletonizer(
                  child: GridView.count(
                      childAspectRatio: 0.6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children:
                          List.generate(MockData.previewList.length, (index) {
                        return Padding(
                            padding: EdgeInsets.fromLTRB(
                                (index % 2 != 0) ? 8 : 0,
                                0,
                                (index % 2 != 0) ? 0 : 8,
                                0),
                            child: PreviewCard(
                                product: MockData.previewList[index],
                                onBookmarkTap: (_) {},
                                loading: true));
                      })));

            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.data!.isEmpty) {
                return const IconPlaceholder(
                    topMargin: 24,
                    iconPath: "assets/bookmark.png",
                    title: "No bookmarks yet...",
                    message:
                        "This user currently has not bookmarked any product.");
              } else {
                List<Bookmark> data = snapshot.data!;
                return GridView.count(
                    childAspectRatio: 0.6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    children: List.generate(data.length, (index) {
                      return Padding(
                          padding: EdgeInsets.fromLTRB((index % 2 != 0) ? 8 : 0,
                              0, (index % 2 != 0) ? 0 : 8, 0),
                          child: PreviewCard(
                              onBookmarkTap: (bool isLiked) async {
                                if (isLiked) {
                                  // Delete the bookmark.
                                  return await context
                                      .read<ProductProvider>()
                                      .deleteBookmark(data[index].product.id ??
                                          MockData.preview.id.toString());
                                } else {
                                  // Create the bookmark.
                                  return await context
                                      .read<ProductProvider>()
                                      .createBookmark(data[index].product.id ??
                                          MockData.preview.id.toString());
                                }
                              },
                              product: data[index].product));
                    }));
              }
          }
        });
  }
}
