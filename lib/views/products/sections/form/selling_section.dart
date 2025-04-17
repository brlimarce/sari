import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sari/providers/context/product_form_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/products/product_form.dart';
import 'package:sari/widgets/form/form_button_group.dart';
import 'package:sari/widgets/form/form_section_header.dart';

class SellingSection extends StatefulWidget {
  final void Function() onBack;
  final void Function() onNext;

  const SellingSection({super.key, required this.onBack, required this.onNext});

  @override
  SellingSectionState createState() => SellingSectionState();
}

class SellingSectionState extends State<SellingSection> {
  final _forBidding = GlobalKey<FormState>();
  final _minePriceKey = GlobalKey<FormFieldState>();
  final _grabPriceKey = GlobalKey<FormFieldState>();
  final _stealKey = GlobalKey<FormFieldState>();
  final _bidEndDateKey = GlobalKey<FormFieldState>();
  final _bidEndTimeKey = GlobalKey<FormFieldState>();

  final _recurrentSelling = GlobalKey<FormState>();
  final _defaultPriceKey = GlobalKey<FormFieldState>();
  final _quantityKey = GlobalKey<FormFieldState>();
  final _sellEndDateKey = GlobalKey<FormFieldState>();
  final _sellEndTimeKey = GlobalKey<FormFieldState>();

  // Field Controllers
  final TextEditingController _minePriceController = TextEditingController();
  final TextEditingController _grabPriceController = TextEditingController();
  final TextEditingController _stealController = TextEditingController();
  final TextEditingController _defaultPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sellEndDateController = TextEditingController();
  final TextEditingController _sellEndTimeController = TextEditingController();
  final TextEditingController _bidEndDateController = TextEditingController();
  final TextEditingController _bidEndTimeController = TextEditingController();

  @override
  void initState() {
    // Initialize the form values.
    final provider = context.read<ProductFormProvider>();

    // For Bidding
    _minePriceController.text =
        _displayBlankNumber(provider.mine_price.toString());

    _grabPriceController.text =
        _displayBlankNumber(provider.grab_price.toString());

    _stealController.text =
        _displayBlankNumber(provider.steal_increment.toString());

    _bidEndDateController.text = provider.end_date;
    _bidEndTimeController.text = provider.end_time;

    // Recurrent Selling
    _defaultPriceController.text =
        _displayBlankNumber(provider.default_price.toString());

    _quantityController.text =
        _displayBlankNumber(provider.stock_qty.toString());

    _sellEndDateController.text = provider.end_date;
    _sellEndTimeController.text = provider.end_time;
    super.initState();
  }

  @override
  void dispose() {
    _minePriceController.dispose();
    _grabPriceController.dispose();
    _stealController.dispose();
    _defaultPriceController.dispose();
    _quantityController.dispose();
    _sellEndDateController.dispose();
    _sellEndTimeController.dispose();
    _bidEndDateController.dispose();
    _bidEndTimeController.dispose();
    super.dispose();
  }

  /// Return a blank value to prevent the field from displaying 0.0
  /// as the initial value.
  ///
  /// [value] The value to check.
  String _displayBlankNumber(String value) {
    return value == "0.0" || value == "0" ? "" : value;
  }

  /// Return 0 if the value is empty.
  String _returnZero(String value) {
    return value.isEmpty ? "0" : value;
  }

