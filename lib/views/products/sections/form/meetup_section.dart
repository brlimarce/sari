import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sari/models/payment_model.dart';
import 'package:sari/models/place_model.dart';
import 'package:sari/models/product_model.dart';
import 'package:sari/providers/context/product_form_provider.dart';
import 'package:sari/providers/product_provider.dart';
import 'package:sari/utils/constants.dart';
import 'package:sari/utils/errors.dart';
import 'package:sari/utils/sari_theme.dart';
import 'package:sari/utils/toast.dart';
import 'package:sari/utils/utils.dart';
import 'package:sari/views/products/product_form.dart';
import 'package:sari/views/products/product_scan_view.dart';
import 'package:sari/widgets/custom_alert_dialog.dart';
import 'package:sari/widgets/form/checkbox_loader.dart';
import 'package:sari/widgets/form/form_button_group.dart';
import 'package:sari/widgets/form/form_section_header.dart';
import 'package:sari/widgets/form/schedule_field.dart';

class MeetupSection extends StatefulWidget {
  final void Function() onBack;

  const MeetupSection({
    super.key,
    required this.onBack,
  });

  @override
  MeetupSectionState createState() => MeetupSectionState();
}

class MeetupSectionState extends State<MeetupSection> {
  final _key = GlobalKey<FormState>();

  // Field Values
  late List<dynamic> scheduleList;
  late List<dynamic> startTimeList;
  late List<dynamic> endTimeList;

  late List<Map<String, dynamic>> _paymentMap;
  late List<Map<String, dynamic>> _placeMap;

  late int _paymentCount;
  late int _placeCount;

