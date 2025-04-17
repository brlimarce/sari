import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
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
import 'package:sari/views/products/ar_view.dart';
import 'package:sari/views/products/product_profile.dart';
import 'package:sari/views/products/product_scan_view.dart';
import 'package:sari/views/transactions/product_transaction_view.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';
import 'package:sari/widgets/transactions/transaction_header.dart';
import 'package:sari/widgets/transactions/transaction_preview.dart';
import 'package:sari/widgets/transactions/transaction_tabs.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SellerView extends StatefulWidget {
  static const String route = '/products';
  int step = 0;

  final List<String> PROCESSING_STATUSES = [
    ProductStatus.PROCESSING,
    ProductStatus.READY_TO_PUBLISH,
    ProductStatus.SCAN_FAILED,
  ];

  List<String> status = [];

  SellerView({super.key});

  @override
  SellerViewState createState() => SellerViewState();
}

class SellerViewState extends State<SellerView> {
  final StreamController<List<PreviewViewModel>> _productStreamController =
      StreamController<List<PreviewViewModel>>();

  @override
  void initState() {
    widget.status = widget.PROCESSING_STATUSES;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _productStreamController.close();
    super.dispose();
  }

  /// Fetch [Product] data from the server.
  void _fetchData() async {
    String? dealer = context.read<DealerAuthProvider>().user?.uid;
    if (!context.mounted) return;

    /// Fetch [Product] from the server.
    Stream<List<PreviewViewModel>> p =
        context.read<ProductProvider>().getAllProducts(filters: {
      "status": widget.status,
      "dealer": dealer!,
    });

    _productStreamController.addStream(p);
  }

