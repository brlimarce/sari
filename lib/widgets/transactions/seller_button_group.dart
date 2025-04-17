import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/place_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:sari/widgets/transactions/dialogs/delivery_modal.dart';

class SellerButtonGroup extends StatefulWidget {
  final String transaction;
  final String status;
  final String product;
  final Function onComplete;
  final String? payment;
  final Place? place;

  const SellerButtonGroup(
      {super.key,
      required this.transaction,
      required this.status,
      required this.product,
      required this.onComplete,
      this.payment,
      this.place});

  @override
  SellerButtonGroupState createState() => SellerButtonGroupState();
}

class SellerButtonGroupState extends State<SellerButtonGroup> {
  @override
  void initState() {
    super.initState();
  }

  /// Display a modal to confirm the payment.
  void _displayPaymentConfirmationModal() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
              title: "Confirm Payment",
              icon: FontAwesomeIcons.solidCircleCheck,
              iconColor: SariTheme.green,
              body: const Text(
                "Once you confirm, the buyer will be able to schedule a meetup with you.",
                textAlign: TextAlign.center,
              ),
              activeButtonLabel: "Confirm",
              onPressed: () async {
                // Process the transaction.
                context.loaderOverlay.show();
                int status = await context
                    .read<TransactionProvider>()
                    .manageMeetup(widget.transaction, widget.product,
                        context.read<DealerAuthProvider>().currentUser!.uid);

                // End the transaction.
                if (!context.mounted) return;
                context.loaderOverlay.hide();

                // Display the success alert.
                if (status == StatusCode.NO_CONTENT) {
                  Navigator.of(context).pop();
                  ToastAlert.success(context,
                      "You have confirmed the payment for this buyer.");
                  widget.onComplete();
                }
              });
        });
  }

  /// Render the layout of the button group.
  ///
  /// [children] contains buttons that will be rendered.
  Widget _renderButtonLayout(List<Widget> children) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        child: Row(children: children));
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.status) {
      /// [Pending Payment]
      case TransactionStatus.PENDING_PAYMENT:
      case TransactionStatus.READY_FOR_CONFIRMATION:
        bool isPendingPayment =
            widget.status == TransactionStatus.PENDING_PAYMENT;

        return _renderButtonLayout([
          /// [Payment Button]
          Expanded(
              child: OutlinedButton(
                  onPressed: () {
                    if (!isPendingPayment) {
                      _displayPaymentConfirmationModal();
                    }
                  },
                  style: OutlinedButtonStyle(
                      border: isPendingPayment
                          ? Color(SariTheme.neutralPalette.get(70))
                          : SariTheme.primary),
                  child: Text(
                      isPendingPayment ? "WAITING FOR PAYMENT" : "CONFIRM",
                      style: ButtonTextStyle(
                          color: isPendingPayment
                              ? Color(SariTheme.neutralPalette.get(70))
                              : SariTheme.primary)))),

          /// [Divider]
          if (!isPendingPayment) const SizedBox(width: 8),

          /// [View Receipt Button]
          if (!isPendingPayment)
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: () {
                      // Display the proof of payment.
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(widget.payment ?? ""),
                                        fit: BoxFit.cover)),
                              ),
                            );
                          });
                    },
                    style: FillButtonStyle(background: SariTheme.secondary),
                    icon: Icon(FontAwesomeIcons.solidEye,
                        size: 16, color: SariTheme.white),
                    label: Text("VIEW",
                        style: ButtonTextStyle(color: SariTheme.white))))
        ]);

      /// [Pending Schedule]
      case TransactionStatus.PENDING_SCHEDULE:
        return _renderButtonLayout([
          Expanded(
              child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButtonStyle(
                      border: Color(SariTheme.neutralPalette.get(70))),
                  child: Text("WAITING FOR MEETUP",
                      style: ButtonTextStyle(
                          color: Color(SariTheme.neutralPalette.get(70))))))
        ]);

      /// [Ready for Meetup]
      case TransactionStatus.READY_FOR_MEETUP:
      case TransactionStatus.RECEIVED:
        return _renderButtonLayout([
          /// [Delivered Button]
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeliveryModal(
                              transaction: widget.transaction,
                              product: widget.product,
                              isBuyer: false,
                              onComplete: widget.onComplete);
                        });
                  },
                  style: FillButtonStyle(background: SariTheme.primary),
                  child: Text("DELIVERED", style: ButtonTextStyle()))),
          const SizedBox(width: 8),

          /// [View Map Button]
          Expanded(
            child: OutlinedButton.icon(
                onPressed: () {
                  context.read<DealerAuthProvider>().redirectUrl(getMapLink(
                      widget.place?.latitude ?? 0,
                      widget.place?.longitude ?? 0));
                },
                style: OutlinedButtonStyle(border: SariTheme.secondary),
                icon: Icon(FontAwesomeIcons.map,
                    size: 16, color: SariTheme.secondary),
                label: Text("VIEW MAP",
                    style: ButtonTextStyle(color: SariTheme.secondary))),
          )
        ]);

      /// [Delivered]
      case TransactionStatus.DELIVERED:
        return _renderButtonLayout([
          Expanded(
              child: ElevatedButton(
                  onPressed: () {},
                  style: OutlinedButtonStyle(
                      border: Color(SariTheme.neutralPalette.get(70))),
                  child: Text("WAITING FOR CONFIRMATION",
                      style: ButtonTextStyle(
                          color: Color(SariTheme.neutralPalette.get(70))))))
        ]);

      /// [Scan-Related Status]
      case ProductStatus.SCAN_FAILED:
      case ProductStatus.READY_TO_PUBLISH:
        return _renderButtonLayout([
          Expanded(
              child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButtonStyle(border: SariTheme.primary),
                  child: Text("RESCAN",
                      style: ButtonTextStyle(color: SariTheme.primary))))
        ]);

      default:
        return Container();
    }
  }
}
