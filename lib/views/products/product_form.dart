// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/views/products/sections/form/meetup_section.dart';
import 'package:sari/views/products/sections/form/product_section.dart';
import 'package:sari/views/products/sections/form/selling_section.dart';
import 'package:sari/widgets/form/form_indicator.dart';

class ProductFormView extends StatefulWidget {
  static const route = '/product/form/create';
  static const int steps = 3;

  ProductFormView({super.key});
  int step = 0;

  @override
  ProductFormState createState() {
    return ProductFormState();
  }
}

class ProductFormState extends State<ProductFormView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Proceed to the next step.
  void goNext() {
    setState(() {
      if (widget.step < ProductFormView.steps - 1) {
        widget.step++;
      }
    });
  }

  // Proceed to the previous step.
  void goBack() {
    setState(() {
      if (widget.step > 0) {
        widget.step--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, provider, child) {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }

      if (provider.error.active) {
        ToastAlert.error(context, provider.error.error);
        provider.error.clear();
      }

      return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(SariTheme.primaryPalette.get(96)),
            title: Image.asset("assets/logo/logo.png", width: 32, height: 32),
            iconTheme:
                IconThemeData(color: Color(SariTheme.neutralPalette.get(50))),
            centerTitle: true,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(12),
                child: FormIndicator(
                    step: widget.step, totalSteps: ProductFormView.steps))),
        backgroundColor: Color(SariTheme.primaryPalette.get(98)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            child: Column(children: [
              (widget.step == 0)
                  ? ProductSection(onNext: () {
                      goNext();
                    })
                  : (widget.step == 1)
                      ? SellingSection(onBack: () {
                          goBack();
                        }, onNext: () {
                          goNext();
                        })
                      : MeetupSection(
                          onBack: () {
                            goBack();
                          },
                        ),
            ])),
      );
    });
  }
}
