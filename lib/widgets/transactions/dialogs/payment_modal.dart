import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/payment_model.dart';
import 'package:sari/models/transaction_model.dart';
import 'package:sari/providers/auth_provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/providers/transaction_provider.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PaymentModal extends StatefulWidget {
  final Transaction transaction;
  final String product;
  final Function onComplete;
  final String? payment;

  const PaymentModal({
    super.key,
    required this.transaction,
    required this.product,
    required this.onComplete,
    this.payment,
  });

  @override
  PaymentModalState createState() => PaymentModalState();
}

class PaymentModalState extends State<PaymentModal> {
  List<PaymentMethod> _paymentMethods = [];
  String _paymentReference = "";

  String _selectedPaymentMethod = "";
  String _selectedAccountName = "";
  String _selectedAccountNumber = "";

  @override
  void initState() {
    _paymentReference = widget.payment ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
  }

  /// Fetch the initial data from the server.
  void _fetchData() async {
    // Skip if data is already loaded.
    if (_paymentMethods.isNotEmpty) return;

    // Fetch payment methods.
    List<PaymentMethod> methods = await context
        .read<ProductProvider>()
        .getAllPaymentMethods(filters: {"product": widget.product});

    // Set the data.
    setState(() {
      _paymentMethods = methods;
      _selectedPaymentMethod = methods.first.id;
      _selectedAccountName = methods.first.account_name ?? "";
      _selectedAccountNumber = methods.first.account_number ?? "";
    });
  }

  /// Check if the URL is a Firebase URL.
  bool _isFirebaseUrl(String url) {
    return url.contains("firebase");
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: "Confirm Payment",
      titleColor: SariTheme.secondary,
      icon: FontAwesomeIcons.moneyBill,
      iconColor: SariTheme.green,
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// [Description]
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Color(SariTheme.neutralPalette.get(40))),
                      children: const <TextSpan>[
                        TextSpan(text: 'Select your '),
                        TextSpan(
                            text: 'preferred payment method',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' and upload your '),
                        TextSpan(
                            text: 'proof of payment.',
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  )),

              /// [Payment Method]
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _paymentMethods.isNotEmpty
                      ? DropdownButtonFormField(
                          value: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value.toString();
                            });
                          },
                          decoration: OutlinedFieldBorder("Payment Method"),
                          items: _paymentMethods.map((p) {
                            return DropdownMenuItem(
                                value: p.id, child: Text(p.name));
                          }).toList(),
                        )
                      : Skeletonizer(
                          child: DropdownButtonFormField(
                          value: "",
                          onChanged: (value) {},
                          decoration: OutlinedFieldBorder("Payment Method"),
                          items: const [],
                        ))),

              /// [Account Number]
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACCOUNT NUMBER',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: SariTheme.secondary,
                                    fontWeight: FontWeight.w800)),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: _paymentMethods.isNotEmpty
                                ? Text(_selectedAccountNumber)
                                : const Skeletonizer(
                                    child: Text("Account Number"))),
                      ])),

              /// [Account Name]
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACCOUNT NAME',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: SariTheme.secondary,
                                    fontWeight: FontWeight.w800)),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: _paymentMethods.isNotEmpty
                                ? Text(_selectedAccountName)
                                : const Skeletonizer(
                                    child: Text("Account Name"))),
                      ])),

              /// [Proof of Payment]
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          // Store the image as a URL.
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  type: FileType.image, allowMultiple: false);

                          File image = File(result!.files.single.path!);
                          setState(() {
                            _paymentReference = image.path;
                          });

                          if (!context.mounted) return;
                          ToastAlert.success(context,
                              "You have successfully uploaded your proof of payment.");
                        } catch (e) {
                          if (!context.mounted) return;
                          ToastAlert.error(
                              context, BaseError.UPLOAD_FAILED_ERROR);
                        }
                      },
                      icon: FaIcon(FontAwesomeIcons.receipt,
                          size: 16, color: SariTheme.white),
                      style: FillButtonStyle(),
                      label: Text(
                        "${_paymentReference.isEmpty ? "UPLOAD" : "REUPLOAD"} RECEIPT",
                        style: ButtonTextStyle(),
                      ))),

              /// [View Payment]
              if (_paymentReference.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                            onPressed: () {
                              // Display the proof of payment.
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                                image: _isFirebaseUrl(
                                                        _paymentReference)
                                                    ? NetworkImage(
                                                        _paymentReference)
                                                    : FileImage(File(
                                                        _paymentReference)),
                                                fit: BoxFit.cover)),
                                      ),
                                    );
                                  });
                            },
                            icon: FaIcon(FontAwesomeIcons.solidEye,
                                size: 16, color: SariTheme.secondary),
                            style: OutlinedButtonStyle(
                                border: SariTheme.secondary),
                            label: Text(
                              "VIEW RECEIPT",
                              style:
                                  ButtonTextStyle(color: SariTheme.secondary),
                            )))),
            ]);
      }),
      activeButtonLabel: "Submit",
      activeButtonColor: SariTheme.green,
      onPressed: () async {
        // Display an error alert if no receipt was uploaded.
        if (_paymentReference.isEmpty) {
          ToastAlert.error(context, "Please upload your proof of payment.");
          return;
        }

        // Process the transaction.
        context.loaderOverlay.show();

        // Delete the pre-existing image (if there is any).
        if (widget.transaction.payment_reference != null) {
          await context
              .read<ProductProvider>()
              .deleteMediaFromFirebase(widget.transaction.payment_reference!);
        }

        // Upload the image to Firebase.
        if (!context.mounted) return;
        String firebaseImageUrl = await context
            .read<ProductProvider>()
            .uploadMediaToFirebase(File(_paymentReference));

        if (!context.mounted) return;
        int status = await context.read<TransactionProvider>().manageMeetup(
            widget.transaction.id!,
            widget.product,
            context.read<DealerAuthProvider>().currentUser!.uid,
            data: {
              "payment_method": _selectedPaymentMethod,
              "payment_reference": firebaseImageUrl
            });

        // End the loading state.
        if (!context.mounted) return;
        context.loaderOverlay.hide();

        // Display the success message.
        if (status == StatusCode.NO_CONTENT) {
          Navigator.of(context).pop();
          ToastAlert.success(
              context, "Please wait for the seller to confirm your payment.");
          widget.onComplete();
        }
      },
    );
  }
}
