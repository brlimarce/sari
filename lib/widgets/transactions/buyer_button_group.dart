import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/place_model.dart';
import 'package:sari/models/transaction_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/transactions/dialogs/delivery_modal.dart';
import 'package:sari/widgets/transactions/dialogs/payment_modal.dart';
import 'package:sari/widgets/transactions/dialogs/review_modal.dart';
import 'package:sari/widgets/transactions/dialogs/schedule_modal.dart';

class BuyerButtonGroup extends StatefulWidget {
  final Transaction transaction;
  final String status;
  final String product;
  final Function onComplete;
  final String? payment;
  final Place? place;

  const BuyerButtonGroup({
    super.key,
    required this.transaction,
    required this.status,
    required this.product,
    required this.onComplete,
    this.place,
    this.payment,
  });

  @override
  BuyerButtonGroupState createState() => BuyerButtonGroupState();
}

class BuyerButtonGroupState extends State<BuyerButtonGroup> {
  @override
  void initState() {
    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
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
          /// [Upload Payment Receipt]
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    if (isPendingPayment) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PaymentModal(
                                transaction: widget.transaction,
                                product: widget.product,
                                onComplete: widget.onComplete);
                          });
                    }
                  },
                  style: OutlinedButtonStyle(
                      border: isPendingPayment
                          ? SariTheme.green
                          : Color(SariTheme.neutralPalette.get(70))),
                  child: Text(isPendingPayment ? "CONFIRM PAYMENT" : "PENDING",
                      style: ButtonTextStyle(
                          color: isPendingPayment
                              ? SariTheme.green
                              : Color(SariTheme.neutralPalette.get(70)))))),

          /// [Reupload Button]
          if (!isPendingPayment) const SizedBox(width: 8),
          if (!isPendingPayment)
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PaymentModal(
                                transaction: widget.transaction,
                                product: widget.product,
                                onComplete: widget.onComplete,
                                payment: widget.payment);
                          });
                    },
                    style: FillButtonStyle(background: SariTheme.secondary),
                    child: Text("REUPLOAD", style: ButtonTextStyle())))
        ]);

      /// [Pending Schedule]
      case TransactionStatus.PENDING_SCHEDULE:
        bool isPendingSchedule =
            widget.status == TransactionStatus.PENDING_SCHEDULE;

        return _renderButtonLayout([
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    if (isPendingSchedule) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ScheduleModal(
                                transaction: widget.transaction.id!,
                                product: widget.product,
                                onComplete: widget.onComplete);
                          });
                    }
                  },
                  style: OutlinedButtonStyle(border: SariTheme.secondary),
                  child: Text("CONFIRM MEETUP",
                      style: ButtonTextStyle(color: SariTheme.secondary))))
        ]);

      /// [Ready for Meetup]
      case TransactionStatus.READY_FOR_MEETUP:
      case TransactionStatus.DELIVERED:
        return _renderButtonLayout([
          /// [Received Button]
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeliveryModal(
                              transaction: widget.transaction.id!,
                              product: widget.product,
                              isBuyer: true,
                              onComplete: widget.onComplete);
                        });
                  },
                  style: FillButtonStyle(background: SariTheme.primary),
                  child: Text("RECEIVED", style: ButtonTextStyle()))),
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

      /// [Received]
      case TransactionStatus.RECEIVED:
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

      /// [Completed]
      case TransactionStatus.COMPLETED:
        return _renderButtonLayout([
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ReviewModal(
                            transaction: widget.transaction.id!,
                            product: widget.product,
                            onComplete: widget.onComplete,
                          );
                        });
                  },
                  style: FillButtonStyle(background: SariTheme.secondary),
                  child: Text("RATE PRODUCT", style: ButtonTextStyle())))
        ]);

      default:
        return Container();
    }
  }
}
