import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/review_model.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';

class ReviewModal extends StatefulWidget {
  final String transaction;
  final String product;
  final Function onComplete;

  const ReviewModal({
    super.key,
    required this.transaction,
    required this.product,
    required this.onComplete,
  });

  @override
  ReviewModalState createState() => ReviewModalState();
}

class ReviewModalState extends State<ReviewModal> {
  int productRating = 1;
  int sellerRating = 1;
  final String review = "";

  final _reviewKey = GlobalKey<FormFieldState>();
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: "Got a few minutes?",
      icon: Icons.waving_hand_rounded,
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          /// [Description]
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Color(SariTheme.neutralPalette.get(40))),
                  children: const <TextSpan>[
                    TextSpan(
                        text: 'We\'d love to hear from you!',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' How would you rate your experience?')
                  ],
                ),
              )),

          /// [Product Rating]
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Color(SariTheme.neutralPalette.get(28))),
                  children: const <TextSpan>[
                    TextSpan(
                        text: 'Product Rating',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),

          /// [Rating Bar]
          RatingBar.builder(
            initialRating: 1,
            minRating: 1,
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemSize: 24.0,
            itemBuilder: (context, _) =>
                Icon(FontAwesomeIcons.solidStar, color: SariTheme.yellow),
            onRatingUpdate: (rating) {
              setState(() {
                productRating = rating.toInt();
              });
            },
          ),

          /// [Seller Rating]
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 36, 0, 10),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Color(SariTheme.neutralPalette.get(28))),
                  children: const <TextSpan>[
                    TextSpan(
                        text: 'Seller Rating',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),

          /// [Rating Bar]
          RatingBar.builder(
            initialRating: 1,
            minRating: 1,
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemSize: 24.0,
            itemBuilder: (context, _) =>
                Icon(FontAwesomeIcons.solidStar, color: SariTheme.tertiary),
            onRatingUpdate: (rating) {
              setState(() {
                sellerRating = rating.toInt();
              });
            },
          ),

          /// [Review]
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 44, 0, 10),
              child: TextFormField(
                  key: _reviewKey,
                  minLines: 4,
                  maxLines: 8,
                  textAlignVertical: TextAlignVertical.top,
                  controller: _reviewController,
                  decoration: OutlinedFieldBorder("Describe your experience.",
                      behavior: FloatingLabelBehavior.never,
                      alignLabelWithHint: true),
                  onChanged: (_) {
                    _reviewKey.currentState!.validate();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ProductError.REQUIRED_ERROR;
                    }

                    return null;
                  })),
        ]));
      }),
      activeButtonLabel: "Submit",
      onPressed: () async {
        if (_reviewKey.currentState!.validate()) {
          // Process the transaction.
          context.loaderOverlay.show();

          // Create a response.
          Review review = Review(
            product_rating: productRating,
            seller_rating: sellerRating,
            review: _reviewController.text,
          );

          int status = await context
              .read<TransactionProvider>()
              .createReview(widget.transaction, review);
          if (!context.mounted) return;

          // End the transaction.
          if (status == StatusCode.CREATED) {
            Navigator.of(context).pop();
            context.loaderOverlay.hide();
            ToastAlert.success(context,
                "Thank you for providing your feedback on this product!");
            widget.onComplete();
          }
        }
      },
    );
  }
}
