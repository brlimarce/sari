// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/product_model.dart';
import 'package:sari/models/review_model.dart';
import 'package:sari/models/views/bid_view_model.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/mock_data.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/dealers/profile_view.dart';
import 'package:sari/views/products/ar_view.dart';
import 'package:sari/views/products/edit_product_form.dart';
import 'package:sari/views/products/home_view.dart';
import 'package:sari/views/products/sections/profile/bid_section.dart';
import 'package:sari/views/products/sections/profile/details_section.dart';
import 'package:sari/views/products/sections/profile/review_section.dart';
import 'package:sari/views/products/sections/profile/schedule_section.dart';
import 'package:sari/views/transactions/buyer_view.dart';
import 'package:sari/views/transactions/seller_view.dart';
import 'package:sari/widgets/buttons/add_icon_button.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:sari/widgets/buttons/heart_button.dart';
import 'package:sari/widgets/buttons/minus_icon_button.dart';
import 'package:sari/widgets/model_viewer_widget.dart';
import 'package:sari/widgets/plain_chip.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductProfileView extends StatefulWidget {
  static const String route = '/product/:id/profile/:seller';
  final String id;
  final bool isOwner;

  const ProductProfileView({
    super.key,
    required this.id,
    required this.isOwner,
  });

  @override
  ProductProfileState createState() => ProductProfileState();
}

class ProductProfileState extends State<ProductProfileView> {
  final _recurrentKey = GlobalKey<FormState>();
  final _biddingKey = GlobalKey<FormState>();

  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _bidController = TextEditingController();

  List<BidViewModel> _bids = [];
  List<Review> _reviews = [];

  Product _product = MockData.product;

  // Loading State
  late bool _loading;

  @override
  void initState() {
    _loading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _bidController.dispose();
    super.dispose();
  }