  /// Render the processing buttons.
  ///
  /// [id] is the product ID.
  /// [status] is the status of the product.
  Widget _renderProcessingButtons(String id, String scanUrl, String status) {
    return Column(children: [
      Row(children: [
        /// [Re-scan Product]
        Expanded(
            child: OutlinedButton(
                onPressed: () {
                  String route = ProductScanView.route.replaceAll(":id", id);
                  context.replace(route.replaceAll(":priority", "false"));
                },
                style: OutlinedButtonStyle(border: SariTheme.secondary),
                child: Text("RE-SCAN",
                    style: ButtonTextStyle(color: SariTheme.secondary)))),
        const SizedBox(width: 8),

        /// [View Product]
        if (scanUrl != "/")
          Expanded(
              child: FilledButton(
                  onPressed: () {
                    String route = ArView.route.replaceAll(":id", id);
                    context.push(
                        route.replaceAll(":url", Uri.encodeComponent(scanUrl)));
                  },
                  style: FillButtonStyle(background: SariTheme.secondary),
                  child: Text("VIEW", style: ButtonTextStyle()))),
      ]),

      /// [Publish Product]
      if (status == ProductStatus.READY_TO_PUBLISH)
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                              title: "Publish Product",
                              titleColor: SariTheme.secondary,
                              icon: FontAwesomeIcons.upload,
                              iconColor: SariTheme.green,
                              body: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Color(SariTheme
                                                .neutralPalette
                                                .get(40))),
                                    children: const <TextSpan>[
                                      TextSpan(
                                          text:
                                              'Publishing this product will make it '),
                                      TextSpan(
                                          text: 'visible to everyone.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              ' Are you sure you want to continue?')
                                    ]),
                              ),
                              activeButtonLabel: "Confirm",
                              activeButtonColor: SariTheme.green,
                              onPressed: () {
                                _publishProduct(id);
                              });
                        });
                  },
                  style: FillButtonStyle(background: SariTheme.primary),
                  child: Text("PUBLISH", style: ButtonTextStyle()))),
        )
    ]);
  }

  /// Publish the product.
  ///
  /// [id] is the product ID.
  void _publishProduct(String id) async {
    context.loaderOverlay.show();
    int response = await context.read<ProductProvider>().publishProduct(id);
    if (!mounted) return;

    if (response == StatusCode.OK) {
      context.loaderOverlay.hide();
      Navigator.of(context).pop();

      _fetchData();
      ToastAlert.success(
          context, "Your product is live! Take a look on the home page.");
    }
  }

  @override
  Widget build(BuildContext context) {
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

      return LayoutView(
        page: 2,
        implied: false,
        child: SingleChildScrollView(
          child: Column(children: [
            /// [Header]
            TransactionHeader(
              palette: SariTheme.greenPalette,
              iconPath: "assets/transaction_products.png",
              name: "Products",
              children: const <TextSpan>[
                TextSpan(text: 'View and track your '),
                TextSpan(
                    text: 'processing',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' and '),
                TextSpan(
                    text: 'published products.',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' Publish them to make them '),
                TextSpan(
                    text: 'public.',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            /// [Tabs]
            TransactionTabs(
                step: widget.step,
                names: const [
                  "Processing",
                  "Published",
                  "Completed",
                  "Cancelled"
                ],
                palette: SariTheme.greenPalette,
                onTabPressed: (int index) {
                  // Determine the status based on the index.
                  List<String> status = [];
                  switch (index) {
                    case 0:
                      status = widget.PROCESSING_STATUSES;
                      break;
                    case 1:
                      status = [
                        ProductStatus.ONGOING,
                        ProductStatus.BID_MINE,
                        ProductStatus.BID_GRAB,
                        ProductStatus.BID_STEAL
                      ];
                      break;
                    case 2:
                      status = [ProductStatus.COMPLETED];
                      break;
                    case 3:
                      status = [ProductStatus.CANCELLED];
                      break;
                  }

                  // Set the current step and status.
                  setState(() {
                    widget.step = index;
                    widget.status = status;
                  });

                  _fetchData();
                }),

            /// [List of Products]
            const SizedBox(height: 24),
            StreamBuilder<List<PreviewViewModel>>(
                stream: _productStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const IconPlaceholder(
                        topMargin: 60,
                        iconPath: "assets/error_folder.png",
                        title: "Looks like an error...",
                        message: BaseError.FETCH_ERROR);
                  }

                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const IconPlaceholder(
                          topMargin: 60,
                          iconPath: "assets/error_folder.png",
                          title: "Looks like an error...",
                          message: BaseError.NO_CONNECTION_ERROR);

                    case ConnectionState.waiting:
                      return Skeletonizer(
                          child: Column(
                              children: List.generate(
                                  MockData.previewList.length, (index) {
                        return TransactionPreview(
                            preview: MockData.previewList[index],
                            status: ProductStatus.PROCESSING,
                            isLast: false,
                            children: const []);
                      })));

                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.data!.isEmpty) {
                        return const IconPlaceholder(
                            topMargin: 60,
                            iconPath: "assets/package_boxes.png",
                            title: "No products found.",
                            message:
                                "You currently don't have any products. Create one to get started!");
                      } else {
                        List<PreviewViewModel> data = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
                          child: Column(
                              children: data.map((preview) {
                            bool bidding =
                                preview.selling_type == SELLING_TYPE.keys.first;
                            int? qty = preview.order_quantity;

                            return InkWell(
                                onTap: () {
                                  // Go to the product profile.
                                  if (preview.status !=
                                          ProductStatus.PROCESSING &&
                                      preview.status !=
                                          ProductStatus.SCAN_FAILED &&
                                      preview.scan_url != "/") {
                                    String route = ProductProfileView.route
                                        .replaceAll(":id", preview.id!);
                                    route = route.replaceAll(
                                        ":seller", preview.created_by.fb_id);
                                    context.push(route);
                                  }
                                },
                                child: TransactionPreview(
                                  preview: preview,
                                  status: preview.status,
                                  isTransaction: false,
                                  isLast:
                                      data.indexOf(preview) == data.length - 1,
                                  buttons: qty != null && qty > 0
                                      ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 16),
                                          child: OutlinedButton(
                                              onPressed: () {
                                                // Place the product's ID and name.
                                                String route =
                                                    ProductTransactionView.route
                                                        .replaceAll(
                                                            ':id', preview.id!);
                                                route = route.replaceAll(
                                                    ':name', preview.name);

                                                // Go to the view.
                                                context.push(route);
                                              },
                                              style: OutlinedButtonStyle(
                                                  border: !bidding
                                                      ? SariTheme.secondary
                                                      : SariTheme.primary),
                                              child: Text(
                                                "VIEW ${!bidding ? 'PURCHASES' : 'BIDS'}",
                                                style: ButtonTextStyle(
                                                    color: !bidding
                                                        ? SariTheme.secondary
                                                        : SariTheme.primary),
                                              )))
                                      : preview.status ==
                                                  ProductStatus
                                                      .READY_TO_PUBLISH ||
                                              preview.status ==
                                                  ProductStatus.SCAN_FAILED
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 0, 16),
                                              child: _renderProcessingButtons(
                                                  preview.id!,
                                                  preview.scan_url,
                                                  preview.status))
                                          : const SizedBox.shrink(),
                                  children: [
                                    bidding
                                        ?

                                        /// [Highest Bidder]
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 16),
                                            child: Row(children: [
                                              // Label
                                              RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                    text: 'Bidder: ',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                              ])),

                                              // User Details
                                              Row(children: [
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(4, 0, 6, 0),
                                                    child: CircleAvatar(
                                                        radius: 14,
                                                        backgroundImage:
                                                            NetworkImage(preview
                                                                    .highest_bidder
                                                                    ?.photo_url ??
                                                                "/"))),
                                                Text(
                                                    preview.highest_bidder
                                                            ?.display_name ??
                                                        "No Bidder",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: SariTheme
                                                                .secondary)),
                                              ])
                                            ]))
                                        :

                                        /// [Order Quantity]
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 16),
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                  text: 'Order Quantity: ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              TextSpan(
                                                  text: qty.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: SariTheme
                                                              .primary)),
                                            ]))),
                                  ],
                                ));
                          }).toList()),
                        );
                      }
                  }
                }),
          ]),
        ),
      );
    });
  }
}
