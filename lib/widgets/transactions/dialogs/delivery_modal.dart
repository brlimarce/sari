import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';

class DeliveryModal extends StatefulWidget {
  final String transaction;
  final String product;
  final bool isBuyer;
  final Function onComplete;

  const DeliveryModal({
    super.key,
    required this.transaction,
    required this.product,
    required this.isBuyer,
    required this.onComplete,
  });

  @override
  DeliveryModalState createState() => DeliveryModalState();
}

class DeliveryModalState extends State<DeliveryModal> {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: "Confirm Delivery",
      icon: FontAwesomeIcons.truck,
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Color(SariTheme.neutralPalette.get(40))),
              children: <TextSpan>[
                const TextSpan(text: 'Please confirm that you have '),
                TextSpan(
                    text: widget.isBuyer ? 'received' : 'delivered',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        ' the item. Both you and the ${widget.isBuyer ? 'seller' : 'buyer'} should '),
                const TextSpan(
                    text: 'confirm the transaction.',
                    style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ));
      }),
      activeButtonLabel: "Confirm",
      onPressed: () async {
        // Process the transaction.
        context.loaderOverlay.show();

        int status = await context.read<TransactionProvider>().manageMeetup(
            widget.transaction,
            widget.product,
            context.read<DealerAuthProvider>().currentUser!.uid);

        // End the loading state.
        if (!context.mounted) return;
        context.loaderOverlay.hide();

        // Display the success message.
        if (status == StatusCode.NO_CONTENT) {
          Navigator.of(context).pop();
          ToastAlert.success(
              context, "You confirmed the delivery of this item.");
          widget.onComplete();
        }
      },
    );
  }
}