  /// Fetch [Product] data from the server.
  void _fetchData() async {
    // Fetch product data from the server.
    final product = await context.read<ProductProvider>().getProduct(widget.id);
    if (!mounted) return;
    setState(() {
      _product = product as Product;
    });

    if (product?.selling_type == SELLING_TYPE.keys.first) {
      // Fetch the highest bids from the server.
      final bids = await context
          .read<TransactionProvider>()
          .getHighestBids(product?.id ?? "");
      if (!mounted) return;
      setState(() {
        _bids = bids;
      });
    } else {
      // Fetch the reviews.
      final reviews = await context
          .read<TransactionProvider>()
          .getReviews(product?.id ?? "");
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
      });
    }

    // End fetching data.
    _loading = false;
  }

  /// Render a tab that consists of an icon and a title.
  ///
  /// Return a [Widget] that contains the tab.
  Tab _buildTab(IconData icon, String title) {
    return Tab(
        icon: Icon(icon, size: 16),
        iconMargin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child:
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  /// Group the [Schedule] object based on their
  /// respective dates and times.
  Map<String, List<String>> _createScheduleMap(List<dynamic> schedule) {
    Map<String, List<String>> meetupSchedule = {};
    for (int i = 0; i < schedule.length; i++) {
      // Convert the schedule to a local timezone.
      DateTime startLocal =
          convertToLocalTimezone(DateTime.parse(schedule[i]['start_date']));
      DateTime endLocal =
          convertToLocalTimezone(DateTime.parse(schedule[i]['end_date']));

      // Parse the date to a readable format.
      String date = DateFormat('MMMM d (EEEE)').format(startLocal);

      // Initialize a list if the date doesn't exist.
      if (!meetupSchedule.containsKey(date)) {
        meetupSchedule[date] = [];
      }

      // Parse the start and end time to a readable format.
      String startTime = _formatTime(startLocal.toString());
      String endTime = _formatTime(endLocal.toString());
      meetupSchedule[date]!.add("$startTime - $endTime");
    }

    return meetupSchedule;
  }

  /// Format the [DateTime] to a readable time.
  String _formatTime(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Render a popup menu item.
  ///
  /// The method will return a [Widget] that contains
  /// an icon and a text.
  Widget _buildPopItem(IconData icon, Color iconColor, String action) {
    return Row(children: [
      // Icon
      Icon(icon, color: iconColor, size: 16),

      // Name
      Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
          child: Text(action,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ))),
    ]);
  }

  /// Delete the [Product].
  void _displayDeleteModal() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "Delete Product",
            titleColor: Theme.of(context).colorScheme.onErrorContainer,
            icon: FontAwesomeIcons.trash,
            iconColor: Theme.of(context).colorScheme.error,
            body: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Color(SariTheme.neutralPalette.get(40))),
                children: <TextSpan>[
                  const TextSpan(text: 'You are about to '),
                  TextSpan(
                      text: 'delete',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error)),
                  const TextSpan(text: ' this product. This action '),
                  const TextSpan(
                      text: 'cannot be undone.',
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),
            activeButtonLabel: "Confirm",
            activeButtonColor: Theme.of(context).colorScheme.error,
            onPressed: () async {
              // Delete the product.
              context.loaderOverlay.show();
              int status = await context
                  .read<ProductProvider>()
                  .deleteProduct(_product.id ?? "", [_product.thumbnail_url]);
              context.loaderOverlay.hide();

              // Process the result.
              if (status != StatusCode.CREATED &&
                  status != StatusCode.NO_CONTENT) {
                return;
              }

              context.replace(HomeView.route);
              Navigator.of(context).pop();
              ToastAlert.success(
                  context, "Your product is successfully deleted.");
            },
          );
        });
  }

  /// Cancel the selling of a [Product].
  void _displayCancelModal() {
    final bool cancelled = _product.status == ProductStatus.CANCELLED;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "${cancelled ? "Restore" : "Cancel"} Selling",
            titleColor: cancelled
                ? SariTheme.primary
                : Theme.of(context).colorScheme.onErrorContainer,
            icon: cancelled ? FontAwesomeIcons.rotate : FontAwesomeIcons.ban,
            iconColor: cancelled
                ? SariTheme.green
                : Theme.of(context).colorScheme.error,
            body: RichText(
              textAlign: cancelled ? TextAlign.justify : TextAlign.center,
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Color(SariTheme.neutralPalette.get(40))),
                children: cancelled
                    ? <TextSpan>[
                        const TextSpan(text: 'The product will be '),
                        TextSpan(
                            text: 'available for sale',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: SariTheme.green)),
                        const TextSpan(
                            text: ' again, but previous transactions '),
                        TextSpan(
                            text: 'cannot be restored.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error)),
                      ]
                    : <TextSpan>[
                        const TextSpan(
                            text: 'All related transactions will be '),
                        TextSpan(
                            text: 'canceled',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error)),
                        const TextSpan(text: ' and '),
                        const TextSpan(
                            text: 'cannot be undone.',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
              ),
            ),
            activeButtonLabel: cancelled ? "Restore" : "Confirm",
            activeButtonColor: cancelled
                ? SariTheme.green
                : Theme.of(context).colorScheme.error,
            onPressed: () async {
              // Cancel/restore the product for sale.
              context.loaderOverlay.show();
              int status = await context
                  .read<ProductProvider>()
                  .cancelSelling(_product.id ?? "");

              // Process the result.
              context.loaderOverlay.hide();
              if (status != StatusCode.NO_CONTENT) return;

              // Redirect to the profile page.
              context.replace(SellerView.route);

              // Display an alert.
              Navigator.of(context).pop();
              ToastAlert.success(
                  context,
                  _product.status == ProductStatus.CANCELLED
                      ? "Your product is now available for sale!"
                      : "Your product is no longer available for sale. You can restore it on its profile.");
            },
          );
        });
  }

  /// Create a [Transaction] for products that
  /// are for recurrent selling.
  void _displayPurchaseModal() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "Confirm Purchase",
            titleColor: SariTheme.primary,
            icon: FontAwesomeIcons.cartPlus,
            activeButtonLabel: "Submit",
            body: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// [Description]
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Color(SariTheme.neutralPalette.get(40))),
                    children: const <TextSpan>[
                      TextSpan(text: 'Select the '),
                      TextSpan(
                          text: 'number of items',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' you want to purchase.')
                    ],
                  ),
                ),

                /// [Quantity]
                const SizedBox(height: 32),
                Form(
                    key: _recurrentKey,
                    child: Row(children: [
                      Expanded(
                          child: TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          // Check if the input is empty.
                          if (value == null || value.isEmpty) {
                            return ProductError.REQUIRED_ERROR;
                          }

                          // Convert the value into a number.
                          final qty = int.tryParse(value);
                          if (qty == null || qty <= 0) {
                            return "It must be more than 0.";
                          } else if (qty > (_product.stock_qty ?? 0)) {
                            return "It exceeds stock quantity.";
                          }

                          return null;
                        },
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Color(SariTheme.neutralPalette.get(40))),
                        onChanged: (_) {
                          _recurrentKey.currentState!.validate();
                        },
                        decoration:
                            OutlinedFieldBorder("Quantity", hintText: "0"),
                      )),
                    ])),
                const SizedBox(height: 10),

                /// [Stock Quantity]
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Color(SariTheme.neutralPalette.get(40))),
                        children: <TextSpan>[
                          const TextSpan(text: 'Stock Quantity: '),
                          TextSpan(
                              text: "${_product.stock_qty}",
                              style: TextStyle(
                                  color: SariTheme.green,
                                  fontWeight: FontWeight.bold))
                        ])),
              ],
            ),
            onPressed: () async {
              if (_recurrentKey.currentState!.validate()) {
                // Create a new purchase in the server.
                context.loaderOverlay.show();
                int quantity = int.parse(_qtyController.text);
                int status = await context
                    .read<TransactionProvider>()
                    .createPurchase(_product.id ?? "", quantity);
                Navigator.of(context).pop();

                // Check if the transaction is created.
                if (!mounted) return;
                if (status != StatusCode.CREATED) return;

                // Display the success modal.
                context.loaderOverlay.hide();
                _displaySuccessModal(false);
              }
            },
          );
        });
  }

  /// Create a [Transaction] for products that
  /// are for bidding.
  void _displayBidModal() {
    bool isSteal = _product.status == ProductStatus.BID_STEAL;
    String endDate = DateFormat('MMMM d').format(_product.end_date);
    _bidController.text = _product.default_price.toString();

    Map<String, dynamic> data = {
      ProductStatus.BID_MINE: {
        "name": "Mine",
        "icon": FontAwesomeIcons.solidHand,
      },
      ProductStatus.BID_GRAB: {
        "name": "Grab",
        "icon": FontAwesomeIcons.hands,
      },
      ProductStatus.BID_STEAL: {
        "name": "Steal",
        "icon": FontAwesomeIcons.handSparkles,
      },
    };

    // Display the dialog.
    showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
              title: "${data[_product.status]['name']} Product",
              icon: data[_product.status]['icon'],
              body: isSteal

                  /// [Steal]
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// [Description]
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Color(
                                        SariTheme.neutralPalette.get(40))),
                            children: <TextSpan>[
                              const TextSpan(text: 'Place your bid '),
                              TextSpan(
                                  text: 'before $endDate',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const TextSpan(
                                  text: '. Increase your bid by at least '),
                              TextSpan(
                                  text: 'Php ${_product.steal_increment}.',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                        /// [Steal Bid]
                        const SizedBox(height: 32),
                        Form(
                            key: _biddingKey,
                            child: Row(children: [
                              // Subtract Button
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                  child: MinusIconButton(onPressed: () {
                                    double bid =
                                        double.parse(_bidController.text);
                                    if (bid > (_product.default_price ?? 0)) {
                                      bid -= (_product.steal_increment ?? 10);
                                      _bidController.text = bid.toString();
                                      _biddingKey.currentState!.validate();
                                    }
                                  })),

                              // Bid Field
                              Expanded(
                                  child: TextFormField(
                                controller: _bidController,
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                validator: (value) {
                                  // Check if the input is empty.
                                  if (value == null || value.isEmpty) {
                                    return ProductError.REQUIRED_ERROR;
                                  }

                                  // Convert the value into a number.
                                  final bid = double.tryParse(value);
                                  if (bid == null ||
                                      bid <= (_product.default_price ?? 0)) {
                                    return "Your bid must be more than the current bid.";
                                  }

                                  return null;
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Color(
                                            SariTheme.neutralPalette.get(40))),
                                onChanged: (_) {
                                  _biddingKey.currentState!.validate();
                                },
                                decoration:
                                    OutlinedFieldBorder("Bid", hintText: "0"),
                              )),

                              // Add Button
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: AddIconButton(onPressed: () {
                                    double bid =
                                        double.parse(_bidController.text);
                                    bid += (_product.steal_increment ?? 10);

                                    _bidController.text = bid.toString();
                                    _biddingKey.currentState!.validate();
                                  })),
                            ])),

                        /// [Space Allowance]
                        const SizedBox(height: 24)
                      ],
                    )

                  /// [Mine and Grab]
                  : RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Color(SariTheme.neutralPalette.get(40))),
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Once you place this bid, you can '),
                          TextSpan(
                              text: 'no longer cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error)),
                          const TextSpan(text: ' it.'),
                        ],
                      ),
                    ),
              activeButtonLabel: isSteal ? "Submit" : "Confirm",
              onPressed: () async {
                if (isSteal) {
                  /// [Steal]
                  if (_biddingKey.currentState!.validate()) {
                    // Create a new purchase in the server.
                    context.loaderOverlay.show();
                    double bid = double.parse(_bidController.text);
                    int status = await context
                        .read<TransactionProvider>()
                        .createBid(_product.id ?? "", bid: bid);
                    Navigator.of(context).pop();

                    // End the loading icon.
                    if (!mounted) return;
                    context.loaderOverlay.hide();
                    if (status != StatusCode.CREATED) return;

                    // Display the success modal.
                    _displaySuccessModal(true);
                  }
                } else {
                  /// [Mine and Grab]
                  context.loaderOverlay.show();
                  int status = await context
                      .read<TransactionProvider>()
                      .createBid(_product.id ?? "");
                  Navigator.of(context).pop();

                  // End the loading icon.
                  if (!mounted) return;
                  context.loaderOverlay.hide();
                  if (status != StatusCode.CREATED) return;

                  // Display the success modal.
                  _displaySuccessModal(true);
                }
              });
        });
  }

  /// Display a success modal after [Transaction] is created.
  void _displaySuccessModal(bool bidding) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "${bidding ? "Bid" : "Order"} Completed",
            icon: FontAwesomeIcons.solidHeart,
            iconColor: SariTheme.pink,
            body: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Color(SariTheme.neutralPalette.get(40))),
                children: <TextSpan>[
                  const TextSpan(text: 'You '),
                  TextSpan(
                      text:
                          'successfully placed ${bidding ? "a bid" : "an order"}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text: '. Check your transactions for more information.')
                ],
              ),
            ),
            activeButtonLabel: "View",
            inactiveButtonLabel: "Go Back",
            onPressed: () {
              Navigator.of(context).pop();
              context.replace(BuyerView.route);
            },
            onInactivePressed: () {
              Navigator.of(context).pop();
              context.replace(HomeView.route);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> scheduleMap =
        _createScheduleMap(_product.meetup_schedule);

    // Determine the button action.
    bool bidding = _product.selling_type == SELLING_TYPE.keys.first;
    String actionLabel = !bidding
        ? "Purchase"
        : (ProductStatus.NAMES[_product.status] ?? "Error").toUpperCase();

    // Check if the product is owned by the current user.

    return Consumer2<ProductProvider, TransactionProvider>(
        builder: (context, productProvider, transactionProvider, child) {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      // Product
      if (productProvider.error.active) {
        ToastAlert.error(context, productProvider.error.error);
        productProvider.error.clear();
      }

      // Transaction
      if (transactionProvider.error.active) {
        ToastAlert.error(context, transactionProvider.error.error);
        transactionProvider.error.clear();
      }

      return Scaffold(
          backgroundColor: Color(SariTheme.neutralPalette.get(99)),
          body: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    /// [Model Viewer]
                    Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(colors: [
                          Color.fromRGBO(226, 232, 240, 1),
                          Color.fromRGBO(148, 163, 184, 1)
                        ]),
                        image: DecorationImage(
                            image: AssetImage('assets/logo_overlay.png'),
                            fit: BoxFit.cover),
                      ),
                      child: SizedBox(
                          height: 400,
                          child: _loading
                              ? Container()
                              : ModelViewerWidget(
                                  url: _product.scan_url, zoom: '8m')),
                    ),

                    /// [Back Button]
                    Positioned(
                      top: 32,
                      left: 16,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: SariTheme.white),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ),

                    /// [AR View]
                    Positioned(
                        right: 32,
                        bottom: 48,
                        child: Container(
                            decoration: BoxDecoration(
                                color: SariTheme.white, shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () {
                                  String route = ArView.route
                                      .replaceAll(":id", _product.id!);
                                  context.push(route.replaceAll(":url",
                                      Uri.encodeComponent(_product.scan_url)));
                                },
                                icon: Icon(Icons.view_in_ar_rounded,
                                    color: SariTheme.secondary)))),

                    /// [More Actions]
                    Positioned(
                        top: widget.isOwner ? 32 : 44,
                        right: widget.isOwner ? 16 : 28,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// [Bookmark Button]
                              if (!widget.isOwner)
                                HeartButton(
                                    productId: _product.id ?? "",
                                    isBookmarked:
                                        _product.is_bookmarked ?? false,
                                    inactiveColor: SariTheme.white,
                                    size: 20),

                              /// [More Actions]
                              if (widget.isOwner)
                                IconButton(
                                  icon: Icon(Icons.more_vert,
                                      color: SariTheme.white),
                                  onPressed: () async {
                                    final bool isCancelled = _product.status ==
                                        ProductStatus.CANCELLED;

                                    final bool isCompleted = _product.status ==
                                        ProductStatus.COMPLETED;

                                    /// [Context Menu]
                                    await showMenu(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                          MediaQuery.of(context).size.width,
                                          0,
                                          0,
                                          MediaQuery.of(context).size.height),
                                      items: <PopupMenuEntry>[
                                        /// [Reopen Selling]
                                        if (isCompleted)
                                          PopupMenuItem(
                                              onTap: () {
                                                context.push(EditProductFormView
                                                    .route
                                                    .replaceAll(
                                                        ":id", _product.id!));
                                              },
                                              child: _buildPopItem(
                                                  FontAwesomeIcons.repeat,
                                                  SariTheme.green,
                                                  "Reopen Selling")),

                                        /// [Delete Product]
                                        if (isCancelled)
                                          PopupMenuItem(
                                              onTap: _displayDeleteModal,
                                              child: _buildPopItem(
                                                  FontAwesomeIcons.trash,
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                  "Delete Product")),

                                        /// [Cancel Selling]
                                        if (!isCompleted)
                                          PopupMenuItem(
                                              onTap: _displayCancelModal,
                                              child: _buildPopItem(
                                                  !isCancelled
                                                      ? FontAwesomeIcons.ban
                                                      : FontAwesomeIcons.rotate,
                                                  !isCancelled
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                      : SariTheme.green,
                                                  "${isCancelled ? "Restore" : "Cancel"} Selling")),
                                      ],
                                    );
                                  },
                                )
                            ])),

                    /// [Border]
                    Positioned(
                      top: 372,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Color(SariTheme.neutralPalette.get(99)),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ],
                ),

                /// [Product Information]
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// [Category]
                        _loading
                            ? Skeletonizer(
                                child: Text("Furniture",
                                    style:
                                        Theme.of(context).textTheme.bodySmall))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    // Icon
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 6, 4),
                                        child: Icon(FontAwesomeIcons.tag,
                                            color: Color(SariTheme
                                                .neutralPalette
                                                .get(80)),
                                            size: 12)),

                                    // Name
                                    Text(_product.category.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Color(SariTheme
                                                    .neutralPalette
                                                    .get(70))))
                                  ]),

                        /// [Product Name]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: _loading
                                ? Skeletonizer(
                                    child: Text("Deleted Product",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium))
                                : Text(_product.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.w900))),
                      ]),
                ),

                /// [Secondary Product Information]
                Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// [Selling End Date]
                          _loading
                              ? Skeletonizer(
                                  child: Text("Until January 1, 2024",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall))
                              : Row(children: [
                                  // Icon
                                  Icon(FontAwesomeIcons.clock,
                                      color: Color(
                                          SariTheme.neutralPalette.get(80)),
                                      size: 14),

                                  // Deadline
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Text(
                                          "Until ${DateFormat('MMMM d, hh:mm a').format(convertToLocalTimezone(_product.end_date))}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error)))
                                ]),

                          /// [Bullet]
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(FontAwesomeIcons.solidCircle,
                                  color: SariTheme.secondary, size: 4)),

                          /// [Rating]
                          _loading
                              ? Skeletonizer(
                                  child: Text("0.00 Ratings",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall))
                              : Row(children: [
                                  // Icon
                                  Icon(FontAwesomeIcons.solidStar,
                                      color: SariTheme.yellow, size: 14),

                                  // Deadline
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Text(
                                          "${_product.rating?.toStringAsFixed(2) ?? "0.0"} Ratings",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(SariTheme
                                                      .neutralPalette
                                                      .get(50)))))
                                ]),
                        ])),

                /// [Product Description]
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
                  child: _loading
                      ? Skeletonizer(
                          child: Text(MockData.product.description,
                              style: Theme.of(context).textTheme.bodyMedium))
                      : Text(_product.description,
                          textAlign: TextAlign.justify,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color:
                                      Color(SariTheme.neutralPalette.get(40)))),
                ),

                /// [Product Keywords]
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                  child: _loading
                      ? Wrap(
                          spacing: 8.0,
                          children: MockData.product.product_keyword
                              .map((_) => Skeletonizer(
                                      child: Chip(
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: -4),
                                    backgroundColor:
                                        Color(SariTheme.neutralPalette.get(96)),
                                    label: const Skeleton.ignore(
                                        child: Text("keyword")),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 0),
                                    side: const BorderSide(
                                        color: Colors.transparent),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(120),
                                    ),
                                  )))
                              .toList(),
                        )
                      : Wrap(
                          spacing: 8.0,
                          children: _product.product_keyword
                              .map((keyword) => PlainChip(
                                    label: keyword.toUpperCase(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    backgroundColor:
                                        Color(SariTheme.primaryPalette.get(96)),
                                    foregroundColor: SariTheme.primary,
                                  ))
                              .toList(),
                        ),
                ),

                /// [Product Seller]
                Padding(
                    padding: const EdgeInsets.fromLTRB(32, 4, 32, 40),
                    child: InkWell(
                        onTap: () {
                          // Redirect to the seller's profile.
                          String route = ProfileView.route.replaceAll(
                            ':id',
                            _product.created_by?['fb_id'] ?? MockData.dealer.id,
                          );

                          // Redirect to the route.
                          context.push(route);
                        },
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon
                              _loading
                                  ? const Skeletonizer(child: CircleAvatar())
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                      _product.created_by?['photo_url'] ?? "",
                                    )),

                              // Name
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 2),
                                            child: _loading
                                                ? const Skeletonizer(
                                                    child: Text("Jane Doe"))
                                                : Text(
                                                    _product.created_by?[
                                                            'display_name'] ??
                                                        "Jane Doe",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600))),
                                        _loading
                                            ? Skeletonizer(
                                                child: Text("Seller",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall))
                                            : Text("Seller",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: Color(SariTheme
                                                            .neutralPalette
                                                            .get(50)))),
                                      ]))
                            ]))),

                /// [Meetup Information]
                _loading
                    ? Skeletonizer(
                        child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: <Widget>[
                            TabBar(
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(
                                    width: 2.5,
                                    color: Color(
                                        SariTheme.neutralPalette.get(80))),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: SariTheme.secondary,
                              unselectedLabelColor:
                                  Color(SariTheme.neutralPalette.get(60)),
                              tabs: <Tab>[
                                _buildTab(FontAwesomeIcons.solidMap, "Details"),
                                _buildTab(
                                    FontAwesomeIcons.solidClock, "Schedule"),
                                _buildTab(
                                    bidding
                                        ? FontAwesomeIcons.coins
                                        : FontAwesomeIcons.solidStar,
                                    bidding ? "Bids" : "Reviews"),
                              ],
                            ),
                            const SizedBox(height: 100)
                          ],
                        ),
                      ))
                    : DefaultTabController(
                        length: 3,
                        child: Column(
                          children: <Widget>[
                            /// [Tab Bar]
                            TabBar(
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(
                                    width: 2.5, color: SariTheme.secondary),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: SariTheme.secondary,
                              unselectedLabelColor:
                                  Color(SariTheme.neutralPalette.get(60)),
                              tabs: <Tab>[
                                /// [Tabs]
                                _buildTab(FontAwesomeIcons.solidMap, "Details"),
                                _buildTab(
                                    FontAwesomeIcons.solidClock, "Schedule"),
                                _buildTab(
                                    bidding
                                        ? FontAwesomeIcons.coins
                                        : FontAwesomeIcons.solidStar,
                                    bidding ? "Bids" : "Reviews"),
                              ],
                            ),

                            /// [Tab Bar View]
                            SizedBox(
                                height: 400,
                                child: TabBarView(
                                  children: [
                                    /// [Meetup Information]
                                    DetailsSection(
                                        meetupPlaces: _product.meetup_place,
                                        paymentMethods:
                                            _product.payment_method),

                                    /// [Meetup Schedule]
                                    ScheduleSection(schedule: scheduleMap),

                                    /// [Highest Bids]
                                    bidding
                                        ? BidSection(bids: _bids)
                                        : ReviewSection(reviews: _reviews)
                                  ],
                                )),
                          ],
                        ),
                      )
              ])),

          /// [Call to Action]
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Color(SariTheme.neutralPalette.get(80)), width: 0.5),
              ),
            ),
            child: BottomAppBar(
              color: SariTheme.white,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    /// [Default Price]
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 28, 0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label
                              _loading
                                  ? Text("Default Price",
                                      style:
                                          Theme.of(context).textTheme.bodySmall)
                                  : Text(
                                      bidding ? "Current Bid" : "Default Price",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Color(SariTheme
                                                  .neutralPalette
                                                  .get(50)))),

                              // Price
                              _loading
                                  ? Skeletonizer(
                                      child: Text("Php 99.00",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 22)))
                                  : Text(
                                      formatToCurrency(_product.default_price ??
                                          MockData.preview.default_price),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: SariTheme.primary)),
                            ])),

                    /// [Call to Action]
                    Expanded(
                        child: _loading
                            ? Skeletonizer(
                                child: ElevatedButton(
                                    onPressed: () {},
                                    style: FillButtonStyle(
                                        background: Color(
                                            SariTheme.neutralPalette.get(90))),
                                    child: const Text("")))
                            : ElevatedButton(
                                onPressed: () {
                                  // Disable the button for cancelled and completed products.
                                  if (_product.status ==
                                          ProductStatus.CANCELLED ||
                                      _product.status ==
                                          ProductStatus.COMPLETED ||
                                      widget.isOwner) {
                                    return;
                                  }

                                  // Display the modal.
                                  if (bidding) {
                                    // For Bidding
                                    _displayBidModal();
                                  } else {
                                    // Recurrent Selling
                                    _displayPurchaseModal();
                                  }
                                },
                                style: FillButtonStyle(
                                    background: _product.status ==
                                                ProductStatus.CANCELLED ||
                                            _product.status ==
                                                ProductStatus.COMPLETED ||
                                            widget.isOwner
                                        ? Color(
                                            SariTheme.neutralPalette.get(80))
                                        : SariTheme.secondary),
                                child: Text(
                                  actionLabel.toUpperCase(),
                                  style: ButtonTextStyle(),
                                ))),
                  ])),
            ),
          ));
    });
  }
}