  String _sellingEndDate = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchItems();
    });

    WidgetsBinding.instance.ensureVisualUpdate();
    super.initState();
    final provider = context.read<ProductFormProvider>();

    // Date
    _sellingEndDate = mergeDateTime(provider.end_date, provider.end_time);

    // Checkboxes
    _paymentMap = provider.payment_method;
    _placeMap = provider.meetup_place;

    _paymentCount = provider.payment_counter;
    _placeCount = provider.place_counter;

    // Schedule Fields
    scheduleList = provider.schedule_date.isNotEmpty
        ? provider.schedule_date
        : [_getInitialDate().toString()];

    startTimeList = provider.schedule_start_time.isNotEmpty
        ? provider.schedule_start_time
        : [""];

    endTimeList = provider.schedule_end_time.isNotEmpty
        ? provider.schedule_end_time
        : [""];
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Fetch the [PaymentMethod] and [Place] from the server.
  void _fetchItems() async {
    // Check if the data is already loaded.
    // If it is, skip the fetch.
    if (_paymentMap.isNotEmpty && _placeMap.isNotEmpty) return;

    // Load the data from the server.
    List<PaymentMethod> payments =
        await context.read<ProductProvider>().getAllPaymentMethods();
    if (!mounted) return;
    List<Place> places = await context.read<ProductProvider>().getAllPlaces();

    setState(() {
      _paymentMap = PaymentMethod.toMap(payments);
      _placeMap = Place.toMap(places);
    });
  }

  /// Get the initial date for the meetup schedule.
  ///
  /// It returns a [DateTime] object.
  String _getInitialDate() {
    final sellingEndDate = DateTime.parse(mergeDateTime(
      context.read<ProductFormProvider>().end_date,
      context.read<ProductFormProvider>().end_time,
    ));

    final date = sellingEndDate.add(const Duration(days: 1)).toString();
    return date.split(' ')[0].trimRight();
  }

  /// Validate the schedule overlap.
  ///
  /// It takes in a [String] date, [String] time, and [int] index.
  bool _validateScheduleOverlap(String date, String time, int index) {
    // Convert the time to DateTime.
    DateTime dateTime = DateTime.parse(mergeDateTime(date, time));

    // Check if the time overlaps with the current schedule.
    for (int i = 0; i < scheduleList.length; i++) {
      // Skip the item's index.
      if (i == index) continue;

      // Check if both schedules (and start time) overlap.
      if (startTimeList[i].isNotEmpty) {
        DateTime start =
            DateTime.parse(mergeDateTime(scheduleList[i], startTimeList[i]));
        if (dateTime.isAtSameMomentAs(start)) {
          return true;
        }
      }

      // Check if both schedules (and end time) overlap.
      if (endTimeList[i].isNotEmpty) {
        DateTime end =
            DateTime.parse(mergeDateTime(scheduleList[i], endTimeList[i]));
        if (dateTime.isAtSameMomentAs(end)) {
          return true;
        }
      }

      // Check if the schedule overlaps the time range.
      if (startTimeList[i].isNotEmpty && endTimeList[i].isNotEmpty) {
        DateTime start =
            DateTime.parse(mergeDateTime(scheduleList[i], startTimeList[i]));
        DateTime end =
            DateTime.parse(mergeDateTime(scheduleList[i], endTimeList[i]));
        if (dateTime.isAfter(start) && dateTime.isBefore(end)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Render the [Button], depending on the index.
  /// If the index is the last item, render a plus icon.
  /// Otherwise, render a minus icon.
  ///
  /// It takes in an [int] index to determine the button function.
  Widget _buildItemButton(int index) {
    bool isLast = index == scheduleList.length - 1;
    return IconButton(
        icon: Icon(isLast ? FontAwesomeIcons.plus : FontAwesomeIcons.minus,
            size: 18),
        onPressed: () {
          // Add or remove the schedule.
          if (isLast) {
            scheduleList.add(_getInitialDate().toString());
            startTimeList.add("");
            endTimeList.add("");
          } else {
            scheduleList.removeAt(index);
            startTimeList.removeAt(index);
            endTimeList.removeAt(index);
          }

          if (mounted) setState(() {});
        },
        color: isLast ? SariTheme.green : Theme.of(context).colorScheme.error,
        style: IconButton.styleFrom(
          backgroundColor: isLast
              ? Color(SariTheme.greenPalette.get(94))
              : Theme.of(context).colorScheme.errorContainer,
        ));
  }

  /// Create a [Product], which will be added
  /// to the server.
  void _submit() async {
    final provider = context.read<ProductFormProvider>();

    // Get selected payment methods.
    List<Map<String, String>> selectedPaymentMethods = [];
    for (int i = 0; i < provider.payment_method.length; i++) {
      if (provider.payment_method[i]["checked"]) {
        selectedPaymentMethods.add({
          "id": provider.payment_method[i]["id"],
          "account_name": provider.payment_method[i]["account_name"]
              .toString()
              .toUpperCase(),
          "account_number":
              provider.payment_method[i]["account_number"].toString(),
        });
      }
    }

    // Get selected meetup places.
    List<String> selectedPlaces = [];
    for (int i = 0; i < provider.meetup_place.length; i++) {
      if (provider.meetup_place[i]["checked"]) {
        selectedPlaces.add(provider.meetup_place[i]["id"]);
      }
    }

    // Get the schedule list.
    List<Map<String, String>> schedules = [];
    for (int i = 0; i < provider.schedule_date.length; i++) {
      schedules.add({
        "start_date": mergeDateTime(
            provider.schedule_date[i], provider.schedule_start_time[i]),
        "end_date": mergeDateTime(
            provider.schedule_date[i], provider.schedule_end_time[i]),
      });
    }

    // Upload the thumbnail to Firebase.
    String thumbnailURL = await context
        .read<ProductProvider>()
        .uploadMediaToFirebase(File(provider.thumbnail_url));

    // Create a new product.
    bool bidding = provider.selling_type == SELLING_TYPE.keys.first;
    late Product product;

    if (bidding) {
      // For Bidding
      product = Product(
        category: provider.category,
        name: provider.name,
        description: provider.description,
        selling_type: provider.selling_type,
        end_date: DateTime.parse(mergeDateTime(
          provider.end_date,
          provider.end_time,
        )),
        thumbnail_url: thumbnailURL,
        scan_url: "/",
        payment_method: selectedPaymentMethods,
        meetup_place: selectedPlaces,
        meetup_schedule: schedules,
        product_keyword: provider.product_keyword,
        mine_price: provider.mine_price,
        grab_price: provider.grab_price,
        steal_increment: provider.steal_increment,
      );
    } else {
      // Recurrent Selling
      product = Product(
        category: provider.category,
        name: provider.name,
        description: provider.description,
        selling_type: provider.selling_type,
        end_date: DateTime.parse(mergeDateTime(
          provider.end_date,
          provider.end_time,
        )),
        thumbnail_url: thumbnailURL,
        scan_url: "/",
        payment_method: selectedPaymentMethods,
        meetup_place: selectedPlaces,
        meetup_schedule: schedules,
        product_keyword: provider.product_keyword,
        default_price: provider.default_price,
        stock_qty: provider.stock_qty,
      );
    }

    // Add the product to the database.
    if (!mounted) return;
    Map<String, dynamic> response =
        await context.read<ProductProvider>().createProduct(product);

    // Hide the loader.
    if (!mounted) return;
    context.loaderOverlay.hide();
    if (response["status"] != StatusCode.CREATED) return;

    // Proceed with 3D reconstruction.
    context.read<ProductFormProvider>().reset();
    String route = ProductScanView.route.replaceAll(":id", response["id"]);
    context.replace(route.replaceAll(":priority", "false"));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (_, result) {
          context.read<ProductFormProvider>().reset();
        },
        child: Form(
          key: _key,
          child: Column(children: [
            /// [Payment Methods]
            FormSectionHeader(
                title: "Payment Methods",
                emojiPath: "assets/svg_icons/emoji_cash.svg",
                description:
                    "Provide options on how the buyers will buy your product.",
                bottomMargin: 20),

            // Items
            _paymentMap.isEmpty
                ? CheckboxLoader(isLoading: _paymentMap.isEmpty)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                    child: Column(
                        children: _paymentMap.map<Widget>((item) {
                      return Column(children: [
                        CheckboxListTile(
                            title: Text(item['name']),
                            value: item['checked'],
                            onChanged: (checked) {
                              setState(() {
                                item['checked'] = checked;
                              });

                              checked! ? _paymentCount++ : _paymentCount--;
                            }),
                        if (item['checked'])
                          Column(children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width * 0.1,
                                    0,
                                    0,
                                    0),
                                child: TextFormField(
                                    initialValue: item['account_name'],
                                    onChanged: (value) {
                                      setState(() {
                                        item['account_name'] = value;
                                      });
                                    },
                                    decoration:
                                        OutlinedFieldBorder("Account Name"),
                                    validator: (value) {
                                      if (value!.length > 70) {
                                        return ProductError
                                            .CHARACTER_LIMIT_ERROR(70);
                                      }
                                      if (value.isEmpty) {
                                        return ProductError.REQUIRED_ERROR;
                                      }

                                      return null;
                                    })),
                            Padding(
                                padding: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width * 0.1,
                                    12,
                                    0,
                                    8),
                                child: TextFormField(
                                    initialValue: item['account_number'],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        item['account_number'] = value;
                                      });
                                    },
                                    decoration:
                                        OutlinedFieldBorder("Account Number"),
                                    validator: (value) {
                                      if (value!.length > 25) {
                                        return ProductError
                                            .CHARACTER_LIMIT_ERROR(25);
                                      }

                                      if (value.isEmpty) {
                                        return ProductError.REQUIRED_ERROR;
                                      }

                                      return null;
                                    }))
                          ])
                      ]);
                    }).toList())),

            /// [Meetup Places]
            FormSectionHeader(
                title: "Meetup Places",
                emojiPath: "assets/svg_icons/emoji_map.svg",
                description:
                    "Let your buyers know how they can get your product.",
                bottomMargin: 20),

            // Items
            _placeMap.isEmpty
                ? CheckboxLoader(isLoading: _placeMap.isEmpty)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                    child: Column(
                        children: _placeMap.map<Widget>((item) {
                      return Column(children: [
                        CheckboxListTile(
                            title: Text(item['name']),
                            value: item['checked'],
                            onChanged: (checked) {
                              setState(() {
                                item['checked'] = checked;
                              });

                              checked! ? _placeCount++ : _placeCount--;
                            }),
                      ]);
                    }).toList())),

            /// [Meetup Schedule]
            FormSectionHeader(
                title: "Meetup Schedule",
                emojiPath: "assets/svg_icons/emoji_calendar.svg",
                description:
                    "Create multiple schedules to find a common time slot."),
            ListView.separated(
                shrinkWrap: true,
                itemCount: scheduleList.length,
                itemBuilder: (context, i) => ScheduleField(
                    key: UniqueKey(),
                    endDate: _sellingEndDate,
                    button: _buildItemButton(i),
                    initialDate: scheduleList[i].toString(),
                    initialStartTime: startTimeList[i].toString(),
                    initialEndTime: endTimeList[i].toString(),
                    onDateChanged: (value) {
                      scheduleList[i] = value;
                      _key.currentState!.validate();
                    },
                    onEndTimeChanged: (value) {
                      endTimeList[i] = value;
                      _key.currentState!.validate();
                    },
                    onStartTimeChanged: (value) {
                      startTimeList[i] = value;
                      _key.currentState!.validate();
                    },
                    onStartTimeValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return ProductError.REQUIRED_ERROR;
                      }
                      // The start time is later than the end time.
                      if (endTimeList[i].isNotEmpty &&
                          DateTime.parse(mergeDateTime(scheduleList[i], value))
                              .isAfter(DateTime.parse(mergeDateTime(
                                  scheduleList[i], endTimeList[i])))) {
                        return ProductError.START_LATER_ERROR;
                      }

                      if (_validateScheduleOverlap(scheduleList[i], value, i)) {
                        return ProductError.SCHEDULE_OVERLAP_ERROR;
                      }

                      return null;
                    },
                    onEndTimeValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return ProductError.REQUIRED_ERROR;
                      }

                      // The end time is earlier than the start time.
                      if (startTimeList[i].isNotEmpty &&
                          DateTime.parse(mergeDateTime(scheduleList[i], value))
                              .isBefore(DateTime.parse(mergeDateTime(
                                  scheduleList[i], startTimeList[i])))) {
                        return ProductError.END_EARLIER_ERROR;
                      }

                      if (_validateScheduleOverlap(scheduleList[i], value, i)) {
                        return ProductError.SCHEDULE_OVERLAP_ERROR;
                      }

                      return null;
                    }),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 4)),

            /// [Button Group]
            FormButtonGroup(
                step: 2,
                totalSteps: ProductFormView.steps,
                onBack: () {
                  context.read<ProductFormProvider>().setMeetupDetails({
                    "payment_method": _paymentMap,
                    "payment_counter": _paymentCount,
                    "meetup_place": _placeMap,
                    "place_counter": _placeCount,
                    "schedule_date": scheduleList,
                    "schedule_start_time": startTimeList,
                    "schedule_end_time": endTimeList,
                  });

                  widget.onBack();
                },
                onNext: () {
                  if (_paymentCount <= 0 && _placeCount <= 0) {
                    ToastAlert.error(
                        context,
                        ProductError.SELECT_ONE_ERROR(
                            "payment method and meetup place"));
                    return;
                  } else if (_paymentCount <= 0) {
                    ToastAlert.error(context,
                        ProductError.SELECT_ONE_ERROR("payment method"));
                    return;
                  } else if (_placeCount <= 0) {
                    ToastAlert.error(
                        context, ProductError.SELECT_ONE_ERROR("meetup place"));
                    return;
                  }

                  if (_key.currentState!.validate()) {
                    // Update the state of the final section.
                    context.read<ProductFormProvider>().setMeetupDetails({
                      "payment_method": _paymentMap,
                      "payment_counter": _paymentCount,
                      "meetup_place": _placeMap,
                      "place_counter": _placeCount,
                      "schedule_date": scheduleList,
                      "schedule_start_time": startTimeList,
                      "schedule_end_time": endTimeList,
                    });

                    // Display a confirmation dialog.
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlertDialog(
                              title: "Confirm Details",
                              icon: FontAwesomeIcons.solidCircleCheck,
                              iconColor: SariTheme.green,
                              body: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Color(SariTheme.neutralPalette
                                              .get(40))),
                                  children: const <TextSpan>[
                                    TextSpan(
                                        text: 'Kindly review the details',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            ' before adding the product. You will '),
                                    TextSpan(
                                        text: 'not be able to edit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: ' the product once you proceed.'),
                                  ],
                                ),
                              ),
                              activeButtonLabel: "Confirm",
                              onPressed: () {
                                // Close the dialog.
                                Navigator.of(context).pop();
                                context.loaderOverlay.show();

                                // Submit the product.
                                _submit();
                              });
                        });
                  }
                })
          ]),
        ));
  }
}
