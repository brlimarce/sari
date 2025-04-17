import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/transaction_model.dart';
import 'package:sari/models/views/preview_view_model.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/mock_data.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/views/layout_view.dart';
import 'package:sari/widgets/placeholder/icon_placeholder.dart';
import 'package:sari/widgets/transactions/seller_button_group.dart';
import 'package:sari/widgets/transactions/transaction_header.dart';
import 'package:sari/widgets/transactions/transaction_preview.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductTransactionView extends StatefulWidget {
  static const String route = '/products/:name/transactions/:id';
  final String id;
  final String name;

  const ProductTransactionView({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  ProductTransactionViewState createState() => ProductTransactionViewState();
}

class ProductTransactionViewState extends State<ProductTransactionView> {
  final StreamController<List<Transaction>> _transactionStreamController =
      StreamController<List<Transaction>>();

  @override
  void initState() {
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

  /// Fetch the data from the server.
  /// The method will fetch the transactions that are related to the product.
  void _fetchData() async {
    Stream<List<Transaction>> t = context
        .read<TransactionProvider>()
        .getAllTransactions(filters: {"product": widget.id});
    _transactionStreamController.addStream(t);
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
          page: 2,
          implied: false,
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                /// [Product Header]
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// [Back Button]
                          IconButton(
                            onPressed: () {
                              context.pop();
                            },
                            icon: Icon(
                              FontAwesomeIcons.arrowLeft,
                              size: 16,
                              color: Color(SariTheme.neutralPalette.get(70)),
                            ),
                          ),

                          /// [Label]
                          Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                              child: Text(widget.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          color: SariTheme.secondary,
                                          fontWeight: FontWeight.w900)))
                        ])),

                /// [Product Transactions]
                StreamBuilder<List<Transaction>>(
                    stream: _transactionStreamController.stream,
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
                              child: Column(
                                  children: List.generate(
                                      MockData.previewList.length, (index) {
                            return TransactionPreview(
                                preview: MockData.previewList[index],
                                status: TransactionStatus.ONGOING,
                                isLast: false,
                                children: const []);
                          })));

                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.data!.isEmpty) {
                            return const IconPlaceholder(
                                iconPath: "assets/transactions_barter.png",
                                title: "No transactions found.",
                                message:
                                    "There are no transactions yet for this product.");
                          } else {
                            List<Transaction> data = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
                              child: Column(
                                  children: data.map((transaction) {
                                PreviewViewModel preview = transaction.product;

                                return TransactionPreview(
                                  preview: preview,
                                  status: transaction.status,
                                  isLast: data.indexOf(transaction) ==
                                      data.length - 1,
                                  buttons: SellerButtonGroup(
                                      transaction: transaction.id!,
                                      status: transaction.status,
                                      product: preview.id!,
                                      payment: transaction.payment_reference,
                                      onComplete: () {
                                        setState(() {
                                          _fetchData();
                                        });
                                      }),
                                  children: [
                                    /// [Transaction Buyer]
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 16),
                                        child: Row(children: [
                                          // Label
                                          RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                                text: 'Buyer: ',
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
                                                            .purchased_by
                                                            .photo_url))),
                                            Text(
                                                transaction
                                                    .purchased_by.display_name,
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

                                    /// [Meetup Schedule]
                                    if (transaction.schedule != null &&
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
                                );
                              }).toList()),
                            );
                          }
                      }
                    }),
              ])));
    });
  }
}
