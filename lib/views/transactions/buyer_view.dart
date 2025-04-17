import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/transaction_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/mock_data.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/layout_view.dart';
import 'package:sari/views/products/product_profile.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';
import 'package:sari/widgets/transactions/buyer_button_group.dart';
import 'package:sari/widgets/transactions/transaction_header.dart';
import 'package:sari/widgets/transactions/transaction_preview.dart';
import 'package:sari/widgets/transactions/transaction_tabs.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BuyerView extends StatefulWidget {
  static const String route = '/transactions';
  int step = 0;

  final List<String> ONGOING_STATUSES = [
    TransactionStatus.ONGOING,
    TransactionStatus.BID_MINE,
    TransactionStatus.BID_GRAB,
    TransactionStatus.BID_STEAL
  ];

  List<String> status = [];

  BuyerView({super.key});

  @override
  BuyerViewState createState() => BuyerViewState();
}

class BuyerViewState extends State<BuyerView> {
  final StreamController<List<Transaction>> _transactionStreamController =
      StreamController<List<Transaction>>();

  @override
  void initState() {
    widget.status = widget.ONGOING_STATUSES;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _transactionStreamController.close();
    super.dispose();
  }

  /// Fetch [Transaction] from the server.
  Future<Stream<List<Transaction>>?> _fetchData() async {
    String? dealer = context.read<DealerAuthProvider>().user?.uid;
    if (!context.mounted) return null;

    Stream<List<Transaction>> t =
        context.read<TransactionProvider>().getAllTransactions(filters: {
      "dealer": dealer,
      "status": widget.status,
    });

    _transactionStreamController.addStream(t);
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(builder: (context, provider, child) {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      if (provider.error.active) {
        ToastAlert.error(context, provider.error.error);
        provider.error.clear();
      }

      return LayoutView(
        page: 1,
        implied: false,
        child: SingleChildScrollView(
          child: Column(children: [
            /// [Header]
            TransactionHeader(
              palette: SariTheme.secondaryPalette,
              iconPath: "assets/transaction_purchases.png",
              name: "Purchases",
              children: const <TextSpan>[
                TextSpan(text: 'Track your '),
                TextSpan(
                    text: 'ongoing, confirmed',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' and '),
                TextSpan(
                    text: 'completed',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' bids and purchases.'),
              ],
            ),

            /// [Tabs]
            TransactionTabs(
                step: widget.step,
                names: const ["Ongoing", "Confirmed", "Completed", "Cancelled"],
                palette: SariTheme.secondaryPalette,
                onTabPressed: (int index) {
                  // Determine the status based on the index.
                  List<String> status = [];
                  switch (index) {
                    case 0:
                      status = widget.ONGOING_STATUSES;
                      break;
                    case 1:
                      status = [
                        TransactionStatus.PENDING_PAYMENT,
                        TransactionStatus.PENDING_SCHEDULE,
                        TransactionStatus.READY_FOR_CONFIRMATION,
                        TransactionStatus.READY_FOR_MEETUP,
                        TransactionStatus.RECEIVED,
                        TransactionStatus.DELIVERED,
                      ];
                      break;
                    case 2:
                      status = [
                        TransactionStatus.COMPLETED,
                        TransactionStatus.RATED
                      ];
                      break;
                    case 3:
                      status = [TransactionStatus.CANCELLED];
                      break;
                  }

                  // Set the current step and status.
                  setState(() {
                    widget.step = index;
                    widget.status = status;
                  });

                  _fetchData();
                }),

            /// [List of Transactions]
            const SizedBox(height: 24),
            StreamBuilder<List<Transaction>>(
                stream: _transactionStreamController.stream,
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
                          status: TransactionStatus.ONGOING,
                          isLast: false,
                          children: const [],
                        );
                      })));

                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.data!.isEmpty) {
                        return const IconPlaceholder(
                            topMargin: 60,
                            iconPath: "assets/transactions_barter.png",
                            title: "No transactions found.",
                            message:
                                "You currently don't have any purchases. Place a bid or purchase an item to get started!");
                      } else {
                        List<Transaction> data = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
                          child: Column(
                              children: data.map((transaction) {
                            return InkWell(
                                onTap: () {
                                  // Go to the product profile.
                                  String route = ProductProfileView.route
                                      .replaceAll(
                                          ":id",
                                          transaction.product.id ??
                                              MockData.product.id!);
                                  route = route.replaceAll(":seller",
                                      transaction.product.created_by.fb_id);
                                  context.push(route);
                                },
                                child: TransactionPreview(
                                  preview: transaction.product,
                                  status: transaction.status,
                                  isLast: data.indexOf(transaction) ==
                                      data.length - 1,
                                  buttons: BuyerButtonGroup(
                                      transaction: transaction,
                                      status: transaction.status,
                                      product: transaction.product.id ??
                                          MockData.product.id!,
                                      onComplete: () async {
                                        setState(() {
                                          _fetchData();
                                        });
                                      },
                                      payment: transaction.payment_reference),
                                  children: [
                                    /// [Seller]
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 16),
                                        child: Row(children: [
                                          // Label
                                          RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                                text: 'Seller: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ])),

                                          // User Details
                                          Row(children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        4, 0, 6, 0),
                                                child: CircleAvatar(
                                                    radius: 14,
                                                    backgroundImage:
                                                        NetworkImage(transaction
                                                            .product
                                                            .created_by
                                                            .photo_url))),
                                            Text(
                                                transaction.product.created_by
                                                    .display_name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: SariTheme
                                                            .secondary)),
                                          ])
                                        ])),

                                    /// [Bid Amount]
                                    if (transaction.product.selling_type ==
                                        SELLING_TYPE.keys.first)
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 16),
                                          child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(children: [
                                                // Label
                                                TextSpan(
                                                    text: 'Your Bid: ',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                TextSpan(
                                                    text: formatToCurrency(
                                                        transaction
                                                                .bid_amount ??
                                                            0),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: SariTheme
                                                                .primary)),
                                              ]))),

                                    /// [Meetup Schedule]
                                    if (transaction.schedule!.isNotEmpty &&
                                        transaction.status ==
                                            TransactionStatus.READY_FOR_MEETUP)
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 4, 0, 4),
                                          child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(children: [
                                                // Label
                                                TextSpan(
                                                    text: 'Schedule: ',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                TextSpan(
                                                    text:
                                                        transaction.schedule ??
                                                            "Unknown",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: SariTheme
                                                                .green)),
                                              ]))),

                                    /// [Meetup Place]
                                    if (transaction.place != null &&
                                        transaction.status ==
                                            TransactionStatus.READY_FOR_MEETUP)
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 16),
                                          child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(children: [
                                                // Label
                                                TextSpan(
                                                    text: 'Meetup Place: ',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                TextSpan(
                                                    text: transaction
                                                            .place?.name ??
                                                        "Unknown",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: SariTheme
                                                                .green)),
                                              ]))),
                                  ],
                                ));
                          }).toList()),
                        );
                      }
                  }
                })
          ]),
        ),
      );
    });
  }
}