  @override
  Widget build(BuildContext context) {
    final initialDate = DateTime.now();
    // final initialDate = DateTime.now().add(Duration(days: 1));
    final endDate = DateTime(initialDate.year + 1, 12, 31);

    return PopScope(
        onPopInvokedWithResult: (_, result) {
          context.read<ProductFormProvider>().reset();
        },
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 36),
            child: Column(children: [
              /// [A. For Bidding]
              (context.read<ProductFormProvider>().selling_type ==
                      SELLING_TYPE.keys.first)
                  ? Form(
                      key: _forBidding,
                      child: Column(children: [
                        FormSectionHeader(
                            title: "For Bidding",
                            emojiPath: "assets/svg_icons/emoji_coin.svg",
                            description:
                                "Set default prices for Mine and Grab and an increment value for users to Steal at a higher price."),

                        /// [Mine Price]
                        TextFormField(
                            key: _minePriceKey,
                            controller: _minePriceController,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            decoration: OutlinedFieldBorder("Mine Price",
                                hintText: "0.00"),
                            onChanged: (_) {
                              _minePriceKey.currentState!.validate();
                              _grabPriceKey.currentState!.validate();
                            },
                            validator: (value) {
                              if (value!.isEmpty || double.parse(value) <= 0) {
                                return ProductError.REQUIRED_ERROR;
                              } else if (_grabPriceController.text.isNotEmpty &&
                                  double.parse(value) >=
                                      double.parse(_grabPriceController.text)) {
                                return ProductError.MINE_GREATER_THAN_GRAB;
                              }

                              return null;
                            }),

                        /// [Grab Price]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                            child: TextFormField(
                                key: _grabPriceKey,
                                controller: _grabPriceController,
                                keyboardType: TextInputType.number,
                                decoration: OutlinedFieldBorder("Grab Price",
                                    hintText: "0.00"),
                                onChanged: (_) {
                                  _grabPriceKey.currentState!.validate();
                                  _minePriceKey.currentState!.validate();
                                },
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      double.parse(value) <= 0) {
                                    return ProductError.REQUIRED_ERROR;
                                  } else if (_minePriceController
                                          .text.isNotEmpty &&
                                      double.parse(value) <=
                                          double.parse(
                                              _minePriceController.text)) {
                                    return ProductError.GRAB_LESS_THAN_MINE;
                                  }

                                  return null;
                                })),

                        /// [Steal Increment]
                        Row(children: [
                          // Field
                          Expanded(
                              child: TextFormField(
                                  key: _stealKey,
                                  controller: _stealController,
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                  decoration: OutlinedFieldBorder(
                                      "Steal Increment",
                                      hintText: "0.00",
                                      behavior: FloatingLabelBehavior.always),
                                  onChanged: (_) {
                                    _stealKey.currentState!.validate();
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return ProductError.REQUIRED_ERROR;
                                    } else if (double.parse(value) % 10 != 0) {
                                      return ProductError.STEAL_INCREMENT_ERROR;
                                    }

                                    return null;
                                  })),

                          // Subtract Button
                          Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                  child: IconButton(
                                      onPressed: () {
                                        int value =
                                            int.parse(_stealController.text);
                                        if (value > 10) {
                                          _stealController.text =
                                              (value - 10).toString();
                                        }
                                      },
                                      icon: FaIcon(FontAwesomeIcons.minus,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)))),

                          // Add Button
                          Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: CircleAvatar(
                                  backgroundColor:
                                      Color(SariTheme.greenPalette.get(94)),
                                  child: IconButton(
                                      onPressed: () {
                                        int value =
                                            int.parse(_stealController.text);
                                        if (value < 100) {
                                          _stealController.text =
                                              (value + 10).toString();
                                        }
                                      },
                                      icon: FaIcon(FontAwesomeIcons.plus,
                                          size: 20, color: SariTheme.green)))),
                        ]),

                        /// [End the Selling]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: FormSectionHeader(
                                title: "End the selling",
                                emojiPath: "assets/svg_icons/emoji_clock.svg",
                                description:
                                    "Let your buyers know when your selling ends!")),

                        /// [Selling End Date]
                        DateTimePicker(
                            key: _bidEndDateKey,
                            controller: _bidEndDateController,
                            type: DateTimePickerType.date,
                            initialDate: initialDate,
                            firstDate: initialDate,
                            lastDate: endDate,
                            decoration: OutlinedFieldBorder("Selling End Date",
                                hintText: "Select a date.",
                                suffixIcon: Icon(FontAwesomeIcons.calendar,
                                    color:
                                        Color(SariTheme.neutralPalette.get(70)),
                                    size: 20)),
                            onChanged: (_) {
                              _bidEndDateKey.currentState!.validate();
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ProductError.REQUIRED_ERROR;
                              }

                              return null;
                            }),

                        /// [Selling End Time]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: DateTimePicker(
                                key: _bidEndTimeKey,
                                controller: _bidEndTimeController,
                                type: DateTimePickerType.time,
                                decoration: OutlinedFieldBorder(
                                    "Selling End Time",
                                    hintText: "Select a time.",
                                    suffixIcon: Icon(FontAwesomeIcons.clock,
                                        color: Color(
                                            SariTheme.neutralPalette.get(70)),
                                        size: 20)),
                                onChanged: (_) {
                                  _bidEndTimeKey.currentState!.validate();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ProductError.REQUIRED_ERROR;
                                  }

                                  return null;
                                })),
                      ]))
                  : Form(
                      key: _recurrentSelling,
                      child: Column(children: [
                        /// [B. Recurrent Selling]
                        FormSectionHeader(
                            title: "Recurrent Selling",
                            emojiPath: "assets/svg_icons/emoji_box.svg",
                            description:
                                "Set the price and stock quantity of the item."),

                        /// [Default Price]
                        TextFormField(
                            key: _defaultPriceKey,
                            controller: _defaultPriceController,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            decoration: OutlinedFieldBorder("Default Price",
                                hintText: "0.00"),
                            onChanged: (_) {
                              _defaultPriceKey.currentState!.validate();
                            },
                            validator: (value) {
                              if (value!.isEmpty || double.parse(value) <= 0) {
                                return ProductError.REQUIRED_ERROR;
                              }

                              return null;
                            }),

                        /// [Stock Quantity]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: TextFormField(
                                key: _quantityKey,
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                decoration: OutlinedFieldBorder(
                                    "Stock Quantity",
                                    hintText:
                                        "The stock should be more than 1."),
                                onChanged: (_) {
                                  _quantityKey.currentState!.validate();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ProductError.REQUIRED_ERROR;
                                  }

                                  if (int.parse(value) < 1) {
                                    return ProductError.STOCK_QUANTITY_ERROR;
                                  }

                                  return null;
                                })),

                        /// [C. End the Selling]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: FormSectionHeader(
                                title: "End the selling",
                                emojiPath: "assets/svg_icons/emoji_clock.svg",
                                description:
                                    "Let your buyers know when your selling ends!")),

                        /// [Selling End Date]
                        DateTimePicker(
                            key: _sellEndDateKey,
                            controller: _sellEndDateController,
                            type: DateTimePickerType.date,
                            initialDate: initialDate,
                            firstDate: initialDate,
                            lastDate: endDate,
                            decoration: OutlinedFieldBorder("Selling End Date",
                                hintText: "Select a date.",
                                suffixIcon: Icon(FontAwesomeIcons.calendar,
                                    color:
                                        Color(SariTheme.neutralPalette.get(70)),
                                    size: 20)),
                            onChanged: (_) {
                              context
                                  .read<ProductFormProvider>()
                                  .resetSchedule();
                              _sellEndDateKey.currentState!.validate();
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ProductError.REQUIRED_ERROR;
                              }

                              return null;
                            }),

                        /// [Selling End Time]
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                            child: DateTimePicker(
                                key: _sellEndTimeKey,
                                controller: _sellEndTimeController,
                                type: DateTimePickerType.time,
                                decoration: OutlinedFieldBorder(
                                    "Selling End Time",
                                    hintText: "Select a time.",
                                    suffixIcon: Icon(FontAwesomeIcons.clock,
                                        color: Color(
                                            SariTheme.neutralPalette.get(70)),
                                        size: 20)),
                                onChanged: (_) {
                                  _sellEndTimeKey.currentState!.validate();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ProductError.REQUIRED_ERROR;
                                  }

                                  return null;
                                })),
                      ])),

              /// [Button Group]
              FormButtonGroup(
                  step: 1,
                  totalSteps: ProductFormView.steps,
                  onBack: () {
                    final type =
                        context.read<ProductFormProvider>().selling_type;
                    if (type == SELLING_TYPE.keys.first) {
                      // For Bidding
                      context.read<ProductFormProvider>().setSellingDetails({
                        "mine_price": double.parse(
                            _returnZero(_minePriceController.text)),
                        "grab_price": double.parse(
                            _returnZero(_grabPriceController.text)),
                        "steal_increment":
                            int.parse(_returnZero(_stealController.text)),
                        "end_date": _bidEndDateController.text.toString(),
                        "end_time": _bidEndTimeController.text.toString()
                      });

                      widget.onBack();
                    } else {
                      // Recurrent Selling
                      context.read<ProductFormProvider>().setSellingDetails({
                        "default_price": double.parse(
                            _returnZero(_defaultPriceController.text)),
                        "stock_qty":
                            int.parse(_returnZero(_quantityController.text)),
                        "end_date": _sellEndDateController.text.toString(),
                        "end_time": _sellEndTimeController.text.toString()
                      });

                      widget.onBack();
                    }
                  },
                  onNext: () {
                    final type =
                        context.read<ProductFormProvider>().selling_type;
                    if (type == SELLING_TYPE.keys.first) {
                      // For Bidding
                      if (_forBidding.currentState!.validate()) {
                        context.read<ProductFormProvider>().setSellingDetails({
                          "mine_price": double.parse(_minePriceController.text),
                          "grab_price": double.parse(_grabPriceController.text),
                          "steal_increment": int.parse(_stealController.text),
                          "end_date": _bidEndDateController.text.toString(),
                          "end_time": _bidEndTimeController.text.toString()
                        });

                        widget.onNext();
                      }
                    } else {
                      // Recurrent Selling
                      if (_recurrentSelling.currentState!.validate()) {
                        context.read<ProductFormProvider>().setSellingDetails({
                          "default_price":
                              double.parse(_defaultPriceController.text),
                          "stock_qty": int.parse(_quantityController.text),
                          "end_date": _sellEndDateController.text.toString(),
                          "end_time": _sellEndTimeController.text.toString()
                        });

                        widget.onNext();
                      }
                    }
                  })
            ])));
  }
}
