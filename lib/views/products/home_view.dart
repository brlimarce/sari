import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sari/models/category_model.dart';
import 'package:sari/models/views/preview_view_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/mock_data.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/layout_view.dart';
import 'package:sari/widgets/buttons/add_fab.dart';
import 'package:sari/widgets/bottom_navbar.dart';
import 'package:sari/widgets/custom_filter_chip.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';
import 'package:sari/widgets/preview_card.dart';
import 'package:sari/widgets/refresh_indicator.dart';
// import 'package:sari/widgets/small_chip.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends StatefulWidget {
  static const String route = '/';

  const HomeView({super.key});

  @override
  HomeViewState createState() {
    return HomeViewState();
  }
}

class HomeViewState extends State<HomeView> {
  List<Category> _categories = [];
  Map<String, bool> _sellingTypeMap = {
    for (var item in SELLING_TYPE.keys) item: false
  };

  final Map<String, String> _sortCriteria = {
    "created_at": "Oldest",
    "-created_at": "Newest",
    "-default_price": "Price (Highest to Lowest)",
    "default_price": "Price (Lowest to Highest)"
  };

  // Selected Filters
  List<String> selectedCategories = [];
  List<String> selectedSellingTypes = [];
  String selectedSort = "";

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final StreamController<List<PreviewViewModel>> _productStreamController =
      StreamController<List<PreviewViewModel>>();

  final _minPriceKey = GlobalKey<FormFieldState>();
  final _maxPriceKey = GlobalKey<FormFieldState>();

