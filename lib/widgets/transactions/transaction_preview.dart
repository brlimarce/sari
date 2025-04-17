import 'package:flutter/material.dart';
import 'package:sari/models/views/preview_view_model.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/status.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/widgets/plain_chip.dart';
import 'package:sari/widgets/server_timer.dart';

class TransactionPreview extends StatelessWidget {
  PreviewViewModel preview;
  List<Widget> children;
  bool isLast;
  String status;
  bool? isTransaction;
  Widget? buttons;

  TransactionPreview({
    super.key,
    required this.preview,
    required this.children,
    required this.isLast,
    required this.status,
    this.isTransaction,
    this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    String name = truncate(preview.name, 20);
    bool isProduct = !(isTransaction ?? true);

    return Padding(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            /// [Product Thumbnail]
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Image.network(preview.thumbnail_url,
                    width: 48, height: 48)),

            /// [Product Details]
            Expanded(
                child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// [Product Name]
                    Text(name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),

                    /// [Product Price]
                    Text(formatToCurrency(preview.default_price),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w900,
                              color: SariTheme.primary,
                            ))
                  ]),

              /// [Deadline and Type]
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// [Deadline]
                    ServerTimer(milliseconds: preview.timestamp),

                    /// [Product Status]
                    PlainChip(
                        foregroundColor: isProduct
                            ? ProductStatus.getForegroundColor(context, status)
                            : TransactionStatus.getForegroundColor(
                                context, status),
                        backgroundColor: isProduct
                            ? ProductStatus.getBackgroundColor(context, status)
                            : TransactionStatus.getBackgroundColor(
                                context, status),
                        label: (isProduct
                                ? ProductStatus.NAMES[status]
                                : TransactionStatus.NAMES[status])
                            ?.toUpperCase()),
                  ]),
            ]))
          ]),

          /// [Transaction Details]
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 64),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children)
                  ])),

          /// [Button Group]
          buttons ?? Container(),

          /// [Divider]
          isLast ? Container() : const Divider(),
        ]));
  }
}