  // Refresh Controller
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _productStreamController.close();
    _refreshController.dispose();
    super.dispose();
  }

  /// Fetch the [Category] and [Product] from the
  /// server, depending on the selected filters.
  ///
  /// Then, convert the [List<Category>] into a [Map].
  void _fetchData() async {
    // Load the product categories.
    if (_categories.isEmpty) {
      List<Category> c =
          await context.read<ProductProvider>().getAllCategories();
      setState(() {
        _categories = c;
      });
    }

    // Load the products.
    if (!mounted) return;

    // Create a filter map.
    Map<String, dynamic> filters = {};
    if (selectedCategories.isNotEmpty) {
      filters["category"] = selectedCategories;
    }

    if (selectedSellingTypes.isNotEmpty) {
      filters["selling_type"] = selectedSellingTypes;
    }

    if (_minPriceController.text.isNotEmpty) {
      filters["min_price"] = _minPriceController.text;
    }

    if (_maxPriceController.text.isNotEmpty) {
      filters["max_price"] = _maxPriceController.text;
    }

    // Add the search string to the map.
    if (_searchController.text.isNotEmpty) {
      filters["search_string"] = _searchController.text;
    }

    // Add the sort criteria to the map.
    if (selectedSort.isNotEmpty) {
      filters["sort_by"] = selectedSort;
    }

    // Add the valid statuses.
    filters["status"] = [
      ProductStatus.ONGOING,
      ProductStatus.BID_MINE,
      ProductStatus.BID_GRAB,
      ProductStatus.BID_STEAL
    ];

    // Fetch the data with or without the filters.
    Stream<List<PreviewViewModel>> p =
        context.read<ProductProvider>().getAllProducts(filters: filters);
    _productStreamController.addStream(p);
  }

  /// Render the bottom widget of the app bar.
  ///
  /// The widget contains the title, description, search bar,
  /// and filter button.
  ///
  /// The [name] is the first name of the current user.
  PreferredSizeWidget _buildBottomWidget(BuildContext context, String name) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(244),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// [App Bar Header]
                Row(children: [
                  // Title
                  Text("Hello, $name",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(color: SariTheme.white)),

                  // Icon
                  Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child:
                          SvgPicture.asset("assets/svg_icons/emoji_heart.svg"))
                ]),

                // Description
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 40),
                    child: Text("Browse to explore amazing deals and arrivals.",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Color(SariTheme.neutralPalette.get(92))))),

                /// [Search and Filter]
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
                    child: Row(children: [
                      // Search Bar
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            fillColor: SariTheme.white,
                            filled: true,
                            labelText: "Search",
                            hintText: "Enter a name or keyword...",
                            alignLabelWithHint: false,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 28),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(80)),
                            ),
                            suffixIcon: IconButton(
                              icon: FaIcon(FontAwesomeIcons.xmark,
                                  size: 20,
                                  color:
                                      Color(SariTheme.neutralPalette.get(80))),
                              onPressed: () {
                                if (_searchController.text.isNotEmpty) {
                                  _searchController.clear();
                                  _fetchData();
                                }
                              },
                            ),
                          ),
                          onSubmitted: (String value) {
                            _fetchData();
                          },
                        ),
                      ),

                      // Filter Button
                      Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: SariTheme.white,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    if (_categories.isNotEmpty) {
                                      _buildFilterSheet(context);
                                    }
                                  },
                                  icon: Icon(Icons.filter_list_rounded,
                                      color: Color(
                                          SariTheme.neutralPalette.get(92)),
                                      size: 28))))
                    ]))
              ])),
    );
  }

  /// Render the filter and sorting criteria.
  ///
  /// The [context] is the current context of the app.
  void _buildFilterSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 36),
                    child: Wrap(children: [
                      /// [Sort by]
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                          child: Text("Sort by",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w800))),

                      // Sort List
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: _sortCriteria.keys.map((key) {
                            return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                child: CustomFilterChip(
                                    label: _sortCriteria[key] ?? "",
                                    selected: selectedSort == key,
                                    onSelected: (value) {
                                      setState(() {
                                        selectedSort =
                                            selectedSort.isNotEmpty &&
                                                    selectedSort == key
                                                ? ""
                                                : key;
                                      });
                                    },
                                    onChanged: (value) {}));
                          }).toList())),

                      /// [Categories]
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 32, 0, 8),
                          child: Text("Categories",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: SariTheme.secondary))),

                      // Category List
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: _categories.map((c) {
                            return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                child: CustomFilterChip(
                                    label: c.name,
                                    selected: selectedCategories.contains(c.id),
                                    onSelected: (selected) {},
                                    onChanged: (selected) {
                                      if (selected) {
                                        selectedCategories.add(c.id);
                                      } else {
                                        selectedCategories.remove(c.id);
                                      }
                                    }));
                          }).toList())),

                      /// [Selling Type]
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 32, 0, 8),
                          child: Text("Selling Type",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w800))),

                      // Selling Type List
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: SELLING_TYPE.keys.map((key) {
                            return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                child: CustomFilterChip(
                                    label: SELLING_TYPE[key] ?? "",
                                    selected: _sellingTypeMap[key] ?? false,
                                    onSelected: (selected) {
                                      setState(() {
                                        _sellingTypeMap[key] = selected;
                                      });
                                    },
                                    onChanged: (selected) {
                                      if (selected) {
                                        selectedSellingTypes.add(key);
                                      } else {
                                        selectedSellingTypes.remove(key);
                                      }
                                    }));
                          }).toList())),

                      /// [Price Range]
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
                          child: Text("Price Range",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w800))),

                      // Text Fields
                      Row(children: [
                        /// [Minimum Price]
                        Expanded(
                            child: TextFormField(
                                key: _minPriceKey,
                                controller: _minPriceController,
                                keyboardType: TextInputType.number,
                                decoration: OutlinedFieldBorder(
                                  "Min Price",
                                ),
                                onChanged: (value) {
                                  _minPriceKey.currentState!.validate();
                                },
                                validator: (value) {
                                  // Convert the values.
                                  double? maxPrice =
                                      double.tryParse(_maxPriceController.text);
                                  double? minPrice =
                                      double.tryParse(value ?? '0');

                                  // Validate the fields.
                                  if ((minPrice != null && maxPrice != null) &&
                                      (minPrice > maxPrice)) {
                                    return ProductError.MIN_PRICE_GREATER_ERROR;
                                  }

                                  return null;
                                })),

                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FaIcon(FontAwesomeIcons.minus,
                                color: SariTheme.secondary, size: 16)),

                        /// [Maximum Price]
                        Expanded(
                            child: TextFormField(
                                key: _maxPriceKey,
                                controller: _maxPriceController,
                                keyboardType: TextInputType.number,
                                decoration: OutlinedFieldBorder(
                                  "Max Price",
                                ),
                                onChanged: (value) {
                                  _maxPriceKey.currentState!.validate();
                                },
                                validator: (value) {
                                  // Convert the values.
                                  double? minPrice =
                                      double.tryParse(_minPriceController.text);
                                  double? maxPrice =
                                      double.tryParse(value ?? '0');

                                  // Validate the fields.
                                  if ((minPrice != null && maxPrice != null) &&
                                      (minPrice > maxPrice)) {
                                    return ProductError.MAX_PRICE_LESS_ERROR;
                                  }

                                  return null;
                                })),
                      ]),

                      /// [Button Group]
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 52, 0, 16),
                          child: Row(children: [
                            /// [Reset Button]
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: () {
                                      // Reset the chips.
                                      setState(() {
                                        selectedSort = "";
                                        selectedCategories = [];
                                        selectedSellingTypes = [];

                                        _sellingTypeMap = {
                                          for (var item in SELLING_TYPE.keys)
                                            item: false
                                        };
                                      });

                                      // Reset the text fields.
                                      _minPriceController.clear();
                                      _maxPriceController.clear();
                                    },
                                    style: OutlinedButtonStyle(),
                                    child: Text(
                                      "RESET",
                                      style: ButtonTextStyle(
                                          color: SariTheme.primary),
                                    ))),

                            // Divider
                            const SizedBox(width: 8),

                            /// [Apply Button]
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_minPriceKey.currentState!
                                              .validate() &&
                                          _maxPriceKey.currentState!
                                              .validate()) {
                                        // Fetch the data from the server.
                                        _fetchData();
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: FillButtonStyle(),
                                    child: Text(
                                      "APPLY",
                                      style: ButtonTextStyle(),
                                    )))
                          ]))
                    ])));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    String name = context
            .read<DealerAuthProvider>()
            .currentUser
            ?.displayName
            ?.split(' ')[0] ??
        "Guest";

    return Consumer2<DealerAuthProvider, ProductProvider>(
        builder: (context, dealerProvider, productProvider, child) {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      // Dealer
      if (dealerProvider.error.active) {
        ToastAlert.error(context, dealerProvider.error.error);
        dealerProvider.error.clear();
      }

      // Product
      if (productProvider.error.active) {
        ToastAlert.error(context, productProvider.error.error);
        productProvider.error.clear();
      }

      return Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: SariTheme.primary,
              title: Image.asset("assets/logo/logo_white.png",
                  width: 32, height: 32),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              actions: renderActions(context, inverted: true),
              centerTitle: true,
              bottom: _buildBottomWidget(context, name)),
          backgroundColor: Color(SariTheme.primaryPalette.get(98)),
          bottomNavigationBar: BottomNavbar(page: 0),
          floatingActionButton: const AddFab(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: CustomRefreshIndicator(
              controller: _refreshController,
              onLoading: _fetchData,
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const ScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// [Space Allowance]
                        const SizedBox(height: 32),

                        /// [Featured Products]
                        StreamBuilder<List<PreviewViewModel>>(
                            stream: _productStreamController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const IconPlaceholder(
                                    iconPath: "assets/error_folder.png",
                                    title: "Looks like an error...",
                                    message: BaseError.FETCH_ERROR);
                              }

                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return const IconPlaceholder(
                                      iconPath: "assets/error_folder.png",
                                      title: "Looks like an error...",
                                      message: BaseError.NO_CONNECTION_ERROR);

                                case ConnectionState.waiting:
                                  return Skeletonizer(
                                      child: GridView.count(
                                          childAspectRatio: 0.6,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          children: List.generate(
                                              MockData.previewList.length,
                                              (index) {
                                            return Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    (index % 2 != 0) ? 8 : 0,
                                                    0,
                                                    (index % 2 != 0) ? 0 : 8,
                                                    0),
                                                child: PreviewCard(
                                                    product: MockData
                                                        .previewList[index],
                                                    onBookmarkTap: (_) {},
                                                    loading: true));
                                          })));

                                case ConnectionState.active:
                                case ConnectionState.done:
                                  if (snapshot.data!.isEmpty) {
                                    return const IconPlaceholder(
                                        iconPath: "assets/search_products.png",
                                        title: "No products yet...",
                                        message:
                                            "There are no products that match your preferences. Try creating one!");
                                  } else {
                                    List<PreviewViewModel> data =
                                        snapshot.data!;
                                    return GridView.count(
                                        childAspectRatio: 0.6,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        children:
                                            List.generate(data.length, (index) {
                                          return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  (index % 2 != 0) ? 8 : 0,
                                                  0,
                                                  (index % 2 != 0) ? 0 : 8,
                                                  6),
                                              child: PreviewCard(
                                                  onBookmarkTap:
                                                      (bool isLiked) async {
                                                    if (isLiked) {
                                                      // Delete the bookmark.
                                                      return await context
                                                          .read<
                                                              ProductProvider>()
                                                          .deleteBookmark(
                                                              data[index].id ??
                                                                  "");
                                                    } else {
                                                      // Create the bookmark.
                                                      return await context
                                                          .read<
                                                              ProductProvider>()
                                                          .createBookmark(
                                                              data[index].id ??
                                                                  "");
                                                    }
                                                  },
                                                  product: data[index]));
                                        }));
                                  }
                              }
                            }),

                        /// [Space Allowance]
                        const SizedBox(height: 28)
                      ]))));
    });
  }
}
